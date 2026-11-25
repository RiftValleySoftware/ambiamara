/*
 © Copyright 2026, The Great Rift Valley Software Company. All rights reserved.
 This code is proprietary and is not licensed for reuse.
 */

import CoreBluetooth
import Combine
import Foundation
#if os(iOS)
import UIKit
#endif

/// A foreground iPad can vend the same request/reply protocol as the paired phone.
/// GATT indications carry replies and change hints; each request is applied only by the host.
final class RiValT_BluetoothRemote: NSObject, ObservableObject {
    static let shared = RiValT_BluetoothRemote()

    private static let serviceID = CBUUID(string: "0250A104-0738-42F6-BF10-847791B599CA")
    private static let channelID = CBUUID(string: "5585507D-1321-41A2-944C-78BFC934D4FD")
    private enum Code: UInt8 {
        case begin = 1, continuation, end, whole, changed, authorization, ready, denied
    }
    private static let maximumPacket = 16_384
    private static func encode(_ message: [String: Any]) -> Data? {
        guard let data = try? PropertyListSerialization.data(fromPropertyList: message, format: .binary, options: 0),
              data.count <= maximumPacket else { return nil }
        return data
    }

    // Five header bytes identify the fragment and request. ATT payload sizes vary by link.
    private static func frames(_ data: Data, id: UInt32, mtu: Int) -> [Data] {
        let capacity = mtu - 5
        guard capacity > 0, !data.isEmpty else { return [] }
        return stride(from: 0, to: data.count, by: capacity).map { offset in
            let end = min(data.count, offset + capacity)
            let code: Code = offset == 0 ? (end == data.count ? .whole : .begin) : (end == data.count ? .end : .continuation)
            var value = Data([code.rawValue, UInt8(truncatingIfNeeded: id >> 24), UInt8(truncatingIfNeeded: id >> 16),
                              UInt8(truncatingIfNeeded: id >> 8), UInt8(truncatingIfNeeded: id)])
            value.append(contentsOf: data[offset..<end])
            return value
        }
    }

    private struct Assembly {
        var id: UInt32?
        var bytes = Data()

        mutating func accept(_ frame: Data) -> (UInt32, [String: Any])? {
            guard frame.count >= 6, let code = Code(rawValue: frame[0]) else { return nil }
            let token = frame[1..<5].reduce(UInt32.zero) { ($0 << 8) | UInt32($1) }
            switch code {
            case .whole, .begin:
                bytes.removeAll(keepingCapacity: true)
                id = token
            case .continuation, .end:
                guard id == token else { return nil }
            default: return nil
            }
            guard bytes.count + frame.count - 5 <= maximumPacket else {
                self = Assembly()
                return nil
            }
            bytes.append(contentsOf: frame.dropFirst(5))
            guard code == .whole || code == .end else { return nil }
            defer { self = Assembly() }
            guard let message = try? PropertyListSerialization.propertyList(from: bytes, options: [], format: nil) as? [String: Any] else { return nil }
            return (token, message)
        }
    }

    private var incoming = Assembly()

#if os(watchOS)
    struct Device: Identifiable {
        let id: UUID
        let name: String
    }

    @Published private(set) var usesIPad = UserDefaults.standard.bool(forKey: "remote.useIPad")
    @Published private(set) var isConnected = false
    @Published private(set) var devices = [Device]()
    @Published private(set) var status = ""
    @Published private(set) var selectedDeviceID = UserDefaults.standard.string(forKey: "remote.iPadID").flatMap(UUID.init(uuidString:))
    @Published private(set) var selectedDeviceName = UserDefaults.standard.string(forKey: "remote.iPadName")
    var onChange: (() -> Void)?
    var onConnectionChange: (() -> Void)?

    private var manager: CBCentralManager?
    private var discovered = [UUID: CBPeripheral]()
    private var peer: CBPeripheral?
    private var channel: CBCharacteristic?
    @Published private(set) var isBrowsing = false
    private var denied = false
    private var outgoing = [Data]()
    private var requestID = UInt32.zero
    private var onReply: (([String: Any]) -> Void)?
    private var onFailure: (() -> Void)?
    private var timeout: DispatchWorkItem?
    private var retry: DispatchWorkItem?

