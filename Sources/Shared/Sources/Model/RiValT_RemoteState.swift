/*
 © Copyright 2026, The Great Rift Valley Software Company. All rights reserved.
*/

import Foundation

/// The Watch renders a sample from the host. Only the host runs a timer and advances its group.
enum RiValT_RemoteState {
    /// How often the host should confirm an unchanged countdown for the complication.
    static let complicationConfirmationInterval: TimeInterval = 15 * 60

    /// A control request the host can apply to the current timer or group.
    enum TimerOperation: String, Codable, CaseIterable {
        /// Starts the ready timer.
        case start
        /// Pauses the running countdown.
        case pause
        /// Continues a paused countdown.
        case resume
        /// Stops the current countdown.
        case stop
        /// Resets the active timer to its configured duration.
        case reset
        /// Advances to the next timer in the group.
        case fastForward
        /// Returns the host to the first timer in the group.
        case rewindGroup
    }

    /// The countdown state displayed by the host and its remotes.
    enum Phase: String, Codable {
        /// The host has no interactive timer to control.
        case unavailable
        /// The selected timer is ready to start.
        case ready
        /// The timer is running above the warning and final thresholds.
        case countdown
        /// The running timer has entered its warning phase.
        case warning
        /// The running timer has entered its final phase.
        case final
        /// The countdown is paused with time remaining.
        case paused
        /// The countdown ended and the alarm is awaiting dismissal.
        case alarm

        /// Whether the countdown is actively advancing in this phase.
        var isCounting: Bool {
            switch self {
            case .countdown, .warning, .final: return true
            default: return false
            }
        }
    }

    /// A host sample with the timing, group position, and controls needed for remote display.
    struct Snapshot: Codable {
        /// The selected timer's stable identifier, or nil when the host has no timer to show.
        let timerID: UUID?
        /// The one-based number of the active timer group.
        let groupNumber: Int
        /// The one-based position of the selected timer in its group.
        let timerNumber: Int
        /// The number of presets in the active group.
        let groupSize: Int
        /// The phase recorded when the host took the sample.
        let phase: Phase
        /// Whole seconds remaining in the active timer when the host took the sample.
        let remaining: Int
        /// The active timer's end time in the host clock, if it is counting down.
        var deadline: Date?
        /// The active timer's warning threshold in seconds remaining.
        let warning: Int
        /// The active timer's final threshold in seconds remaining.
        let final: Int
        /// The operations advertised in the host's response.
        let commands: [TimerOperation]
        /// On the Watch, identifies the specific host state the displayed controls describe.
        var stamp: String?
        /// Advertised separately so older Watches can still decode every value in the commands array.
        var canRewindGroup: Bool?
        /// Seconds in later timers included in the host's displayed countdown.
        var followingDuration: Int?
        /// The countdown that Play would start while the host editor is showing an individual preset.
        var complicationPresetTime: Int?
        /// Configured duration to display if the complication loses its host mid-countdown.
        var complicationRewindTime: Int?
        /// The host expects the active timer's deadline to start an alarm instead of another timer.
        var complicationAlarmAtDeadline: Bool?

        /// Restores the configured rewind duration when available, keeping active alarms until the host clears them.
        var rewoundForComplication: Self {
            guard phase != .alarm else { return self }
            // Older hosts only supplied the configured duration while the timer was ready.
            let preset = complicationRewindTime ?? complicationPresetTime ?? (phase == .ready ? remaining + (followingDuration ?? 0) : nil)
            return Self(timerID: timerID, groupNumber: groupNumber, timerNumber: timerNumber, groupSize: groupSize,
                        phase: timerID != nil && preset != nil ? .ready : .unavailable, remaining: preset ?? 0, deadline: nil,
                        warning: warning, final: final, commands: [], complicationRewindTime: preset)
        }

