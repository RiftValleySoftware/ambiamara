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

/* ###################################################################################################################################### */
// MARK: - Various Strings, Used in Messaging -
/* ###################################################################################################################################### */
/**
 These are the main message keys between the app and the Watch.
 */
class Timer_Messages {
    /// Select a timer
    static let s_timerListSelectTimerMessageKey = "SelectTimer"
    /// Start a timer
    static let s_timerListStartTimerMessageKey = "StartTimer"
    /// Pause a timer
    static let s_timerListPauseTimerMessageKey = "PauseTimer"
    /// Stop a timer
    static let s_timerListStopTimerMessageKey = "StopTimer"
    /// Reset a timer to start
    static let s_timerListResetTimerMessageKey = "ResetTimer"
    /// Force a timer to end
    static let s_timerListEndTimerMessageKey = "EndTimer"
    /// Update a timer to current state
    static let s_timerListUpdateTimerMessageKey = "UpdateTimer"
    /// Update a timer completely
    static let s_timerListUpdateFullTimerMessageKey = "UpdateFullTimer"
    /// List the alarms
    static let s_timerListAlarmMessageKey = "W00t!"
    /// App is going into background
    static let s_timerAppInBackgroundMessageKey = "AppInBackground"
    /// App is coming into foreground
    static let s_timerAppInForegroundMessageKey = "AppInForeground"
    /// Ask for app status
    static let s_timerRequestAppStatusMessageKey = "WhatUpDood"
    /// Ask for status of active timer
    static let s_timerRequestActiveTimerUIDMessageKey = "Whazzup"
    /// Recalculate the timer messages
    static let s_timerRecaclulateTimersMessageKey = "ScarfNBarf"
    /// Resend the timer list
    static let s_timerSendListAgainMessageKey = "SayWhut"
    /// Send a new tick
    static let s_timerSendTickMessageKey = "Tick"
    /// Ask how many timers there are
    static let s_timerListHowdyMessageValue = "HowManyTimers"
    /// Ask for timer status
    static let s_timerStatusUserInfoValue = "TimerStatus"
    /// Ask for timer list
    static let s_timerListUserInfoValue = "TimerList"
    /// Ask for alarm data
    static let s_timerAlarmUserInfoValue = "Alarm"
    /// The app is in the forground
    static let s_timerAppInForegroundMessageValue = "AppData"
}

/**
 These are the data keys for each timer object.
 */
class Timer_Data_Keys {
    /// A unique ID
    static let s_timerDataUIDKey = "UID"
    /// The name of the timer
    static let s_timerDataTimerNameKey = "TimerName"
    /// The timer setting
    static let s_timerDataTimeSetKey = "TimeSet"
    /// The current time
    static let s_timerDataCurrentTimeKey = "CurrentTime"
    /// Set the warning threshold
    static let s_timerDataTimeSetWarnKey = "TimeSetWarn"
    /// Set the final threshold
    static let s_timerDataTimeSetFinalKey = "TimeSetFinal"
    /// Display the mode
    static let s_timerDataDisplayModeKey = "DisplayMode"
    /// Display the color
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
 These are useful UIView extensions that we use to get the current first responder, and add dynamically-constructed auto layout views.
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
        inSubView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        inSubView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        inSubView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        inSubView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
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
 This is a simple way to create a simple "color rectangle."
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
 Just a way to get an int from our time tuple.
 */
extension Int {
    /* ################################################################## */
    /**
     Casting operator for TimeTuple to an integer.
     */
    init(_ inTimeTuple: TimeInstance) {
        self.init(inTimeTuple.intVal)
    }
}

/* ###################################################################################################################################### */
// MARK: - TimeInstance Class -
/* ###################################################################################################################################### */
/**
 This class holds the timer value as hours, minutes and seconds.
 */
class TimeInstance {
    // MARK: - Private Instance Properties
    /* ################################################################################################################################## */
    /// The number of hours in this instance, from 0 - 23
    private var _hours: Int
    /// The number of minutes in this instance, from 0 - 59
    private var _minutes: Int
    /// The number of seconds in this instance, from 0 - 59
    private var _seconds: Int
    
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
     
     - returns: The hours (0 - 23)
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
     
     - returns: The minutes (0 - 59)
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
     
     - returns: The seconds (0 - 59)
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
     - returns: the value of the instance as DateComponents, for easy use in date calculations.
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
    
