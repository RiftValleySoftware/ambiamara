/*
 © Copyright 2026, The Great Rift Valley Software Company. All rights reserved.
 This code is proprietary and is not licensed for reuse.
 */

import CoreBluetooth
import Combine
import Foundation
import WatchKit

/// A foreground iPad can vend the same request/reply protocol as the paired phone.
/// GATT indications carry replies and change hints; each request is applied only by the host.
final class RiValT_BluetoothRemote: NSObject, ObservableObject {
    /// The transport shared by the timer delegate and the app's remote settings.
    static let shared = RiValT_BluetoothRemote()

    /// Shared device identifiers and packet framing for the Bluetooth link.
    private typealias Packet = RiValT_BluetoothRemotePacket

    /// The current assembly for fragments received from the remote device.
    private var incoming = Packet.Assembly()

    /// The identity and advertised name of an iPad discovered by the Watch.
    struct Device: Identifiable {
        /// Core Bluetooth's identifier for this peripheral.
        let id: UUID
        /// The label shown for this iPad in the device picker.
        let name: String
    }

    /// Whether the Watch uses Bluetooth to control an iPad.
    @Published private(set) var usesIPad = UserDefaults.standard.bool(forKey: "remote.useIPad")
    /// Whether the selected iPad has approved the encrypted request channel.
    @Published private(set) var isConnected = false
    /// The iPads found during the current device scan.
    @Published private(set) var devices = [Device]()
    /// The localized scan, connection, or pairing status shown on the Watch.
    @Published private(set) var status = ""
    /// The persisted identifier of the selected iPad.
    @Published private(set) var selectedDeviceID = UserDefaults.standard.string(forKey: "remote.iPadID").flatMap(UUID.init(uuidString:))
    /// The last advertised label saved for the selected iPad.
    @Published private(set) var selectedDeviceName = UserDefaults.standard.string(forKey: "remote.iPadName")
    /// Notifies the timer delegate that the host asked for a fresh snapshot.
    var onChange: (() -> Void)?
    /// Notifies the timer delegate that link or device selection state changed.
    var onConnectionChange: (() -> Void)?

    /// The Core Bluetooth central manager used to discover and connect to iPads.
    private var manager: CBCentralManager?
    /// Recently discovered peripherals keyed by their Bluetooth identifiers.
    private var discovered = [UUID: CBPeripheral]()
    /// The peripheral connecting to or serving the Watch.
    private var peer: CBPeripheral?
    /// The characteristic used to send requests and receive indications.
    private var channel: CBCharacteristic?
    /// Whether the device picker is actively requesting a scan.
    @Published private(set) var isBrowsing = false
    /// Whether pairing failed and automatic reconnection must wait for user action.
    private var denied = false
    /// The request fragments awaiting acknowledged writes.
    private var outgoing = [Data]()
    /// The packet identifier used to match a reply to the current request.
    private var requestID = UInt32.zero
    /// The last Watch name acknowledged by the iPad on this connection.
    private var reportedWatchName: String?
    /// The completion callback for the current request's reply.
    private var onReply: (([String: Any]) -> Void)?
    /// The completion callback for a timed-out or failed request.
    private var onFailure: (() -> Void)?
    /// The pending deadline for the current request.
    private var timeout: DispatchWorkItem?
    /// The scheduled reconnect after a dropped peripheral connection.
    private var retry: DispatchWorkItem?

    /// Initializes the central manager or resumes discovery when browsing or using an iPad.
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

    /// Starts a device scan and clears stale results while retaining the currently connected iPad.
    func browse() {
        if !isBrowsing {
            devices.removeAll { $0.id != peer?.identifier }
            discovered = discovered.filter { $0.key == peer?.identifier }
        }
        isBrowsing = true
        denied = false
        activate()
    }

    /// Retries an explicit connection attempt and clears a prior authorization denial.
    func retryConnection() {
        guard usesIPad, !isConnected else { return }
        if denied {
            clearPeer()
            denied = false
        }
        activate()
    }

    /// Stops device browsing and keeps scanning only when needed to reconnect to the selected iPad.
    func endBrowsing() {
        isBrowsing = false
        if !usesIPad || peer != nil || selectedDeviceID == nil { manager?.stopScan() }
        if !usesIPad { status = "" }
    }

    /// Switches to the paired iPhone and closes the Bluetooth link.
    func selectPhone() {
        isBrowsing = false
        usesIPad = false
        UserDefaults.standard.set(false, forKey: "remote.useIPad")
        manager?.stopScan()
        clearPeer()
        status = ""
    }

    /// Persists the chosen iPad, resets the old link, and begins connecting.
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