        /// Checks the advertised commands and the separately negotiated group rewind capability.
        func supports(_ operation: TimerOperation) -> Bool {
            operation == .rewindGroup ? canRewindGroup == true : commands.contains(operation)
        }

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

        /// Returns whole seconds left on the displayed countdown, including any following timers.
        func displayRemaining(at date: Date) -> Int {
            guard let displayDeadline else { return remaining + (followingDuration ?? 0) }
            return max(0, Int(ceil(displayDeadline.timeIntervalSince(date))))
        }

        /// Uses the complication's configured ready duration when available and the live display otherwise.
        func complicationRemaining(at date: Date) -> Int {
            if phase == .ready, let complicationPresetTime { return complicationPresetTime }
            return displayRemaining(at: date)
        }

        /// Advances through the warning and final thresholds using the active timer's deadline.
        ///
        /// At zero, it holds the last host phase until the host reports whether the timer advanced or raised an alarm.
        func phase(at date: Date) -> Phase {
            guard phase.isCounting, deadline != nil else { return phase }
            let seconds = remaining(at: date)
            // Only the host can decide whether reaching zero advances the group or raises an alarm.
            guard seconds > 0 else { return phase }
            if seconds <= final { return .final }
            if seconds <= warning { return .warning }
            return .countdown
        }

        /// Shows a scheduled alarm on the face while the Watch awaits the host's next sample.
        func complicationPhase(at date: Date) -> Phase {
            if complicationAlarmAtDeadline == true, timerID != nil, (followingDuration ?? 0) == 0,
               let end = displayDeadline, date >= end { return .alarm }
            return phase(at: date)
        }

        /// Continuous ticks share a command revision. A seek, restart, selection or control change invalidates it.
        func representsSameControlState(as other: Self) -> Bool {
            timerID == other.timerID && groupNumber == other.groupNumber && timerNumber == other.timerNumber
                && groupSize == other.groupSize && commands == other.commands && canRewindGroup == other.canRewindGroup && warning == other.warning
                && final == other.final && deadline == other.deadline
                && (followingDuration ?? 0) == (other.followingDuration ?? 0)
                && complicationPresetTime == other.complicationPresetTime
                && complicationRewindTime == other.complicationRewindTime
                && (complicationAlarmAtDeadline == true) == (other.complicationAlarmAtDeadline == true)
                && (deadline != nil && phase.isCounting && other.phase.isCounting || (phase == other.phase && remaining == other.remaining))
        }
    }
}

extension RiValT_RemoteState {
    /// Each command names the host process and the control state the wearer saw.
    struct Host {
        /// A fresh identifier for this host process that invalidates commands from an earlier session.
        let session = UUID().uuidString
        /// The current command revision, incremented on control changes and accepted requests.
        private(set) var revision = 0
        /// The latest snapshot used to validate a remote command.
        private var snapshot: Snapshot?

        /// Records a sample and advances the revision when the available controls or their target change.
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
                  snapshot?.supports(command) == true else { return nil }
            revision += 1
            return command
        }
    }

    /// Estimate host clock minus Watch clock from a live request. Exclude time spent processing the request.
    struct Clock {
        /// Recent clock offset estimates with their network delay and local measurement time.
        private var samples = [(offset: TimeInterval, delay: TimeInterval, measured: Date)]()
        /// The offset from the lowest-latency sample, or zero before a valid exchange.
        private var offset: TimeInterval { samples.min { $0.delay < $1.delay }?.offset ?? 0 }

        /// Records a valid request/reply exchange and discards outdated or inconsistent estimates.
        ///
        /// - Returns: Whether the exchange supplied a usable clock sample.
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

        /// Converts a time measured on the host clock to the Watch clock.
        func localDate(forHostDate date: Date) -> Date { date.addingTimeInterval(-offset) }
        /// Converts a time measured on the Watch clock to the host clock.
        func hostDate(forLocalDate date: Date) -> Date { date.addingTimeInterval(offset) }
    }
}
