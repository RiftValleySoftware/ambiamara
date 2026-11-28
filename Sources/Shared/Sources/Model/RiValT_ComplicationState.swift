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
    /// The WidgetKit kind shared by the complication and its timeline reload requests.
    static let kind = "Rift_Valley_Timer_Complications"
    /// The expected interval between phone confirmations of an unchanged countdown.
    static let confirmationInterval = RiValT_RemoteState.complicationConfirmationInterval
    /// The storage key for the encoded timer sample.
    private static let recordKey = "complication.timer"
    /// The storage key identifying the host selected for the complication.
    private static let sourceKey = "complication.source"
    /// The storage key for the host-time cutoff after a disconnect.
    private static let disconnectedAtKey = "complication.disconnectedAt"
    /// The app group preferences shared by the Watch app and complication.
    private static var defaults: UserDefaults? { UserDefaults(suiteName: "group.rvs.ambiamara") }

    /// The latest timer sample for the selected host and its timeline confirmation.
    struct Record: Codable {
        /// The last saved host snapshot with a Watch-local deadline.
        let snapshot: RiValT_RemoteState.Snapshot
        /// The host timestamp used to reject out-of-order samples.
        let updatedAt: Date
        /// The phone or iPad source that supplied the sample.
        let source: String
        /// Watch-local time of the host sample that last renewed the installed countdown timeline.
        var confirmedAt: Date?

        /// The Watch time when a countdown without a newer confirmation reverts to its preset.
        var rewindDate: Date? { confirmedAt?.addingTimeInterval(2 * confirmationInterval) }

        /// Returns the stored sample or its ready display once its confirmation expires.
        func snapshot(at date: Date) -> RiValT_RemoteState.Snapshot {
            if let rewindDate, date >= rewindDate { return snapshot.rewoundForComplication }
            return snapshot
        }
    }

    /// Reads the current source's sample and rewinds it if it predates the disconnect cutoff.
    static func read(from storage: UserDefaults? = defaults) -> Record? {
        guard let defaults = storage, let data = defaults.data(forKey: recordKey),
              let record = try? PropertyListDecoder().decode(Record.self, from: data),
              record.source == (defaults.string(forKey: sourceKey) ?? "phone") else { return nil }
        if let cutoff = defaults.object(forKey: disconnectedAtKey) as? Date, record.updatedAt <= cutoff {
            return Record(snapshot: record.snapshot.rewoundForComplication, updatedAt: record.updatedAt, source: record.source)
        }
        return record
    }

    /// Changing hosts must never leave the previous device's timer on the face.
    static func selectSource(_ source: String, in storage: UserDefaults? = defaults) {
        guard let defaults = storage, (defaults.string(forKey: sourceKey) ?? "phone") != source else { return }
        defaults.removeObject(forKey: recordKey)
        defaults.removeObject(forKey: disconnectedAtKey)
        defaults.set(source, forKey: sourceKey)
        reload()
    }

    /// Keep delayed background deliveries from restarting a countdown that has already lost its host.
    static func rewind(source: String, at hostDate: Date, in storage: UserDefaults? = defaults) {
        guard let defaults = storage, (defaults.string(forKey: sourceKey) ?? "phone") == source else { return }
        let previous = read(from: defaults)
        let cutoff = max(hostDate, previous?.updatedAt ?? hostDate)
        if let oldCutoff = defaults.object(forKey: disconnectedAtKey) as? Date, oldCutoff >= cutoff { return }
        defaults.set(cutoff, forKey: disconnectedAtKey)
        if let state = previous?.snapshot, !state.representsSameControlState(as: state.rewoundForComplication) { reload() }
    }

    /// Stores a current-source sample and requests a timeline reload when display state or confirmation changes.
    /// A confirmed live response clears the disconnect cutoff.
    static func save(_ snapshot: RiValT_RemoteState.Snapshot, updatedAt: Date, source: String, confirmed: Bool = false,
                     localSampleDate: Date? = nil, in storage: UserDefaults? = defaults) {
        guard let defaults = storage, (defaults.string(forKey: sourceKey) ?? "phone") == source else { return }
        var snapshot = snapshot
        // Only the paired phone confirms the installed countdown while the Watch app is suspended.
        if source != "phone" { snapshot.complicationAlarmAtDeadline = nil }
        let previous = read(from: defaults)
        // A delayed background context must not replace a newer live request/reply.
        guard previous.map({ $0.updatedAt < updatedAt || (confirmed && $0.updatedAt == updatedAt) }) ?? true else { return }
        let cutoff = confirmed ? nil : defaults.object(forKey: disconnectedAtKey) as? Date
        var comparison = cutoff.map { updatedAt <= $0 } == true ? snapshot.rewoundForComplication : snapshot
        if let oldDeadline = previous?.snapshot.deadline, let newDeadline = comparison.deadline,
           abs(oldDeadline.timeIntervalSince(newDeadline)) < 0.1 {
            // Small clock-calibration changes must not consume WidgetKit's reload budget on every poll.
            comparison.deadline = oldDeadline
        }
        let stateChanged = previous?.snapshot.representsSameControlState(as: comparison) != true
        var confirmation: Date?
        if source == "phone", comparison.displayDeadline != nil, comparison.complicationRewindTime != nil {
            let sampleDate = localSampleDate ?? updatedAt
            if !stateChanged, let previousDate = previous?.confirmedAt, sampleDate.timeIntervalSince(previousDate) < confirmationInterval {
                confirmation = previousDate
            } else {
                confirmation = sampleDate
            }
        }
        let record = Record(snapshot: snapshot, updatedAt: updatedAt, source: source, confirmedAt: confirmation)
        guard let data = try? PropertyListEncoder().encode(record) else { return }
        defaults.set(data, forKey: recordKey)
        if confirmed { defaults.removeObject(forKey: disconnectedAtKey) }
        if stateChanged || previous?.confirmedAt != confirmation { reload() }
    }

    /// Requests new timelines for the RVT complication on watchOS.
    private static func reload() {
        #if os(watchOS)
        WidgetCenter.shared.reloadTimelines(ofKind: kind)
        #endif
    }

    /// Formats a nonnegative duration as minutes and seconds, adding hours when needed.
    static func clockText(_ seconds: Int) -> String {
        let value = max(0, seconds)
        if value >= 3600 {
            return String(format: "%d:%02d:%02d", value / 3600, value / 60 % 60, value % 60)
        }
        return String(format: "%d:%02d", value / 60, value % 60)
    }
}
