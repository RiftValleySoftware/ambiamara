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
    enum BackupError: Error {
        case invalidSetup
        case unsupportedVersion
        case settingsUnavailable
    }

    struct Preferences: Codable, Equatable {
        let startTimerImmediately: Bool
        let displayToolbar: Bool
        let autoHideToolbar: Bool
        let oneTapEditing: Bool
        let combineTimers: Bool
    }

    private struct Header: Decodable {
        let version: Int
    }

    private struct Group: Codable {
        enum AlarmMode: String, Codable {
            case none, vibrate, sound, soundVibrate
        }

        let id: UUID
        let displayType: String
        let alarmMode: AlarmMode
        let alarmFilename: String?
        let transitionSoundFilename: String?
        let timers: [Preset]

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
        private static func soundFilename(_ value: String) -> String {
            URL(string: value)?.lastPathComponent ?? value
        }

        var isValid: Bool {
            let needsAlarmFile = alarmMode == .sound || alarmMode == .soundVibrate
            return (1...TimerGroup.maxTimersInGroup).contains(timers.count)
                && TimerGroup.DisplayType(rawValue: displayType) != nil
                && needsAlarmFile == (alarmFilename != nil)
                && [alarmFilename, transitionSoundFilename].compactMap { $0 }.allSatisfy(Self.isFilename)
                && timers.allSatisfy(\.isValid)
        }

        private static func isFilename(_ value: String) -> Bool {
            !value.isEmpty && value != "." && value != ".." && !value.contains("/") && !value.contains("\\")
        }

        var persistentValues: [String: any Hashable] {
            var values: [String: any Hashable] = ["id": id.uuidString,
                                                  "displayType": displayType,
                                                  "soundTypeString": alarmMode.rawValue]
            values["mainSoundFileName"] = alarmFilename
            values["transitionSoundFilename"] = transitionSoundFilename
            return values
        }
    }

    private struct Preset: Codable {
        let id: UUID
        let duration: Int
        let warning: Int
        let final: Int

        init(_ timer: Timer) {
            id = timer.id
            duration = timer.startingTimeInSeconds
            warning = timer.warningTimeInSeconds
            final = timer.finalTimeInSeconds
        }

        var isValid: Bool {
            let finalLimit = warning > 0 ? warning : duration
            return (0...86_399).contains(duration)
                && (warning == 0 || (0..<duration).contains(warning))
                && (final == 0 || (0..<finalLimit).contains(final))
        }

        func persistentValues(selected: Bool) -> [String: any Hashable] {
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

    static let typeIdentifier = "com.riftvalleysoftware.rivalt.timer-backup"
    static let fileExtension = "rivaltbackup"
    private static let currentVersion = 1

    private let version: Int
    let exportedAt: Date
    let preferences: Preferences
    private let selectedTimerID: UUID?
    private let groups: [Group]

    var groupCount: Int { groups.count }
    var timerCount: Int { groups.reduce(0) { $0 + $1.timers.count } }

    init(model: TimerModel, preferences: Preferences) {
        version = Self.currentVersion
        exportedAt = .now
        self.preferences = preferences
        selectedTimerID = model.selectedTimer?.id
        groups = model.map(Group.init)
    }

    func encoded() throws -> Data {
        try validate()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(self)
    }

    static func decode(_ data: Data) throws -> Self {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let header = try decoder.decode(Header.self, from: data)
        guard header.version == currentVersion else { throw BackupError.unsupportedVersion }
        let backup = try decoder.decode(Self.self, from: data)
        try backup.validate()
        return backup
    }

    var persistentTimerModel: [[[String: any Hashable]]] {
        groups.map { group in
            [group.persistentValues] + group.timers.map { $0.persistentValues(selected: $0.id == selectedTimerID) }
        }
    }

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
