//
//  LGV_Timer_SharedDeclarations.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 6/13/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//

import Foundation

class LGV_Timer_Messages {
    static let s_timerListHowdyMessageKey = "Howdy"
    static let s_timerListSelectTimerMessageKey = "SelectTimer"
    static let s_timerListStartTimerMessageKey = "StartTimer"
    static let s_timerListPauseTimerMessageKey = "PauseTimer"
    static let s_timerListStopTimerMessageKey = "StopTimer"
    static let s_timerListResetTimerMessageKey = "ResetTimer"
    static let s_timerListEndTimerMessageKey = "EndTimer"
    static let s_timerListUpdateTimerMessageKey = "UpdateTimer"
    static let s_timerListUpdateFullTimerMessageKey = "UpdateFullTimer"
    static let s_timerListAlarmMessageKey = "W00t!"
    static let s_timerAppInBackgroundMessageKey = "AppInBackground"
    static let s_timerAppInForegroundMessageKey = "AppInForeground"
    static let s_timerRequestAppStatusMessageKey = "WhatUpDood"
    static let s_timerRequestActiveTimerUIDMessageKey = "Whazzup"
    static let s_timerRecaclulateTimersMessageKey = "ScarfNBarf"
    static let s_timerSendListAgainMessageKey = "SayWhut"

    static let s_timerListHowdyMessageValue = "HowManyTimers"
    static let s_timerStatusUserInfoValue = "TimerStatus"
    static let s_timerListUserInfoValue = "TimerList"
    static let s_timerAlarmUserInfoValue = "Alarm"
}

class LGV_Timer_Data_Keys {
    static let s_timerDataUIDKey = "UID"
    static let s_timerDataTimerNameKey = "TimerName"
    static let s_timerDataTimeSetKey = "TimeSet"
    static let s_timerDataCurrentTimeKey = "CurrentTime"
    static let s_timerDataTimeSetWarnKey = "TimeSetWarn"
    static let s_timerDataTimeSetFinalKey = "TimeSetFinal"
    static let s_timerDataDisplayModeKey = "DisplayMode"
    static let s_timerDataColorKey = "Color"
}

/* ###################################################################################################################################### */
/**
 These are String class extensions that we'll use throughout the app.
 */