    /// Connects to the saved peripheral when available and scans when browsing or searching for it.
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
            manager.scanForPeripherals(withServices: [Packet.serviceID])
        } else {
            manager.stopScan()
        }
    }

    /// Clears the current peripheral, cancels its connection, and fails any request in flight.
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

    /// Releases a disconnected peer and schedules discovery again if automatic retry is allowed.
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

    /// Sends a single framed request and calls the matching reply or failure handler.
    func request(_ message: [String: Any], reply: @escaping ([String: Any]) -> Void, failure: @escaping () -> Void) {
        guard usesIPad, isConnected, onReply == nil, let peer, let channel else {
            failure()
            return
        }
        var packet = message
        let watchName = WKInterfaceDevice.current().name
        if watchName != reportedWatchName { packet[Packet.watchNameKey] = watchName }
        guard let data = Packet.encode(packet) else {
            failure()
            return
        }
        requestID = UInt32.random(in: 1...UInt32.max)
        // Short writes, each acknowledged by the iPad, avoid opaque long-write offsets.
        outgoing = Packet.frames(data, id: requestID, mtu: min(peer.maximumWriteValueLength(for: .withResponse),
                                                             peer.maximumWriteValueLength(for: .withoutResponse)))
        guard !outgoing.isEmpty else { failure(); return }
        onReply = { [weak self] response in
            self?.reportedWatchName = watchName
            reply(response)
        }
        onFailure = failure
        let item = DispatchWorkItem { [weak self] in self?.failRequest() }
        timeout = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: item)
        peer.writeValue(outgoing.removeFirst(), for: channel, type: .withResponse)
    }

    /// Cancels the deadline and clears the assembly, fragments, and handlers for the finished request.
    private func finishRequest() {
        timeout?.cancel()
        timeout = nil
        onReply = nil
        onFailure = nil
        incoming = Packet.Assembly()
        outgoing.removeAll()
    }

    /// Clears the request before notifying its failure handler.
    private func failRequest() {
        let callback = onFailure
        finishRequest()
        callback?()
    }
}

extension RiValT_BluetoothRemote: CBCentralManagerDelegate, CBPeripheralDelegate {
    /// Resumes discovery when Bluetooth powers on or clears the link and displays the unavailable state.
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn { discover(); return }
        devices = []
        discovered = [:]
        if usesIPad { clearPeer() }
        guard usesIPad || isBrowsing else { return }
        status = central.state == .unauthorized ? String(localized: "Allow Bluetooth access in Settings.") : String(localized: "Bluetooth unavailable.")
    }

    /// Adds a discovered iPad to the picker and connects when it matches the saved selection.
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

    /// Discovers the RiVal.T service on the selected iPad after connecting.
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard peripheral === peer else { return }
        peripheral.discoverServices([Packet.serviceID])
    }
    /// Schedules reconnection if the selected peripheral fails to connect.
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) { reconnect(after: peripheral) }
    /// Schedules reconnection after losing the selected peripheral.
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) { reconnect(after: peripheral) }

    /// Finds the host service and requests discovery of its control characteristic.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard peripheral === peer else { return }
        guard error == nil, let service = peripheral.services?.first(where: { $0.uuid == Packet.serviceID }) else {
            manager?.cancelPeripheralConnection(peripheral)
            return
        }
        peripheral.discoverCharacteristics([Packet.channelID], for: service)
    }
    /// Reconnects when the selected iPad invalidates the timer service.
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        if peripheral === peer, invalidatedServices.contains(where: { $0.uuid == Packet.serviceID }) {
            manager?.cancelPeripheralConnection(peripheral)
        }
    }
    /// Subscribes to indications on the selected iPad's control characteristic.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard peripheral === peer else { return }
        guard error == nil, let characteristic = service.characteristics?.first(where: { $0.uuid == Packet.channelID }) else {
            manager?.cancelPeripheralConnection(peripheral)
            return
        }
        channel = characteristic
        peripheral.setNotifyValue(true, for: characteristic)
    }
    /// Handles a failed subscription and requires a manual retry after authentication or pairing errors.
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
    /// Sends the next request fragment after a write is acknowledged or fails the exchange.
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard peripheral === peer, characteristic === channel, onReply != nil else { return }
        if error != nil { failRequest(); return }
        if !outgoing.isEmpty { peripheral.writeValue(outgoing.removeFirst(), for: characteristic, type: .withResponse) }
    }
    /// Handles authorization and change indications or completes the matching request from reply fragments.
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard peripheral === peer, characteristic === channel, error == nil, let frame = characteristic.value,
              let byte = frame.first, let code = Packet.Code(rawValue: byte) else { return }
        switch code {
        case .ready:
            reportedWatchName = nil
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
