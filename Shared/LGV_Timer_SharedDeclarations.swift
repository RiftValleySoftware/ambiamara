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
    static let s_timerConnectionAckMessageKey = "BillTheCat"
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

// MARK: - TimerSettingTuple Class -
/* ###################################################################################################################################### */
/**
 This is the basic element that describes one timer.
 
 It is a class, because that means that references (as opposed to copies) will be passed around.
 */
class TimerSettingTuple {
    var timeSet: Int                    ///< This is the set (start) time for the countdown timer. It is an integer, with the number of seconds (0 - 86399)
    var timeSetPodiumWarn: Int          ///< This is the number of seconds (0 - 86399) before the yellow light comes on in Podium Mode. If 0, then it is automatically calculated.
    var timeSetPodiumFinal: Int         ///< This is the number of seconds (0 - 86399) before the red light comes on in Podium Mode. If 0, then it is automatically calculated.
    var displayMode: TimerDisplayMode   ///< This is how the timer will display
    var colorTheme: Int                 ///< This is the 0-based index for the color theme.
    var alertMode: AlertMode            ///< This determines what kind of alert the timer makes when it is complete.
    var soundID: Int                    ///< This will be the ID of a system sound for this timer.
    var uid: String                     ///< This will be a unique ID, assigned to the pref, so we can match it.
    
    // MARK: - Initializers
    /* ################################################################################################################################## */
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
    init(timeSet: Int, timeSetPodiumWarn: Int, timeSetPodiumFinal: Int, displayMode: TimerDisplayMode, colorTheme: Int, alertMode: AlertMode, alertVolume: Int, soundID: Int, uid: String!) {
        
        self.timeSet = timeSet
        self.timeSetPodiumWarn = timeSetPodiumWarn
        self.timeSetPodiumFinal = timeSetPodiumFinal
        self.displayMode = displayMode
        self.colorTheme = colorTheme
        self.alertMode = alertMode
        self.soundID = soundID
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
            return String(format: "timeSet: %@, timeSetPodiumWarn: %@, timeSetPodiumFinal: %d, displayMode: %@, colorTheme: %d, alertMode: %d, soundID: %d, uid: %@",
                          self.timeSet.description,
                          self.timeSetPodiumWarn.description,
                          self.timeSetPodiumFinal.description,
                          self.displayMode.rawValue,
                          self.colorTheme,
                          self.alertMode.rawValue,
                          self.soundID,
                          self.uid
            )
        }
    }
}
