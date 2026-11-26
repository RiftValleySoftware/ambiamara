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
    typealias Snapshot = RiValT_WatchDelegate.Snapshot
    typealias Operation = RiValT_WatchDelegate.TimerOperation

    private let connection = RiValT_Watch_AppDelegate.connection

    private var isActive = false
    private var previousSnapshot: Snapshot?
    private var alarmHaptics: Task<Void, Never>?

    init() {
        self.connection.updateHandler = { [weak self] in
            self?.objectWillChange.send()
            self?.updateHaptics()
        }
    }

    var snapshot: Snapshot? { self.connection.canReachHost ? self.connection.snapshot : nil }
    var isConnecting: Bool { self.connection.isConnecting }
    var connectionFailed: Bool { self.connection.connectionFailed }
    var isSendingCommand: Bool { self.connection.isUpdateInProgress }

    var commandRejected: Bool { self.connection.commandRejected }

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

    func reconnect() {
        self.connection.reconnect()
    }

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