extension String {
    /* ################################################################## */
    /**
     */
    var localizedVariant: String {
        return NSLocalizedString(self, comment: "")
    }
}

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
    
    /* ################################################################## */
    /**
     Returns the value in an easily readable format.
     */
    var description: String {
        get {
            return String(format: "%02d:%02d:%02d", self._hours, self._minutes, self._seconds)
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

/* ################################################################## */
/**
 These are the three final alert modes we have for our countdown timer.
 */
enum AlertMode: Int {
    case Silent         = 0
    case VibrateOnly    = 1
    case SoundOnly      = 2
    case Both           = 3
}

/* ################################################################## */
/**
 These are the various states a timer can be in.
 */
enum TimerStatus: Int {
    case Invalid        = 0 ///< This is set for a timeSet value of 0.
    case Stopped        = 1 ///< This means the timer is not running, and currentTime is timeSet.
    case Paused         = 2 ///< The timer is paused, and the currentTime is less than timeSet.
    case Running        = 3 ///< The timer is running "green," which means that currentTime is greater than timeSetWarn.
    case WarnRun        = 4 ///< The timer is running "yellow," which means that currentTime is less than, or equal to timeSetWarn.
    case FinalRun       = 5 ///< The timer is running "red," which means that currentTime is less than, or equal to timeSetFinal.
    case Alarm          = 6 ///< The timer is in an alarm state, which means that currentTime is 0.
}

// MARK: - TimerSettingTuple Class -
/* ###################################################################################################################################### */
/**
 This is the basic element that describes one timer.
 
 It is a class, because that means that references (as opposed to copies) will be passed around.
 */
class TimerSettingTuple: NSCoding {
    private enum TimerStateKeys: String {
        case TimeSet            = "TimeSet"
        case TimeSetPodiumWarn  = "TimeSetPodiumWarn"
        case TimeSetPodiumFinal = "TimeSetPodiumFinal"
        case CurrentTime        = "CurrentTime"
        case DisplayMode        = "DisplayMode"
        case ColorTheme         = "ColorTheme"
        case AlertMode          = "AlertMode"
        case SoundID            = "SoundID"
        case Status             = "Status"
        case UID                = "UID"
    }
    
    var timeSet: Int                    ///< This is the set (start) time for the countdown timer. It is an integer, with the number of seconds (0 - 86399)
    var timeSetPodiumWarn: Int          ///< This is the number of seconds (0 - 86399) before the yellow light comes on in Podium Mode. If 0, then it is automatically calculated.
    var timeSetPodiumFinal: Int         ///< This is the number of seconds (0 - 86399) before the red light comes on in Podium Mode. If 0, then it is automatically calculated.
    var currentTime: Int                ///< The actual time for this timer.
    var displayMode: TimerDisplayMode   ///< This is how the timer will display
    var colorTheme: Int                 ///< This is the 0-based index for the color theme.
    var alertMode: AlertMode            ///< This determines what kind of alert the timer makes when it is complete.
    var soundID: Int                    ///< This will be the ID of a system sound for this timer.
    var timerStatus: TimerStatus        ///< This is the current status of this timer.
    var uid: String                     ///< This will be a unique ID, assigned to the pref, so we can match it.
    
    // MARK: - Initializers
    /* ################################################################################################################################## */
    init() {
        self.timeSet = 0
        self.timeSetPodiumWarn = 0
        self.timeSetPodiumFinal = 0
        self.currentTime = 0
        self.displayMode = .Dual
        self.colorTheme = 0
        self.alertMode = .Silent
        self.soundID = 5
        self.timerStatus = .Stopped
        self.uid = NSUUID().uuidString
    }
    
    /* ################################################################## */
    /**
     Initialize just like a tuple.
     
     :param: timeSet This is the set (start) time for the countdown timer. It is an integer, with the number of seconds (0 - 86399)
     :param: timeSetPodiumWarn This is the number of seconds (0 - 86399) before the yellow light comes on in Podium Mode. If 0, then it is automatically calculated.
     :param: timeSetPodiumFinal This is the number of seconds (0 - 86399) before the red light comes on in Podium Mode. If 0, then it is automatically calculated.
     :param: displayMode This is how the timer will display
     :param: colorTheme This is the 0-based index for the color theme.
     :param: alertMode This determines what kind of alert the timer makes when it is complete.
     :param: soundID This is the ID of the sound to play (when in mode 1 or 2).
     :param: uid This is a unique ID for this setting. It can be defaulted.
     */
    init(timeSet: Int, timeSetPodiumWarn: Int, timeSetPodiumFinal: Int, currentTime: Int, displayMode: TimerDisplayMode, colorTheme: Int, alertMode: AlertMode, alertVolume: Int, soundID: Int, timerStatus: TimerStatus, uid: String!) {
        
        self.timeSet = timeSet
        self.timeSetPodiumWarn = timeSetPodiumWarn
        self.timeSetPodiumFinal = timeSetPodiumFinal
        self.currentTime = currentTime
        self.displayMode = displayMode
        self.colorTheme = colorTheme
        self.alertMode = alertMode
        self.soundID = soundID
        self.timerStatus = timerStatus
        self.uid = (nil == uid) ? NSUUID().uuidString : uid
    }
    
    // MARK: - Instance Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Returns the value in an easily readable format.
     */
    var description: String {
        get {
            return String(format: "timeSet: %@, timeSetPodiumWarn: %@, timeSetPodiumFinal: %d, currentTime: %d displayMode: %@, colorTheme: %d, alertMode: %d, soundID: %d, timerStatus: %d uid: %@",
                          self.timeSet.description,
                          self.timeSetPodiumWarn.description,
                          self.timeSetPodiumFinal.description,
                          self.currentTime.description,
                          self.displayMode.rawValue,
                          self.colorTheme,
                          self.alertMode.rawValue,
                          self.soundID,
                          self.timerStatus.rawValue,
                          self.uid
            )
        }
    }
    
    // MARK: - NSCoding Protocol Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Initialize from a serialized state.
     */
    required init?(coder: NSCoder) {
        self.displayMode = .Dual
        self.alertMode = .Both
        self.timerStatus = .Stopped
        self.uid = ""

        let timeSet = coder.decodeInteger(forKey: type(of: self).TimerStateKeys.TimeSet.rawValue)
        self.timeSet = timeSet
        
        let timeWarn = coder.decodeInteger(forKey: type(of: self).TimerStateKeys.TimeSetPodiumWarn.rawValue)
        self.timeSetPodiumWarn = timeWarn
        
        let timeFinal = coder.decodeInteger(forKey: type(of: self).TimerStateKeys.TimeSetPodiumFinal.rawValue)
        self.timeSetPodiumFinal = timeFinal
        
        let currentTime = coder.decodeInteger(forKey: type(of: self).TimerStateKeys.CurrentTime.rawValue)
        self.currentTime = currentTime
        
        if let displayMode = TimerDisplayMode(rawValue: coder.decodeInteger(forKey: type(of: self).TimerStateKeys.DisplayMode.rawValue)) {
            self.displayMode = displayMode
        }
        
        let colorTheme = coder.decodeInteger(forKey: type(of: self).TimerStateKeys.ColorTheme.rawValue)
        self.colorTheme = colorTheme
        
        if let alertMode = AlertMode(rawValue: coder.decodeInteger(forKey: type(of: self).TimerStateKeys.AlertMode.rawValue)) {
            self.alertMode = alertMode
        }
        
        let soundID = coder.decodeInteger(forKey: type(of: self).TimerStateKeys.SoundID.rawValue)
        self.soundID = soundID
        
        if let timerStatus = TimerStatus(rawValue: coder.decodeInteger(forKey: type(of: self).TimerStateKeys.Status.rawValue)) {
            self.timerStatus = timerStatus
        }
        
        if let uid = coder.decodeObject(forKey: type(of: self).TimerStateKeys.UID.rawValue) as? String {
            self.uid = uid
        }
    }
    
    /* ################################################################## */
    /**
     Serialize the object state.
     */
    func encode(with: NSCoder) {
        with.encode(self.timeSet, forKey: type(of: self).TimerStateKeys.TimeSet.rawValue)
        with.encode(self.timeSetPodiumWarn, forKey: type(of: self).TimerStateKeys.TimeSetPodiumWarn.rawValue)
        with.encode(self.timeSetPodiumFinal, forKey: type(of: self).TimerStateKeys.TimeSetPodiumFinal.rawValue)
        with.encode(self.currentTime, forKey: type(of: self).TimerStateKeys.CurrentTime.rawValue)
        with.encode(self.displayMode.rawValue, forKey: type(of: self).TimerStateKeys.DisplayMode.rawValue)
        with.encode(self.colorTheme, forKey: type(of: self).TimerStateKeys.ColorTheme.rawValue)
        with.encode(self.alertMode.rawValue, forKey: type(of: self).TimerStateKeys.AlertMode.rawValue)
        with.encode(self.timerStatus.rawValue, forKey: type(of: self).TimerStateKeys.Status.rawValue)
        with.encode(self.uid, forKey: type(of: self).TimerStateKeys.UID.rawValue)
    }
}

// MARK: - LGV_Timer_AppStatus Class -
/* ###################################################################################################################################### */
/**
 This class encapsulates the entire app status.
 */
class LGV_Timer_AppStatus: NSCoding, Sequence {
    private enum AppStateKeys: String {
        case Timers         = "Timers"
        case SelectedTimer  = "SelectedTimer"
    }
    
    private var _timers:[TimerSettingTuple] = []
    private var _selectedTimer0BasedIndex:Int = -1
    
    // MARK: - Instance Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var timerSelected: Bool {
        get { return 0 <= self.selectedTimerIndex }
    }
    
    /* ################################################################## */
    /**
     */
    var selectedTimer: TimerSettingTuple! {
        get {
            var ret: TimerSettingTuple! = nil
            
            if 0..<self._timers.count ~= self._selectedTimer0BasedIndex {
                ret = self._timers[self._selectedTimer0BasedIndex]
            }
            
            return ret
        }
        
        set {
            self._selectedTimer0BasedIndex = -1
            if let setValue = newValue {
                for index in 0..<self._timers.count {
                    if self._timers[index].uid == setValue.uid {
                        self._selectedTimer0BasedIndex = index
                        break
                    }
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    var selectedTimerIndex: Int {
        get { return self._selectedTimer0BasedIndex }
        set {
            if 0..<self._timers.count ~= newValue {
                self._selectedTimer0BasedIndex = newValue
            } else {
                self._selectedTimer0BasedIndex = -1
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    var selectedTimerUID: String {
        get {
            var ret: String = ""
            
            if 0..<self.count ~= self.selectedTimerIndex {
                ret = self._timers[self.selectedTimerIndex].uid
            }
            
            return ret
        }
        
        set {
            self._selectedTimer0BasedIndex = -1
            
            if !newValue.isEmpty {
                for index in 0..<self._timers.count {
                    if self._timers[index].uid == newValue {
                        self._selectedTimer0BasedIndex = index
                        break
                    }
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    var isEmpty: Bool {
        get { return 0 < self.count }
    }
    
    /* ################################################################## */
    /**
     */
    var count: Int {
        get { return self._timers.count }
    }
    
    /* ################################################################## */
    /**
     */
    var timers: [TimerSettingTuple] {
        get { return self._timers }
        set {
            self._timers = newValue
            if !(0..<self.count ~= self.selectedTimerIndex) {
                self._selectedTimer0BasedIndex = -1
            }
        }
    }
    
    // MARK: - Sequence Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    subscript(_ index: Int) -> TimerSettingTuple {
        return self._timers[index]
    }
    
    /* ################################################################## */
    /**
     */
    func indexOf(_ inUID: String) -> Int {
        var ret: Int = -1
        
        for index in 0..<self._timers.count {
            if self._timers[index].uid == inUID {
                ret = index
                break
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     */
    func indexOf(_ inObject: TimerSettingTuple) -> Int {
        return self.indexOf(inObject.uid)
    }
    
    /* ################################################################## */
    /**
     */
    func contains(_ inObject: TimerSettingTuple) -> Bool {
        return 0 <= self.indexOf(inObject)
    }
    
    /* ################################################################## */
    /**
     */
    func contains(_ inUID: String) -> Bool {
        return 0 <= self.indexOf(inUID)
    }
    
    /* ################################################################## */
    /**
     */
    func makeIterator() -> AnyIterator<TimerSettingTuple> {
        var nextIndex = 0
        
        // Return a "bottom-up" iterator for the list.
        return AnyIterator() {
            if nextIndex == self._timers.count {
                return nil
            }
            nextIndex += 1
            return self._timers[nextIndex - 1]
        }
    }
    
    /* ################################################################## */
    /**
     */
    func append(_ inObject: TimerSettingTuple) {
        self._timers.append(inObject)
    }
    
    /* ################################################################## */
    /**
     */
    func remove(at index: Int) {
        if 0..<self.count ~= index {
            self._timers.remove(at: index)
            if index < self._selectedTimer0BasedIndex {
                self._selectedTimer0BasedIndex -= 1
            } else {
                if index == self._selectedTimer0BasedIndex {
                    self._selectedTimer0BasedIndex = -1
                }
            }
        }
    }
    
    // MARK: - NSCoding Protocol Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Initialize from a serialized state.
     */
    required init?(coder: NSCoder) {
        self._timers = []
        
        if let timers = coder.decodeObject(forKey: type(of: self).AppStateKeys.Timers.rawValue) as? [TimerSettingTuple] {
            self._timers = timers
        }
        
        let selectedTimer0BasedIndex = coder.decodeInteger(forKey: type(of: self).AppStateKeys.SelectedTimer.rawValue)
        self._selectedTimer0BasedIndex = selectedTimer0BasedIndex
    }
    
    /* ################################################################## */
    /**
     Serialize the object state.
     */
    func encode(with: NSCoder) {
        with.encode(self._timers, forKey: type(of: self).AppStateKeys.Timers.rawValue)
        with.encode(self._selectedTimer0BasedIndex, forKey: type(of: self).AppStateKeys.SelectedTimer.rawValue)
    }
}