    func activate() {
        guard usesIPad || isBrowsing else { return }
        if manager == nil {
            manager = CBCentralManager(delegate: self, queue: .main)
        } else if let manager, manager.state != .poweredOn {
            centralManagerDidUpdateState(manager)
        } else {
            discover()
        }
    }

    func browse() {
        if !isBrowsing {
            devices.removeAll { $0.id != peer?.identifier }
            discovered = discovered.filter { $0.key == peer?.identifier }
        }
        isBrowsing = true
        denied = false
        activate()
    }

    func retryConnection() {
        guard usesIPad, !isConnected else { return }
        if denied {
            clearPeer()
            denied = false
        }
        activate()
    }

    func endBrowsing() {
        isBrowsing = false
        if !usesIPad || peer != nil || selectedDeviceID == nil { manager?.stopScan() }
        if !usesIPad { status = "" }
    }

    func selectPhone() {
        isBrowsing = false
        usesIPad = false
        UserDefaults.standard.set(false, forKey: "remote.useIPad")
        manager?.stopScan()
        clearPeer()
        status = ""
    }

    func selectDevice(_ device: Device) {
        if usesIPad, peer?.identifier == device.id, isConnected { return }
        usesIPad = true
        UserDefaults.standard.set(true, forKey: "remote.useIPad")
        clearPeer()
        denied = false
        selectedDeviceID = device.id
        selectedDeviceName = device.name
        UserDefaults.standard.set(device.id.uuidString, forKey: "remote.iPadID")
        UserDefaults.standard.set(device.name, forKey: "remote.iPadName")
        discover()
    }

    private func discover() {
        guard usesIPad || isBrowsing, !denied, let manager, manager.state == .poweredOn else { return }
        if usesIPad, peer == nil, let selectedDeviceID,
           let saved = discovered[selectedDeviceID] ?? manager.retrievePeripherals(withIdentifiers: [selectedDeviceID]).first {
            peer = saved
            saved.delegate = self
            manager.connect(saved)
            status = String(localized: "Connecting to iPad…")
        }
        if isBrowsing || (usesIPad && peer == nil && selectedDeviceID != nil) {
            if peer == nil && devices.isEmpty { status = String(localized: "Looking for nearby iPads…") }
            manager.scanForPeripherals(withServices: [Self.serviceID])
        } else {
            manager.stopScan()
        }
    }

    private func clearPeer() {
        let previous = peer
        peer = nil
        channel = nil
        isConnected = false
        retry?.cancel()
        retry = nil
        if let previous, manager?.state == .poweredOn { manager?.cancelPeripheralConnection(previous) }
        failRequest()
        onConnectionChange?()
    }

    private func reconnect(after peripheral: CBPeripheral) {
        guard peer === peripheral else { return }
        peer = nil
        channel = nil
        isConnected = false
        failRequest()
        onConnectionChange?()
        guard usesIPad, !denied else { return }
        status = String(localized: "Looking for iPad…")
        retry?.cancel()
        let item = DispatchWorkItem { [weak self] in self?.discover() }
        retry = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: item)
    }

    func request(_ message: [String: Any], reply: @escaping ([String: Any]) -> Void, failure: @escaping () -> Void) {
        guard usesIPad, isConnected, onReply == nil, let peer, let channel, let data = Self.encode(message) else {
            failure()
            return
        }
        requestID = UInt32.random(in: 1...UInt32.max)
        // Short writes, each acknowledged by the iPad, avoid opaque long-write offsets.
        outgoing = Self.frames(data, id: requestID, mtu: min(peer.maximumWriteValueLength(for: .withResponse),
                                                             peer.maximumWriteValueLength(for: .withoutResponse)))
        guard !outgoing.isEmpty else { failure(); return }
        onReply = reply
        onFailure = failure
        let item = DispatchWorkItem { [weak self] in self?.failRequest() }
        timeout = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: item)
        peer.writeValue(outgoing.removeFirst(), for: channel, type: .withResponse)
    }

    private func finishRequest() {
        timeout?.cancel()
        timeout = nil
        onReply = nil
        onFailure = nil
        incoming = Assembly()
        outgoing.removeAll()
    }

    private func failRequest() {
        let callback = onFailure
        finishRequest()
        callback?()
    }
