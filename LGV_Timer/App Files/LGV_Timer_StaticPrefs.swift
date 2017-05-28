//
//  LGV_Timer_StaticPrefs.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 5/24/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//

import Foundation

// MARK: - Convenience Cast -
/* ###################################################################################################################################### */
extension Int {
    /* ################################################################## */
    /**
     Casting operator for TimeTuple to an integer.
     */
    init(_ inTimeTuple: TimeTuple) {
        self.init(inTimeTuple.intVal)
    }
}

// MARK: - TimeTuple Class -
/* ###################################################################################################################################### */
/**
 This is a class designed to behave like a tuple.
 
 It holds the timer value as hours, minutes and seconds.
 */
class TimeTuple {
    // MARK: - Private Instance Properties
    /* ################################################################################################################################## */
    private var _hours: Int     ///< The number of hours in this instance, from 0 - 23
    private var _minutes: Int   ///< The number of minutes in this instance, from 0 - 59
    private var _seconds: Int   ///< The number of seconds in this instance, from 0 - 59
    
    // MARK: - Internal Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This sets/returns the value of this class, as a total sum of seconds (0 - 86399)
     */
    var intVal: Int {
        get {
            return min(86399, max(0, (self.hours * 3600) + (self.minutes * 60) + self.seconds))
        }
        
        set {
            let temp = min(86399, max(0, newValue))
            
            self.hours = max(0, Int(temp / 3600))
            self.minutes = max(0, Int(temp / 60) - (self.hours * 60))
            self.seconds = max(0, Int(temp) - ((self.hours * 3600) + (self.minutes * 60)))
        }
    }
    
    /* ################################################################## */
    /**
     Public accessor fo the hours.
     */
    var hours: Int {
        get {
            return self._hours
        }
        
        set {
            self._hours = min(23, max(0, newValue))
        }
    }
    
    /* ################################################################## */
    /**
     Public accessor fo the minutes.
     */
    var minutes: Int {
        get {
            return self._minutes
        }
        
        set {
            self._minutes = min(59, max(0, newValue))
        }
    }
    
    /* ################################################################## */
    /**
     Public accessor fo the seconds.
     */
    var seconds: Int {
        get {
            return self._seconds
        }
        
        set {
            self._seconds = min(59, max(0, newValue))
        }
    }
    
    /* ################################################################## */
    /**
     Returns the value of the instance as DateComponents, for easy use in date calculations.
     */
    var dateComponents: DateComponents {
        get {
            return DateComponents(calendar: nil, timeZone: nil, era: nil, year: nil, month: nil, day: nil, hour: self._hours, minute: self._minutes, second: self._seconds, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
        }
        
        set {
            self.intVal = 0
            
            if let hour = newValue.hour {
                self.hours = Int(hour)
            }
            if let minute = newValue.minute {
                self.minutes = Int(minute)
            }
            if let second = newValue.second {
                self.seconds = Int(second)
            }
        }
    }
    
    // MARK: - Initializers
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Initialize just like a tuple.
     
     :param: hours The number of hours, as an Int, from 0 - 23.
     :param: minutes The number of minutes, as an Int, from 0 - 59.
     :param: seconds The number of seconds, as an Int, from 0 - 59.
     */
    init(hours: Int, minutes: Int, seconds: Int) {
        self._hours = max(0, min(23, hours))
        self._minutes = max(0, min(59, minutes))
        self._seconds = max(0, min(59, seconds))
    }
    
    /* ################################################################## */
    /**
     Initialize from total seconds.
     
     :param: The number of seconds as an Int, from 0 - 86399.
     */
    init(_ inSeconds:Int) {
        let temp = min(86399, max(0, inSeconds))
        
        self._hours = max(0, Int(temp / 3600))
        self._minutes = max(0, Int(temp / 60) - (self._hours * 60))
        self._seconds = max(0, Int(temp) - ((self._hours * 3600) + (self._minutes * 60)))
    }
}

/* ################################################################## */
/**
 These are the three display modes we have for our countdown timer.
 */
enum TimerDisplayMode: Int {
    case Digital    = 0 ///< Display only digits.
    case Podium     = 1 ///< Display only "podium lights."
    case Dual       = 2 ///< Display both.
}

/// This is the basic element that describes one timer.
typealias TimerSettingTuple = (
    timeSet: Int,                   ///< This is the set (start) time for the countdown timer. It is an integer, with the number of seconds (0 - 86399)
    timeSetPodiumWarn: Int,         ///< This is the number of seconds (0 - 86399) before the yellow light comes on in Podium Mode. If 0, then it is automatically calculated.
    timeSetPodiumFinal: Int,        ///< This is the number of seconds (0 - 86399) before the red light comes on in Podium Mode. If 0, then it is automatically calculated.
    displayMode: TimerDisplayMode,  ///< This is how the timer will display
    keepsDeviceAwake: Bool,         ///< Detemines whether or not to keep the device awake while counting down.
    colorTheme: Int                 ///< This is the 0-based index for the color theme.
)

// MARK: - Prefs Class -
/* ###################################################################################################################################### */
/**
 This is a very simple "persistent user prefs" class. It is instantiated as a SINGLETON, and provides a simple, property-oriented gateway
 to the simple persistent user prefs in iOS. It shouldn't be used for really big, important prefs, but is ideal for the basic "settings"
 type of prefs most users set in their "gear" screen.
 */
class LGV_Timer_StaticPrefs {
    // MARK: - Private Static Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /** This is the key for the prefs used by this app. */
    private static let _mainPrefsKey: String = "LGV_Timer_StaticPrefs"
    /** This is how we enforce a SINGLETON pattern. */
    private static var _sSingletonPrefs: LGV_Timer_StaticPrefs! = nil

