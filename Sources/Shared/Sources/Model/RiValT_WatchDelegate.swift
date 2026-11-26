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
    typealias Snapshot = RiValT_RemoteState.Snapshot
    typealias Phase = RiValT_RemoteState.Phase
    typealias TimerOperation = RiValT_RemoteState.TimerOperation

    private var session: WCSession? { WCSession.isSupported() ? .default : nil }
    private let padLink = RiValT_BluetoothRemote.shared

    #if os(watchOS)
    var updateHandler: (() -> Void)?
    private(set) var snapshot: Snapshot?
    private(set) var canReachHost = false
    private(set) var connectionFailed = false
    private var activatingSession = false
    var isConnecting: Bool {
        !canReachHost && !connectionFailed && (pendingID != nil || (!padLink.usesIPad && activatingSession))
    }
    private(set) var isUpdateInProgress = false
    private(set) var commandRejected = false

    private var active = false
    private var pendingID: String?
    // BLE exchanges are serial. Preserve the exact state the wearer saw if a tap overlaps a read.
    private struct PendingCommand {
        let operation: TimerOperation
        let session: String
        let revision: Int
        let tapped: Date
    }
    private var waitingForPoll: PendingCommand?
    private var needsRefresh = false
    private var heartbeat: DispatchWorkItem?
    private var complicationRewind: DispatchWorkItem?
    private var hostSession: String?
    private var revision = 0
    private var clock = RiValT_RemoteState.Clock()
    #else
    let timerModel = TimerModel()
    private var host = RiValT_RemoteState.Host()
    private var lastNotifiedRevision = -1
    private var lastNotifiedPhase: Phase?
    private var lastComplicationSnapshot: Snapshot?
    private var lastComplicationUpdate = Date.distantPast
    #endif

    init(activate: Bool = true) {
        super.init()
        #if !os(watchOS)
        RiValT_Settings.ephemeralFirstTime = true
        let settings = RiValT_Settings()
        timerModel.asArray = settings.timerModel
        if timerModel.allTimers.isEmpty {
            let timer = timerModel.createNewTimer(at: IndexPath(item: 0, section: 0))
            timer.isSelected = true
            settings.timerModel = timerModel.asArray
        }
        #endif
        if activate { self.activate() }
    }

    func activate() {
        #if os(watchOS)
        padLink.onConnectionChange = { [weak self] in self?.connectionChanged() }
        padLink.onChange = { [weak self] in self?.refresh() }
        #else
        padLink.onRequest = { [weak self] message, reply in
            guard let self else { reply([:]); return }
            self.answer(message, reply: reply)
        }
        #endif
        padLink.activate()
        session?.delegate = self
        #if os(watchOS)
        activatingSession = session?.activationState == .notActivated
        #endif
        session?.activate()
    }
}

#if !os(watchOS)
extension RiValT_WatchDelegate {
    func updateSettings() {
        RiValT_Settings().timerModel = timerModel.asArray
        publishSnapshot()
    }

    /// Host callbacks can originate on the engine queue. Read its model and the UIKit navigation state on main.
    nonisolated func publishSnapshot() {
        DispatchQueue.main.async { self.publishCurrentSnapshot() }
    }

    /// Scene callbacks publish synchronously so a background rewind is queued before suspension.
    func publishCurrentSnapshot() {
        let session = self.session
        let watchIsReachable = session?.activationState == .activated && session?.isReachable == true
        publishComplicationSnapshot()
        guard watchIsReachable || padLink.hasRemoteSubscriber, let state = capture(),
              lastNotifiedRevision != host.revision || lastNotifiedPhase != state.phase
        else { return }
        lastNotifiedRevision = host.revision
        lastNotifiedPhase = state.phase
        padLink.notifyChange()
        if watchIsReachable, let session {
            // This is just an invalidation. All Watch state comes from a measured request/reply exchange.
            session.sendMessage(["changed": true], replyHandler: nil, errorHandler: nil)
        }
    }

    /// Application context keeps only the latest state and can be delivered with the Watch app asleep.
    private func publishComplicationSnapshot() {
        let now = Date()
        guard let session, session.activationState == .activated, session.isPaired,
              session.isWatchAppInstalled,
              let state = RiValT_AppDelegate.appDelegateInstance?.remoteSnapshot(forComplication: true),
              lastComplicationSnapshot?.representsSameControlState(as: state) != true
                || (state.displayDeadline != nil && now.timeIntervalSince(lastComplicationUpdate) >= RiValT_RemoteState.complicationConfirmationInterval),
              let encoded = try? PropertyListEncoder().encode(state)
        else { return }
        do {
            try session.updateApplicationContext(["complicationState": encoded,
                                                   "complicationUpdatedAt": now.timeIntervalSince1970])
            lastComplicationSnapshot = state
            lastComplicationUpdate = now
        } catch {
            // A later state publication retries if the session cannot accept this update yet.
            lastComplicationSnapshot = nil
        }
    }

