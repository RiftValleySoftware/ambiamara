/**
 © Copyright 2018, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

/* ###################################################################################################################################### */
/**
 This file contains declarations and classes that are shared between the phone app and the companion Watch app.
 */

import UIKit

// MARK: - Various Strings, Used in Messaging -
/* ###################################################################################################################################### */
/**
 These are the main message keys between the app and the Watch.
 */
class Timer_Messages {
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
    static let s_timerSendTickMessageKey = "Tick"
    
    static let s_timerListHowdyMessageValue = "HowManyTimers"
    static let s_timerStatusUserInfoValue = "TimerStatus"
    static let s_timerListUserInfoValue = "TimerList"
    static let s_timerAlarmUserInfoValue = "Alarm"
    static let s_timerAppInForegroundMessageValue = "AppData"
}

/**
 These are the data keys for each timer object.
 */
class Timer_Data_Keys {
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
     This allows us to easily localize. Simply use this to apply any localization.
     */
    var localizedVariant: String {
        return NSLocalizedString(self, comment: "")
    }
    
    /* ################################################################## */
    /**
     This extension lets us uppercase only the first letter of the string (used for weekdays).
     From here: https://stackoverflow.com/a/28288340/879365
     
     - returns: The string, with only the first letter uppercased.
     */
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
    
    /* ################################################################## */
    /**
     The following calculated property comes from this: http://stackoverflow.com/a/27736118/879365
     
     This extension function cleans up a URI string.
     
     - returns: a string, cleaned for URI.
     */
    var urlEncodedString: String? {
        let customAllowedSet =  CharacterSet.urlQueryAllowed
        if let ret = self.addingPercentEncoding(withAllowedCharacters: customAllowedSet) {
            return ret
        } else {
            return ""
        }
    }
}

/* ###################################################################################################################################### */
/**
 */
extension UIView {
    /* ################################################################## */
    /**
     This allows us to add a subview, and set it up with auto-layout constraints to fill the superview.
     
     - parameter inSubview: The subview we want to add.
     */
    func addContainedView(_ inSubView: UIView) {
        self.addSubview(inSubView)
        
        inSubView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addConstraints([
            NSLayoutConstraint(item: inSubView,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .top,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: inSubView,
                               attribute: .left,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .left,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: inSubView,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .bottom,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: inSubView,
                               attribute: .right,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .right,
                               multiplier: 1.0,
                               constant: 0)])
    }
    
    /* ################################################################## */
    /**
     - returns: the first responder view. Nil, if no view is a first responder.
     */
    var currentFirstResponder: UIResponder! {
        if self.isFirstResponder {
            return self
        }
        
        for view in self.subviews {
            if let responder = view.currentFirstResponder {
                return responder
            }
        }
        
        return nil
    }
}

/* ###################################################################################################################################### */
/**
 */