    // MARK: - Private Variable Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /** We load the user prefs into this Dictionary object. */
    private var _loadedPrefs: NSMutableDictionary! = nil
    
    // MARK: - Private Enums
    /* ################################################################################################################################## */
    /* ################################################################## */
    /** These are the keys we use for our persistent prefs dictionary. */
    private enum PrefsKeys: String {
        /** This will be a Boolean pref, indicating whether or not the clock should keep the phone from going to sleep while it's active. */
        case KeepAwakeClock = "KeepAwakeClock"
        /** This will be a Boolean pref, indicating whether or not the stopwatch should keep the phone from going to sleep while it's active. */
        case KeepAwakeStopwatch = "KeepAwakeStopwatch"
        /** This will be a Boolean pref, indicating whether or not the stopwatch will display a lap counter. */
        case UseLapsStopwatch = "UseLapsStopwatch"
        /** This will be an array of dictionaries, with a list of timers. */
        case TimerList = "TimerList"
    }
    
    // MARK: - Internal Enums
    /* ################################################################################################################################## */
    /* ################################################################## */
    /** These are the keys we use for our timer prefs dictionary. */
    enum TimerPrefKeys: String {
        case TimeSet            = "TimeSet"
        case TimeSetPodiumWarn  = "TimeSetPodiumWarn"
        case TimeSetPodiumFinal = "TimeSetPodiumFinal"
        case DisplayMode        = "DisplayMode"
        case KeepsDeviceAwake   = "KeepsDeviceAwake"
        case ColorTheme         = "ColorTheme"
    }
    
    // MARK: - Private Static Constants
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     These are the thresholds that we apply to our timer when automatically determining the "traffic lights" for podium mode.
     */
    static let _podiumModeWarningThreshold: Float  = (6 / 36)
    static let _podiumModeFinalThreshold: Float    = (3 / 36)
    
    // MARK: - Private Initializer
    /* ################################################################################################################################## */
    /* ################################################################## */
    /** We do this to prevent the class from being instantiated in a different context than our controlled one. */
    private init(){/* Sergeant Schultz says: "I do nut'ing. Nut-ING!" */}

    // MARK: - Private Instance Methods
    /* ################################################################## */
    /**
     This method loads the main prefs into our instance storage.
     
     NOTE: This will overwrite any unsaved changes to the current _loadedPrefs property.
     
     - returns: a Bool. True, if the load was successful.
     */
    private func _loadPrefs() -> Bool {
        if nil == self._loadedPrefs {
            if let temp = UserDefaults.standard.object(forKey: type(of: self)._mainPrefsKey) as? NSDictionary {
                self._loadedPrefs = NSMutableDictionary(dictionary: temp)
            } else {
                self._loadedPrefs = NSMutableDictionary()
            }
        }
        
        return nil != self._loadedPrefs
    }
    
    // MARK: - Private Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This method simply saves the main preferences Dictionary into the standard user defaults.
     */
    private func _savePrefs() {
        UserDefaults.standard.set(self._loadedPrefs, forKey: type(of: self)._mainPrefsKey)
    }
    
    // MARK: - Internal Class Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This calculates the auto-calculation for the "warning," or "yellow traffic light" for the Podium Mode timer.
     
     :param: inTimerSet The value of the countdown timer.
     
     :returns: an Int, with the warning threshold.
     */
    class func calcPodiumModeWarningThresholdForTimerValue(_ inTimerSet: Int) -> Int {
        return max(0, min(inTimerSet, Int(ceil(Float(inTimerSet) * self._podiumModeWarningThreshold))))
    }
    