    /* ###################################################################################################################################### */
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
    /// Display only digits.
    case Digital    = 0
    /// Display only "podium lights."
    case Podium     = 1
    /// Display both.
    case Dual       = 2
}

/* ################################################################## */
/**
 These are the three final alert modes we have for our countdown timer.
 */
enum AlertMode: Int {
    /// Silent mode
    case Silent         = 0
    /// Vibrate only mode
    case VibrateOnly    = 1
    /// Sound only mode
    case SoundOnly      = 2
    /// Both sound and vibrate mode
    case Both           = 3
}

/* ################################################################## */
/**
 These are the three final alert modes we have for our countdown timer.
 */
enum SoundMode: Int {
    /// Play a preset sound
    case Sound  = 0
    /// Play a selected song
    case Music  = 1
    /// Silent
    case Silent = 2
}

/* ################################################################## */
/**
 These are the various states a timer can be in.
 */
enum TimerStatus: Int {
    /// This is set for a timeSet value of 0.
    case Invalid        = 0
    /// This means the timer is not running, and currentTime is timeSet.
    case Stopped        = 1
    /// The timer is paused, and the currentTime is less than timeSet.
    case Paused         = 2
    /// The timer is running "green," which means that currentTime is greater than timeSetWarn.
    case Running        = 3
    /// The timer is running "yellow," which means that currentTime is less than, or equal to timeSetWarn.
    case WarnRun        = 4
    /// The timer is running "red," which means that currentTime is less than, or equal to timeSetFinal.
    case FinalRun       = 5
    /// The timer is in an alarm state, which means that currentTime is 0.
    case Alarm          = 6
}

/* ###################################################################################################################################### */
// MARK: - TimerSettingClass Class -
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
    /// A preset warning threshold
    private static let _podiumModeWarningThreshold: Float  = (6 / 36)
    /// A preset final threshold (half the warning)
    private static let _podiumModeFinalThreshold: Float    = (3 / 36)
    
    /* ################################################################## */
    /**
     This enum contains all the various timer state Dictionary keys.
     */
    private enum TimerStateKeys: String {
        /// Time is being set
        case TimeSet
        /// Warning time is being set
        case TimeSetPodiumWarn
        /// Final time is being set
        case TimeSetPodiumFinal
        /// The current time is being changed
        case CurrentTime
        /// The display mode is being changed
        case DisplayMode
        /// The color theme is being changed
        case ColorTheme
        /// The alert mode is being changed
        case AlertMode
        /// The sound mode is being changed
        case SoundMode
        /// The sound ID is being changed
        case SoundID
        /// The song URL is being changed
        case SongURLString
        /// The next timer is being changed
        case SucceedingTimerID
        /// The audible ticks mode is being changed
        case AudibleTicks
        /// The status is being  changed
        case Status
        /// The UID is being changed
        case UID
    }

    /* ################################################################################################################################## */
    // MARK: - Instance Properties
    /* ################################################################################################################################## */
    /// This is the App Status object that "owns" this instance.
    var handler: LGV_Timer_State! = nil
    /// This will be used to track the timer progress.
    var firstTick: TimeInterval = 0.0
    /// This will be used to track the timer progress.
    var lastTick: TimeInterval = 0.0
    /// This is the color from the color theme, and is used to transmit the color to the watch.
    var storedColor: AnyObject! = nil
    /// This will be a unique ID, assigned to the pref, so we can match it.
    var uid: String = ""
    
    /* ################################################################## */
    /// This is how the timer will display
    var displayMode: TimerDisplayMode {
        didSet {
            if oldValue != self.displayMode {
                if nil != self.handler {
                    self.handler.sendDisplayModeUpdateMessage(self, from: oldValue)
                }
            }
        }
    }
    
    /* ################################################################## */
    /// This determines what kind of alert the timer makes when it is complete.
    var alertMode: AlertMode {
        didSet {
            if oldValue != self.alertMode {
                if nil != self.handler {
                    self.handler.sendAlertModeUpdateMessage(self, from: oldValue)
                }
            }
        }
    }
    
    /* ################################################################## */
    /// This determines what kind of sound the timer makes when it makes sounds.
    var soundMode: SoundMode {
        didSet {
            if oldValue != self.soundMode {
                if nil != self.handler {
                    self.handler.sendSoundModeUpdateMessage(self, from: oldValue)
                }
            }
        }
    }
    
    /* ################################################################## */
    /// This is the 0-based index for the color theme.
    var colorTheme: Int {
        didSet {
            if oldValue != self.colorTheme {
                if nil != self.handler {
                    self.handler.sendColorThemeUpdateMessage(self, from: oldValue)
                }
            }
        }
    }
    
    /* ################################################################## */
    /// This will be the 0-based ID of a sound for this timer.
    var soundID: Int {
        didSet {
            if oldValue != self.soundID {
                if nil != self.handler {
                    self.handler.sendSoundIDUpdateMessage(self, from: oldValue)
                }
            }
        }
    }
    
