/*
 © Copyright 2018-2026, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import Combine
import Foundation
import WatchKit

/// The Watch observes the chosen device. Only that device can change the timer.
@MainActor
final class RiValT_ObservableModel: ObservableObject {
    /// The live timer sample displayed by the Watch views.
    typealias Snapshot = RiValT_WatchDelegate.Snapshot
    /// An operation the wearer can request from the selected host.
    typealias Operation = RiValT_WatchDelegate.TimerOperation

    /// The app-wide connection shared by the views and background delivery handler.
    private let connection = RiValT_Watch_AppDelegate.connection

    /// Whether the Watch scene is active and eligible to play haptics.
    private var isActive = false
    /// The previous host sample used to detect phase and timer changes.
    private var previousSnapshot: Snapshot?
    /// The repeating haptics task while a host-confirmed alarm is active.
    private var alarmHaptics: Task<Void, Never>?

    /// Subscribes the view model and its haptics to connection updates.
    init() {
        self.connection.updateHandler = { [weak self] in
            self?.objectWillChange.send()
            self?.updateHaptics()
        }
    }

    /// The most recent timer sample while a live host is reachable.
    var snapshot: Snapshot? { self.connection.canReachHost ? self.connection.snapshot : nil }
    /// Whether the active transport is waiting for a connection or first response.
    var isConnecting: Bool { self.connection.isConnecting }
    /// Whether the active connection is reporting a failure.
    var connectionFailed: Bool { self.connection.connectionFailed }
    /// Whether a timer action is pending acknowledgement.
    var isSendingCommand: Bool { self.connection.isUpdateInProgress }

    /// Whether the last timer action was rejected.
    var commandRejected: Bool { self.connection.commandRejected }

    /// Updates the connection and haptics when the Watch scene becomes active or inactive.
    func setActive(_ active: Bool) {
        self.isActive = active
        self.connection.setWatchActive(active)
        self.updateHaptics()
    }

    /// React to host-confirmed transitions, never to a locally predicted timer expiry.
    private func updateHaptics() {
        let current = self.snapshot
        defer { self.previousSnapshot = current }
        guard self.isActive, let current else {
            self.alarmHaptics?.cancel()
            self.alarmHaptics = nil
            return
        }

        if current.phase == .alarm {
            if self.alarmHaptics == nil {
                self.alarmHaptics = Task { @MainActor in
                    while !Task.isCancelled {
                        WKInterfaceDevice.current().play(.notification)
                        do {
                            try await Task.sleep(for: .seconds(2))
                        } catch {
                            return
                        }
                    }
                }
            }
            return
        }
        self.alarmHaptics?.cancel()
        self.alarmHaptics = nil

        guard let previous = self.previousSnapshot,
              previous.phase != .unavailable, current.phase != .unavailable else { return }
        if previous.timerID != current.timerID || previous.phase != current.phase {
            switch current.phase {
            case .warning, .final: WKInterfaceDevice.current().play(.directionDown)
            case .countdown: WKInterfaceDevice.current().play(.start)
            case .paused: WKInterfaceDevice.current().play(.stop)
            case .ready: WKInterfaceDevice.current().play(.click)
            default: break
            }
        }
    }

    /// Retries the selected host connection.
    func reconnect() {
        self.connection.reconnect()
    }

    /// Requests a fresh sample from the active host.
    func refresh() {
        self.connection.refresh()
    }

    /// A group can advance or the host can change while the wearer is choosing an action.
    func send(_ operation: Operation, for displayed: Snapshot) {
        guard !self.isSendingCommand else { return }
        guard let current = self.snapshot,
              let stamp = displayed.stamp, current.stamp == stamp,
              current.supports(operation),
              current.deadline.map({ $0 > .now }) ?? true
        else {
            self.connection.refresh()
            return
        }
        self.connection.sendCommand(command: operation)
    }
}