#elseif os(iOS)
    var onRequest: (([String: Any], @escaping ([String: Any]) -> Void) -> Void)?
    var isEnabled: Bool { UserDefaults.standard.bool(forKey: "remote.iPadEnabled") }
    var hasRemoteSubscriber: Bool { approved }
    private(set) lazy var hostName: String = {
        let key = "remote.iPadLabel"
        if let label = UserDefaults.standard.string(forKey: key) { return label }
        let label = "RiVal.T-" + UUID().uuidString.prefix(4)
        UserDefaults.standard.set(label, forKey: key)
        return label
    }()
    private var manager: CBPeripheralManager?
    private var channel: CBMutableCharacteristic?
    private var subscriber: CBCentral?
    private weak var permissionAlert: UIAlertController?
    @Published private(set) var hostingIssue: String?
    private var hostRetry: DispatchWorkItem?
    private var retryDelay: TimeInterval = 1
    private var serviceAdded = false
    private var observing = false
    private var output = [Data]()

    func setEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "remote.iPadEnabled")
        if enabled {
            hostingIssue = nil
            activate()
        } else {
            UserDefaults.standard.removeObject(forKey: "remote.approvedWatch")
            stop()
        }
    }

    func activate() {
        guard UIDevice.current.userInterfaceIdiom == .pad, !ProcessInfo.processInfo.isMacCatalystApp, isEnabled else { return }
        if !observing {
            observing = true
            let center = NotificationCenter.default
            center.addObserver(self, selector: #selector(start), name: UIApplication.didBecomeActiveNotification, object: nil)
            center.addObserver(self, selector: #selector(stop), name: UIApplication.didEnterBackgroundNotification, object: nil)
        }
        start()
    }

    @objc private func start() {
        guard isEnabled, UIApplication.shared.applicationState == .active else { return }
        guard let manager else {
            self.manager = CBPeripheralManager(delegate: self, queue: .main)
            return
        }
        guard manager.state == .poweredOn else {
            if manager.state != .unknown, manager.state != .resetting {
                let key = manager.state == .unauthorized ? "SLUG-WATCH-REMOTE-PERMISSION" : "SLUG-WATCH-REMOTE-RADIO"
                hostingIssue = NSLocalizedString(key, comment: "")
            }
            return
        }
        if channel != nil {
            if serviceAdded, !manager.isAdvertising { advertise() }
            return
        }
        let characteristic = CBMutableCharacteristic(type: Self.channelID,
                                                    properties: [.write, .indicateEncryptionRequired],
                                                    value: nil, permissions: [.writeEncryptionRequired])
        channel = characteristic
        let service = CBMutableService(type: Self.serviceID, primary: true)
        service.characteristics = [characteristic]
        manager.add(service)
    }

    private func advertise() {
        manager?.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [Self.serviceID], CBAdvertisementDataLocalNameKey: hostName])
    }

    private func scheduleHostRetry() {
        guard isEnabled, UIApplication.shared.applicationState == .active, manager?.state == .poweredOn else { return }
        hostingIssue = NSLocalizedString("SLUG-WATCH-REMOTE-RETRYING", comment: "")
        hostRetry?.cancel()
        let attempt = DispatchWorkItem { [weak self] in self?.start() }
        hostRetry = attempt
        DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay, execute: attempt)
        retryDelay = min(8, retryDelay * 2)
    }

    @objc private func stop() {
        hostRetry?.cancel()
        hostRetry = nil
        retryDelay = 1
        hostingIssue = nil
        if manager?.state == .poweredOn {
            manager?.stopAdvertising()
            manager?.removeAllServices()
        }
        channel = nil
        serviceAdded = false
        releaseSubscriber()
    }

    private func releaseSubscriber() {
        subscriber = nil
        output.removeAll()
        incoming = Assembly()
        permissionAlert?.dismiss(animated: false)
        permissionAlert = nil
    }

    private var approved: Bool {
        guard let subscriber else { return false }
        return subscriber.identifier.uuidString == UserDefaults.standard.string(forKey: "remote.approvedWatch")
    }

    private func authorize(_ central: CBCentral) {
        if approved {
            queue(Data([Code.ready.rawValue]))
            return
        }
        guard UserDefaults.standard.string(forKey: "remote.approvedWatch") == nil,
              let windowScene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first(where: { $0.activationState == .foregroundActive }),
              var presenter = windowScene.keyWindow?.rootViewController else {
            queue(Data([Code.denied.rawValue]))
            return
        }
        while let presented = presenter.presentedViewController { presenter = presented }
        let code = String(Int.random(in: 1000...9999))
        var message = Data([Code.authorization.rawValue])
        message.append(contentsOf: code.utf8)
        queue(message)
        let alert = UIAlertController(title: NSLocalizedString("SLUG-WATCH-PAIR-TITLE", comment: ""),
                                      message: String(format: NSLocalizedString("SLUG-WATCH-PAIR-CODE", comment: ""), code),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("SLUG-WATCH-PAIR-DENY", comment: ""), style: .cancel) { [weak self] _ in
            guard let self, self.subscriber?.identifier == central.identifier else { return }
            self.queue(Data([Code.denied.rawValue]))
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("SLUG-WATCH-PAIR-ALLOW", comment: ""), style: .default) { [weak self] _ in
            guard let self, self.subscriber?.identifier == central.identifier, self.isEnabled else { return }
            UserDefaults.standard.set(central.identifier.uuidString, forKey: "remote.approvedWatch")
            self.queue(Data([Code.ready.rawValue]))
        })
        permissionAlert = alert
        presenter.present(alert, animated: true)
    }

    func notifyChange() {
        let hint = Data([Code.changed.rawValue])
        guard approved, !output.contains(hint) else { return }
        queue(hint)
    }

    private func queue(_ frame: Data) {
        output.append(frame)
        flush()
    }

    private func flush() {
        guard let manager, let channel, let subscriber else { return }
        while let frame = output.first {
            guard manager.updateValue(frame, for: channel, onSubscribedCentrals: [subscriber]) else { return }
            output.removeFirst()
        }
    }