extension UIImage {
    /* ################################################################## */
    /**
     This allows us to create a simple "filled color" image.
     
     From here: https://stackoverflow.com/a/33675160/879365
     
     - parameter color: The UIColor we want to fill the image with.
     - parameter size: An optional parameter (default is zero) that designates the size of the image.
     */
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

/* ###################################################################################################################################### */
/**
 */
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
     Public accessor for the hours.
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
     Public accessor for the minutes.
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
     Public accessor for the seconds.
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
        return String(format: "%02d:%02d:%02d", self._hours, self._minutes, self._seconds)
    }
    
    // MARK: - Initializers
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Initialize just like a tuple.
     
     - parameter hours: The number of hours, as an Int, from 0 - 23.
     - parameter minutes: The number of minutes, as an Int, from 0 - 59.
     - parameter seconds: The number of seconds, as an Int, from 0 - 59.
     */
    init(hours: Int, minutes: Int, seconds: Int) {
        self._hours = max(0, min(23, hours))
        self._minutes = max(0, min(59, minutes))
        self._seconds = max(0, min(59, seconds))
    }
    
    /* ################################################################## */
    /**
     Initialize from total seconds.
     
     - parameter inSeconds: The number of seconds as an Int, from 0 - 86399.
     */
    init(_ inSeconds: Int) {
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
 These are the three final alert modes we have for our countdown timer.
 */
enum SoundMode: Int {
    case Sound  = 0
    case Music  = 1
    case Silent = 2
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
 */
class TimerSettingTuple: NSObject, NSCoding {
    // MARK: - Private Static Constants
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     These are the default thresholds that we apply to our timer when automatically determining the "traffic lights" for podium mode.
     */
    private static let _podiumModeWarningThreshold: Float  = (6 / 36)
    private static let _podiumModeFinalThreshold: Float    = (3 / 36)
    
    /* ################################################################## */
    /**
     This enum contains all the various timer state Dictionary keys.
     */
    private enum TimerStateKeys: String {
        case TimeSet
        case TimeSetPodiumWarn
        case TimeSetPodiumFinal
        case CurrentTime
        case DisplayMode
        case ColorTheme
        case AlertMode
        case SoundMode
        case SoundID
        case SongURLString
        case Status
        case UID
    }
    
    var handler: LGV_Timer_State! = nil ///< This is the App Status object that "owns" this instance.
    var firstTick: TimeInterval = 0.0   ///< This will be used to track the timer progress.
    var lastTick: TimeInterval = 0.0    ///< This will be used to track the timer progress.
    var storedColor: AnyObject! = nil   ///< This is the color from the color theme, and is used to transmit the color to the watch.
    
    /* ################################################################## */
    var uid: String                     ///< This will be a unique ID, assigned to the pref, so we can match it.
    
    /* ################################################################## */
    var displayMode: TimerDisplayMode { ///< This is how the timer will display
        didSet {
            if oldValue != self.displayMode {
                if nil != self.handler {
                    self.handler.sendDisplayModeUpdateMessage(self, from: oldValue)
                }
            }
        }
    }

    /* ################################################################## */
    var alertMode: AlertMode {          ///< This determines what kind of alert the timer makes when it is complete.
        didSet {
            if oldValue != self.alertMode {
                if nil != self.handler {
                    self.handler.sendAlertModeUpdateMessage(self, from: oldValue)
                }
            }
        }
    }

    /* ################################################################## */
    var soundMode: SoundMode {          ///< This determines what kind of sound the timer makes when it makes sounds.
        didSet {
            if oldValue != self.soundMode {
                if nil != self.handler {
                    self.handler.sendSoundModeUpdateMessage(self, from: oldValue)
                }
            }
        }
    }

    /* ################################################################## */
    var colorTheme: Int {               ///< This is the 0-based index for the color theme.
        didSet {
            if oldValue != self.colorTheme {
                if nil != self.handler {
                    self.handler.sendColorThemeUpdateMessage(self, from: oldValue)
                }
            }
        }
    }
    
    /* ################################################################## */
    var soundID: Int {                  ///< This will be the 0-based ID of a sound for this timer.
        didSet {
            if oldValue != self.soundID {
                if nil != self.handler {
                    self.handler.sendSoundIDUpdateMessage(self, from: oldValue)
                }
            }
        }
    }
    
    var songURLString: String {
        didSet {
            if oldValue != self.songURLString {
                if nil != self.handler {
                    self.handler.sendSongURLUpdateMessage(self, from: oldValue)
                }
            }
        }
    }
    
    /* ################################################################## */
    var timeSet: Int {                  ///< This is the set (start) time for the countdown timer. It is an integer, with the number of seconds (0 - 86399)
        didSet {
            if oldValue != self.timeSet {
                if nil != self.handler {
                    self.handler.sendSetTimeUpdateMessage(self, from: oldValue)
                }
            }
            
            if self.timeSet <= self.timeSetPodiumWarn {
                self.timeSetPodiumWarn = type(of: self).calcPodiumModeWarningThresholdForTimerValue(self.timeSet)
                self.timeSetPodiumFinal = type(of: self).calcPodiumModeFinalThresholdForTimerValue(self.timeSet)
            }
        }
    }
    
    /* ################################################################## */
    var timeSetPodiumWarn: Int {        ///< This is the number of seconds (0 - 86399) before the yellow light comes on in Podium Mode. If 0, then it is automatically calculated.
        didSet {
            if oldValue != self.timeSetPodiumWarn {
                if nil != self.handler {
                    self.handler.sendWarnTimeUpdateMessage(self, from: oldValue)
                }
            }
        }
    }
    
    /* ################################################################## */
    var timeSetPodiumFinal: Int {       ///< This is the number of seconds (0 - 86399) before the red light comes on in Podium Mode. If 0, then it is automatically calculated.
        didSet {
            if oldValue != self.timeSetPodiumFinal {
                if nil != self.handler {
                    self.handler.sendFinalTimeUpdateMessage(self, from: oldValue)
                }
            }
        }
    }
    
    /* ################################################################## */
    var currentTime: Int {              ///< The actual time for this timer.
        didSet {
            if (nil != self.handler) && (oldValue != self.currentTime) {
                if (.Running == self.timerStatus) || (.WarnRun == self.timerStatus) || (.FinalRun == self.timerStatus) || (.Alarm == self.timerStatus) {
                    self.handler.sendTimeUpdateMessage(self, from: oldValue)
                }
            }
        }
    }
    
    /* ################################################################## */
   var timerStatus: TimerStatus {      ///< This is the current status of this timer.
        didSet {
            if oldValue != self.timerStatus {
                if .Running == self.timerStatus {
                    if (.Stopped == oldValue) || (.Alarm == oldValue) {
                        self.firstTick = Date.timeIntervalSinceReferenceDate
                    }
                    
                    if (.Stopped == oldValue) || (.Alarm == oldValue) || (.Paused == oldValue) {
                        self.lastTick = Date.timeIntervalSinceReferenceDate
                    }
                }
                    
                if .Stopped == self.timerStatus {
                    self.firstTick = 0.0
                    self.lastTick = 0.0
                }
                
                if (.Stopped == self.timerStatus) || ((.Running == self.timerStatus) && ((.Stopped == oldValue) || (.Alarm == oldValue))) {
                    self.currentTime = self.timeSet
                }
                
                if .Alarm == self.timerStatus {
                    self.currentTime = 0
                }
                
                if nil != self.handler {
                    self.handler.sendStatusUpdateMessage(self, from: oldValue)
                }
            }
        }
    }
    
    // MARK: - Instance Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var dictionary: [String: Any] {
        /* ################################################################## */
        get {
            var ret: [String: Any] = [:]
            
            ret["uid"] = self.uid
            ret["timerStatus"] = self.timerStatus.rawValue
            ret["displayMode"] = self.displayMode.rawValue
            ret["alertMode"] = self.alertMode.rawValue
            ret["soundMode"] = self.soundMode.rawValue
            ret["songURLString"] = self.songURLString
            ret["colorTheme"] = self.colorTheme
            ret["timeSet"] = self.timeSet
            ret["timeSetPodiumWarn"] = self.timeSetPodiumWarn
            ret["timeSetPodiumFinal"] = self.timeSetPodiumFinal
            ret["currentTime"] = self.currentTime
            let data = NSMutableData()
            let archiver = NSKeyedArchiver(forWritingWith: data)
            archiver.encode(self.storedColor, forKey: "storedColor")
            archiver.finishEncoding()
            ret["storedColor"] = data
            
            return ret
        }
        
        /* ################################################################## */
        set {
            if let uid = newValue["uid"] as? String {
                self.uid = uid
            }
            
            if let timerStatus = newValue["timerStatus"] as? Int {
                self.timerStatus = TimerStatus(rawValue: timerStatus)!
            }
            
            if let displayMode = newValue["displayMode"] as? Int {
                self.displayMode = TimerDisplayMode(rawValue: displayMode)!
            }
            
            if let alertMode = newValue["alertMode"] as? Int {
                self.alertMode = AlertMode(rawValue: alertMode)!
            }
            
            if let songURLString = newValue["songURLString"] as? String {
                self.songURLString = songURLString
            }

            if let soundMode = newValue["soundMode"] as? Int {
                self.soundMode = SoundMode(rawValue: soundMode)!
            }

            if let colorTheme = newValue["colorTheme"] as? Int {
                self.colorTheme = colorTheme
            }
            
            if let timeSet = newValue["timeSet"] as? Int {
                self.timeSet = timeSet
            }
            
            if let timeSetPodiumWarn = newValue["timeSetPodiumWarn"] as? Int {
                self.timeSetPodiumWarn = timeSetPodiumWarn
            }
            
            if let timeSetPodiumFinal = newValue["timeSetPodiumFinal"] as? Int {
                self.timeSetPodiumFinal = timeSetPodiumFinal
            }
            
            if let currentTime = newValue["currentTime"] as? Int {
                self.currentTime = currentTime
            }
            
            if let storedColor = newValue["storedColor"] as? Data {
                let unarchiver = NSKeyedUnarchiver(forReadingWith: storedColor)
                if let storedColor = unarchiver.decodeObject(forKey: "storedColor") {
                    self.storedColor = storedColor as AnyObject
                }
                unarchiver.finishDecoding()
            }
        }
    }
    
    // MARK: - Initializers
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override init() {
        self.uid = NSUUID().uuidString
        self.handler = nil
        self.timeSet = 0
        self.timeSetPodiumWarn = 0
        self.timeSetPodiumFinal = 0
        self.currentTime = 0
        self.displayMode = .Dual
        self.colorTheme = 0
        self.alertMode = .Silent
        self.soundMode = .Silent
        self.soundID = 5
        self.songURLString = ""
        self.timerStatus = .Stopped
        self.firstTick = 0.0
        self.lastTick = 0.0
        super.init()
    }
    
    /* ################################################################## */
    /**
     Initialize just like a tuple.
     
     - parameter timeSet: This is the set (start) time for the countdown timer. It is an integer, with the number of seconds (0 - 86399)
     - parameter timeSetPodiumWarn: This is the number of seconds (0 - 86399) before the yellow light comes on in Podium Mode. If 0, then it is automatically calculated.
     - parameter timeSetPodiumFinal: This is the number of seconds (0 - 86399) before the red light comes on in Podium Mode. If 0, then it is automatically calculated.
     - parameter displayMode: This is how the timer will display
     - parameter colorTheme: This is the 0-based index for the color theme.
     - parameter alertMode: This determines what kind of alert the timer makes when it is complete.
     - parameter soundMode: This determines what kind of sound the timer makes when it makes sounds.
     - parameter soundID: This is the ID of the sound to play (when in mode 1 or 2).
     - parameter songURLString: This is a String, containing a music URL (when in mode 1 or 2).
     - parameter uid: This is a unique ID for this setting. It can be defaulted.
     - parameter handler: This is the "owner" of this instance. Default is nil.
     */
    convenience init(timeSet: Int, timeSetPodiumWarn: Int, timeSetPodiumFinal: Int, currentTime: Int, displayMode: TimerDisplayMode, colorTheme: Int, alertMode: AlertMode, soundMode: SoundMode, alertVolume: Int, soundID: Int, songURLString: String, timerStatus: TimerStatus, uid: String!, handler: LGV_Timer_State! = nil) {
        self.init()
        self.timeSet = timeSet
        self.timeSetPodiumWarn = timeSetPodiumWarn
        self.timeSetPodiumFinal = timeSetPodiumFinal
        self.currentTime = currentTime
        self.displayMode = displayMode
        self.colorTheme = colorTheme
        self.alertMode = alertMode
        self.soundMode = soundMode
        self.soundID = soundID
        self.songURLString = songURLString
        self.timerStatus = timerStatus
        self.uid = (nil == uid) ? NSUUID().uuidString: uid
        self.handler = handler
    }
    
    /* ################################################################## */
    /**
     Initialize from a stored dictionary.
     
     - parameter dictionary: This is a Dictionary that contains the state.
     - parameter handler: This is the "owner" of this instance. Default is nil.
     */
    convenience init(dictionary: [String: Any], handler: LGV_Timer_State! = nil) {
        self.init()
        self.dictionary = dictionary
        self.handler = handler
    }
    
    // MARK: - Instance Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Returns the value in an easily readable format.
     */
    override var description: String {
        let ret = String(format: "timeSet: %d, timeSetPodiumWarn: %d, timeSetPodiumFinal: %d, currentTime: %d, displayMode: %d, colorTheme: %d, alertMode: %d, soundMode: %d, songURLString: %@, soundID: %d, timerStatus: %d, firstTick: %.5f, lastTick: %.5f, uid: %@",
                      self.timeSet,
                      self.timeSetPodiumWarn,
                      self.timeSetPodiumFinal,
                      self.currentTime,
                      self.displayMode.rawValue,
                      self.colorTheme,
                      self.alertMode.rawValue,
                      self.soundMode.rawValue,
                      self.songURLString,
                      self.soundID,
                      self.timerStatus.rawValue,
                      self.firstTick,
                      self.lastTick,
                      self.uid
        )
        
        return ret
    }
    
    /* ################################################################## */
    /**
     Returns true if this is selected.
     */
    var selected: Bool {
        get {
            if nil != self.handler {
                return self.handler!.selectedTimerUID == self.uid
            }
            
            return false
        }
        
        set {
            if nil != self.handler {
                if (self.handler!.selectedTimerUID == self.uid) && !newValue {
                    self.handler!.selectedTimerUID = ""
                } else {
                    if newValue {
                        if self.handler!.selectedTimerUID != self.uid {
                            self.timerStatus = .Stopped
                        }
                        self.handler!.selectedTimerUID = self.uid
                    }
                }
            }
        }
    }
    
    // MARK: - Internal Class Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This calculates the auto-calculation for the "warning," or "yellow traffic light" for the Podium Mode timer.
     
     - parameter inTimerSet: The value of the countdown timer.
     
     - returns: an Int, with the warning threshold.
     */
    class func calcPodiumModeWarningThresholdForTimerValue(_ inTimerSet: Int) -> Int {
        return max(0, min(inTimerSet, Int(ceil(Float(inTimerSet) * self._podiumModeWarningThreshold))))
    }
    
    /* ################################################################## */
    /**
     This calculates the auto-calculation for the "final," or "red traffic light" for the Podium Mode timer.
     
     - parameter inTimerSet: The value of the countdown timer.
     
     - returns: an Int, with the final threshold.
     */
    class func calcPodiumModeFinalThresholdForTimerValue(_ inTimerSet: Int) -> Int {
        return max(0, min(calcPodiumModeWarningThresholdForTimerValue(inTimerSet), Int(ceil(Float(inTimerSet) * self._podiumModeFinalThreshold))))
    }
    
    // MARK: - Static Operator Overloads
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Equatable operator. Simply compares the UIDs
     
     - parameter left: The left timer object.
     - parameter right: The right timer object.
     
     - returns: true, if the UIDs match.
     */
    static func == (left: TimerSettingTuple, right: TimerSettingTuple) -> Bool {
        return left.uid == right.uid
    }
    
    // MARK: - Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Delete thyself.
     */
    func seppuku() {
        if nil != self.handler {
            let myIndex = self.handler.indexOf(self)
            self.handler.remove(at: myIndex)
        }
    }
    
    // MARK: - NSCoding Protocol Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Initialize from a serialized state.
     
     - parameter coder: The coder containing the state
     */
    required init?(coder: NSCoder) {
        self.songURLString = ""
        self.displayMode = .Dual
        self.alertMode = .Both
        self.soundMode = .Sound
        self.timerStatus = .Stopped
        self.uid = ""
        self.firstTick = 0.0
        self.lastTick = 0.0
        self.handler = nil

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
        
        if let soundMode = SoundMode(rawValue: coder.decodeInteger(forKey: type(of: self).TimerStateKeys.SoundMode.rawValue)) {
            self.soundMode = soundMode
        }

        let soundID = coder.decodeInteger(forKey: type(of: self).TimerStateKeys.SoundID.rawValue)
        self.soundID = soundID
        
        if let songURLString = coder.decodeObject(forKey: type(of: self).TimerStateKeys.SongURLString.rawValue) as? String {
            self.songURLString = songURLString
        }

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
     
     - parameter with: The coder we'll be setting the state into.
     */
    func encode(with: NSCoder) {
        with.encode(self.timeSet, forKey: type(of: self).TimerStateKeys.TimeSet.rawValue)
        with.encode(self.timeSetPodiumWarn, forKey: type(of: self).TimerStateKeys.TimeSetPodiumWarn.rawValue)
        with.encode(self.timeSetPodiumFinal, forKey: type(of: self).TimerStateKeys.TimeSetPodiumFinal.rawValue)
        with.encode(self.currentTime, forKey: type(of: self).TimerStateKeys.CurrentTime.rawValue)
        with.encode(self.displayMode.rawValue, forKey: type(of: self).TimerStateKeys.DisplayMode.rawValue)
        with.encode(self.colorTheme, forKey: type(of: self).TimerStateKeys.ColorTheme.rawValue)
        with.encode(self.alertMode.rawValue, forKey: type(of: self).TimerStateKeys.AlertMode.rawValue)
        with.encode(self.soundMode.rawValue, forKey: type(of: self).TimerStateKeys.SoundMode.rawValue)
        with.encode(self.songURLString, forKey: type(of: self).TimerStateKeys.SongURLString.rawValue)
        with.encode(self.timerStatus.rawValue, forKey: type(of: self).TimerStateKeys.Status.rawValue)
        with.encode(self.soundID, forKey: type(of: self).TimerStateKeys.SoundID.rawValue)
        with.encode(self.uid, forKey: type(of: self).TimerStateKeys.UID.rawValue)
    }
}

// MARK: - LGV_Timer_AppStatusDelegate Protocol -
/* ###################################################################################################################################### */
/**
 This protocol allows observers of the app status.
 */
protocol LGV_Timer_StateDelegate: class {
    func appState(_ appState: LGV_Timer_State, didUpdateTimerStatus: TimerSettingTuple, from: TimerStatus)
    func appState(_ appState: LGV_Timer_State, didUpdateTimerDisplayMode: TimerSettingTuple, from: TimerDisplayMode)
    func appState(_ appState: LGV_Timer_State, didUpdateTimerCurrentTime: TimerSettingTuple, from: Int)
    func appState(_ appState: LGV_Timer_State, didUpdateTimerSoundID: TimerSettingTuple, from: Int)
    func appState(_ appState: LGV_Timer_State, didUpdateTimerSongURL: TimerSettingTuple, from: String)
    func appState(_ appState: LGV_Timer_State, didUpdateTimerAlertMode: TimerSettingTuple, from: AlertMode)
    func appState(_ appState: LGV_Timer_State, didUpdateTimerSoundMode: TimerSettingTuple, from: SoundMode)
    func appState(_ appState: LGV_Timer_State, didUpdateTimerColorTheme: TimerSettingTuple, from: Int)
    func appState(_ appState: LGV_Timer_State, didUpdateTimerWarnTime: TimerSettingTuple, from: Int)
    func appState(_ appState: LGV_Timer_State, didUpdateTimerFinalTime: TimerSettingTuple, from: Int)
    func appState(_ appState: LGV_Timer_State, didUpdateTimerTimeSet: TimerSettingTuple, from: Int)
    func appState(_ appState: LGV_Timer_State, didAddTimer: TimerSettingTuple)
    func appState(_ appState: LGV_Timer_State, willRemoveTimer: TimerSettingTuple)
    func appState(_ appState: LGV_Timer_State, didRemoveTimerAtIndex: Int)
    func appState(_ appState: LGV_Timer_State, didSelectTimer: TimerSettingTuple!)
    func appState(_ appState: LGV_Timer_State, didDeselectTimer: TimerSettingTuple)
}

// MARK: - LGV_Timer_State Class -
/* ###################################################################################################################################### */
/**
 This class encapsulates the entire app status.
 */
class LGV_Timer_State: NSObject, NSCoding, Sequence {
    private enum AppStateKeys: String {
        case Timers
        case SelectedTimer
        case ShowControls
    }
    
    private var _timers: [TimerSettingTuple] = []
    private var _selectedTimer0BasedIndex: Int = -1
    private var _showControlsInRunningTimer: Bool = true
        
    weak var delegate: LGV_Timer_StateDelegate! = nil
    
    // MARK: - Instance Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var timerSelected: Bool {
        return 0 <= self.selectedTimerIndex
    }
    
    /* ################################################################## */
    /**
     */
    var showControlsInRunningTimer: Bool {
        get { return self._showControlsInRunningTimer }
        set { self._showControlsInRunningTimer = newValue }
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
            DispatchQueue.main.async {
                if let oldTimer = self.selectedTimer {
                    if oldTimer.uid != newValue.uid {
                        if nil != self.delegate {
                            self.delegate.appState(self, didDeselectTimer: oldTimer)
                        }
                    }
                }
                
                self._selectedTimer0BasedIndex = -1
                
                if let setValue = newValue {
                    for index in 0..<self._timers.count where self._timers[index].uid == setValue.uid {
                        self._selectedTimer0BasedIndex = index
                        if nil != self.delegate { self.delegate.appState(self, didSelectTimer: self._timers[index]) }
                        break
                    }
                } else {
                    self._selectedTimer0BasedIndex = -1
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
            DispatchQueue.main.async {
                let oldTimer = self.selectedTimer
                var newTimer: TimerSettingTuple! = nil
                
                if 0..<self._timers.count ~= newValue {
                    self._selectedTimer0BasedIndex = newValue
                    newTimer = self.selectedTimer
                } else {
                    self._selectedTimer0BasedIndex = -1
                }
                
                if nil != self.delegate {
                    if nil != oldTimer {
                        self.delegate.appState(self, didDeselectTimer: oldTimer!)
                    }
                    
                    self.delegate.appState(self, didSelectTimer: newTimer)
                }
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
            DispatchQueue.main.async {
                if let oldTimer = self.selectedTimer {
                    if oldTimer.uid != newValue {
                        if nil != self.delegate {
                            self.delegate.appState(self, didDeselectTimer: oldTimer)
                        }
                    }
                }
                
                self._selectedTimer0BasedIndex = -1
                
                if !newValue.isEmpty {
                    for index in 0..<self._timers.count where self._timers[index].uid == newValue {
                        self._selectedTimer0BasedIndex = index
                        if nil != self.delegate {
                            self.delegate.appState(self, didSelectTimer: self._timers[index])
                        }
                        break
                    }
                } else {
                    self._selectedTimer0BasedIndex = -1
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    var isEmpty: Bool {
        return 0 < self.count
    }
    
    /* ################################################################## */
    /**
     */
    var count: Int {
        return self._timers.count
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
    
    /* ################################################################## */
    /**
     */
    var dictionary: [String: Any] {
        get {
            var ret: [String: Any] = [:]
            ret["selectedTimerIndex"] = self.selectedTimerIndex
            var timerArray: [[String: Any]] = []
            for timer in self.timers {
                let timerDictionary = timer.dictionary
                timerArray.append(timerDictionary)
            }
            ret["timers"] = timerArray
            return ret
        }
        
        set {
            if let selectedTimerIndex = newValue["selectedTimerIndex"] as? Int {
                self.selectedTimerIndex = selectedTimerIndex
            }
            
            if let timerArray = newValue["timers"] as? [[String: Any]] {
                // We do this really strange dance in order to prevent timer objects from being removed or orphaned.
                // This array simply makes sure we get rid of timers we don't have in the new list, add new ones, and set existing timers to new settings.
                var newTimerArray: [TimerSettingTuple] = []
                
                // We append any new timer objects that we didn't already have, and set existing objects to their new values. We put existing objects where we want them in the new order.
                for timerDictionary in timerArray {
                    if let uid = timerDictionary["uid"] as? String {
                        var found: Bool = false
                        
                        // See if we already have this object. If so, we set it to the new value, and append it now.
                        for timerObject in self.timers where timerObject.uid == uid {
                            timerObject.dictionary = timerDictionary
                            newTimerArray.append(timerObject)
                            found = true
                            break
                        }
                        
                        // If we didn't find it, we append a new instance.
                        if !found {
                            newTimerArray.append(TimerSettingTuple(dictionary: timerDictionary, handler: self))
                        }
                    }
                }
                
                self.timers = newTimerArray
            }
        }
    }
    
    // MARK: - Initializer
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    init(delegate: LGV_Timer_StateDelegate) {
        self.delegate = delegate
    }
    
    /* ################################################################## */
    /**
     Initialize from a stored dictionary.
     
     - parameter dictionary: This is a Dictionary that contains the state.
     - parameter delegate: This is the "owner" of this instance. Default is nil.
     */
    init(dictionary: [String: Any], delegate: LGV_Timer_StateDelegate! = nil) {
        super.init()
        self.dictionary = dictionary
        self.delegate = delegate
    }
    
    // MARK: - Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func createNewTimer() -> TimerSettingTuple {
        let ret = TimerSettingTuple()
        
        ret.handler = self
        
        DispatchQueue.main.async {
            self.append(ret)
            
            self.delegate?.appState(self, didAddTimer: ret)
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     */
    func sendTimeUpdateMessage(_ inTimerObject: TimerSettingTuple, from: Int) {
        DispatchQueue.main.async {
            self.delegate?.appState(self, didUpdateTimerCurrentTime: inTimerObject, from: from)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendSoundIDUpdateMessage(_ inTimerObject: TimerSettingTuple, from: Int) {
        DispatchQueue.main.async {
            self.delegate?.appState(self, didUpdateTimerSoundID: inTimerObject, from: from)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendSongURLUpdateMessage(_ inTimerObject: TimerSettingTuple, from: String) {
        DispatchQueue.main.async {
            self.delegate?.appState(self, didUpdateTimerSongURL: inTimerObject, from: from)
        }
    }

    /* ################################################################## */
    /**
     */
    func sendAlertModeUpdateMessage(_ inTimerObject: TimerSettingTuple, from: AlertMode) {
        DispatchQueue.main.async {
            self.delegate?.appState(self, didUpdateTimerAlertMode: inTimerObject, from: from)
        }
    }

    /* ################################################################## */
    /**
     */
    func sendSoundModeUpdateMessage(_ inTimerObject: TimerSettingTuple, from: SoundMode) {
        DispatchQueue.main.async {
            self.delegate?.appState(self, didUpdateTimerSoundMode: inTimerObject, from: from)
        }
    }

    /* ################################################################## */
    /**
     */
    func sendColorThemeUpdateMessage(_ inTimerObject: TimerSettingTuple, from: Int) {
        DispatchQueue.main.async {
            self.delegate?.appState(self, didUpdateTimerColorTheme: inTimerObject, from: from)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendSetTimeUpdateMessage(_ inTimerObject: TimerSettingTuple, from: Int) {
        DispatchQueue.main.async {
            self.delegate?.appState(self, didUpdateTimerTimeSet: inTimerObject, from: from)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendWarnTimeUpdateMessage(_ inTimerObject: TimerSettingTuple, from: Int) {
        DispatchQueue.main.async {
            self.delegate?.appState(self, didUpdateTimerWarnTime: inTimerObject, from: from)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendFinalTimeUpdateMessage(_ inTimerObject: TimerSettingTuple, from: Int) {
        DispatchQueue.main.async {
            self.delegate?.appState(self, didUpdateTimerFinalTime: inTimerObject, from: from)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendStatusUpdateMessage(_ inTimerObject: TimerSettingTuple, from: TimerStatus) {
        DispatchQueue.main.async {
            self.delegate?.appState(self, didUpdateTimerStatus: inTimerObject, from: from)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendDisplayModeUpdateMessage(_ inTimerObject: TimerSettingTuple, from: TimerDisplayMode) {
        DispatchQueue.main.async {
            self.delegate?.appState(self, didUpdateTimerDisplayMode: inTimerObject, from: from)
        }
    }
    
    /* ################################################################################################################################## */
    // MARK: - Sequence Methods
    /* ################################################################################################################################## */
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
        
        if !inUID.isEmpty {
            for index in 0..<self._timers.count where self._timers[index].uid == inUID {
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
        return AnyIterator {
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
        DispatchQueue.main.async {
            self._timers.append(inObject)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func remove(at index: Int) {
        DispatchQueue.main.async {
            if 0..<self.count ~= index {
                let timer = self[index]
                
                if nil != self.delegate {
                    self.delegate.appState(self, willRemoveTimer: timer)
                }
                
                self._timers.remove(at: index)
                if index < self._selectedTimer0BasedIndex {
                    self._selectedTimer0BasedIndex -= 1
                } else {
                    if index == self._selectedTimer0BasedIndex {
                        self._selectedTimer0BasedIndex = -1
                    }
                }
                
                if nil != self.delegate {
                    self.delegate.appState(self, didRemoveTimerAtIndex: index)
                }
            }
        }
    }
    
    /* ################################################################################################################################## */
    // MARK: - NSCoding Protocol Methods
    /* ################################################################################################################################## */
    /**
     Initialize from a serialized state.
     
     - parameter coder: The coder we'll be getting the state from.
     */
    required init?(coder: NSCoder) {
        super.init()
        
        self._timers = []
        
        if let timers = coder.decodeObject(forKey: type(of: self).AppStateKeys.Timers.rawValue) as? [TimerSettingTuple] {
            self._timers = timers
            
            for timer in self.timers {
                timer.handler = self
            }
        }
        
        if coder.containsValue(forKey: type(of: self).AppStateKeys.SelectedTimer.rawValue) {
            let selectedTimer0BasedIndex = coder.decodeInteger(forKey: type(of: self).AppStateKeys.SelectedTimer.rawValue)
            self._selectedTimer0BasedIndex = selectedTimer0BasedIndex
        } else {
            self._selectedTimer0BasedIndex = -1
        }
        
        if coder.containsValue(forKey: type(of: self).AppStateKeys.ShowControls.rawValue) {
            let showControls = coder.decodeBool(forKey: type(of: self).AppStateKeys.ShowControls.rawValue)
            self._showControlsInRunningTimer = showControls
        } else {
            self._showControlsInRunningTimer = true
        }
    }
    
    /* ################################################################## */
    /**
     Serialize the object state.
     
     - parameter with: The coder we'll be setting the state into.
     */
    func encode(with: NSCoder) {
        with.encode(self._timers, forKey: type(of: self).AppStateKeys.Timers.rawValue)
        with.encode(self._selectedTimer0BasedIndex, forKey: type(of: self).AppStateKeys.SelectedTimer.rawValue)
        with.encode(self._showControlsInRunningTimer, forKey: type(of: self).AppStateKeys.ShowControls.rawValue)
    }
}