    /* ################################################################## */
    /// This will be the 0-based ID of a following timer for this. -1, if no succeeding timer.
    var succeedingTimerID: Int {
        didSet {
            if oldValue != self.succeedingTimerID {
                if nil != self.handler {
                    self.handler.sendSucceedingTimerIDUpdateMessage(self, from: oldValue)
                }
            }
        }
    }
    
    /* ################################################################## */
    /// This will be a boolean value that is true if the timer is to make audible ticks and transition noises.
    var audibleTicks: Bool {
        didSet {
            if oldValue != self.audibleTicks {
                if nil != self.handler {
                    self.handler.sendAudibleTicksUpdateMessage(self, from: oldValue)
                }
            }
        }
    }
    
    /* ################################################################## */
    /// This is the URI of a selected song to play as an alarm.
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
    /// This is the set (start) time for the countdown timer. It is an integer, with the number of seconds (0 - 86399)
    var timeSet: Int {
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
    /// This is the number of seconds (0 - 86399) before the yellow light comes on in Podium Mode. If 0, then it is automatically calculated.
    var timeSetPodiumWarn: Int {
        didSet {
            if oldValue != self.timeSetPodiumWarn {
                if nil != self.handler {
                    self.handler.sendWarnTimeUpdateMessage(self, from: oldValue)
                }
            }
        }
    }
    
    /* ################################################################## */
    /// This is the number of seconds (0 - 86399) before the red light comes on in Podium Mode. If 0, then it is automatically calculated.
    var timeSetPodiumFinal: Int {
        didSet {
            if oldValue != self.timeSetPodiumFinal {
                if nil != self.handler {
                    self.handler.sendFinalTimeUpdateMessage(self, from: oldValue)
                }
            }
        }
    }
    
    /* ################################################################## */
    /// The actual time for this timer.
    var currentTime: Int {
        didSet {
            if (nil != self.handler) && (oldValue != self.currentTime) {
                if (.Running == self.timerStatus) || (.WarnRun == self.timerStatus) || (.FinalRun == self.timerStatus) || (.Alarm == self.timerStatus) {
                    self.handler.sendTimeUpdateMessage(self, from: oldValue)
                }
            }
        }
    }
    
    /* ################################################################## */
    /// This is the current status of this timer.
    var timerStatus: TimerStatus {
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
    
    /* ################################################################################################################################## */
    // MARK: - Instance Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /// The actual time for this timer, as a long, spoken text string.
    var setSpeakableTime: String {
        var ret = [String]()
        
        let hours = Int(self.timeSet / (60 * 60))
        let minutes = Int(self.timeSet / (60)) - (hours * 60)
        let seconds = Int(self.timeSet) - (minutes * 60) - (hours * 60 * 60)
        
        if 0 < hours {
            if 1 == hours {
                ret.append("TIME-HOUR".localizedVariant)
            } else {
                ret.append(String(format: "TIME-HOURS-FORMAT".localizedVariant, hours))
            }
        }
        
        if 0 < minutes {
            if 1 == minutes {
                ret.append("TIME-MINUTE".localizedVariant)
            } else {
                ret.append(String(format: "TIME-MINUTES-FORMAT".localizedVariant, minutes))
            }
        }
        
        if 1 == seconds {
            ret.append("TIME-SECOND".localizedVariant)
        } else if 0 == hours && 0 == minutes {
            ret.append(String(format: "TIME-SECONDS-FORMAT".localizedVariant, seconds))
        }
        
        return ret.joined(separator: " ")
    }
    
    /* ################################################################## */
    /// The actual time for this timer, as a numerical only, spoken text string.
    var currentQuickSpeakableTime: String {
        var ret = [String]()
        
        let currTime = self.currentTime - 1 // We do this, because we lose a second while talking.
        
        let hours = Int(currTime / (60 * 60))
        let minutes = Int(currTime / (60)) - (hours * 60)
        let seconds = Int(currTime) - (minutes * 60) - (hours * 60 * 60)
        
        if 0 < hours {
            ret.append(String(hours))
        }
        
        if 0 < hours || 0 < minutes {
            if 9 < minutes || 0 == hours {  // Make sure we speak two digits.
                ret.append(String(minutes))
            } else if 0 < hours {
                ret.append("0" + String(minutes))
            }
        }
        
        if 9 < seconds || (0 == hours && 0 == minutes) {
            ret.append(String(seconds))
        } else {
            ret.append("0" + String(seconds))
        }

        return ret.joined(separator: " ")
    }
    
    /* ################################################################## */
    /**
     - returns: The state, as a simple dictionary object.
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
            ret["succeedingTimerID"] = self.succeedingTimerID
            ret["audibleTicks"] = self.audibleTicks
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
            
            if let succeedingTimerID = newValue["succeedingTimerID"] as? Int {
                self.succeedingTimerID = succeedingTimerID
            }
            
            if let audibleTicks = newValue["audibleTicks"] as? Bool {
                self.audibleTicks = audibleTicks
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
    
    /* ################################################################################################################################## */
    // MARK: - Initializers
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Default initializer
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
        self.succeedingTimerID = -1
        self.audibleTicks = false
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
     - parameter succeedingTimerID: This is the ID of the next timer to play after this one.
     - parameter audibleTicks: This is a boolean that, if true, means that each second's transition will be marked by an audible "tick," as well as transitions from one state to another.
     - parameter songURLString: This is a String, containing a music URL (when in mode 1 or 2).
     - parameter uid: This is a unique ID for this setting. It can be defaulted.
     - parameter handler: This is the "owner" of this instance. Default is nil.
     */
    convenience init(timeSet: Int, timeSetPodiumWarn: Int, timeSetPodiumFinal: Int, currentTime: Int, displayMode: TimerDisplayMode, colorTheme: Int, alertMode: AlertMode, soundMode: SoundMode, alertVolume: Int, soundID: Int, succeedingTimerID: Int, audibleTicks: Bool, songURLString: String, timerStatus: TimerStatus, uid: String!, handler: LGV_Timer_State! = nil) {
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
        self.succeedingTimerID = succeedingTimerID
        self.audibleTicks = audibleTicks
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
    
    /* ################################################################################################################################## */
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
    
    /* ################################################################################################################################## */
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
    
    /* ################################################################################################################################## */
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
    
    /* ################################################################################################################################## */
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
    
    /* ################################################################################################################################## */
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
        self.succeedingTimerID = -1
        self.audibleTicks = false

        if coder.containsValue(forKey: TimerStateKeys.SucceedingTimerID.rawValue) {
            let succeedingTimerID = coder.decodeInteger(forKey: type(of: self).TimerStateKeys.SucceedingTimerID.rawValue)
            self.succeedingTimerID = succeedingTimerID
        }
        
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
        
        let succeedingTimerID = coder.decodeInteger(forKey: type(of: self).TimerStateKeys.SucceedingTimerID.rawValue)
        self.succeedingTimerID = succeedingTimerID
        
        let audibleTicks = coder.decodeBool(forKey: type(of: self).TimerStateKeys.AudibleTicks.rawValue)
        self.audibleTicks = audibleTicks

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
        with.encode(self.succeedingTimerID, forKey: type(of: self).TimerStateKeys.SucceedingTimerID.rawValue)
        with.encode(self.audibleTicks, forKey: type(of: self).TimerStateKeys.AudibleTicks.rawValue)
        with.encode(self.songURLString, forKey: type(of: self).TimerStateKeys.SongURLString.rawValue)
        with.encode(self.timerStatus.rawValue, forKey: type(of: self).TimerStateKeys.Status.rawValue)
        with.encode(self.soundID, forKey: type(of: self).TimerStateKeys.SoundID.rawValue)
        with.encode(self.uid, forKey: type(of: self).TimerStateKeys.UID.rawValue)
    }
}

/* ################################################################################################################################## */
// MARK: - LGV_Timer_AppStatusDelegate Protocol -
/* ###################################################################################################################################### */
/**
 This protocol allows observers of the app status.
 */
protocol LGV_Timer_StateDelegate: class {
    /* ################################################################## */
    /**
     Called when the timer status changes
     
     - parameter appState: The instance that called this delegate method.
     - parameter didUpdateTimerStatus: The timer setting tuple that was affected.
     - parameter from: The original state before the change.
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerStatus: TimerSettingTuple, from: TimerStatus)
    
    /* ################################################################## */
    /**
     Called when the timer mode changes
     
     - parameter appState: The instance that called this delegate method.
     - parameter didUpdateTimerDisplayMode: The timer setting tuple that was affected.
     - parameter from: The original state before the change.
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerDisplayMode: TimerSettingTuple, from: TimerDisplayMode)
    
    /* ################################################################## */
    /**
     Called when the timer current time changes
     
     - parameter appState: The instance that called this delegate method.
     - parameter didUpdateTimerCurrentTime: The timer setting tuple that was affected.
     - parameter from: The original time before the change.
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerCurrentTime: TimerSettingTuple, from: Int)
    
    /* ################################################################## */
    /**
     Called when the timer warning time setting is changed
     
     - parameter appState: The instance that called this delegate method.
     - parameter didUpdateTimerWarnTime: The timer setting tuple that was affected.
     - parameter from: The original time before the change.
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerWarnTime: TimerSettingTuple, from: Int)

    /* ################################################################## */
    /**
     Called when the timer final time setting is changed
     
     - parameter appState: The instance that called this delegate method.
     - parameter didUpdateTimerFinalTime: The timer setting tuple that was affected.
     - parameter from: The original time before the change.
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerFinalTime: TimerSettingTuple, from: Int)

    /* ################################################################## */
    /**
     Called when the timer starting time setting is changed
     
     - parameter appState: The instance that called this delegate method.
     - parameter didUpdateTimerTimeSet: The timer setting tuple that was affected.
     - parameter from: The original time before the change.
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerTimeSet: TimerSettingTuple, from: Int)

    /* ################################################################## */
    /**
     Called when the timer sound ID setting is changed
     
     - parameter appState: The instance that called this delegate method.
     - parameter didUpdateTimerSoundID: The timer setting tuple that was affected.
     - parameter from: The original ID before the change.
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerSoundID: TimerSettingTuple, from: Int)
    
    /* ################################################################## */
    /**
     Called when the timer song URL setting is changed
     
     - parameter appState: The instance that called this delegate method.
     - parameter didUpdateTimerSongURL: The timer setting tuple that was affected.
     - parameter from: The original URL (as a String) before the change.
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerSongURL: TimerSettingTuple, from: String)

    /* ################################################################## */
    /**
     Called when the timer alert mode setting is changed
     
     - parameter appState: The instance that called this delegate method.
     - parameter didUpdateTimerAlertMode: The timer setting tuple that was affected.
     - parameter from: The original mode before the change.
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerAlertMode: TimerSettingTuple, from: AlertMode)

    /* ################################################################## */
    /**
     Called when the timer sound mode setting is changed
     
     - parameter appState: The instance that called this delegate method.
     - parameter didUpdateTimerSoundMode: The timer setting tuple that was affected.
     - parameter from: The original mode before the change.
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerSoundMode: TimerSettingTuple, from: SoundMode)

    /* ################################################################## */
    /**
     Called when the next timer ID setting is changed
     
     - parameter appState: The instance that called this delegate method.
     - parameter didUpdateSucceedingTimerID: The timer setting tuple that was affected.
     - parameter from: The original ID before the change.
     */
    func appState(_ appState: LGV_Timer_State, didUpdateSucceedingTimerID: TimerSettingTuple, from: Int)

    /* ################################################################## */
    /**
     Called when the audible ticks setting is changed
     
     - parameter appState: The instance that called this delegate method.
     - parameter didUpdateAudibleTicks: The timer setting tuple that was affected.
     - parameter from: The original state before the change.
     */
    func appState(_ appState: LGV_Timer_State, didUpdateAudibleTicks: TimerSettingTuple, from: Bool)

    /* ################################################################## */
    /**
     Called when the color theme setting is changed
     
     - parameter appState: The instance that called this delegate method.
     - parameter didUpdateTimerColorTheme: The timer setting tuple that was affected.
     - parameter from: The original state before the change.
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerColorTheme: TimerSettingTuple, from: Int)

    /* ################################################################## */
    /**
     Called when a timer is added
     
     - parameter appState: The instance that called this delegate method.
     - parameter didAddTimer: The timer setting tuple that was affected.
     */
    func appState(_ appState: LGV_Timer_State, didAddTimer: TimerSettingTuple)

    /* ################################################################## */
    /**
     Called when a timer is about to be removed
     
     - parameter appState: The instance that called this delegate method.
     - parameter didAddTimer: The timer setting tuple that will be removed.
     */
    func appState(_ appState: LGV_Timer_State, willRemoveTimer: TimerSettingTuple)
    
    /* ################################################################## */
    /**
     Called when a timer was removed
     
     - parameter appState: The instance that called this delegate method.
     - parameter didRemoveTimerAtIndex: The 0-based index of the imer that was removed.
     */
    func appState(_ appState: LGV_Timer_State, didRemoveTimerAtIndex: Int)
    
    /* ################################################################## */
    /**
     Called when a timer was selected
     
     - parameter appState: The instance that called this delegate method.
     - parameter didSelectTimer: The timer setting tuple that was affected. It is optional, as it is possible to select no timer.
     */
    func appState(_ appState: LGV_Timer_State, didSelectTimer: TimerSettingTuple!)
    
    /* ################################################################## */
    /**
     Called when a timer was deselected
     
     - parameter appState: The instance that called this delegate method.
     - parameter didSelectTimer: The timer setting tuple that was affected.
     */
    func appState(_ appState: LGV_Timer_State, didDeselectTimer: TimerSettingTuple)
}

/* ################################################################################################################################## */
// MARK: - LGV_Timer_State Class -
/* ###################################################################################################################################### */
/**
 This class encapsulates the entire app status.
 */
class LGV_Timer_State: NSObject, NSCoding, Sequence {
    /// These are the states the app could be in
    private enum AppStateKeys: String {
        /// The list of timers
        case Timers
        /// A timer was selected
        case SelectedTimer
        /// Controls are displayed in the running timer
        case ShowControls
    }
    
    /// The list of timers
    private var _timers: [TimerSettingTuple] = []
    /// The selected timer (-1 is the list of timers)
    private var _selectedTimer0BasedIndex: Int = -1
    /// True, if the controls are to be shown in the running timer.
    private var _showControlsInRunningTimer: Bool = true
    /// This is our delegate. It's weak, to prevent reference loops.
    weak var delegate: LGV_Timer_StateDelegate! = nil
    
    /* ################################################################################################################################## */
    // MARK: - Instance Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     - returns: True, if a timer is currently selected.
     */
    var timerSelected: Bool {
        return 0 <= self.selectedTimerIndex
    }
    
    /* ################################################################## */
    /**
     - returns: True, if the control bar is shown in the running timer.
     */
    var showControlsInRunningTimer: Bool {
        get { return self._showControlsInRunningTimer }
        set { self._showControlsInRunningTimer = newValue }
    }
    
    /* ################################################################## */
    /**
     Setting this will cause the app to select a new timer.
     
     - returns: The current running timer. Nil, if no timer selected (list of timers).
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
            if let oldTimer = self.selectedTimer {
                if oldTimer.uid != newValue.uid {
                    DispatchQueue.main.async {
                        self.delegate?.appState(self, didDeselectTimer: oldTimer)
                    }
                }
                
                self._selectedTimer0BasedIndex = -1
                
                if let setValue = newValue {
                    for index in 0..<self._timers.count where self._timers[index].uid == setValue.uid {
                        self._selectedTimer0BasedIndex = index
                        DispatchQueue.main.async {
                            self.delegate?.appState(self, didSelectTimer: self._timers[index])
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
     Setting this will cause the app to select a new timer.
     
     - returns: The 0-based index of the currently selected timer. -1 if the timer list is displayed.
     */
    var selectedTimerIndex: Int {
        get { return self._selectedTimer0BasedIndex }
        set {
            let oldTimer = self.selectedTimer
            var newTimer: TimerSettingTuple! = nil
            
            if 0..<self._timers.count ~= newValue {
                self._selectedTimer0BasedIndex = newValue
                newTimer = self.selectedTimer
            } else {
                self._selectedTimer0BasedIndex = -1
            }
            
            if nil != oldTimer {
                DispatchQueue.main.async {
                    self.delegate?.appState(self, didDeselectTimer: oldTimer!)
                }
            }
            
            DispatchQueue.main.async {
                self.delegate?.appState(self, didSelectTimer: newTimer)
            }
        }
    }

    /* ################################################################## */
    /**
     - returns: The UUID of the currently selected timer (or an empty string)
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
            if let oldTimer = self.selectedTimer {
                if oldTimer.uid != newValue {
                    DispatchQueue.main.async {
                        self.delegate?.appState(self, didDeselectTimer: oldTimer)
                    }
                }
            }
            
            self._selectedTimer0BasedIndex = -1
            
            if !newValue.isEmpty {
                for index in 0..<self._timers.count where self._timers[index].uid == newValue {
                    self._selectedTimer0BasedIndex = index
                    DispatchQueue.main.async {
                        self.delegate?.appState(self, didSelectTimer: self._timers[index])
                    }
                    break
                }
            } else {
                self._selectedTimer0BasedIndex = -1
            }
        }
    }
    
    /* ################################################################## */
    /**
     - returns: The 0-based index of the next timer (-1 if none).
     */
    var nextTimer: Int {
        if 0 <= self._selectedTimer0BasedIndex && self._selectedTimer0BasedIndex < self.timers.count {
            let nextIndex = self.selectedTimer.succeedingTimerID
            
            if nextIndex < self.timers.count {
                return Swift.max(-1, nextIndex)
            }
        }
        
        return -1
    }

    /* ################################################################## */
    /**
     - returns: True, if there are no timers in the list.
     */
    var isEmpty: Bool {
        return 0 < self.count
    }
    
    /* ################################################################## */
    /**
     - returns: The number of timers in the lisy.
     */
    var count: Int {
        return self._timers.count
    }
    
    /* ################################################################## */
    /**
     - returns: The list of timers (accessor)
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
     - returns: The timer list, as a dictionary, with "selectedTimerIndex" as an element indicating which of the timers is selected, and an Array of timers.
     */
    var dictionary: [String: Any] {
        get {
            var ret: [String: Any] = [:]
            ret["selectedTimerIndex"] = self.selectedTimerIndex
            var timerArray: [[String: Any]] = []
            self.timers.forEach {
                let timerDictionary = $0.dictionary
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
                timerArray.forEach {
                    if let uid = $0["uid"] as? String {
                        var found: Bool = false
                        
                        // See if we already have this object. If so, we set it to the new value, and append it now.
                        for timerObject in self.timers where timerObject.uid == uid {
                            timerObject.dictionary = $0
                            newTimerArray.append(timerObject)
                            found = true
                            break
                        }
                        
                        // If we didn't find it, we append a new instance.
                        if !found {
                            newTimerArray.append(TimerSettingTuple(dictionary: $0, handler: self))
                        }
                    }
                }
                
                self.timers = newTimerArray
            }
        }
    }
    
    /* ################################################################################################################################## */
    // MARK: - Initializer
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Simple direct initializer with a delegate
     
     - parameter delegate: The delegate for this object.
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
    
    /* ################################################################################################################################## */
    // MARK: - Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Creates a new timer object from scratch.
     
     - returns: A new TimerSettingTuple, initialized to default.
     */
    func createNewTimer() -> TimerSettingTuple {
        let ret = TimerSettingTuple()
        
        ret.handler = self
        
        self.append(ret)
        DispatchQueue.main.async {
            self.delegate?.appState(self, didAddTimer: ret)
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     Send a timer update message to the delegate.
     
     - parameter inTimerObject: The timer sending the message
     - parameter from: The old value
     */
    func sendTimeUpdateMessage(_ inTimerObject: TimerSettingTuple, from: Int) {
        DispatchQueue.main.async {
            self.delegate?.appState(self, didUpdateTimerCurrentTime: inTimerObject, from: from)
        }
    }
    
    /* ################################################################## */
    /**
     Send a timer sound ID update message to the delegate.
     
     - parameter inTimerObject: The timer sending the message
     - parameter from: The old value
     */
    func sendSoundIDUpdateMessage(_ inTimerObject: TimerSettingTuple, from: Int) {
        DispatchQueue.main.async {
            self.delegate?.appState(self, didUpdateTimerSoundID: inTimerObject, from: from)
        }
    }
    
    /* ################################################################## */
    /**
     Send a timer next timer ID update message to the delegate.
     
     - parameter inTimerObject: The timer sending the message
     - parameter from: The old value
     */
    func sendSucceedingTimerIDUpdateMessage(_ inTimerObject: TimerSettingTuple, from: Int) {
        DispatchQueue.main.async {
            self.delegate?.appState(self, didUpdateSucceedingTimerID: inTimerObject, from: from)
        }
    }
    
    /* ################################################################## */
    /**
     Send a timer audible ticks setting update message to the delegate.
     
     - parameter inTimerObject: The timer sending the message
     - parameter from: The old value
     */
    func sendAudibleTicksUpdateMessage(_ inTimerObject: TimerSettingTuple, from: Bool) {
        DispatchQueue.main.async {
            self.delegate?.appState(self, didUpdateAudibleTicks: inTimerObject, from: from)
        }
    }
    
    /* ################################################################## */
    /**
     Send a timer song URL change setting update message to the delegate.
     
     - parameter inTimerObject: The timer sending the message
     - parameter from: The old value
     */
    func sendSongURLUpdateMessage(_ inTimerObject: TimerSettingTuple, from: String) {
        DispatchQueue.main.async {
            self.delegate?.appState(self, didUpdateTimerSongURL: inTimerObject, from: from)
        }
    }

    /* ################################################################## */
    /**
     Send a timer alert mode change setting update message to the delegate.
     
     - parameter inTimerObject: The timer sending the message
     - parameter from: The old value
     */
    func sendAlertModeUpdateMessage(_ inTimerObject: TimerSettingTuple, from: AlertMode) {
        DispatchQueue.main.async {
            self.delegate?.appState(self, didUpdateTimerAlertMode: inTimerObject, from: from)
        }
    }

    /* ################################################################## */
    /**
     Send a timer sound mode change setting update message to the delegate.
     
     - parameter inTimerObject: The timer sending the message
     - parameter from: The old value
     */
    func sendSoundModeUpdateMessage(_ inTimerObject: TimerSettingTuple, from: SoundMode) {
        DispatchQueue.main.async {
            self.delegate?.appState(self, didUpdateTimerSoundMode: inTimerObject, from: from)
        }
    }

    /* ################################################################## */
    /**
     Send a timer color theme change setting update message to the delegate.
     
     - parameter inTimerObject: The timer sending the message
     - parameter from: The old value
     */
    func sendColorThemeUpdateMessage(_ inTimerObject: TimerSettingTuple, from: Int) {
        DispatchQueue.main.async {
            self.delegate?.appState(self, didUpdateTimerColorTheme: inTimerObject, from: from)
        }
    }
    
    /* ################################################################## */
    /**
     Send a timer set time change setting update message to the delegate.
     
     - parameter inTimerObject: The timer sending the message
     - parameter from: The old value
     */
    func sendSetTimeUpdateMessage(_ inTimerObject: TimerSettingTuple, from: Int) {
        DispatchQueue.main.async {
            self.delegate?.appState(self, didUpdateTimerTimeSet: inTimerObject, from: from)
        }
    }
    
    /* ################################################################## */
    /**
     Send a timer set warning time change setting update message to the delegate.
     
     - parameter inTimerObject: The timer sending the message
     - parameter from: The old value
     */
    func sendWarnTimeUpdateMessage(_ inTimerObject: TimerSettingTuple, from: Int) {
        DispatchQueue.main.async {
            self.delegate?.appState(self, didUpdateTimerWarnTime: inTimerObject, from: from)
        }
    }
    
    /* ################################################################## */
    /**
     Send a timer set final time change setting update message to the delegate.
     
     - parameter inTimerObject: The timer sending the message
     - parameter from: The old value
    */
    func sendFinalTimeUpdateMessage(_ inTimerObject: TimerSettingTuple, from: Int) {
        DispatchQueue.main.async {
            self.delegate?.appState(self, didUpdateTimerFinalTime: inTimerObject, from: from)
        }
    }
    
    /* ################################################################## */
    /**
     Send a timer status update message to the delegate.
     
     - parameter inTimerObject: The timer sending the message
     - parameter from: The old value
     */
    func sendStatusUpdateMessage(_ inTimerObject: TimerSettingTuple, from: TimerStatus) {
        DispatchQueue.main.async {
            self.delegate?.appState(self, didUpdateTimerStatus: inTimerObject, from: from)
        }
    }
    
    /* ################################################################## */
    /**
     Send a timer display mode setting update message to the delegate.
     
     - parameter inTimerObject: The timer sending the message
     - parameter from: The old value
     */
    func sendDisplayModeUpdateMessage(_ inTimerObject: TimerSettingTuple, from: TimerDisplayMode) {
        DispatchQueue.main.async {
            self.delegate?.appState(self, didUpdateTimerDisplayMode: inTimerObject, from: from)
        }
    }
    
    /* ################################################################################################################################## */
    // MARK: - Sequence Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     - parameter index: The 0-based index of the requested element.
     - returns: The tuple at the given subscript.
     */
    subscript(_ index: Int) -> TimerSettingTuple {
        return self._timers[index]
    }
    
    /* ################################################################## */
    /**
     Get the index of an element by its UUID
     
     - parameter inUID: The UUID of the element we're looking for.
     - returns: The 0-based index of the given element.
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
     Get the index of an element
     
     - parameter inObject: The element we're looking for.
     - returns: The 0-based index of the given element.
     */
    func indexOf(_ inObject: TimerSettingTuple) -> Int {
        return self.indexOf(inObject.uid)
    }
    
    /* ################################################################## */
    /**
     See if our settings contain an object.
     
     - parameter inObject: The element we're looking for.
     - returns: true, if the settings array contains the given object.
     */
    func contains(_ inObject: TimerSettingTuple) -> Bool {
        return 0 <= self.indexOf(inObject)
    }
    
    /* ################################################################## */
    /**
     See if our settings contain an object by its UUID.
     
     - parameter inUID: The UUID of the element we're looking for.
     - returns: true, if the settings array contains the given object.
     */
    func contains(_ inUID: String) -> Bool {
        return 0 <= self.indexOf(inUID)
    }
    
    /* ################################################################## */
    /**
     - returns: A new, initialized iterator of the settings.
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
     Append a new object to the end of our array.
     
     - parameter inObject: The object we're appending.
     */
    func append(_ inObject: TimerSettingTuple) {
        DispatchQueue.main.async {
            self._timers.append(inObject)
        }
    }
    
    /* ################################################################## */
    /**
     Remove an object at the given 0-based index.
     
     - parameter at: The 0-based index of the object to be removed.
     */
    func remove(at index: Int) {
        DispatchQueue.main.async {
            if 0..<self.count ~= index {
                let timer = self[index]
                
                DispatchQueue.main.async {
                    self.delegate?.appState(self, willRemoveTimer: timer)
                }
                
                // This removes us from any other timers' succeeding timer, and will decrement ones that point after it.
                for lilTimer in self where index..<self.count ~= lilTimer.succeedingTimerID {
                    lilTimer.succeedingTimerID = lilTimer.succeedingTimerID == index ? -1 : lilTimer.succeedingTimerID - 1
                }
                
                self._timers.remove(at: index)

                if index < self._selectedTimer0BasedIndex {
                    self._selectedTimer0BasedIndex -= 1
                } else {
                    if index == self._selectedTimer0BasedIndex {
                        self._selectedTimer0BasedIndex = -1
                    }
                }
                
                DispatchQueue.main.async {
                    self.delegate?.appState(self, didRemoveTimerAtIndex: index)
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
            
            self.timers.forEach {
                $0.handler = self
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