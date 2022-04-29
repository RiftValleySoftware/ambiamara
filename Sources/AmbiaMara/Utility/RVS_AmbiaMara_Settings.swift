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
    struct TimerSettings {
        /* ############################################################## */
        /**
         */
        typealias KVP = (key: String, value: [Int])
        
        /* ############################################################## */
        /**
         */
        let id: String

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
        var kvp: KVP { (key: id, value: [startTime, warnTime, finalTime]) }
        
        /* ############################################################## */
        /**
         */
        var isCurrent: Bool {
            get { id == RVS_AmbiaMara_Settings().currentTimerID }
            set { RVS_AmbiaMara_Settings().currentTimerID = id }
        }

        /* ############################################################## */
        /**
         */
        init(_ inKVP: KVP) {
            id = inKVP.key
            startTime = inKVP.value[0]
            warnTime = inKVP.value[1]
            finalTime = inKVP.value[2]
        }

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
        if let index = ids.firstIndex(of: inTimer.id) {
            timers.remove(at: index)
        }
        
        if !(0..<timers.count).contains(currentTimerIndex) {
            currentTimerIndex = max(-1, min(currentTimerIndex, timers.count - 1))
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
    var timers: [TimerSettings] {
        get {
            guard let kvpArray = values[Keys._timers.rawValue] as? [String: [Int]],
                  !kvpArray.isEmpty
            else { return [] }
            
            return kvpArray.compactMap {
                guard 3 == $0.value.count,
                      !$0.key.isEmpty
                else { return nil }
                return TimerSettings(id: $0.key, startTime: $0.value[0], warnTime: $0.value[1], finalTime: $0.value[2])
            }.sorted { a, b in a.startTime < b.startTime ? true : a.id < b.id }
        }
        set {
            var newDictionary: [String: [Int]] = [:]
            newValue.forEach {
                let kvp = $0.kvp
                newDictionary[kvp.key] = kvp.value
            }
            values[Keys._timers.rawValue] = newDictionary
        }
    }

    /* ################################################################## */
    /**
     */
    var ids: [String] { timers.map { $0.id } }

    /* ################################################################## */
    /**
     */
    var numberOfTimers: Int { ids.count }

    /* ################################################################## */
    /**
     */
    var currentTimerIndex: Int {
        get { max(-1, min(values[Keys.currentTimerIndex.rawValue] as? Int ?? -1, timers.count - 1)) }
        set { values[Keys.currentTimerIndex.rawValue] = newValue }
    }

    /* ################################################################## */
    /**
     */
    var currentTimerID: String {
        get { currentTimer.id }
        set { currentTimerIndex = ids.firstIndex(of: newValue) ?? -1 }
    }

    /* ################################################################## */
    /**
     */
    var currentTimer: TimerSettings {
        get {
            if timers.isEmpty {
                _add(timer: TimerSettings())
                currentTimerIndex = 0
            } else if -1 == currentTimerIndex {
                currentTimerIndex = 0
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
    func getTimer(byID inID: String) -> TimerSettings? {
        guard let index = ids.firstIndex(of: inID) else { return nil }
        return timers[index]
    }
}
