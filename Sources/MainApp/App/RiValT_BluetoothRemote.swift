/*
 © Copyright 2026, The Great Rift Valley Software Company. All rights reserved.
 This code is proprietary and is not licensed for reuse.
 */

import CoreBluetooth
import Combine
import Foundation
import UIKit

/// A foreground iPad can vend the same request/reply protocol as the paired phone.
/// GATT indications carry replies and change hints; each request is applied only by the host.
final class RiValT_BluetoothRemote: NSObject, ObservableObject {
    /// The transport shared by the timer delegate and the app's remote settings.
    static let shared = RiValT_BluetoothRemote()

    /// Shared device identifiers and packet framing for the Bluetooth link.
    private typealias Packet = RiValT_BluetoothRemotePacket

    /// The current assembly for fragments received from the remote device.
    private var incoming = Packet.Assembly()

    /// The host callback that processes a complete Watch request and sends a reply.
    var onRequest: (([String: Any], @escaping ([String: Any]) -> Void) -> Void)?
    /// Whether the user enabled Watch Remote hosting in the iPad app.
    var isEnabled: Bool { UserDefaults.standard.bool(forKey: "remote.iPadEnabled") }
    /// Whether an approved Watch is subscribed to the iPad's channel.
    var hasRemoteSubscriber: Bool { approved }
    /// The persistent device label advertised to nearby Watches.
    private(set) lazy var hostName: String = {
        let key = "remote.iPadLabel"
        if let label = UserDefaults.standard.string(forKey: key) { return label }
        let label = "RiVal.T-" + UUID().uuidString.prefix(4)
        UserDefaults.standard.set(label, forKey: key)
        return label
    }()
    /// The Core Bluetooth peripheral manager used by the iPad.
    private var manager: CBPeripheralManager?
    /// The encrypted request and indication characteristic registered with the peripheral manager.
    private var channel: CBMutableCharacteristic?
    /// The Watch currently subscribed to the characteristic.
    private var subscriber: CBCentral?
    /// The pairing confirmation alert, if one is on screen.
    private weak var permissionAlert: UIAlertController?
    /// A localized status message when hosting needs user attention or is retrying.
    @Published private(set) var hostingIssue: String?
    /// The connected Watch's name, or the default connected label before it provides one.
    @Published private(set) var connectedWatchName: String?
    /// The pending attempt to restart service registration or advertising.
    private var hostRetry: DispatchWorkItem?
    /// The delay before the next hosting retry, capped at eight seconds.
    private var retryDelay: TimeInterval = 1
    /// Whether the peripheral manager confirmed registration of the service.
    private var serviceAdded = false
    /// Whether foreground and background observers have already been registered.
    private var observing = false
    /// The ordered indications waiting to be sent to the current Watch.
    private var output = [Data]()

    /// Persists the hosting preference and starts the service or clears the approved Watch and stops it.
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

    /// Registers lifecycle observers once and starts hosting on a supported iPad.
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

