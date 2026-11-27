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
        XCTAssertNotEqual(state.complicationPhase(at: afterExpiry), .alarm)
    }

    func testHostCanScheduleAnAlarmOnTheComplicationAtTheFinalDeadline() throws {
        let running = sample(deadline: deadline)
        var scheduled = running
        scheduled.complicationAlarmAtDeadline = true
        let payload = try PropertyListEncoder().encode(scheduled)
        let received = try PropertyListDecoder().decode(Remote.Snapshot.self, from: payload)

        XCTAssertFalse(received.representsSameControlState(as: running))
        XCTAssertEqual(received.complicationPhase(at: deadline.addingTimeInterval(-0.01)), .final)
        XCTAssertEqual(received.complicationPhase(at: deadline), .alarm)
        XCTAssertEqual(received.complicationRemaining(at: deadline), 0)
        XCTAssertEqual(received.complicationPhase(at: deadline.addingTimeInterval(6)), .alarm)
        XCTAssertNotEqual(received.phase(at: deadline), .alarm)

        // A combined countdown with another segment ahead must not show an alarm at this handoff.
        scheduled.followingDuration = 40
        XCTAssertNotEqual(scheduled.complicationPhase(at: deadline), .alarm)
    }

    func testOnlyHostCanResumePausedTimer() {
        let paused = sample(phase: .paused, remaining: 5, commands: [.resume, .stop])
        let minutesLater = deadline.addingTimeInterval(600)
        XCTAssertEqual(paused.remaining(at: minutesLater), 5)
        XCTAssertEqual(paused.phase(at: minutesLater), .paused)
    }

    func testCombinedReadoutKeepsWarningsAndControlsOnTheActiveTimer() {
        let segment = sample(remaining: 600, deadline: deadline)
        var combined = segment
        combined.followingDuration = 150
        XCTAssertEqual(combined.displayRemaining(at: deadline.addingTimeInterval(-600)), 750)
        let warning = deadline.addingTimeInterval(-8)
        XCTAssertEqual(combined.displayRemaining(at: warning), 158)
        XCTAssertEqual(combined.phase(at: warning), .warning)
        XCTAssertEqual(combined.phase(at: deadline.addingTimeInterval(-3)), .final)
        // The combined digits continue while the Watch waits for the host to confirm the next timer and its controls.
        let delayed = deadline.addingTimeInterval(2)
        XCTAssertEqual(combined.remaining(at: delayed), 0)
        XCTAssertEqual(combined.displayRemaining(at: deadline), 150)
        XCTAssertEqual(combined.displayRemaining(at: delayed), 148)
        XCTAssertEqual(segment.displayRemaining(at: delayed), 0)
        XCTAssertEqual(combined.displayRemaining(at: deadline.addingTimeInterval(151)), 0)
        XCTAssertFalse(combined.representsSameControlState(as: segment))
    }

    func testStationarySeekPreviewUsesTheTimeAndPhaseOnTheHost() {
        var frozen = sample(phase: .warning, remaining: 5, commands: [])
        frozen.followingDuration = 30
        XCTAssertNil(frozen.displayDeadline)
        XCTAssertEqual(frozen.displayRemaining(at: deadline.addingTimeInterval(60)), 35)
        XCTAssertEqual(frozen.phase(at: deadline), .warning)
        var moved = sample(phase: .warning, remaining: 4, commands: [])
        moved.followingDuration = 30
        XCTAssertFalse(frozen.representsSameControlState(as: moved))
    }

    func testPausedCombinedReadoutAndLegacySnapshotDecoding() throws {
        var paused = sample(phase: .paused, remaining: 47, commands: [.resume, .stop])
        let encoder = PropertyListEncoder()
        let decoder = PropertyListDecoder()
        // Older live messages and complication records omit the duration of subsequent timers.
        let legacy = try decoder.decode(Remote.Snapshot.self, from: encoder.encode(paused))
        XCTAssertNil(legacy.followingDuration)
        XCTAssertNil(legacy.complicationAlarmAtDeadline)
        XCTAssertEqual(legacy.displayRemaining(at: deadline), 47)

        paused.followingDuration = 30
        let combined = try decoder.decode(Remote.Snapshot.self, from: encoder.encode(paused))
        XCTAssertEqual(combined.displayRemaining(at: deadline.addingTimeInterval(600)), 77)
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

    func testGroupRewindRequiresAnAdvertisedCapabilityAndCurrentRevision() throws {
        var host = Remote.Host()
        var ready = sample(phase: .ready, commands: [.start, .stop])
        func rewindRequest() -> [String: Any] {
            ["command": "rewindGroup", "session": host.session, "revision": host.revision,
             "expires": deadline.addingTimeInterval(3).timeIntervalSince1970]
        }
        host.update(ready)
        XCTAssertNil(host.consumeCommand(rewindRequest(), at: deadline))

        ready.canRewindGroup = true
        let encoded = try PropertyListEncoder().encode(ready)
        let received = try PropertyListDecoder().decode(Remote.Snapshot.self, from: encoded)
        XCTAssertTrue(received.supports(.rewindGroup))
        XCTAssertEqual(received.commands, [.start, .stop])
        host.update(received)
        let request = rewindRequest()
        XCTAssertEqual(host.consumeCommand(request, at: deadline), .rewindGroup)
        XCTAssertNil(host.consumeCommand(request, at: deadline))

        let queued = rewindRequest()
        ready.canRewindGroup = nil
        host.update(ready)
        XCTAssertNil(host.consumeCommand(queued, at: deadline))
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

/// Complication state uses an isolated preferences suite, never the application's presets.
final class ComplicationStateTests: XCTestCase {
    private typealias Store = RiValT_ComplicationState

    private func withStore(_ test: (UserDefaults) throws -> Void) rethrows {
        let name = "RiValT.ComplicationTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        try test(defaults)
    }

    private func sample(_ phase: RiValT_RemoteState.Phase, seconds: Int, deadline: Date? = nil,
                        timerID: UUID = UUID()) -> RiValT_RemoteState.Snapshot {
        .init(timerID: timerID, groupNumber: 1, timerNumber: 1, groupSize: 2, phase: phase,
              remaining: seconds, deadline: deadline, warning: 60, final: 30, commands: [])
    }

    func testDelayedBackgroundDeliveryCannotReplacePausedTimer() {
        withStore { defaults in
            let now = Date()
            Store.save(sample(.paused, seconds: 47), updatedAt: now, source: "phone", in: defaults)
            Store.save(sample(.countdown, seconds: 50, deadline: now.addingTimeInterval(50)),
                       updatedAt: now.addingTimeInterval(-3), source: "phone", in: defaults)
            let result = Store.read(from: defaults)?.snapshot
            XCTAssertEqual(result?.phase, .paused)
            XCTAssertEqual(result?.remaining(at: now.addingTimeInterval(600)), 47)
        }
    }

    func testReadyComplicationUsesCombinedPresetOnlyWhenEnabled() {
        withStore { defaults in
            let now = Date()
            let individual = sample(.ready, seconds: 120)
            var combined = individual
            combined.complicationPresetTime = 150
            XCTAssertFalse(combined.representsSameControlState(as: individual))

            for source in ["phone", "ipad-test"] {
                Store.selectSource(source, in: defaults)
                Store.save(combined, updatedAt: now, source: source, in: defaults)
                let saved = Store.read(from: defaults)?.snapshot
                XCTAssertEqual(saved?.complicationRemaining(at: now), 150)
                XCTAssertEqual(saved?.displayRemaining(at: now), 120)

                Store.save(individual, updatedAt: now.addingTimeInterval(1), source: source, in: defaults)
                XCTAssertEqual(Store.read(from: defaults)?.snapshot.complicationRemaining(at: now), 120)
            }
        }
    }

    func testChangingHostsClearsOldTimerAndRejectsPhoneUpdates() {
        withStore { defaults in
            let now = Date()
            Store.save(sample(.ready, seconds: 300), updatedAt: now, source: "phone", in: defaults)
            XCTAssertEqual(Store.read(from: defaults)?.snapshot.remaining, 300)
            Store.selectSource("ipad-test", in: defaults)
            XCTAssertNil(Store.read(from: defaults))
            Store.save(sample(.ready, seconds: 600), updatedAt: now, source: "phone", in: defaults)
            XCTAssertNil(Store.read(from: defaults))
            Store.save(sample(.ready, seconds: 120), updatedAt: now, source: "ipad-test", in: defaults)
            XCTAssertEqual(Store.read(from: defaults)?.snapshot.remaining, 120)
            Store.selectSource("phone", in: defaults)
            XCTAssertNil(Store.read(from: defaults))
        }
    }

    func testCachedCountdownStopsAtZeroWithoutAdvancingGroup() {
        withStore { defaults in
            let now = Date()
            Store.save(sample(.countdown, seconds: 90, deadline: now.addingTimeInterval(90)), updatedAt: now, source: "phone", in: defaults)
            let result = Store.read(from: defaults)?.snapshot
            XCTAssertEqual(result?.remaining(at: now.addingTimeInterval(30)), 60)
            XCTAssertEqual(result?.remaining(at: now.addingTimeInterval(120)), 0)
            XCTAssertEqual(result?.complicationRemaining(at: now.addingTimeInterval(120)), 0)
            XCTAssertEqual(result?.timerNumber, 1)

            var combined = sample(.countdown, seconds: 90, deadline: now.addingTimeInterval(90))
            combined.followingDuration = 150
            Store.save(combined, updatedAt: now.addingTimeInterval(1), source: "phone", in: defaults)
            let countdown = Store.read(from: defaults)?.snapshot
            XCTAssertEqual(countdown?.complicationRemaining(at: now.addingTimeInterval(120)), 120)
            XCTAssertEqual(countdown?.complicationRemaining(at: now.addingTimeInterval(240)), 0)
        }
    }

    func testDisconnectRestoresTheConfiguredPresetAndRemovesTheLiveDeadline() {
        withStore { defaults in
            let now = Date()
            var running = sample(.countdown, seconds: 42, deadline: now.addingTimeInterval(42))
            running.followingDuration = 30
            running.complicationRewindTime = 180
            Store.save(running, updatedAt: now, source: "phone", in: defaults)
            Store.rewind(source: "ipad-test", at: now, in: defaults)
            XCTAssertEqual(Store.read(from: defaults)?.snapshot.complicationRemaining(at: now), 72)

            Store.rewind(source: "phone", at: now.addingTimeInterval(1), in: defaults)
            let stopped = Store.read(from: defaults)?.snapshot
            XCTAssertEqual(stopped?.phase, .ready)
            XCTAssertNil(stopped?.displayDeadline)
            XCTAssertEqual(stopped?.complicationRemaining(at: now.addingTimeInterval(2)), 180)
            XCTAssertEqual(stopped?.complicationRemaining(at: now.addingTimeInterval(600)), 180)
        }
    }

    func testAlarmSurvivesDisconnectUntilHostDismissesIt() {
        withStore { defaults in
            let now = Date()
            let timerID = UUID()
            var alarm = sample(.alarm, seconds: 0, timerID: timerID)
            alarm.complicationRewindTime = 180
            Store.save(alarm, updatedAt: now, source: "phone", in: defaults)

            let disconnectedAt = now.addingTimeInterval(2)
            Store.rewind(source: "phone", at: disconnectedAt, in: defaults)
            let later = now.addingTimeInterval(3 * Store.confirmationInterval)
            XCTAssertEqual(Store.read(from: defaults)?.snapshot(at: later).phase(at: later), .alarm)

            let dismissed = sample(.ready, seconds: 180, timerID: timerID)
            Store.save(dismissed, updatedAt: later, source: "phone", in: defaults)
            Store.save(alarm, updatedAt: disconnectedAt, source: "phone", in: defaults)
            XCTAssertEqual(Store.read(from: defaults)?.snapshot(at: later).phase(at: later), .ready)
        }
    }

    func testPauseAndDisconnectCancelAnOutstandingScheduledAlarm() {
        withStore { defaults in
            let now = Date()
            let deadline = now.addingTimeInterval(40)
            let timerID = UUID()
            var running = sample(.countdown, seconds: 40, deadline: deadline, timerID: timerID)
            running.complicationRewindTime = 180
            running.complicationAlarmAtDeadline = true
            Store.save(running, updatedAt: now, source: "phone", in: defaults)
            XCTAssertEqual(Store.read(from: defaults)?.snapshot(at: deadline).complicationPhase(at: deadline), .alarm)

            let paused = sample(.paused, seconds: 38, timerID: timerID)
            Store.save(paused, updatedAt: now.addingTimeInterval(2), source: "phone", in: defaults)
            Store.save(running, updatedAt: now.addingTimeInterval(1), source: "phone", in: defaults)
            XCTAssertEqual(Store.read(from: defaults)?.snapshot(at: deadline).complicationPhase(at: deadline), .paused)

            Store.save(running, updatedAt: now.addingTimeInterval(3), source: "phone", in: defaults)
            Store.rewind(source: "phone", at: now.addingTimeInterval(4), in: defaults)
            XCTAssertEqual(Store.read(from: defaults)?.snapshot(at: deadline).complicationPhase(at: deadline), .ready)

            Store.selectSource("ipad-test", in: defaults)
            Store.save(running, updatedAt: now, source: "ipad-test", in: defaults)
            XCTAssertNotEqual(Store.read(from: defaults)?.snapshot(at: deadline).complicationPhase(at: deadline), .alarm)
        }
    }

    func testDelayedContextCannotRestartCountdownAfterDisconnect() {
        withStore { defaults in
            let now = Date()
            var running = sample(.countdown, seconds: 15, deadline: now.addingTimeInterval(15))
            running.complicationRewindTime = 90
            Store.save(running, updatedAt: now, source: "phone", in: defaults)
            Store.rewind(source: "phone", at: now.addingTimeInterval(2), in: defaults)

            // This context was newer than the live sample but was sent before the disconnection.
            Store.save(running, updatedAt: now.addingTimeInterval(1), source: "phone", in: defaults)
            XCTAssertEqual(Store.read(from: defaults)?.snapshot.complicationRemaining(at: now.addingTimeInterval(5)), 90)
            XCTAssertNil(Store.read(from: defaults)?.snapshot.displayDeadline)

            Store.save(running, updatedAt: now.addingTimeInterval(6), source: "phone", in: defaults)
            XCTAssertEqual(Store.read(from: defaults)?.snapshot.complicationRemaining(at: now.addingTimeInterval(7)), 8)
        }
    }

    func testDisconnectUsesOnlyKnownPresetTimesFromOlderHosts() {
        let now = Date()
        let running = sample(.countdown, seconds: 42, deadline: now.addingTimeInterval(42))
        XCTAssertEqual(running.rewoundForComplication.phase, .unavailable)
        XCTAssertNil(running.rewoundForComplication.displayDeadline)

        var ready = sample(.ready, seconds: 120)
        ready.complicationPresetTime = 150
        XCTAssertEqual(ready.rewoundForComplication.complicationRemaining(at: now), 150)
    }

    func testUnconfirmedPhoneCountdownRewindsAndAConfirmationExtendsItsTimeline() throws {
        try withStore { defaults in
            let now = Date()
            let interval = Store.confirmationInterval
            let deadline = now.addingTimeInterval(8 * interval)
            var running = sample(.countdown, seconds: Int(8 * interval), deadline: deadline)
            running.complicationRewindTime = 10_800
            running.complicationAlarmAtDeadline = true
            Store.save(running, updatedAt: now, source: "phone", in: defaults)
            let first = try XCTUnwrap(Store.read(from: defaults))
            let firstExpiry = try XCTUnwrap(first.rewindDate)
            XCTAssertEqual(first.snapshot(at: firstExpiry.addingTimeInterval(-1)).displayDeadline, deadline)
            XCTAssertNil(first.snapshot(at: firstExpiry).displayDeadline)
            XCTAssertEqual(first.snapshot(at: firstExpiry).complicationRemaining(at: firstExpiry), 10_800)
            XCTAssertEqual(first.snapshot(at: deadline).complicationPhase(at: deadline), .ready)

            let confirmation = now.addingTimeInterval(interval + 1)
            Store.save(running, updatedAt: confirmation, source: "phone", in: defaults)
            let renewed = try XCTUnwrap(Store.read(from: defaults))
            let nextExpiry = try XCTUnwrap(renewed.rewindDate)
            XCTAssertGreaterThan(nextExpiry, firstExpiry)
            XCTAssertEqual(renewed.snapshot(at: firstExpiry).displayDeadline, deadline)
            XCTAssertEqual(renewed.snapshot(at: nextExpiry).phase, .ready)
        }
    }

    func testTimeFormattingIncludesHoursAndClampsNegativeValues() {
        XCTAssertEqual(Store.clockText(-1), "0:00")
        XCTAssertEqual(Store.clockText(0), "0:00")
        XCTAssertEqual(Store.clockText(59), "0:59")
        XCTAssertEqual(Store.clockText(300), "5:00")
        XCTAssertEqual(Store.clockText(3600), "1:00:00")
        XCTAssertEqual(Store.clockText(3661), "1:01:01")
    }
}
