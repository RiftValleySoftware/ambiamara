/*
 © Copyright 2018-2026, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_PersistentPrefs
import RVS_Generic_Swift_Toolbox

/* ###################################################################################################################################### */
// MARK: - Persistent Settings Class -
/* ###################################################################################################################################### */
/**
 This class stores our timer settings as app persistent storage.
 */
class RiValT_Settings: RVS_PersistentPrefs {
    /* ################################################################################################################################## */
    // MARK: RVS_PersistentPrefs Conformance
    /* ################################################################################################################################## */
    /// This is an enumeration that will list the prefs keys for us.
    enum Keys: String {
        /* ############################################################## */
        /**
         The timers, stored as a Dictionary (key is the ID).
         */
        case timerModel

        /* ################################################################## */
        /**
         If this is true, then going into the running timer screen starts the timer immediately.
         If false, then it starts as paused.
         */
        case startTimerImmediately

        /* ################################################################## */
        /**
         If this is true, the running timer toolbar is displayed at the top of the screen.
         */
        case displayToolbar

        /* ################################################################## */
        /**
         If this is true, then the toolbar (if in displayToolbar mode) will fade, after a few seconds of inactivity.
         */
        case autoHideToolbar

        /* ################################################################## */
        /**
         If this is true, then tapping on a timer will immediately go to its editor.
         */
        case oneTapEditing

        /* ################################################################## */
        /// Display the combined remaining time of the running timer group.
        case combineTimers

        /* ############################################################## */
        /**
         These are all the keys, in an Array of String.
         */
        static var allKeys: [String] { [
                                        timerModel.rawValue,
                                        startTimerImmediately.rawValue,
                                        displayToolbar.rawValue,
                                        autoHideToolbar.rawValue,
                                        oneTapEditing.rawValue,
                                        combineTimers.rawValue
                                        ]
        }
    }
    
    /* ########################################################## */
    /**
     - returns: An Array of Strings, representing the URIs of the sounds avaialable for alarms.
     */
    private static var _soundCache: [String]?

    /* ########################################################## */
    /**
     - returns: An Array of Strings, representing the URIs of the sounds avaialable for transition notifications.
     */
    private static var _transitionSoundCache: [String]?

    /* ################################################################## */
    /**
     This is used as a semaphore, indicating that this is the first time the app has entered the foreground.
     */
    static var ephemeralFirstTime = false

    /* ########################################################## */
    /**
     - returns: An Array of Strings, representing the URIs of the sounds avaialable for alarms.
     */
    class var soundURIs: [String] {
        let ret = self._soundCache ?? Bundle.main.paths(forResourcesOfType: "mp3", inDirectory: "Alarms").map { $0.urlEncodedString ?? "" }.sorted { a, b in
            if let soundA = URL(string: a.urlEncodedString ?? "")?.lastPathComponent.localizedVariant,
               let soundB = URL(string: b.urlEncodedString ?? "")?.lastPathComponent.localizedVariant {
                return soundA < soundB
            } else { return false }
        }
        
        #if DEBUG
            print("Alarm Sounds: \(ret.compactMap { URL(string: $0.urlEncodedString ?? "")?.lastPathComponent.localizedVariant })")
        #endif
        self._soundCache = ret
        
        return ret
    }
    
    /* ########################################################## */
    /**
     - returns: An Array of Strings, representing the URIs of the sounds avaialable for transition notifications.
     */
    class var transitionSoundURIs: [String] {
        let ret = self._transitionSoundCache ?? Bundle.main.paths(forResourcesOfType: "mp3", inDirectory: "Sounds").map { $0.urlEncodedString ?? "" }.sorted { a, b in
            if let soundA = URL(string: a.urlEncodedString ?? "")?.lastPathComponent.localizedVariant,
               let soundB = URL(string: b.urlEncodedString ?? "")?.lastPathComponent.localizedVariant {
                return soundA < soundB
            } else { return false }
        }
        
        #if DEBUG
            print("Transition Sounds: \(ret.compactMap { URL(string: $0.urlEncodedString ?? "")?.lastPathComponent.localizedVariant })")
        #endif
        self._transitionSoundCache = ret
        
        return ret
    }

    /* ################################################################## */
    /**
     If this is true, then going into the running timer screen starts the timer immediately.
     If false, then it starts as paused.
     */
    var startTimerImmediately: Bool {
        get { 0 != (values[Keys.startTimerImmediately.rawValue] as? Int ?? 1) }
        set { values[Keys.startTimerImmediately.rawValue] = newValue ? 1 : 0 }
    }

