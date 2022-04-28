/*
 © Copyright 2018-2022, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_Persistent_Prefs

/* ###################################################################################################################################### */
// MARK: - Persistent Settings Class -
/* ###################################################################################################################################### */
/**
 This class stores our timer settings as app persistent storage.
 */
class RVS_AmbiaMara_Settings: RVS_PersistentPrefs {
    /* ################################################################################################################################## */
    // MARK: Individual Timer State
    /* ################################################################################################################################## */
    struct TimerSettings: Codable {
        /* ############################################################## */
        /**
         */
        let id: UUID

        /* ############################################################## */
        /**
         */
        var startTime: Int

        /* ############################################################## */
        /**
         */
        var warnTime: Int

        /* ############################################################## */
        /**
         */
        var finalTime: Int
        
        /* ############################################################## */
        /**
         */
        init(id inID: UUID = UUID(), startTime inStartTime: Int = 0, warnTime inWarnTime: Int = 0, finalTime inFinalTime: Int = 0) {
            id = inID
            startTime = inStartTime
            warnTime = inWarnTime
            finalTime = inFinalTime
        }
    }

    /* ################################################################################################################################## */
    // MARK: RVS_PersistentPrefs Conformance
    /* ################################################################################################################################## */
    /**
     This is an enumeration that will list the prefs keys for us.
     */
    enum Keys: String {
        /* ############################################################## */
        /**
         */
        case timers

        /* ############################################################## */
        /**
         */
        case currentTimerIndex

        /* ############################################################## */
        /**
         These are all the keys, in an Array of String.
         */
        static var allKeys: [String] { [
                                        timers.rawValue,
                                        currentTimerIndex.rawValue
                                        ]
        }
    }
    
    /* ################################################################## */
    /**
     */
    override var keys: [String] { Keys.allKeys }
    
    /* ################################################################## */
    /**
     */
    private var _timers: [TimerSettings] {
        get { values[Keys.timers.rawValue] as? [TimerSettings] ?? [] }
        set { values[Keys.timers.rawValue] = newValue }
    }

    /* ################################################################## */
    /**
     */
    private func _remove(timer inTimer: TimerSettings) {
        if let index = _timers.firstIndex(where: { $0.id == inTimer.id }) {
            _timers.remove(at: index)
        }
        
        if !(0..<_timers.count).contains(currentTimerIndex) {
            currentTimerIndex = max(0, min(currentTimerIndex, _timers.count - 1))
        }
    }

    /* ################################################################## */
    /**
     */
    private func _add(timer inTimer: TimerSettings) {
        guard let index = _timers.firstIndex(where: { $0.id == inTimer.id }) else {
            _timers.append(inTimer)
            currentTimerIndex = _timers.count - 1
            return
        }
   
        _timers[index] = inTimer
    }

    /* ################################################################## */
    /**
     */
    var ids: [UUID] { _timers.map { $0.id } }
    
    /* ################################################################## */
    /**
     */
    var timers: [TimerSettings] {
        get { _timers }
        set {
            _timers = newValue
            currentTimerIndex = max(0, min(currentTimerIndex, _timers.count - 1))
        }
    }

    /* ################################################################## */
    /**
     */
    var numberOfTimers: Int { ids.count }

    /* ################################################################## */
    /**
     */
    var currentTimerIndex: Int {
        get { values[Keys.currentTimerIndex.rawValue] as? Int ?? 0 }
        set { values[Keys.currentTimerIndex.rawValue] = newValue }
    }
    
    /* ################################################################## */
    /**
     */
    var currentTimer: TimerSettings {
        get {
            if _timers.isEmpty {
                _add(timer: TimerSettings())
            }
            return _timers[currentTimerIndex]
        }
        set {
            if let index = _timers.firstIndex(where: { $0.id == newValue.id }) {
                currentTimerIndex = index
                _timers[currentTimerIndex] = newValue
            } else {
                _add(timer: newValue)
                currentTimerIndex = _timers.count - 1
            }
        }
    }

    /* ################################################################## */
    /**
     */
    func getTimer(index inIndex: Int) -> TimerSettings? {
        guard (0..<_timers.count).contains(inIndex) else { return nil }
        currentTimerIndex = inIndex
        return _timers[inIndex]
    }

    /* ################################################################## */
    /**
     */
    func getTimer(id inID: UUID) -> TimerSettings? {
        guard let index = _timers.firstIndex(where: { $0.id == inID }) else { return nil }
        currentTimerIndex = index
        return _timers[index]
    }
}
