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
        /* ############################################################################################################################## */
        // MARK: Default Range Setup Struct
        /* ############################################################################################################################## */
        /**
         This allows us to have an easily indexable set of values, so that we can specify warning and final suggestions for certain times.
         */
        struct DefaultRangeElement: Hashable {
            /* ###################################################### */
            /**
             The range to which this applies.
            */
            let range: Range<Int>
            
            /* ###################################################### */
            /**
             The warning time (seconds)
            */
            let warnTime: Int
            
            /* ###################################################### */
            /**
             The final time (seconds)
            */
            let finalTime: Int
            
            /* ###################################################### */
            /**
             We hash on the range only.
              - parameter into: The hasher to set.
            */
            func hash(into inHasher: inout Hasher) {
                inHasher.combine(range)
            }

            /* ###################################################### */
            /**
             We equate on the range only.
             - parameter lhs: The lefthand side of the comparison.
             - parameter rhs: The righthand side of the comparison.
             - returns: True, if the ranges match.
             */
            static func == (lhs: DefaultRangeElement, rhs: DefaultRangeElement) -> Bool {
                lhs.range == rhs.range
            }
        }
        
        /* ########################################################## */
        /**
         This has the timer settings in a Key-Value-Pair (KVP) fashion, for storage.
         - parameter key: The key, which is from the UUID string.
         - parameter value: A three-element Array of Int:
                            - 0 is start time
                            - 1 is warn time
                            - 2 is final time.
                            The values are seconds.
         */
        typealias KVP = (key: String, value: [Int])
        
        /* ########################################################## */
        /**
         The ID, which is set from a UUID.
         */
        let id: String

        /* ########################################################## */
        /**
         The start time (as seconds)
         */
        var startTime: Int

        /* ########################################################## */
        /**
         The warning time (as seconds)
         */
        var warnTime: Int

        /* ########################################################## */
        /**
         The warning time (as seconds)
         */
        var finalTime: Int
        
        /* ########################################################## */
        /**
         - returns: The timer, expressed as a KVP.
         */
        var kvp: KVP { (key: id, value: [startTime, warnTime, finalTime]) }
        
        /* ########################################################## */
        /**
         - returns: True, if this is the currently selected timer.
         Setting this, selects this timer.
         */
        var isCurrent: Bool {
            get { id == RVS_AmbiaMara_Settings().currentTimerID }
            set { RVS_AmbiaMara_Settings().currentTimerID = id }
        }

        /* ########################################################## */
        /**
         Initializer, from a KVP
         - parameter inKVP: The KVP, specifying this timer.
         */
        init(_ inKVP: KVP) {
            id = inKVP.key
            startTime = inKVP.value[0]
            warnTime = inKVP.value[1]
            finalTime = inKVP.value[2]
        }

        /* ########################################################## */
        /**
         Initializer with values. All are optional.
         - parameters:
            - id: The unique ID string. If not provided, a new one is created as a UUID string.
            - startTime: The start time, in seconds. If not provided, this is 0.
            - warnTime: The warning time, in seconds. If not provided, this is 0.
            - finalTime: The final time, in seconds. If not provided, this is 0.
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
         The timers, stored as a Dictionary (key is the ID).
         */
        case timers

        /* ############################################################## */
        /**
         The current selected timer index. -1 is no timer selected,
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
     Remove the timer from storage.
     - parameter timer: The timer to be removed.
     Upon return, the timer is no longer styored in persistent prefs.
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
     Add the timer to storage. If the timer is already in storage, it is updated.
     - parameter timer: The timer to be added.
     */
    private func _add(timer inTimer: TimerSettings) {
        guard let index = timers.firstIndex(where: { $0.id == inTimer.id }) else {
            timers.append(inTimer)
            return
        }
   
        timers[index] = inTimer
    }
    
    /* ################################################################## */
    /**
     The keys (for determining storage).
     */
    override var keys: [String] { Keys.allKeys }

    /* ################################################################## */
    /**
     The timers, as TimerSettings instances.
     The Array is sorted by the duration of the timer Start times.
     */
    var timers: [TimerSettings] {
        get {
            guard let kvpArray = values[Keys.timers.rawValue] as? [String: [Int]],
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
            values[Keys.timers.rawValue] = newDictionary
        }
    }

    /* ################################################################## */
    /**
     The IDs of the timer Array (in the order of the timer sort)
     */
    var ids: [String] { timers.map { $0.id } }

    /* ################################################################## */
    /**
     The number of timers.
     */
    var numberOfTimers: Int { ids.count }

    /* ################################################################## */
    /**
     The current index into the Array of timers (so 0-based), of the currently selected timer.
     */
    var currentTimerIndex: Int {
        get { max(-1, min(values[Keys.currentTimerIndex.rawValue] as? Int ?? -1, timers.count - 1)) }
        set { values[Keys.currentTimerIndex.rawValue] = newValue }
    }

    /* ################################################################## */
    /**
     The ID of the currently selected timer.
     */
    var currentTimerID: String {
        get { currentTimer.id }
        set { currentTimerIndex = ids.firstIndex(of: newValue) ?? -1 }
    }

    /* ################################################################## */
    /**
     The currently selected timer instance.
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
     This fetches a timer by its ID.
     */
    func getTimer(byID inID: String) -> TimerSettings? {
        guard let index = ids.firstIndex(of: inID) else { return nil }
        return timers[index]
    }
}
