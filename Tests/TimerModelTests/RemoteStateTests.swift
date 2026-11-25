/*
 © Copyright 2026, The Great Rift Valley Software Company. All rights reserved.
 */

import XCTest

final class RemoteStateTests: XCTestCase {
    private typealias Remote = RiValT_RemoteState
    private let timerID = UUID()
    private let deadline = Date(timeIntervalSinceReferenceDate: 1_000)

    private func sample(id: UUID? = nil, phase: Remote.Phase = .countdown, remaining: Int = 12,
                        deadline: Date? = nil, commands: [Remote.TimerOperation] = [.pause, .stop]) -> Remote.Snapshot {
        Remote.Snapshot(timerID: id ?? timerID, groupNumber: 1, timerNumber: 1, groupSize: 3,
                        phase: phase, remaining: remaining, deadline: deadline, warning: 8, final: 3, commands: commands)
    }

    func testDelayedSnapshotMatchesHostSecondAndThresholds() {
        let state = sample(deadline: deadline)
        // The host sent 12. Even if it arrives later, the Watch uses the host's original deadline.
        for (secondsLeft, expectedSecond, phase): (Double, Int, Remote.Phase) in [
            (9.01, 10, .countdown), (8.01, 9, .countdown), (8, 8, .warning),
            (3.01, 4, .warning), (3, 3, .final), (0.01, 1, .final)
        ] {
            let instant = deadline.addingTimeInterval(-secondsLeft)
            XCTAssertEqual(state.remaining(at: instant), expectedSecond)
            XCTAssertEqual(state.phase(at: instant), phase)
        }
        let afterExpiry = deadline.addingTimeInterval(10)
        XCTAssertEqual(state.remaining(at: afterExpiry), 0)
        XCTAssertNotEqual(state.phase(at: afterExpiry), .alarm, "Only the host knows whether the next timer started.")
    }

    func testOnlyHostCanResumePausedTimer() {
        let paused = sample(phase: .paused, remaining: 5, commands: [.resume, .stop])
        let minutesLater = deadline.addingTimeInterval(600)
        XCTAssertEqual(paused.remaining(at: minutesLater), 5)
        XCTAssertEqual(paused.phase(at: minutesLater), .paused)
    }

    func testControlRevisionSurvivesTicksButChangesWhenCommandMeaningChanges() {
        let original = sample(deadline: deadline)
        XCTAssertTrue(original.representsSameControlState(as: sample(phase: .final, remaining: 2, deadline: deadline)))
        XCTAssertFalse(original.representsSameControlState(as: sample(id: UUID(), deadline: deadline)))
        XCTAssertFalse(original.representsSameControlState(as: sample(deadline: deadline.addingTimeInterval(1))))
        XCTAssertFalse(original.representsSameControlState(as: sample(phase: .paused, remaining: 8, commands: [.resume, .stop])))
        let paused = sample(phase: .paused, remaining: 8, commands: [.resume, .stop])
        XCTAssertFalse(paused.representsSameControlState(as: sample(phase: .paused, remaining: 7, commands: [.resume, .stop])))
    }

    private func pauseRequest(for host: Remote.Host) -> [String: Any] {
        ["session": host.session, "revision": host.revision, "command": "pause",
         "expires": deadline.addingTimeInterval(3).timeIntervalSince1970]
    }

    func testDuplicateCommandCannotPauseAgainAfterResume() {
        var host = Remote.Host()
        let running = sample(deadline: deadline.addingTimeInterval(12))
        host.update(running)
        let command = pauseRequest(for: host)
        XCTAssertEqual(host.consumeCommand(command, at: deadline), .pause)
        // Re-delivery before the UI switches to paused must also be harmless.
        XCTAssertNil(host.consumeCommand(command, at: deadline))
        host.update(sample(phase: .paused, remaining: 12, commands: [.resume, .stop]))
        host.update(running)
        XCTAssertNil(host.consumeCommand(command, at: deadline))
        XCTAssertEqual(host.consumeCommand(pauseRequest(for: host), at: deadline), .pause)
    }

    func testLateWrongHostAndOutOfOrderCommandsAreIgnored() {
        var host = Remote.Host()
        let running = sample(deadline: deadline.addingTimeInterval(12))
        host.update(running)
        let command = pauseRequest(for: host)
        XCTAssertNil(host.consumeCommand(command, at: deadline.addingTimeInterval(4)))

        var restarted = Remote.Host()
        restarted.update(running)
        XCTAssertEqual(host.revision, restarted.revision)
        XCTAssertNil(restarted.consumeCommand(command, at: deadline))

        host.update(sample(id: UUID(), deadline: deadline.addingTimeInterval(12)))
        XCTAssertNil(host.consumeCommand(command, at: deadline))
        let fresh = pauseRequest(for: host)
        var unavailableAction = fresh
        unavailableAction["command"] = "resume"
        XCTAssertNil(host.consumeCommand(unavailableAction, at: deadline))
        XCTAssertEqual(host.consumeCommand(fresh, at: deadline), .pause)
    }

    func testClockCompensatesForSkewProcessingAndVariableTransit() {
        var clock = Remote.Clock()
        let sent = Date(timeIntervalSinceReferenceDate: 5_000)
        // Host clock is 120 seconds ahead. Both legs take 0.125s and the host spends 0.25s handling the request.
        XCTAssertTrue(clock.record(sent: sent, received: sent.addingTimeInterval(0.5),
                                   hostReceived: sent.addingTimeInterval(120.125), hostReplied: sent.addingTimeInterval(120.375)))
        let hostDeadline = sent.addingTimeInterval(130)
        XCTAssertEqual(clock.localDate(forHostDate: hostDeadline), sent.addingTimeInterval(10))
        XCTAssertEqual(clock.hostDate(forLocalDate: sent), sent.addingTimeInterval(120))

        // A slower, asymmetric sample must not move the displayed countdown.
        let nextRequest = sent.addingTimeInterval(1)
        _ = clock.record(sent: nextRequest, received: nextRequest.addingTimeInterval(0.625),
                         hostReceived: nextRequest.addingTimeInterval(120.0625), hostReplied: nextRequest.addingTimeInterval(120.0625))
        XCTAssertEqual(clock.localDate(forHostDate: hostDeadline), sent.addingTimeInterval(10))
    }

    func testInvalidClockMeasurementPreservesLastCalibration() {
        var clock = Remote.Clock()
        let sent = Date(timeIntervalSinceReferenceDate: 5_000)
        let hostTime = sent.addingTimeInterval(-20)
        XCTAssertTrue(clock.record(sent: sent, received: sent.addingTimeInterval(0.25),
                                   hostReceived: hostTime.addingTimeInterval(0.125), hostReplied: hostTime.addingTimeInterval(0.125)))
        XCTAssertFalse(clock.record(sent: sent, received: sent.addingTimeInterval(-1),
                                    hostReceived: hostTime, hostReplied: hostTime))
        XCTAssertEqual(clock.localDate(forHostDate: hostTime), sent)
    }
}
