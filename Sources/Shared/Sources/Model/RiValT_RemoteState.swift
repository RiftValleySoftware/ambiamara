/*
 © Copyright 2026, The Great Rift Valley Software Company. All rights reserved.
*/

import Foundation

/// The Watch renders a sample from the host. Only the host runs a timer and advances its group.
enum RiValT_RemoteState {
    enum TimerOperation: String, Codable, CaseIterable {
        case start, pause, resume, stop, reset, fastForward
    }

    enum Phase: String, Codable {
        case unavailable, ready, countdown, warning, final, paused, alarm

        var isCounting: Bool {
            switch self {
            case .countdown, .warning, .final: return true
            default: return false
            }
        }
    }

    struct Snapshot: Codable {
        let timerID: UUID?
        let groupNumber: Int
        let timerNumber: Int
        let groupSize: Int
        let phase: Phase
        let remaining: Int
        var deadline: Date?
        let warning: Int
        let final: Int
        let commands: [TimerOperation]
        /// On the Watch, identifies the specific host state the displayed controls describe.
        var stamp: String?
        /// Seconds in later timers included in the host's displayed countdown.
        var followingDuration: Int?

        /// TimerEngine displays ceiling seconds. A delayed message therefore still shows the current second.
        func remaining(at date: Date) -> Int {
            guard phase.isCounting, let deadline else { return remaining }
            return max(0, Int(ceil(deadline.timeIntervalSince(date))))
        }

        /// The digital readout counts through a group handoff. Commands and warnings still use the current timer's deadline.
        var displayDeadline: Date? {
            guard phase.isCounting, let deadline else { return nil }
            return deadline.addingTimeInterval(TimeInterval(followingDuration ?? 0))
        }

        func displayRemaining(at date: Date) -> Int {
            guard let displayDeadline else { return remaining + (followingDuration ?? 0) }
            return max(0, Int(ceil(displayDeadline.timeIntervalSince(date))))
        }

        func phase(at date: Date) -> Phase {
            guard phase.isCounting, deadline != nil else { return phase }
            let seconds = remaining(at: date)
            // Only the host can decide whether reaching zero advances the group or raises an alarm.
            guard seconds > 0 else { return phase }
            if seconds <= final { return .final }
            if seconds <= warning { return .warning }
            return .countdown
        }

        /// Continuous ticks share a command revision. A seek, restart, selection or control change invalidates it.
        func representsSameControlState(as other: Self) -> Bool {
            timerID == other.timerID && groupNumber == other.groupNumber && timerNumber == other.timerNumber
                && groupSize == other.groupSize && commands == other.commands && warning == other.warning
                && final == other.final && deadline == other.deadline
                && (followingDuration ?? 0) == (other.followingDuration ?? 0)
                && (deadline != nil && phase.isCounting && other.phase.isCounting || (phase == other.phase && remaining == other.remaining))
        }
    }
}

extension RiValT_RemoteState {
    /// Each command names the host process and the control state the wearer saw.
    struct Host {
        let session = UUID().uuidString
        private(set) var revision = 0
        private var snapshot: Snapshot?

        mutating func update(_ state: Snapshot) {
            if snapshot?.representsSameControlState(as: state) != true {
                revision += 1
            }
            snapshot = state
        }

        /// Consume the revision before UIKit handles the action, even when navigation finishes asynchronously.
        mutating func consumeCommand(_ request: [String: Any], at now: Date) -> TimerOperation? {
            guard let operation = request["command"] as? String, let command = TimerOperation(rawValue: operation),
                  let expires = request["expires"] as? TimeInterval,
                  (0...4).contains(expires - now.timeIntervalSince1970),
                  request["session"] as? String == session,
                  request["revision"] as? Int == revision,
                  snapshot?.commands.contains(command) == true else { return nil }
            revision += 1
            return command
        }
    }

    /// Estimate host clock minus Watch clock from a live request. Exclude time spent processing the request.
    struct Clock {
        private var samples = [(offset: TimeInterval, delay: TimeInterval, measured: Date)]()
        private var offset: TimeInterval { samples.min { $0.delay < $1.delay }?.offset ?? 0 }

        @discardableResult
        mutating func record(sent: Date, received: Date, hostReceived: Date, hostReplied: Date) -> Bool {
            let roundTrip = received.timeIntervalSince(sent)
            let processing = hostReplied.timeIntervalSince(hostReceived)
            let delay = roundTrip - processing
            guard (0...3).contains(roundTrip), processing >= 0, delay >= -0.002 else { return false }
            let offset = (hostReceived.timeIntervalSince(sent) + hostReplied.timeIntervalSince(received)) / 2
            // Keep the lowest latency recent exchange. Disjoint offset bounds indicate a clock adjustment.
            samples.removeAll { sample in
                let age = received.timeIntervalSince(sample.measured)
                return !(0...30).contains(age) || abs(sample.offset - offset) > (sample.delay + delay) / 2 + 0.05
            }
            samples.append((offset, max(0, delay), received))
            return true
        }

        func localDate(forHostDate date: Date) -> Date { date.addingTimeInterval(-offset) }
        func hostDate(forLocalDate date: Date) -> Date { date.addingTimeInterval(offset) }
    }
}
