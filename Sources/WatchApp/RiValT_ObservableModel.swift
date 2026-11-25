/*
 © Copyright 2018-2026, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import Combine
import Foundation

/// The Watch observes the chosen device. Only that device can change the timer.
@MainActor
final class RiValT_ObservableModel: ObservableObject {
    typealias Snapshot = RiValT_WatchDelegate.Snapshot
    typealias Operation = RiValT_WatchDelegate.TimerOperation

    private let connection = RiValT_Watch_AppDelegate.connection

    init() {
        self.connection.updateHandler = { [weak self] in
            self?.objectWillChange.send()
        }
    }

    var snapshot: Snapshot? { self.connection.canReachHost ? self.connection.snapshot : nil }
    var isConnecting: Bool { self.connection.isConnecting }
    var connectionFailed: Bool { self.connection.connectionFailed }
    var isSendingCommand: Bool { self.connection.isUpdateInProgress }

    var commandRejected: Bool { self.connection.commandRejected }

    func setActive(_ active: Bool) {
        self.connection.setWatchActive(active)
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
              current.commands.contains(operation),
              current.deadline.map({ $0 > .now }) ?? true
        else {
            self.connection.refresh()
            return
        }
        self.connection.sendCommand(command: operation)
    }
}
