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

    /// The host's authoritative model of timer groups and presets.
    let timerModel = TimerModel()
    /// The host identity, current control snapshot, and command revision.
    private var host = RiValT_RemoteState.Host()
    /// The last command revision announced to interactive remotes.
    private var lastNotifiedRevision = -1
    /// The last timer phase announced to interactive remotes.
    private var lastNotifiedPhase: Phase?
    /// The most recent timer sample sent to the complication.
    private var lastComplicationSnapshot: Snapshot?
    /// The time when the host last sent a complication sample.
    private var lastComplicationUpdate = Date.distantPast

    /// Initializes the timer link and restores the host's persisted presets.
    ///
    /// - Parameter activate: Whether to activate the transports immediately.
    init(activate: Bool = true) {
        super.init()
        RiValT_Settings.ephemeralFirstTime = true
        let settings = RiValT_Settings()
        timerModel.asArray = settings.timerModel
        if timerModel.allTimers.isEmpty {
            let timer = timerModel.createNewTimer(at: IndexPath(item: 0, section: 0))
            timer.isSelected = true
            settings.timerModel = timerModel.asArray
        }
        if activate { self.activate() }
    }

    /// Installs the transport callbacks and activates WatchConnectivity and the iPad Bluetooth link.
    func activate() {
        padLink.onRequest = { [weak self] message, reply in
            guard let self else { reply([:]); return }
            self.answer(message, reply: reply)
        }
        padLink.activate()
        session?.delegate = self
        session?.activate()
    }
}

extension RiValT_WatchDelegate {
    /// Persists the timer model and notifies remotes of its current state.
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

    /// Sends a changed or overdue complication sample, using priority delivery when available.
    private func publishComplicationSnapshot() {
        let now = Date()
        guard let session, session.activationState == .activated, session.isPaired,
              session.isWatchAppInstalled,
              let app = RiValT_AppDelegate.appDelegateInstance else { return }
        let state = app.remoteSnapshot(forComplication: true)
        let stateChanged = lastComplicationSnapshot?.representsSameControlState(as: state) != true
        let needsConfirmation = state.displayDeadline != nil
            && now.timeIntervalSince(lastComplicationUpdate) >= RiValT_RemoteState.complicationConfirmationInterval
        guard stateChanged || needsConfirmation,
              let encoded = try? PropertyListEncoder().encode(state)
        else { return }

        let payload: [String: Any] = ["complicationState": encoded, "complicationUpdatedAt": now.timeIntervalSince1970]
        do {
            // Application context keeps the latest snapshot available when priority delivery is unavailable.
            try session.updateApplicationContext(payload)
            lastComplicationSnapshot = state
            lastComplicationUpdate = now
            // Reserve the limited priority transfers for state changes outside a scrub gesture.
            if stateChanged, !app.isScrubbingComplicationTimer, session.isComplicationEnabled {
                // Only the latest snapshot is useful if the Watch was disconnected.
                session.outstandingUserInfoTransfers.first(where: \.isCurrentComplicationInfo)?.cancel()
                if session.remainingComplicationUserInfoTransfers > 0 {
                    _ = session.transferCurrentComplicationUserInfo(payload)
                }
            }
        } catch {
            // A later state publication retries if the session cannot accept this update yet.
            lastComplicationSnapshot = nil
        }
    }

    /// Reads the app's current timer state and records it for command validation.
    private func capture() -> Snapshot? {
        guard let app = RiValT_AppDelegate.appDelegateInstance else { return nil }
        let state = app.remoteSnapshot()
        host.update(state)
        return state
    }

    /// Validates a remote request, applies any accepted command, and replies with the host's current state.
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

extension RiValT_WatchDelegate: WCSessionDelegate {
    /// Publishes the host state after WatchConnectivity activation.
    nonisolated func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.publishSnapshot()
        }
    }

    /// Receives reachability changes. Host snapshots are published by model and scene updates.
    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {}

    /// Receives the iPhone session's inactive transition while watch pairing changes.
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}
    /// Reactivates WatchConnectivity after the active watch session is replaced.
    nonisolated func sessionDidDeactivate(_ session: WCSession) { session.activate() }

    /// Routes an interactive Watch message to the main queue with its receipt time.
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any],
                             replyHandler: @escaping ([String: Any]) -> Void) {
        let received = Date()
        DispatchQueue.main.async { self.answer(message, received: received, reply: replyHandler) }
    }
}
