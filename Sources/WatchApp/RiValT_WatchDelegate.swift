/*
    © Copyright 2012-2025, Little Green Viper Software Development LLC

    LICENSE:

    MIT License

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
    files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
    modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
    OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
    CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Foundation
import WatchConnectivity

/// The iPhone or iPad owns the timer. A Watch sends explicit, expiring commands against a state it has seen.
@MainActor
final class RiValT_WatchDelegate: NSObject {
    /// The timer and control sample exchanged with the Watch.
    typealias Snapshot = RiValT_RemoteState.Snapshot
    /// The phase displayed for the current timer sample.
    typealias Phase = RiValT_RemoteState.Phase
    /// An explicit control action the Watch can request.
    typealias TimerOperation = RiValT_RemoteState.TimerOperation

    /// The shared WatchConnectivity session when supported by the device.
    private var session: WCSession? { WCSession.isSupported() ? .default : nil }
    /// The Bluetooth link used for a nearby iPad.
    private let padLink = RiValT_BluetoothRemote.shared

    /// Notifies the Watch model when the snapshot, connection, or command status changes.
    var updateHandler: (() -> Void)?
    /// Notifies the app when it can reconsider completing background connectivity work.
    var connectivityProgressHandler: (() -> Void)?
    /// Tracks complication updates still waiting to be stored on the main actor.
    private nonisolated let complicationDeliveries = DispatchGroup()
    /// The latest live host sample with its countdown deadline converted to Watch time.
    private(set) var snapshot: Snapshot?
    /// Whether the chosen host has provided a valid live sample on the current connection.
    private(set) var canReachHost = false
    /// Whether session activation or the latest state request failed.
    private(set) var connectionFailed = false
    /// Whether WatchConnectivity activation is waiting for its delegate callback.
    private var activatingSession = false
    /// Whether the Watch is waiting for the first live sample or the phone session to activate.
    var isConnecting: Bool {
        !canReachHost && !connectionFailed && (pendingID != nil || (!padLink.usesIPad && activatingSession))
    }
    /// Whether a control command is waiting to be sent or acknowledged.
    private(set) var isUpdateInProgress = false
    /// Whether the last command was declined or its target state changed before it could be sent.
    private(set) var commandRejected = false

    /// Whether the Watch scene is active and should send interactive requests.
    private var active = false
    /// The identifier of the single request currently in flight.
    private var pendingID: String?
    // BLE exchanges are serial. Preserve the exact state the wearer saw if a tap overlaps a read.
    /// A control intent kept with the host state the wearer saw while a poll was in flight.
    private struct PendingCommand {
        /// The timer operation selected by the wearer.
        let operation: TimerOperation
        /// The host process that supplied the displayed snapshot.
        let session: String
        /// The control revision displayed when the wearer tapped.
        let revision: Int
        /// The Watch time of the tap, used to expire the intent.
        let tapped: Date
    }
    /// The command to reconsider after the current poll completes.
    private var waitingForPoll: PendingCommand?
    /// Whether a refresh was requested during the current exchange.
    private var needsRefresh = false
    /// The scheduled poll for the next host snapshot.
    private var heartbeat: DispatchWorkItem?
    /// The delayed complication rewind when the phone becomes unreachable.
    private var complicationRewind: DispatchWorkItem?
    /// The host process identifier from the last valid interactive response.
    private var hostSession: String?
    /// The command revision advertised in the last accepted snapshot.
    private var revision = 0
    /// Recent measurements used to translate between the host and Watch clocks.
    private var clock = RiValT_RemoteState.Clock()

    /// Initializes the Watch's timer link.
    ///
    /// - Parameter activate: Whether to activate the transports immediately.
    init(activate: Bool = true) {
        super.init()
        if activate { self.activate() }
    }

    /// Installs the transport callbacks and activates WatchConnectivity and the iPad Bluetooth link.
    func activate() {
        padLink.onConnectionChange = { [weak self] in self?.connectionChanged() }
        padLink.onChange = { [weak self] in self?.refresh() }
        padLink.activate()
        session?.delegate = self
        activatingSession = session?.activationState == .notActivated
        session?.activate()
    }
}

extension RiValT_WatchDelegate {
    /// Whether activation, pending session content, and complication writes have all finished.
    var canCompleteConnectivityTasks: Bool {
        guard !activatingSession else { return false }
        if let session, session.activationState == .activated, session.hasContentPending { return false }
        return complicationDeliveries.wait(timeout: .now()) == .success
    }

    /// Whether the currently selected transport can send an interactive request.
    private var linkIsReachable: Bool {
        if padLink.usesIPad { return padLink.isConnected }
        guard let session else { return false }
        return session.activationState == .activated && session.isReachable
    }

    /// Updates interactive polling and complication handling when the Watch scene changes activity.
    func setWatchActive(_ value: Bool) {
        guard active != value else { return }
        active = value
        connectionChanged()
    }

    /// The persisted complication source key for the selected phone or iPad.
    private var complicationSource: String {
        padLink.usesIPad ? "ipad-\(padLink.selectedDeviceID?.uuidString ?? "unknown")" : "phone"
    }

    /// Whether the activated phone session has lost interactive reachability.
    private var phoneIsUnreachable: Bool {
        session?.activationState == .activated && !linkIsReachable
    }

    /// Rewinds the selected host's stored complication at the current host time.
    private func rewindComplication() {
        RiValT_ComplicationState.rewind(source: complicationSource, at: clock.hostDate(forLocalDate: Date()))
    }

    /// Cancels a scheduled rewind when the phone recovers or the selected device changes.
    private func cancelComplicationRewind() {
        complicationRewind?.cancel()
        complicationRewind = nil
    }

    /// Rewinds immediately for iPad loss and delays a phone rewind to allow a transition to the watch face.
    private func handleComplicationConnectionLoss() {
        if padLink.usesIPad {
            rewindComplication()
            return
        }
        guard active, complicationRewind == nil else { return }
        // Interactive reachability can drop before the scene becomes inactive on the way to the face.
        let clockAtDisconnect = clock
        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.complicationRewind = nil
            guard self.active, !self.padLink.usesIPad,
                  self.phoneIsUnreachable || self.connectionFailed else { return }
            RiValT_ComplicationState.rewind(source: "phone", at: clockAtDisconnect.hostDate(forLocalDate: Date()))
        }
        complicationRewind = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: work)
    }

    /// Resets interactive state, selects the complication source, and refreshes a reachable active host.
    private func connectionChanged() {
        RiValT_ComplicationState.selectSource(complicationSource)
        if padLink.usesIPad {
            cancelComplicationRewind()
            if !padLink.isConnected { rewindComplication() }
        } else if active && phoneIsUnreachable {
            handleComplicationConnectionLoss()
        } else {
            cancelComplicationRewind()
        }
        if !padLink.usesIPad, let session { receiveComplicationUpdate(session.receivedApplicationContext) }
        heartbeat?.cancel()
        pendingID = nil
        waitingForPoll = nil
        needsRefresh = false
        commandRejected = false
        connectionFailed = false
        isUpdateInProgress = false
        clearSnapshot()
        if active && linkIsReachable { refresh() }
    }

    /// Discards the live snapshot and host clock estimate, then notifies observers.
    private func clearSnapshot() {
        snapshot = nil
        hostSession = nil
        clock = RiValT_RemoteState.Clock()
        canReachHost = false
        updateHandler?()
    }

    /// An explicit retry may reactivate a failed session or retry the selected iPad's approval.
    func reconnect() {
        guard active else { return }
        connectionFailed = false
        if padLink.usesIPad {
            padLink.retryConnection()
        } else if let session, session.activationState == .notActivated && !activatingSession {
            activatingSession = true
            session.activate()
        }
        updateHandler?()
        refresh()
    }

    /// Wake, reconnection, user refresh and a host invalidation all take this same path.
    func refresh() {
        guard active, linkIsReachable else { return }
        guard pendingID == nil else {
            needsRefresh = true
            return
        }
        request(command: nil)
    }

    /// Sends the supported command or queues it with the displayed host revision until the current poll completes.
    func sendCommand(command: TimerOperation) {
        guard active, canReachHost, !isUpdateInProgress, linkIsReachable,
              let hostSession, snapshot?.supports(command) == true else { return }
        let tapped = Date()
        if pendingID != nil {
            waitingForPoll = PendingCommand(operation: command, session: hostSession, revision: revision, tapped: tapped)
            commandRejected = false
            isUpdateInProgress = true
            updateHandler?()
        } else {
            request(command: command, tapped: tapped)
        }
    }

    /// Sends a snapshot request or expiring command over the selected transport and starts a reply timeout.
    private func request(command: TimerOperation?, tapped: Date? = nil) {
        let id = UUID().uuidString
        var packet: [String: Any] = ["version": 1, "request": id]
        let sent = Date()
        if let command {
            guard let hostSession else { return }
            packet["command"] = command.rawValue
            packet["session"] = hostSession
            packet["revision"] = revision
            packet["expires"] = clock.hostDate(forLocalDate: tapped ?? sent).addingTimeInterval(3).timeIntervalSince1970
            isUpdateInProgress = true
            commandRejected = false
        }
        heartbeat?.cancel()
        pendingID = id
        needsRefresh = false
        if command != nil || !canReachHost { updateHandler?() }

        let failure = { [weak self] in
            DispatchQueue.main.async { self?.failed(id: id) }
        }
        let response: ([String: Any]) -> Void = { [weak self] reply in
            let received = Date()
            DispatchQueue.main.async {
                self?.received(reply, id: id, sent: sent, at: received, wasCommand: command != nil)
            }
        }
        if padLink.usesIPad {
            padLink.request(packet, reply: response, failure: failure)
        } else {
            session?.sendMessage(packet, replyHandler: response, errorHandler: { _ in failure() })
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in self?.failed(id: id) }
    }

    /// Clears the failed exchange, reports the connection loss, and schedules another poll.
    private func failed(id: String) {
        guard pendingID == id else { return }
        pendingID = nil
        waitingForPoll = nil
        isUpdateInProgress = false
        needsRefresh = false
        connectionFailed = true
        handleComplicationConnectionLoss()
        clearSnapshot()
        scheduleRefresh(in: 1)
    }

    /// Validates the host reply, updates the clock and timer snapshot, and reconciles any queued command.
    private func received(_ reply: [String: Any], id: String, sent: Date, at received: Date, wasCommand: Bool) {
        guard pendingID == id else { return }
        guard active, linkIsReachable, reply["version"] as? Int == 1,
              reply["request"] as? String == id, let session = reply["session"] as? String,
              let updatedRevision = reply["revision"] as? Int,
              let receivedAtHost = reply["hostReceived"] as? TimeInterval,
              let repliedAtHost = reply["hostReplied"] as? TimeInterval,
              let data = reply["state"] as? Data,
              var state = try? PropertyListDecoder().decode(Snapshot.self, from: data)
        else { failed(id: id); return }

        if hostSession != session { clock = RiValT_RemoteState.Clock() }
        guard clock.record(sent: sent, received: received,
                           hostReceived: Date(timeIntervalSince1970: receivedAtHost),
                           hostReplied: Date(timeIntervalSince1970: repliedAtHost))
        else { failed(id: id); return }
        state.deadline = state.deadline.map(clock.localDate(forHostDate:))
        state.stamp = "\(session)-\(updatedRevision)"
        cancelComplicationRewind()
        pendingID = nil
        hostSession = session
        revision = updatedRevision
        snapshot = state
        let hostDate = Date(timeIntervalSince1970: repliedAtHost)
        if state.phase != .unavailable {
            RiValT_ComplicationState.save(state, updatedAt: hostDate, source: complicationSource, confirmed: true,
                                          localSampleDate: clock.localDate(forHostDate: hostDate))
        } else if let data = reply["complicationState"] as? Data, var face = try? PropertyListDecoder().decode(Snapshot.self, from: data) {
            face.deadline = face.deadline.map(clock.localDate(forHostDate:))
            RiValT_ComplicationState.save(face, updatedAt: hostDate, source: complicationSource, confirmed: true,
                                          localSampleDate: clock.localDate(forHostDate: hostDate))
        } else {
            rewindComplication()
        }
        connectionFailed = false
        isUpdateInProgress = false
        canReachHost = true
        if wasCommand { commandRejected = reply["accepted"] as? Bool != true }
        if let intent = waitingForPoll {
            waitingForPoll = nil
            if intent.session == session, intent.revision == updatedRevision,
               (0..<3).contains(Date().timeIntervalSince(intent.tapped)), state.supports(intent.operation) {
                request(command: intent.operation, tapped: intent.tapped)
                return
            }
            commandRejected = true
        }
        updateHandler?()
        if needsRefresh { refresh() } else { scheduleRefresh(in: 3) }
    }

    /// Keep background execution until the main actor has stored the delivered snapshot.
    private nonisolated func enqueueComplicationUpdate(_ payload: [String: Any]) {
        complicationDeliveries.enter()
        DispatchQueue.main.async {
            self.receiveComplicationUpdate(payload)
            self.complicationDeliveries.leave()
            self.connectivityProgressHandler?()
        }
    }

    /// Background data is for the face only; it never enables remote controls or establishes reachability.
    private func receiveComplicationUpdate(_ payload: [String: Any]) {
        guard !padLink.usesIPad,
              let data = payload["complicationState"] as? Data,
              let timestamp = payload["complicationUpdatedAt"] as? TimeInterval,
              var state = try? PropertyListDecoder().decode(Snapshot.self, from: data)
        else { return }
        // Use a measured clock correction when available; otherwise paired devices' wall clocks apply.
        state.deadline = state.deadline.map(clock.localDate(forHostDate:))
        let hostDate = Date(timeIntervalSince1970: timestamp)
        RiValT_ComplicationState.save(state, updatedAt: hostDate, source: "phone", localSampleDate: clock.localDate(forHostDate: hostDate))
    }

    /// Schedules the next snapshot request while the Watch scene is active.
    private func scheduleRefresh(in seconds: TimeInterval) {
        heartbeat?.cancel()
        guard active else { return }
        let work = DispatchWorkItem { [weak self] in self?.refresh() }
        heartbeat = work
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: work)
    }
}

extension RiValT_WatchDelegate: WCSessionDelegate {
    /// Refreshes connection state after WatchConnectivity activation.
    nonisolated func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.activatingSession = false
            if !self.padLink.usesIPad {
                self.connectionChanged()
                if error != nil {
                    self.connectionFailed = true
                    self.handleComplicationConnectionLoss()
                    self.updateHandler?()
                }
            }
            self.connectivityProgressHandler?()
        }
    }

    /// Reevaluates the Watch's selected connection after a reachability change.
    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            if !self.padLink.usesIPad { self.connectionChanged() }
        }
    }

    /// Queues the paired phone's latest application-context sample for the complication.
    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        enqueueComplicationUpdate(applicationContext)
    }

    /// Queues a priority complication update received from the paired phone.
    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        enqueueComplicationUpdate(userInfo)
    }

    /// Requests a new snapshot after the paired phone sends a change hint.
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard message["changed"] as? Bool == true else { return }
        DispatchQueue.main.async {
            if !self.padLink.usesIPad { self.refresh() }
        }
    }
}