#endif
}

#if os(watchOS)
extension RiValT_BluetoothRemote: CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn { discover(); return }
        devices = []
        discovered = [:]
        if usesIPad { clearPeer() }
        guard usesIPad || isBrowsing else { return }
        status = central.state == .unauthorized ? String(localized: "Allow Bluetooth access in Settings.") : String(localized: "Bluetooth unavailable.")
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        guard usesIPad || isBrowsing else { return }
        let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? peripheral.name ?? "iPad"
        discovered[peripheral.identifier] = peripheral
        if !devices.contains(where: { $0.id == peripheral.identifier }) {
            devices.append(Device(id: peripheral.identifier, name: name))
            if !usesIPad || selectedDeviceID == nil { status = "" }
        }
        if usesIPad, peripheral.identifier == selectedDeviceID, peer == nil { discover() }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard peripheral === peer else { return }
        peripheral.discoverServices([Self.serviceID])
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) { reconnect(after: peripheral) }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) { reconnect(after: peripheral) }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard peripheral === peer else { return }
        guard error == nil, let service = peripheral.services?.first(where: { $0.uuid == Self.serviceID }) else {
            manager?.cancelPeripheralConnection(peripheral)
            return
        }
        peripheral.discoverCharacteristics([Self.channelID], for: service)
    }
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        if peripheral === peer, invalidatedServices.contains(where: { $0.uuid == Self.serviceID }) {
            manager?.cancelPeripheralConnection(peripheral)
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard peripheral === peer else { return }
        guard error == nil, let characteristic = service.characteristics?.first(where: { $0.uuid == Self.channelID }) else {
            manager?.cancelPeripheralConnection(peripheral)
            return
        }
        channel = characteristic
        peripheral.setNotifyValue(true, for: characteristic)
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard peripheral === peer, characteristic === channel else { return }
        if let error = error as NSError? {
            // Retry link losses automatically, but wait for a user action after a pairing failure.
            let attErrors: [CBATTError.Code] = [.insufficientAuthentication, .insufficientAuthorization, .insufficientEncryption, .insufficientEncryptionKeySize]
            let pairingErrors: [CBError.Code] = [.peerRemovedPairingInformation, .encryptionTimedOut, .tooManyLEPairedDevices]
            if (error.domain == CBATTErrorDomain && attErrors.contains { $0.rawValue == error.code })
                || (error.domain == CBErrorDomain && pairingErrors.contains { $0.rawValue == error.code }) {
                denied = true
                status = String(localized: "Bluetooth pairing failed. Tap Reconnect to try again.")
            }
        }
        if error != nil || !characteristic.isNotifying {
            manager?.cancelPeripheralConnection(peripheral)
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard peripheral === peer, characteristic === channel, onReply != nil else { return }
        if error != nil { failRequest(); return }
        if !outgoing.isEmpty { peripheral.writeValue(outgoing.removeFirst(), for: characteristic, type: .withResponse) }
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard peripheral === peer, characteristic === channel, error == nil, let frame = characteristic.value,
              let byte = frame.first, let code = Code(rawValue: byte) else { return }
        switch code {
        case .ready:
            status = ""
            isConnected = true
            onConnectionChange?()
        case .changed:
            if isConnected { onChange?() }
        case .authorization:
            guard frame.count == 5, let code = String(bytes: frame.dropFirst(), encoding: .ascii),
                  code.allSatisfy(\.isNumber) else { return }
            status = String(format: String(localized: "Confirm %@ on iPad."), code)
        case .denied:
            denied = true
            status = String(localized: "Access declined on iPad.")
            manager?.cancelPeripheralConnection(peripheral)
        default:
            guard let (id, message) = incoming.accept(frame), id == requestID, let callback = onReply else { return }
            finishRequest()
            callback(message)
        }
    }
}
#elseif os(iOS)
extension RiValT_BluetoothRemote: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            hostingIssue = nil
            start()
        } else {
            stop()
            if isEnabled {
                let key = peripheral.state == .unauthorized ? "SLUG-WATCH-REMOTE-PERMISSION" : "SLUG-WATCH-REMOTE-RADIO"
                hostingIssue = NSLocalizedString(key, comment: "")
            }
        }
    }
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        guard channel != nil, isEnabled, service.characteristics?.first === channel else { return }
        guard error == nil else {
            channel = nil
            scheduleHostRetry()
            return
        }
        serviceAdded = true
        advertise()
    }
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        guard isEnabled, serviceAdded else { return }
        if error != nil {
            scheduleHostRetry()
        } else {
            hostRetry?.cancel()
            retryDelay = 1
            hostingIssue = nil
        }
    }
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        guard characteristic === channel, isEnabled else { return }
        // Only the user-approved watch can occupy an existing host binding.
        if let saved = UserDefaults.standard.string(forKey: "remote.approvedWatch"), saved != central.identifier.uuidString {
            if let channel { _ = peripheral.updateValue(Data([Code.denied.rawValue]), for: channel, onSubscribedCentrals: [central]) }
            return
        }
        guard subscriber == nil || subscriber?.identifier == central.identifier else {
            if let channel { _ = peripheral.updateValue(Data([Code.denied.rawValue]), for: channel, onSubscribedCentrals: [central]) }
            return
        }
        subscriber = central
        authorize(central)
    }
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        if characteristic === channel, subscriber?.identifier == central.identifier { releaseSubscriber() }
    }
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) { flush() }
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        guard let first = requests.first else { return }
        guard UIApplication.shared.applicationState == .active, isEnabled, approved,
              let handler = onRequest, let subscriber, let channel,
              requests.allSatisfy({ $0.central.identifier == subscriber.identifier && $0.characteristic === channel && $0.offset == 0 && $0.value != nil })
        else {
            peripheral.respond(to: first, withResult: .insufficientAuthorization)
            return
        }
        peripheral.respond(to: first, withResult: .success)
        for request in requests {
            guard let data = request.value, let (id, message) = incoming.accept(data) else { continue }
            handler(message) { [weak self] response in
                guard let self, self.subscriber?.identifier == subscriber.identifier, self.channel === channel, self.approved,
                      let bytes = Self.encode(response) else { return }
                self.output += Self.frames(bytes, id: id, mtu: subscriber.maximumUpdateValueLength)
                self.flush()
            }
        }
    }
}
#endif