    /* ################################################################## */
    /**
     If this is true, then the toolbar is shown at the top of the running timer.
     */
    var displayToolbar: Bool {
        get {
            guard !ProcessInfo().isMacCatalystApp else { return true }
            return 0 != (values[Keys.displayToolbar.rawValue] as? Int ?? 1)
        }
        set { values[Keys.displayToolbar.rawValue] = newValue ? 1 : 0 }
    }

    /* ################################################################## */
    /**
     If this is true, then the toolbar (if in displayToolbar mode) will fade, after a few seconds of inactivity.
     */
    var autoHideToolbar: Bool {
        get {
            guard !ProcessInfo().isMacCatalystApp else { return false }
            return 0 != (values[Keys.autoHideToolbar.rawValue] as? Int ?? 1)
        }
        set { values[Keys.autoHideToolbar.rawValue] = newValue ? 1 : 0 }
    }

    /* ################################################################## */
    /**
     If this is true (default), then tapping on any timer, will open its editor.
     */
    var oneTapEditing: Bool {
        get { 0 != (values[Keys.oneTapEditing.rawValue] as? Int ?? 1) }
        set { values[Keys.oneTapEditing.rawValue] = newValue ? 1 : 0 }
    }

    /* ################################################################## */
    /// Display the combined remaining time of the running timer group. Defaults to true.
    var combineTimers: Bool {
        get { 0 != (values[Keys.combineTimers.rawValue] as? Int ?? 1) }
        set { values[Keys.combineTimers.rawValue] = newValue ? 1 : 0 }
    }
    
    /* ################################################################## */
    /**
     The keys (for determining storage).
     */
    override var keys: [String] { Keys.allKeys }

    /* ################################################################## */
    /**
     The timers, stored as a Dictionary (key is the ID).
     */
    var timerModel: [[[String: any Hashable]]] {
        get {
            let rawValues = self.values[Keys.timerModel.rawValue] as? [[NSDictionary]] ?? []
            var groups = [[[String: any Hashable]]]()
            rawValues.forEach { inGroup in
                var groupTemp = [[String: any Hashable]]()
                inGroup.forEach { inTimer in
                    var timerTemp = [String: any Hashable]()
                    inTimer.forEach { inKey, inValue in
                        if let key = inKey as? String,
                           let value = inValue as? any Hashable {
                            timerTemp[key] = value
                        }
                    }
                    groupTemp.append(timerTemp)
                }
                groups.append(groupTemp)
            }
            return groups
        }
        set { self.values[Keys.timerModel.rawValue] = newValue }
    }
}

extension RiValT_Settings {
    /// Captures the current behavior preferences and the supplied timer model in a portable backup.
    func timerBackup(for model: TimerModel) throws -> RiValT_TimerBackup {
        let preferences = RiValT_TimerBackup.Preferences(startTimerImmediately: startTimerImmediately,
                                                        displayToolbar: displayToolbar,
                                                        autoHideToolbar: autoHideToolbar,
                                                        oneTapEditing: oneTapEditing,
                                                        combineTimers: combineTimers)
        guard lastError == nil else { throw RiValT_TimerBackup.BackupError.settingsUnavailable }
        return RiValT_TimerBackup(model: model, preferences: preferences)
    }

    /// Persists the backed-up preferences and presets, then stops the previous timers and replaces the live model.
    func restoreTimerBackup(_ backup: RiValT_TimerBackup, into model: TimerModel) throws {
        let preferences = backup.preferences
        let timerValues = backup.persistentTimerModel
        values = [
            Keys.timerModel.rawValue: timerValues,
            Keys.startTimerImmediately.rawValue: preferences.startTimerImmediately ? 1 : 0,
            Keys.displayToolbar.rawValue: preferences.displayToolbar ? 1 : 0,
            Keys.autoHideToolbar.rawValue: preferences.autoHideToolbar ? 1 : 0,
            Keys.oneTapEditing.rawValue: preferences.oneTapEditing ? 1 : 0,
            Keys.combineTimers.rawValue: preferences.combineTimers ? 1 : 0
        ]
        guard lastError == nil else { throw RiValT_TimerBackup.BackupError.settingsUnavailable }

        model.allTimers.forEach { $0.stop() }
        model.asArray = timerValues
    }
}