    /* ################################################################## */
    /**
     This calculates the auto-calculation for the "final," or "red traffic light" for the Podium Mode timer.
     
     :param: inTimerSet The value of the countdown timer.
     
     :returns: an Int, with the final threshold.
     */
    class func calcPodiumModeFinalThresholdForTimerValue(_ inTimerSet: Int) -> Int {
        return max(0, min(calcPodiumModeWarningThresholdForTimerValue(inTimerSet), Int(ceil(Float(inTimerSet) * self._podiumModeFinalThreshold))))
    }
    
    // MARK: - Class Static Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is how the singleton instance is instantiated and accessed. Always use this variable to capture the prefs object.
     
     The syntax is:
     
     let myPrefs = AppStaticPrefs.prefs
     
     - returns the current prefs object.
     */
    static var prefs: LGV_Timer_StaticPrefs {
        get {
            if nil == self._sSingletonPrefs {
                self._sSingletonPrefs = LGV_Timer_StaticPrefs()
            }
            
            return self._sSingletonPrefs
        }
    }
    
    /* ################################################################## */
    /**
     This tells us whether or not the device is set for military time.
     
     - returns: True, if the device is set for Ante Meridian (AM/PM) time.
     */
    static var using12hClockFormat: Bool {
        get {
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            
            let dateString = formatter.string(from: Date())
            let amRange = dateString.range(of: formatter.amSymbol)
            let pmRange = dateString.range(of: formatter.pmSymbol)
            
            return !(pmRange == nil && amRange == nil)
        }
    }
    
    // MARK: - Internal Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This method is a public interface to the private method.
     */
    func savePrefs() {
        self._savePrefs()
    }
    
    // MARK: - Internal Instance Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This sets/returns whether or not the clock keeps the device awake while timing.
     */
    var clockKeepsDeviceAwake: Bool {
        get {
            var ret: Bool = false
            
            if self._loadPrefs() {
                if let temp = self._loadedPrefs.object(forKey: PrefsKeys.KeepAwakeClock.rawValue) as? NSNumber {
                    ret = temp.boolValue
                }
            }
            
            return ret
        }
        
        set {
            if self._loadPrefs() {
                let savedVal = NSNumber(value: newValue)
                self._loadedPrefs.setObject(savedVal, forKey: PrefsKeys.KeepAwakeClock.rawValue as NSCopying)
            }
        }
    }
    
    /* ################################################################## */
    /**
     This sets/returns whether or not the stopwatch keeps the device awake while timing.
     */
    var stopwatchKeepsDeviceAwake: Bool {
        get {
            var ret: Bool = false
            
            if self._loadPrefs() {
                if let temp = self._loadedPrefs.object(forKey: PrefsKeys.KeepAwakeStopwatch.rawValue) as? NSNumber {
                    ret = temp.boolValue
                }
            }
            
            return ret
        }
        
        set {
            if self._loadPrefs() {
                let savedVal = NSNumber(value: newValue)
                self._loadedPrefs.setObject(savedVal, forKey: PrefsKeys.KeepAwakeStopwatch.rawValue as NSCopying)
            }
        }
    }
    
    /* ################################################################## */
    /**
     This sets/returns whether or not the stopwatch tracks laps.
     */
    var stopwatchTracksLaps: Bool {
        get {
            var ret: Bool = true
            
            if self._loadPrefs() {
                if let temp = self._loadedPrefs.object(forKey: PrefsKeys.UseLapsStopwatch.rawValue) as? NSNumber {
                    ret = temp.boolValue
                }
            }
            
            return ret
        }
        
        set {
            if self._loadPrefs() {
                let savedVal = NSNumber(value: newValue)
                self._loadedPrefs.setObject(savedVal, forKey: PrefsKeys.UseLapsStopwatch.rawValue as NSCopying)
            }
        }
    }
    