    /// Prepares the encrypted service or restarts advertising when the app is active and Bluetooth is ready.
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
        let characteristic = CBMutableCharacteristic(type: Packet.channelID,
                                                    properties: [.write, .indicateEncryptionRequired],
                                                    value: nil, permissions: [.writeEncryptionRequired])
        channel = characteristic
        let service = CBMutableService(type: Packet.serviceID, primary: true)
        service.characteristics = [characteristic]
        manager.add(service)
    }

    /// Advertises the timer service UUID and the iPad's persistent device label.
    private func advertise() {
        manager?.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [Packet.serviceID], CBAdvertisementDataLocalNameKey: hostName])
    }

    /// Schedules a retry with backoff while the enabled host remains active and Bluetooth is on.
    private func scheduleHostRetry() {
        guard isEnabled, UIApplication.shared.applicationState == .active, manager?.state == .poweredOn else { return }
        hostingIssue = NSLocalizedString("SLUG-WATCH-REMOTE-RETRYING", comment: "")
        hostRetry?.cancel()
        let attempt = DispatchWorkItem { [weak self] in self?.start() }
        hostRetry = attempt
        DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay, execute: attempt)
        retryDelay = min(8, retryDelay * 2)
    }

    /// Stops advertising, removes services, and releases subscriber and retry state.
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

    /// Clears the subscriber, displayed name, pending packets, and pairing alert.
    private func releaseSubscriber() {
        subscriber = nil
        connectedWatchName = nil
        output.removeAll()
        incoming = Packet.Assembly()
        permissionAlert?.dismiss(animated: false)
        permissionAlert = nil
    }

    /// Whether the subscribed Watch matches the identifier approved by the user.
    private var approved: Bool {
        guard let subscriber else { return false }
        return subscriber.identifier.uuidString == UserDefaults.standard.string(forKey: "remote.approvedWatch")
    }

    /// Signals that the encrypted channel is ready and sets the default connected label.
    private func confirmWatchConnection() {
        // Older Watch releases do not send a name with their requests.
        connectedWatchName = NSLocalizedString("SLUG-WATCH-REMOTE-CONNECTED", comment: "")
        queue(Data([Packet.Code.ready.rawValue]))
    }

    /// Reuses existing approval or prompts the iPad user to confirm the Watch's displayed pairing code.
    private func authorize(_ central: CBCentral) {
        if approved {
            confirmWatchConnection()
            return
        }
        guard UserDefaults.standard.string(forKey: "remote.approvedWatch") == nil,
              let windowScene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first(where: { $0.activationState == .foregroundActive }),
              var presenter = windowScene.keyWindow?.rootViewController else {
            queue(Data([Packet.Code.denied.rawValue]))
            return
        }
        while let presented = presenter.presentedViewController { presenter = presented }
        let code = String(Int.random(in: 1000...9999))
        var message = Data([Packet.Code.authorization.rawValue])
        message.append(contentsOf: code.utf8)
        queue(message)
        let alert = UIAlertController(title: NSLocalizedString("SLUG-WATCH-PAIR-TITLE", comment: ""),
                                      message: String(format: NSLocalizedString("SLUG-WATCH-PAIR-CODE", comment: ""), code),
                                      preferredStyle: .alert)
        let decline = UIAlertAction(title: NSLocalizedString("SLUG-WATCH-PAIR-DENY", comment: ""), style: .cancel) { [weak self] _ in
            guard let self, self.subscriber?.identifier == central.identifier else { return }
            self.queue(Data([Packet.Code.denied.rawValue]))
        }
        decline.setAccessibility(label: "SLUG-ACC-WATCH-PAIR-DENY-LABEL", hint: "SLUG-ACC-WATCH-PAIR-DENY-HINT")
        alert.addAction(decline)
        let allow = UIAlertAction(title: NSLocalizedString("SLUG-WATCH-PAIR-ALLOW", comment: ""), style: .default) { [weak self] _ in
            guard let self, self.subscriber?.identifier == central.identifier, self.isEnabled else { return }
            UserDefaults.standard.set(central.identifier.uuidString, forKey: "remote.approvedWatch")
            self.confirmWatchConnection()
        }
        allow.setAccessibility(label: "SLUG-ACC-WATCH-PAIR-ALLOW-LABEL", hint: "SLUG-ACC-WATCH-PAIR-ALLOW-HINT")
        alert.addAction(allow)
        permissionAlert = alert
        presenter.present(alert, animated: true)
    }

    /// Queues a single change hint for the approved Watch so it can request a fresh snapshot.
    func notifyChange() {
        let hint = Data([Packet.Code.changed.rawValue])
        guard approved, !output.contains(hint) else { return }
        queue(hint)
    }

    /// Appends an indication and attempts to send pending indications in order.
    private func queue(_ frame: Data) {
        output.append(frame)
        flush()
    }

    /// Sends queued indications until Core Bluetooth reports backpressure.
    private func flush() {
        guard let manager, let channel, let subscriber else { return }
        while let frame = output.first {
            guard manager.updateValue(frame, for: channel, onSubscribedCentrals: [subscriber]) else { return }
            output.removeFirst()
        }
    }
}

extension RiValT_BluetoothRemote: CBPeripheralManagerDelegate {
    /// Starts hosting when Bluetooth becomes available or reports why it cannot run.
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
    /// Starts advertising once the current service is registered or schedules a retry if registration failed.
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
    /// Clears the retry status after advertising starts or schedules another attempt after a failure.
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
    /// Accepts a subscription to the current channel and starts approval for the eligible Watch.
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        guard characteristic === channel, isEnabled else { return }
        // Only the user-approved watch can occupy an existing host binding.
        if let saved = UserDefaults.standard.string(forKey: "remote.approvedWatch"), saved != central.identifier.uuidString {
            if let channel { _ = peripheral.updateValue(Data([Packet.Code.denied.rawValue]), for: channel, onSubscribedCentrals: [central]) }
            return
        }
        guard subscriber == nil || subscriber?.identifier == central.identifier else {
            if let channel { _ = peripheral.updateValue(Data([Packet.Code.denied.rawValue]), for: channel, onSubscribedCentrals: [central]) }
            return
        }
        subscriber = central
        authorize(central)
    }
    /// Releases state when the current Watch unsubscribes from the active channel.
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        if characteristic === channel, subscriber?.identifier == central.identifier { releaseSubscriber() }
    }
    /// Resumes sending pending indications when Core Bluetooth has capacity again.
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) { flush() }
    /// Accepts and assembles writes from the approved Watch and sends replies over the same channel.
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
            if let name = (message[Packet.watchNameKey] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines),
               !name.isEmpty, name != connectedWatchName {
                connectedWatchName = name
            }
            handler(message) { [weak self] response in
                guard let self, self.subscriber?.identifier == subscriber.identifier, self.channel === channel, self.approved,
                      let bytes = Packet.encode(response) else { return }
                self.output += Packet.frames(bytes, id: id, mtu: subscriber.maximumUpdateValueLength)
                self.flush()
            }
        }
    }
}