    private func capture() -> Snapshot? {
        guard let app = RiValT_AppDelegate.appDelegateInstance else { return nil }
        let state = app.remoteSnapshot()
        host.update(state)
        return state
    }

    private func answer(_ request: [String: Any], received: Date = Date(), reply: @escaping ([String: Any]) -> Void) {
        guard request["version"] as? Int == 1, let requestID = request["request"] as? String,
              UUID(uuidString: requestID) != nil, var state = capture()
        else { reply([:]); return }

        var accepted = false
        if let app = RiValT_AppDelegate.appDelegateInstance,
           let command = host.consumeCommand(request, at: Date()) {
            accepted = app.performRemoteCommand(command)
            state = capture() ?? state
            publishSnapshot()
        }

        guard let encoded = try? PropertyListEncoder().encode(state) else { reply([:]); return }
        var response: [String: Any] = ["version": 1, "request": requestID, "session": host.session, "revision": host.revision,
                                      "hostReceived": received.timeIntervalSince1970, "hostReplied": Date().timeIntervalSince1970,
                                      "state": encoded, "accepted": accepted]
        if state.phase == .unavailable, let face = RiValT_AppDelegate.appDelegateInstance?.remoteSnapshot(forComplication: true) {
            response["complicationState"] = try? PropertyListEncoder().encode(face)
        }
        reply(response)
    }
}
#else
extension RiValT_WatchDelegate {
    private var linkIsReachable: Bool {
        if padLink.usesIPad { return padLink.isConnected }
        guard let session else { return false }
        return session.activationState == .activated && session.isReachable
    }

    func setWatchActive(_ value: Bool) {
        guard active != value else { return }
        active = value
        connectionChanged()
    }

    private var complicationSource: String {
        padLink.usesIPad ? "ipad-\(padLink.selectedDeviceID?.uuidString ?? "unknown")" : "phone"
    }

    private var phoneIsUnreachable: Bool {
        session?.activationState == .activated && !linkIsReachable
    }

    private func rewindComplication() {
        RiValT_ComplicationState.rewind(source: complicationSource, at: clock.hostDate(forLocalDate: Date()))
    }

    private func cancelComplicationRewind() {
        complicationRewind?.cancel()
        complicationRewind = nil
    }

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
        if !padLink.usesIPad, let session { receiveComplicationContext(session.receivedApplicationContext) }
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

    /// Background data is for the face only; it never enables remote controls or establishes reachability.
    private func receiveComplicationContext(_ context: [String: Any]) {
        guard !padLink.usesIPad,
              let data = context["complicationState"] as? Data,
              let timestamp = context["complicationUpdatedAt"] as? TimeInterval,
              var state = try? PropertyListDecoder().decode(Snapshot.self, from: data)
        else { return }
        // Use a measured clock correction when available; otherwise paired devices' wall clocks apply.
        state.deadline = state.deadline.map(clock.localDate(forHostDate:))
        let hostDate = Date(timeIntervalSince1970: timestamp)
        RiValT_ComplicationState.save(state, updatedAt: hostDate, source: "phone", localSampleDate: clock.localDate(forHostDate: hostDate))
    }

    private func scheduleRefresh(in seconds: TimeInterval) {
        heartbeat?.cancel()
        guard active else { return }
        let work = DispatchWorkItem { [weak self] in self?.refresh() }
        heartbeat = work
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: work)
    }
}
#endif

extension RiValT_WatchDelegate: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            #if os(watchOS)
            self.activatingSession = false
            if !self.padLink.usesIPad {
                self.connectionChanged()
                if error != nil {
                    self.connectionFailed = true
                    self.handleComplicationConnectionLoss()
                    self.updateHandler?()
                }
            }
            #else
            self.publishSnapshot()
            #endif
        }
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        #if os(watchOS)
        DispatchQueue.main.async {
            if !self.padLink.usesIPad { self.connectionChanged() }
        }
        #endif
    }

    #if os(watchOS)
    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async { self.receiveComplicationContext(applicationContext) }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard message["changed"] as? Bool == true else { return }
        DispatchQueue.main.async {
            if !self.padLink.usesIPad { self.refresh() }
        }
    }
    #else
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}
    nonisolated func sessionDidDeactivate(_ session: WCSession) { session.activate() }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any],
                             replyHandler: @escaping ([String: Any]) -> Void) {
        let received = Date()
        DispatchQueue.main.async { self.answer(message, received: received, reply: replyHandler) }
    }
    #endif
}