    /* ################################################################## */
    /**
     This sets/returns a list of timers. We must have at least one timer.
     */
    var timers:[TimerSettingTuple] {
        get {
            var ret: [TimerSettingTuple] = []
            let defaultValue: TimerSettingTuple = (timeSet: 0, timeSetPodiumWarn: 0, timeSetPodiumFinal: 0, displayMode: .Digital, keepsDeviceAwake: true, colorTheme: 0)
            
            if self._loadPrefs() {
                if let temp = self._loadedPrefs.object(forKey: PrefsKeys.TimerList.rawValue) as? NSArray {
                    for index in 0..<temp.count {
                        if let arrayElement = temp[index] as? NSDictionary {
                            var temp: TimerSettingTuple = defaultValue
                            print("\(arrayElement)")
                            if let timeSet = arrayElement.object(forKey: TimerPrefKeys.TimeSet.rawValue as NSString) as? NSNumber {
                                temp.timeSet = min(86399, max(0, timeSet.intValue))
                            }
                            
                            if let timeSetPodiumWarn = arrayElement.object(forKey: TimerPrefKeys.TimeSetPodiumWarn.rawValue as NSString) as? NSNumber {
                                temp.timeSetPodiumWarn = max(0, timeSetPodiumWarn.intValue)
                            }
                            
                            if let timeSetPodiumFinal = arrayElement.object(forKey: TimerPrefKeys.TimeSetPodiumFinal.rawValue as NSString) as? NSNumber {
                                temp.timeSetPodiumFinal = max(0, timeSetPodiumFinal.intValue)
                            }
                            
                            if let displayMode = arrayElement.object(forKey: TimerPrefKeys.DisplayMode.rawValue as NSString) as? NSNumber {
                                if let dMode = TimerDisplayMode(rawValue: displayMode.intValue) {
                                    temp.displayMode = dMode
                                }
                            }
                            
                            if let keepsDeviceAwake = arrayElement.object(forKey: TimerPrefKeys.KeepsDeviceAwake.rawValue as NSString) as? NSNumber {
                                temp.keepsDeviceAwake = keepsDeviceAwake.boolValue
                            }

                            if let colorTheme = arrayElement.object(forKey: TimerPrefKeys.ColorTheme.rawValue as NSString) as? NSNumber {
                                temp.colorTheme = colorTheme.intValue
                            }
                            
                            // If either of these is zero, then we need to calculate the thresholds.
                            if (0 == temp.timeSetPodiumWarn) || (0 == temp.timeSetPodiumFinal) {
                                if 0 < temp.timeSet {
                                    temp.timeSetPodiumWarn = type(of: self).calcPodiumModeWarningThresholdForTimerValue(temp.timeSet)
                                    temp.timeSetPodiumFinal = type(of: self).calcPodiumModeFinalThresholdForTimerValue(temp.timeSet)
                                } else {
                                    temp.timeSetPodiumWarn = 0
                                    temp.timeSetPodiumFinal = 0
                                }
                            }
                            
                            ret.append(temp)
                        } else {
                            ret.append(defaultValue)
                        }
                    }
                } else {
                    ret.append(defaultValue)
                }
            } else {
                ret.append(defaultValue)
            }
            
            return ret
        }
        
        set {
            if self._loadPrefs() {
                let tempSetting:NSMutableArray = []
                
                for timer in newValue {
                    let timerInstance = NSDictionary()
                    
                    let timeSetKey = TimerPrefKeys.TimeSet.rawValue
                    let timeSetValue = NSNumber(value: min(86399, max(0, timer.timeSet)))
                    timerInstance.setValue(timeSetValue, forKey: timeSetKey)
                    
                    let timeSetPodiumWarnKey = TimerPrefKeys.TimeSetPodiumWarn.rawValue
                    let timeSetPodiumWarnValue = NSNumber(value: min(timeSetValue.intValue, max(0, timer.timeSetPodiumWarn)))
                    timerInstance.setValue(timeSetPodiumWarnValue, forKey: timeSetPodiumWarnKey)
                    
                    let timeSetPodiumFinalKey = TimerPrefKeys.TimeSetPodiumFinal.rawValue
                    let timeSetPodiumFinalValue = NSNumber(value: min(timeSetPodiumWarnValue.intValue, max(0, timer.timeSetPodiumWarn)))
                    timerInstance.setValue(timeSetPodiumFinalValue, forKey: timeSetPodiumFinalKey)
                    
                    let displayModeKey = TimerPrefKeys.DisplayMode.rawValue
                    let displayModeValue = NSNumber(value: timer.displayMode.rawValue)
                    timerInstance.setValue(displayModeValue, forKey: displayModeKey)
                    
                    let keepsAwakeKey = TimerPrefKeys.KeepsDeviceAwake.rawValue
                    let keepsAwakeValue = NSNumber(value: timer.keepsDeviceAwake)
                    timerInstance.setValue(keepsAwakeValue, forKey: keepsAwakeKey)
                    
                    let colorThemeKey = TimerPrefKeys.ColorTheme.rawValue
                    let colorThemeValue = NSNumber(value: timer.colorTheme)
                    timerInstance.setValue(colorThemeValue, forKey: colorThemeKey)
                    
                    tempSetting.add(timerInstance)
                }
                
                // We're not allowed to have zero timers.
                if 0 == tempSetting.count {
                    tempSetting.add(TimerSettingTuple(timeSet: 0, timeSetPodiumWarn: 0, timeSetPodiumFinal: 0, displayMode: .Digital, keepsDeviceAwake: true, colorTheme: 0))
                }
                
                self._loadedPrefs.setObject(tempSetting, forKey: PrefsKeys.TimerList.rawValue as NSCopying)
            }
        }
    }
}
