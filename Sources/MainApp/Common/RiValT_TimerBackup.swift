/*
 © Copyright 2018-2026, The Great Rift Valley Software Company. All rights reserved.

 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.

 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import Foundation

/// The file format for a portable snapshot of the timer setup.
struct RiValT_TimerBackup: Codable {
    /// Failures specific to validating or restoring a timer backup.
    enum BackupError: Error {
        /// A group, preset, identifier, or selected timer violates the backup format.
        case invalidSetup
        /// The file uses a format version this build cannot read.
        case unsupportedVersion
        /// The app could not access the persistent settings needed for the backup.
        case settingsUnavailable
    }

    /// App-wide behavior preferences saved alongside the timer groups.
    struct Preferences: Codable, Equatable {
        /// Whether opening a timer starts it immediately.
        let startTimerImmediately: Bool
        /// Whether the running timer shows its controls in a toolbar.
        let displayToolbar: Bool
        /// Whether the running timer toolbar hides after inactivity.
        let autoHideToolbar: Bool
        /// Whether a single tap opens a preset for editing.
        let oneTapEditing: Bool
        /// Whether the running display counts down the selected timer and the timers that follow it.
        let combineTimers: Bool
    }

    /// The version field read before decoding the version-specific payload.
    private struct Header: Decodable {
        /// The backup schema version advertised by the file.
        let version: Int
    }

    /// The portable representation of a timer group and its presentation settings.
    private struct Group: Codable {
        /// The group's alarm behavior, encoded independently of the sound file.
        enum AlarmMode: String, Codable {
            /// The alarm produces neither sound nor vibration.
            case none
            /// The alarm vibrates on devices that support it.
            case vibrate
            /// The alarm plays the group's selected sound.
            case sound
            /// The alarm plays the selected sound and vibrates on supported devices.
            case soundVibrate
        }

        /// The stable identifier of the timer group.
        let id: UUID
        /// The raw value of the group's countdown display style.
        let displayType: String
        /// The output to use when a timer reaches its alarm.
        let alarmMode: AlarmMode
        /// The bundled alarm filename for sound-based alarm modes.
        let alarmFilename: String?
        /// The bundled filename played when advancing to the next timer.
        let transitionSoundFilename: String?
        /// The timer presets in their original order within the group.
        let timers: [Preset]

        /// Copies the presentation settings and ordered presets from a live timer group.
        init(_ group: TimerGroup) {
            id = group.id
            displayType = group.displayType.rawValue
            transitionSoundFilename = group.transitionSoundFilename.map(Self.soundFilename)
            timers = group.map(Preset.init)

            switch group.soundType {
            case .none:
                alarmMode = .none
                alarmFilename = nil
            case .vibrate:
                alarmMode = .vibrate
                alarmFilename = nil
            case .sound(let filename):
                alarmMode = .sound
                alarmFilename = Self.soundFilename(filename)
            case .soundVibrate(let filename):
                alarmMode = .soundVibrate
                alarmFilename = Self.soundFilename(filename)
            }
        }

        // A sound selected in the current session can still hold its full bundle path.
        /// Extracts the bundle-relative filename from a stored sound URL.
        private static func soundFilename(_ value: String) -> String {
            URL(string: value)?.lastPathComponent ?? value
        }

        /// Whether the group has a supported display style, alarm configuration, and valid presets.
        var isValid: Bool {
            let needsAlarmFile = alarmMode == .sound || alarmMode == .soundVibrate
            return (1...TimerGroup.maxTimersInGroup).contains(timers.count)
                && TimerGroup.DisplayType(rawValue: displayType) != nil
                && needsAlarmFile == (alarmFilename != nil)
                && [alarmFilename, transitionSoundFilename].compactMap { $0 }.allSatisfy(Self.isFilename)
                && timers.allSatisfy(\.isValid)
        }

        /// Checks that a sound reference is a single filename.
        private static func isFilename(_ value: String) -> Bool {
            !value.isEmpty && value != "." && value != ".." && !value.contains("/") && !value.contains("\\")
        }

        /// Converts the group metadata to the keys understood by the app's settings serializer.
        var persistentValues: [String: any Hashable] {
            var values: [String: any Hashable] = ["id": id.uuidString,
                                                  "displayType": displayType,
                                                  "soundTypeString": alarmMode.rawValue]
            values["mainSoundFileName"] = alarmFilename
            values["transitionSoundFilename"] = transitionSoundFilename
            return values
        }
    }

    /// A timer's configured durations without its runtime countdown state.
    private struct Preset: Codable {
        /// The stable identifier used to restore the original selection.
        let id: UUID
        /// The preset's full duration in seconds.
        let duration: Int
        /// The seconds remaining at the warning threshold, or zero when disabled.
        let warning: Int
        /// The seconds remaining at the final threshold, or zero when disabled.
        let final: Int

        /// Copies the configured durations from the live timer.
        init(_ timer: Timer) {
            id = timer.id
            duration = timer.startingTimeInSeconds
            warning = timer.warningTimeInSeconds
            final = timer.finalTimeInSeconds
        }

        /// Whether the durations fit in one day and the enabled phase thresholds descend toward zero.
        var isValid: Bool {
            let finalLimit = warning > 0 ? warning : duration
            return (0...86_399).contains(duration)
                && (warning == 0 || (0..<duration).contains(warning))
                && (final == 0 || (0..<finalLimit).contains(final))
        }

        /// Builds the app's persisted timer record with a stopped countdown.
        ///
        /// - Parameter selected: Whether to restore this preset as the selected timer.
        func persistentValues(selected: Bool) -> [String: any Hashable] {
            /// The timer engine keys used by the local settings serializer.
            typealias Key = TimerEngine.CodingKeys
            return [Key.id.rawValue: id.uuidString,
                    Key.startingTimeInSeconds.rawValue: duration,
                    Key.warningTimeInSeconds.rawValue: warning,
                    Key.finalTimeInSeconds.rawValue: final,
                    // The local serializer needs a start time even for a stopped preset.
                    Key.startTime.rawValue: 0.0,
                    Key.lastMode.rawValue: "stopped",
                    "isSelected": selected]
        }
    }

    /// The stable identifier shared by current and earlier timer backup files.
    static let typeIdentifier = "com.riftvalleysoftware.rivalt.timer-backup"
    /// The filename extension for exported backup files.
    static let fileExtension = "rvtbackup"
    /// The schema version written and accepted by this build.
    private static let currentVersion = 1

    /// The schema version stored in this backup.
    private let version: Int
    /// The date and time the backup was created.
    let exportedAt: Date
    /// The app-wide behavior preferences recorded at export.
    let preferences: Preferences
    /// The selected preset's identifier, if a timer was selected.
    private let selectedTimerID: UUID?
    /// The backed-up groups in their original order.
    private let groups: [Group]

    /// The number of timer groups in the backup.
    var groupCount: Int { groups.count }
    /// The total number of presets across all groups.
    var timerCount: Int { groups.reduce(0) { $0 + $1.timers.count } }

    /// Captures the ordered timer groups and selection along with the supplied preferences.
    init(model: TimerModel, preferences: Preferences) {
        version = Self.currentVersion
        exportedAt = .now
        self.preferences = preferences
        selectedTimerID = model.selectedTimer?.id
        groups = model.map(Group.init)
    }

    /// Validates the backup and encodes it as legible JSON with ISO 8601 dates.
    func encoded() throws -> Data {
        try validate()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(self)
    }

    /// Reads the schema version first, then decodes and validates the backup.
    static func decode(_ data: Data) throws -> Self {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let header = try decoder.decode(Header.self, from: data)
        guard header.version == currentVersion else { throw BackupError.unsupportedVersion }
        let backup = try decoder.decode(Self.self, from: data)
        try backup.validate()
        return backup
    }

    /// Converts the groups and presets to the app's persisted timer model format.
    var persistentTimerModel: [[[String: any Hashable]]] {
        groups.map { group in
            [group.persistentValues] + group.timers.map { $0.persistentValues(selected: $0.id == selectedTimerID) }
        }
    }

    /// Rejects invalid groups, duplicate IDs, and a selected timer ID that is absent from the backup.
    private func validate() throws {
        let timerIDs = groups.flatMap { $0.timers.map(\.id) }
        let uniqueTimerIDs = Set(timerIDs)
        guard !groups.isEmpty, groups.allSatisfy(\.isValid),
              Set(groups.map(\.id)).count == groups.count,
              uniqueTimerIDs.count == timerIDs.count,
              selectedTimerID.map(uniqueTimerIDs.contains) ?? true
        else { throw BackupError.invalidSetup }
    }
}
