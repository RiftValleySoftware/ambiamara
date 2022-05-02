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
         The start time (as seconds)
         */
        private var _startTime: Int

        /* ########################################################## */
        /**
         The warning time (as seconds)
         */
        private var _warnTime: Int

        /* ########################################################## */
        /**
         The warning time (as seconds)
         */
        private var _finalTime: Int

        /* ########################################################## */
        /**
         The ID, which is set from a UUID.
         */
        let id: String

        /* ########################################################## */
        /**
         The start time (as seconds)
         */
        var startTime: Int {
            get { _startTime }
            set { _startTime = newValue }
        }

        /* ########################################################## */
        /**
         The start time (as hours, minutes, and seconds)
         */
        var startTimeAsComponents: [Int] {
            var currentValue = startTime
            
            let hours = min(99, currentValue / (60 * 60))
            currentValue -= (hours * 60 * 60)
            let minutes = min(59, currentValue / 60)
            currentValue -= (minutes * 60)
            let seconds = min(59, currentValue)
            
            return [hours, minutes, seconds]
        }

        /* ########################################################## */
        /**
         The warning time (as seconds)
         */
        var warnTime: Int {
            get { max(0, min(_startTime - 1, _warnTime)) }
            set { _warnTime = max(0, min(_startTime - 1, newValue)) }
        }
 
        /* ########################################################## */
        /**
         The warning time (as hours, minutes, and seconds)
         */
        var warnTimeAsComponents: [Int] {
            var currentValue = warnTime
            
            let hours = min(99, currentValue / (60 * 60))
            currentValue -= (hours * 60 * 60)
            let minutes = min(59, currentValue / 60)
            currentValue -= (minutes * 60)
            let seconds = min(59, currentValue)
            
            return [hours, minutes, seconds]
        }

        /* ########################################################## */
        /**
         The warning time (as seconds)
         */
        var finalTime: Int {
            get { max(0, min(_startTime, warnTime - 1, _finalTime)) }
            set { _finalTime = max(0, min(warnTime - 1, newValue)) }
        }
        
       /* ########################################################## */
       /**
        The final time (as hours, minutes, and seconds)
        */
       var finalTimeAsComponents: [Int] {
           var currentValue = finalTime
           
           let hours = min(99, currentValue / (60 * 60))
           currentValue -= (hours * 60 * 60)
           let minutes = min(59, currentValue / 60)
           currentValue -= (minutes * 60)
           let seconds = min(59, currentValue)
           
           return [hours, minutes, seconds]
       }

        /* ########################################################## */
        /**
         - returns: The timer's index. -1 if not found.
         */
        var index: Int {
            for item in RVS_AmbiaMara_Settings().timers.enumerated() where item.element.id == id {
                return item.offset
            }
            
            return -1
        }
        
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
            _startTime = inKVP.value[0]
            _warnTime = inKVP.value[1]
            _finalTime = inKVP.value[2]
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
            _startTime = inStartTime
            _warnTime = inWarnTime
            _finalTime = inFinalTime
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
         The timer IDs, stored as an Array. This is how we order the timers.
         */
        case timerIDs

        /* ############################################################## */
        /**
         The current selected timer index. -1 is no timer selected.
         */
        case currentTimerIndex

        /* ############################################################## */
        /**
         If true, then the setup screen will provide guidance, in popovers.
         */
        case useGuidancePopovers

        /* ############################################################## */
        /**
         If true, then the alarm will use haptics (vibration), in devices that support it.
         */
        case useVibrate

        /* ############################################################## */
        /**
         The alarm mode. It will store one of the AlarmSoundMode values as an Int.
         */
        case alarmMode
        
        /* ############################################################## */
        /**
         The selected sound. This is a 0-based index (Int).
         */
        case selectedSoundIndex
        
        /* ################################################################## */
        /**
         If the digits are to be shown in the running timer, this boolean is true.
         */
        case showDigits

        /* ################################################################## */
        /**
         If the "stoplights" are to be shown in the running timer, this boolean is true.
         */
        case showStoplights

        /* ############################################################## */
        /**
         These are all the keys, in an Array of String.
         */
        static var allKeys: [String] { [
                                        timers.rawValue,
                                        timerIDs.rawValue,
                                        currentTimerIndex.rawValue,
                                        useGuidancePopovers.rawValue,
                                        useVibrate.rawValue,
                                        alarmMode.rawValue,
                                        selectedSoundIndex.rawValue,
                                        showDigits.rawValue,
                                        showStoplights.rawValue
                                        ]
        }
    }

    /* ################################################################## */
    /**
     Remove the timer from storage.
     - parameter timer: The timer to be removed.
     Upon return, the timer is no longer styored in persistent prefs.
     */
    func remove(timer inTimer: TimerSettings) {
        if let timerIndex = ids.firstIndex(of: inTimer.id) {
            timers.remove(at: timerIndex)
        }
        
        if !(0..<timers.count).contains(currentTimerIndex) {
            currentTimerIndex = max(-1, min(currentTimerIndex, timers.count - 1))
        }
    }

    /* ################################################################## */
    /**
     Add the timer to storage. If the timer is already in storage, it is updated.
     - parameter timer: The timer to be added.
     - parameter andSelect: If true, then the current selection will move to this timer. Default is false.
     */
    func add(timer inTimer: TimerSettings = TimerSettings(), andSelect inAndSelect: Bool = false) {
        guard let index = timers.firstIndex(where: { $0.id == inTimer.id }) else {
            timers.append(inTimer)
            if inAndSelect {
                currentTimerIndex = timers.count - 1
            }
            return
        }
   
        timers[index] = inTimer
        
        if inAndSelect {
            currentTimerIndex = index
        }
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
                  !kvpArray.isEmpty,
                  !ids.isEmpty
            else { return [] }
            
            return ids.compactMap {
                guard let timer = kvpArray[$0],
                      3 == timer.count,
                      !$0.isEmpty
                else { return nil }
                return TimerSettings(id: $0, startTime: timer[0], warnTime: timer[1], finalTime: timer[2])
            }
        }
        set {
            var ids = [String]()
            var newDictionary: [String: [Int]] = [:]
            newValue.forEach {
                let kvp = $0.kvp
                ids.append(kvp.key)
                newDictionary[kvp.key] = kvp.value
            }
            values[Keys.timerIDs.rawValue] = ids
            values[Keys.timers.rawValue] = newDictionary
        }
    }

    /* ################################################################## */
    /**
     This returns the timer IDs, as an Array. This is how we deal with ordering the timers, since they are stored as a Dictionary.
     */
    var ids: [String] { values[Keys.timerIDs.rawValue] as? [String] ?? [] }

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
     If true, then the setup scren will provide guidance popovers.
     */
    var useGuidancePopovers: Bool {
        get { 0 != (values[Keys.useGuidancePopovers.rawValue] as? Int ?? 0) }
        set { values[Keys.useGuidancePopovers.rawValue] = newValue ? 1 : 0 }
    }

    /* ################################################################## */
    /**
     If true, then the alarm will use haptics (vibration), in devices that support it.
     */
    var useVibrate: Bool {
        get { 0 != (values[Keys.useVibrate.rawValue] as? Int ?? 0) }
        set { values[Keys.useVibrate.rawValue] = newValue ? 1 : 0 }
    }

    /* ################################################################## */
    /**
     The alarm audio mode. If true, then there will be an audible alarm.
     */
    var alarmMode: Bool {
        get { 0 != (values[Keys.alarmMode.rawValue] as? Int ?? 0) }
        set { values[Keys.alarmMode.rawValue] = newValue ? 1 : 0 }
    }

    /* ################################################################## */
    /**
     The selected sound, for an alarm. This is a 0-based index.
     */
    var selectedSoundIndex: Int {
        get { values[Keys.selectedSoundIndex.rawValue] as? Int ?? 0 }
        set { values[Keys.selectedSoundIndex.rawValue] = newValue }
    }

    /* ################################################################## */
    /**
     If the digits are to be shown in the running timer, this should be true.
     */
    var showDigits: Bool {
        get { 0 != (values[Keys.showDigits.rawValue] as? Int ?? 1) }
        set { values[Keys.showDigits.rawValue] = newValue ? 1 : 0 }
    }

    /* ################################################################## */
    /**
     If the "stoplights" are to be shown in the running timer, this should be true.
     */
    var showStoplights: Bool {
        get { 0 != (values[Keys.showStoplights.rawValue] as? Int ?? 1) }
        set { values[Keys.showStoplights.rawValue] = newValue ? 1 : 0 }
    }

    /* ################################################################## */
    /**
     The currently selected timer instance.
     */
    var currentTimer: TimerSettings {
        get {
            if ids.isEmpty {
                add(timer: TimerSettings())
                currentTimerIndex = 0
            } else if -1 == currentTimerIndex {
                currentTimerIndex = 0
            }
            
            currentTimerIndex = min(currentTimerIndex, numberOfTimers - 1)
            return timers[currentTimerIndex]
        }
        
        set {
            if let index = timers.firstIndex(where: { $0.id == newValue.id }) {
                currentTimerIndex = index
                timers[currentTimerIndex] = newValue
            } else {
                add(timer: newValue)
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
