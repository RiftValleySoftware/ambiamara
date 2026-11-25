/*
 © Copyright 2026, The Great Rift Valley Software Company. All rights reserved.
 This code is proprietary and is not licensed for reuse.
 */

import Foundation
#if os(watchOS)
import WidgetKit
#endif

/// A read-only copy of the chosen host's timer, shared by the Watch app and its widgets.
/// This never runs an engine or advances a timer group on the Watch.
enum RiValT_ComplicationState {
    static let kind = "Rift_Valley_Timer_Complications"
    private static let recordKey = "complication.timer"
    private static let sourceKey = "complication.source"
    private static var defaults: UserDefaults? { UserDefaults(suiteName: "group.rvs.ambiamara") }

    struct Record: Codable {
        let snapshot: RiValT_RemoteState.Snapshot
        let updatedAt: Date
        let source: String
    }

    static func read(from storage: UserDefaults? = defaults) -> Record? {
        guard let defaults = storage, let data = defaults.data(forKey: recordKey),
              let record = try? PropertyListDecoder().decode(Record.self, from: data),
              record.source == (defaults.string(forKey: sourceKey) ?? "phone") else { return nil }
        return record
    }

    /// Changing hosts must never leave the previous device's timer on the face.
    static func selectSource(_ source: String, in storage: UserDefaults? = defaults) {
        guard let defaults = storage, (defaults.string(forKey: sourceKey) ?? "phone") != source else { return }
        defaults.removeObject(forKey: recordKey)
        defaults.set(source, forKey: sourceKey)
        reload()
    }

    static func save(_ snapshot: RiValT_RemoteState.Snapshot, updatedAt: Date, source: String, in storage: UserDefaults? = defaults) {
        guard let defaults = storage, (defaults.string(forKey: sourceKey) ?? "phone") == source else { return }
        let previous = read(from: defaults)
        // A delayed background context must not replace a newer live request/reply.
        guard previous.map({ $0.updatedAt <= updatedAt }) ?? true else { return }
        let record = Record(snapshot: snapshot, updatedAt: updatedAt, source: source)
        guard let data = try? PropertyListEncoder().encode(record) else { return }
        defaults.set(data, forKey: recordKey)
        var comparison = snapshot
        if let oldDeadline = previous?.snapshot.deadline, let newDeadline = snapshot.deadline,
           abs(oldDeadline.timeIntervalSince(newDeadline)) < 0.1 {
            // Small clock-calibration changes must not consume WidgetKit's reload budget on every poll.
            comparison.deadline = oldDeadline
        }
        if previous?.snapshot.representsSameControlState(as: comparison) != true { reload() }
    }

    private static func reload() {
        #if os(watchOS)
        WidgetCenter.shared.reloadTimelines(ofKind: kind)
        #endif
    }

    static func clockText(_ seconds: Int) -> String {
        let value = max(0, seconds)
        if value >= 3600 {
            return String(format: "%d:%02d:%02d", value / 3600, value / 60 % 60, value % 60)
        }
        return String(format: "%d:%02d", value / 60, value % 60)
    }
}
