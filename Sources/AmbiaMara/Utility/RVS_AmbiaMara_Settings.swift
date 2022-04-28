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
    class TimerSettings: Codable {
        /* ############################################################## */
        /**
         */
        var id: String

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
        init(id inID: String = UUID().uuidString, startTime inStartTime: Int = 0, warnTime inWarnTime: Int = 0, finalTime inFinalTime: Int = 0) {
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
        case _timers

        /* ############################################################## */
        /**
         */
        case currentTimerIndex

        /* ############################################################## */
        /**
         These are all the keys, in an Array of String.
         */
        static var allKeys: [String] { [
                                        _timers.rawValue,
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
    private func _remove(timer inTimer: TimerSettings) {
        if let index = timers.firstIndex(where: { $0.id == inTimer.id }) {
            timers.remove(at: index)
        }
        
        if !(0..<timers.count).contains(currentTimerIndex) {
            currentTimerIndex = max(0, min(currentTimerIndex, timers.count - 1))
        }
    }

    /* ################################################################## */
    /**
     */
    private func _add(timer inTimer: TimerSettings) {
        guard let index = timers.firstIndex(where: { $0.id == inTimer.id }) else {
            timers.append(inTimer)
            currentTimerIndex = timers.count - 1
            return
        }
   
        currentTimerIndex = index
        timers[index] = inTimer
    }

    /* ################################################################## */
    /**
     */
    var ids: [String] { timers.map { $0.id } }
    
    /* ################################################################## */
    /**
     */
    var timers: [TimerSettings] {
        get { values[Keys._timers.rawValue] as? [TimerSettings] ?? [] }
        set {
            values[Keys._timers.rawValue] = newValue
            currentTimerIndex = max(0, min(currentTimerIndex, timers.count - 1))
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
        get {
            let index = values[Keys.currentTimerIndex.rawValue] as? Int ?? 0
            return max(0, min(index, timers.count - 1))
        }
        set { values[Keys.currentTimerIndex.rawValue] = newValue }
    }
    
    /* ################################################################## */
    /**
     */
    var currentTimer: TimerSettings {
        get {
            if timers.isEmpty {
                _add(timer: TimerSettings())
            }
            return timers[currentTimerIndex]
        }
        
        set {
            if let index = timers.firstIndex(where: { $0.id == newValue.id }) {
                currentTimerIndex = index
                timers[currentTimerIndex] = newValue
            } else {
                _add(timer: newValue)
                currentTimerIndex = timers.count - 1
            }
        }
    }

    /* ################################################################## */
    /**
     */
    func getTimer(index inIndex: Int) -> TimerSettings? {
        guard (0..<timers.count).contains(inIndex) else { return nil }
        currentTimerIndex = inIndex
        return timers[inIndex]
    }

    /* ################################################################## */
    /**
     */
    func getTimer(id inID: String) -> TimerSettings? {
        guard let index = timers.firstIndex(where: { $0.id == inID }) else { return nil }
        currentTimerIndex = index
        return timers[index]
    }
}
