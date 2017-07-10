//
//  LGV_Timer_TimerEngine.swift
//  X-Timer
//
//  Created by Chris Marshall on 7/9/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//

import UIKit

// MARK: - LGV_Timer_TimerEngineDelegate Protocol -
/* ###################################################################################################################################### */
/**
 This protocol allows observers of the engine.
 */
protocol LGV_Timer_TimerEngineDelegate {
    func timerEngine(_ timerEngine: LGV_Timer_TimerEngine, didAddTimer: TimerSettingTuple)
    func timerEngine(_ timerEngine: LGV_Timer_TimerEngine, willRemoveTimer: TimerSettingTuple)
    func timerEngine(_ timerEngine: LGV_Timer_TimerEngine, didRemoveTimerAtIndex: Int)
    func timerEngine(_ timerEngine: LGV_Timer_TimerEngine, didSelectTimer: TimerSettingTuple)
    func timerEngine(_ timerEngine: LGV_Timer_TimerEngine, didDeselectTimer: TimerSettingTuple)
    
    func timerSetting(_ timerSetting: TimerSettingTuple, alarm: Int)
    func timerSetting(_ timerSetting: TimerSettingTuple, changedCurrentTimeFrom: Int)
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimerStatusFrom: TimerStatus)
}

/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_TimerEngine: NSObject, Sequence, LGV_Timer_AppStatusDelegate {
    static let timerInterval: TimeInterval = 0.1
    static let timerTickInterval: TimeInterval = 1.0
    static let timerAlarmInterval: TimeInterval = 0.5
    
    // MARK: - Private Enums
    /* ################################################################################################################################## */
    /* ################################################################## */
    /** These are the keys we use for our persistent prefs dictionary. */
    private enum PrefsKeys: String {
        /** This will be an array of dictionaries, with a list of timers. */
        case TimerList = "TimerList"    ///< The old timer prefs.
        case AppStatus = "AppStatus"
    }
    
    // MARK: - Private Static Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /** This is the key for the prefs used by this app. */
    private static let _mainPrefsKey: String = "LGV_Timer_StaticPrefs"
    /** This is the key for the app status prefs used by this app. */
    private static let _appStatusPrefsKey: String = "LGV_Timer_AppStatus"
    
    private var _timerTicking: Bool = false
    private var _firstTick: TimeInterval = 0.0
    private var _alarmCount: Int = 0
    
    var prefs: LGV_Timer_StaticPrefs = LGV_Timer_StaticPrefs.prefs
    var appStatus: LGV_Timer_AppStatus! = nil
    var timer: Timer! = nil
    var delegate: LGV_Timer_TimerEngineDelegate! = nil
    
    // MARK: - Internal Enums
    /* ################################################################################################################################## */
    /* ################################################################## */
    /** These are the keys we use for our timer prefs dictionary. */
    enum TimerPrefKeys: String {
        case TimeSet            = "TimeSet"
        case TimeSetPodiumWarn  = "TimeSetPodiumWarn"
        case TimeSetPodiumFinal = "TimeSetPodiumFinal"
        case DisplayMode        = "DisplayMode"
        case ColorTheme         = "ColorTheme"
        case AlertMode          = "AlertMode"
        case SoundID            = "SoundID"
        case UID                = "UID"
    }
    
    // MARK: - Internal Static Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This returns one default configurasion timer "tuple" object.
     */
    static var defaultTimer: TimerSettingTuple {
        get {
            let ret: TimerSettingTuple = TimerSettingTuple()
            return ret
        }
    }
    
    // MARK: - Instance Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var timerSelected: Bool {
        get { return self.appStatus.timerSelected }
    }
    
    /* ################################################################## */
    /**
     */
    var selectedTimer: TimerSettingTuple! {
        get { return self.appStatus.selectedTimer }
    }
    
    /* ################################################################## */
    /**
     */
    var selectedTimerIndex: Int {
        get { return self.appStatus.selectedTimerIndex }
        set { self.appStatus.selectedTimerIndex = newValue }
    }
    
    /* ################################################################## */
    /**
     */
    var selectedTimerUID: String {
        get { return self.appStatus.selectedTimerUID }
        set { self.appStatus.selectedTimerUID = newValue }
    }
    
    /* ################################################################## */
    /**
     */
    var isEmpty: Bool {
        get { return self.appStatus.isEmpty }
    }
    
    /* ################################################################## */
    /**
     */
    var timers:[TimerSettingTuple] {
        get { return self.appStatus.timers }
        set { self.appStatus.timers = newValue }
    }
    
    /* ################################################################## */
    /**
     */
    var count: Int {
        get { return self.appStatus.count }
    }
    
    /* ################################################################## */
    /**
     */
    var timerActive: Bool {
        get { return nil != self.timer }
        
        set {
            if (nil == self.timer) && self.timerSelected {
                self.selectedTimer.lastTick = Date.timeIntervalSinceReferenceDate
                self.timer = Timer.scheduledTimer(timeInterval: type(of: self).timerInterval, target: self, selector: #selector(self.timerCallback(_:)), userInfo: nil, repeats: true)
            } else {
                if nil != self.timer {
                    self.timer.invalidate()
                    self.timer = nil
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    var actualTimeSinceStart: TimeInterval {
        get {
            if self.timerSelected && (0.0 < self._firstTick) {
                return Date.timeIntervalSinceReferenceDate - self._firstTick
            } else {
                return 0.0
            }
        }
    }
    
    // MARK: - Private Class Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    private class func _convertStorageToTimer(_ inTimer: NSDictionary) -> TimerSettingTuple {
        let tempSetting:TimerSettingTuple = self.defaultTimer
        
        if let timeSet = inTimer.object(forKey: TimerPrefKeys.TimeSet.rawValue) as? NSNumber {
            tempSetting.timeSet = timeSet.intValue
        }
        
        if let timeSetPodiumWarn = inTimer.object(forKey: TimerPrefKeys.TimeSetPodiumWarn.rawValue) as? NSNumber {
            tempSetting.timeSetPodiumWarn = timeSetPodiumWarn.intValue
        }
        
        if let timeSetPodiumFinal = inTimer.object(forKey: TimerPrefKeys.TimeSetPodiumFinal.rawValue) as? NSNumber {
            tempSetting.timeSetPodiumFinal = timeSetPodiumFinal.intValue
        }
        
        if let displayMode = inTimer.object(forKey: TimerPrefKeys.DisplayMode.rawValue) as? NSNumber {
            if let displayModeType = TimerDisplayMode(rawValue: displayMode.intValue) {
                tempSetting.displayMode = displayModeType
            }
        }
        
        if let colorTheme = inTimer.object(forKey: TimerPrefKeys.ColorTheme.rawValue) as? NSNumber {
            tempSetting.colorTheme = colorTheme.intValue
        }
        
        if let alertMode = inTimer.object(forKey: TimerPrefKeys.AlertMode.rawValue) as? NSNumber {
            if let alertModeType = AlertMode(rawValue: alertMode.intValue) {
                tempSetting.alertMode = alertModeType
            }
        }
        
        if let soundID = inTimer.object(forKey: TimerPrefKeys.SoundID.rawValue) as? NSNumber {
            tempSetting.soundID = soundID.intValue
        }
        
        if let uid = inTimer.object(forKey: TimerPrefKeys.UID.rawValue) as? NSString {
            tempSetting.uid = uid as String
        } else {
            tempSetting.uid = NSUUID().uuidString
        }
        
        return tempSetting
    }
    
    // MARK: - Initializers and Deinitializer
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     We declare this private to keep the class from being initialized without a delegate.
     */
    private override init() {
    }
    
    /* ################################################################## */
    /**
     */
    init(delegate: LGV_Timer_TimerEngineDelegate) {
        super.init()
        self.delegate = delegate
        self._loadPrefs()
    }
    
    /* ################################################################## */
    /**
     */
    deinit {
        if nil != self.timer {
            self.timer.invalidate()
            self.timer = nil
        }
        
        var index = 0
        
        for timer in self.timers {
            if nil != self.delegate {
                DispatchQueue.main.async {
                    self.delegate.timerEngine(self, willRemoveTimer: timer)
                    self.delegate.timerEngine(self, didRemoveTimerAtIndex: index)
                }
                index += 1
            }
        }
    }
    
    // MARK: - Private Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This method loads the main prefs into our instance storage.
     
     NOTE: This will overwrite any unsaved changes to the current _loadedPrefs property.
     */
    private func _loadPrefs() {
        self.appStatus = LGV_Timer_AppStatus(delegate: self)
        if let loadedPrefs = UserDefaults.standard.object(forKey: type(of: self)._mainPrefsKey) as? NSDictionary {
            var timers: [TimerSettingTuple] = []
            
            if let temp = loadedPrefs.object(forKey: PrefsKeys.TimerList.rawValue) as? NSArray {
                for index in 0..<temp.count {
                    if let arrayElement = temp[index] as? NSDictionary {
                        let temp: TimerSettingTuple = type(of:self)._convertStorageToTimer(arrayElement)
                        timers.append(temp)
                    }
                }
            }
            
            if !timers.isEmpty {
                self.timers = timers
                UserDefaults.standard.removeObject(forKey: type(of: self)._mainPrefsKey)
                self.savePrefs()
            } else {
                self.timers = []
                let _ = self.createNewTimer()
            }
            
            self.selectedTimerIndex = -1
       } else {
            if let temp = UserDefaults.standard.object(forKey: type(of: self)._appStatusPrefsKey) as? Data {
                if let temp2 = NSKeyedUnarchiver.unarchiveObject(with: temp) as? LGV_Timer_AppStatus {
                    self.appStatus = temp2
                    self.appStatus.delegate = self
                }
            }
        }
    }
    
    // MARK: - Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func createNewTimer() -> TimerSettingTuple {
        let timer = self.appStatus.createNewTimer()
        return timer
    }
    
    /* ################################################################## */
    /**
     This method simply saves the main preferences Dictionary into the standard user defaults.
     */
    func savePrefs() {
        let appData = NSKeyedArchiver.archivedData(withRootObject: self.appStatus)
        UserDefaults.standard.set(appData, forKey: type(of: self)._appStatusPrefsKey)
    }
    
    /* ################################################################## */
    /**
     */
    func pauseTimer() {
        if let selectedTimer = self.selectedTimer {
            selectedTimer.timerStatus = .Paused
        }
    }
    
    /* ################################################################## */
    /**
     */
    func continueTimer() {
        if let selectedTimer = self.selectedTimer {
            if 0 >= selectedTimer.currentTime {
                self.startTimer()
            } else {
                switch selectedTimer.currentTime {
                case 0...selectedTimer.timeSetPodiumFinal:
                    selectedTimer.timerStatus = .FinalRun
                case (selectedTimer.timeSetPodiumFinal + 1)...selectedTimer.timeSetPodiumWarn:
                    selectedTimer.timerStatus = .WarnRun
                default:
                    selectedTimer.timerStatus = .Running
                }
            }
       }
    }
    
    /* ################################################################## */
    /**
     */
    func startTimer() {
        if let selectedTimer = self.selectedTimer {
            self._firstTick = Date.timeIntervalSinceReferenceDate
            selectedTimer.currentTime = selectedTimer.timeSet
            selectedTimer.timerStatus = .Running
       }
    }
    
    /* ################################################################## */
    /**
     */
    func stopTimer() {
        if let selectedTimer = self.selectedTimer {
            self._firstTick = 0.0
            selectedTimer.currentTime = selectedTimer.timeSet
            selectedTimer.timerStatus = .Stopped
        }
    }
    
    /* ################################################################## */
    /**
     */
    func resetTimer() {
        if let selectedTimer = self.selectedTimer {
            self._firstTick = 0.0
            selectedTimer.currentTime = selectedTimer.timeSet
            selectedTimer.timerStatus = .Stopped
       }
    }
    
    /* ################################################################## */
    /**
     */
    func endTimer() {
        if let selectedTimer = self.selectedTimer {
            selectedTimer.currentTime = 0
            selectedTimer.timerStatus = .Alarm
       }
    }
    
    // MARK: - LGV_Timer_AppStatusDelegate Methods
    /* ################################################################################################################################## */
   /* ################################################################## */
    /**
     */
    func appStatus(_ appStatus: LGV_Timer_AppStatus, didAddTimer: TimerSettingTuple) {
        if nil != self.delegate {
            self.delegate.timerEngine(self, didAddTimer: didAddTimer)
            self.savePrefs()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func appStatus(_ appStatus: LGV_Timer_AppStatus, willRemoveTimer: TimerSettingTuple) {
        if nil != self.delegate {
            self.delegate.timerEngine(self, willRemoveTimer: willRemoveTimer)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func appStatus(_ appStatus: LGV_Timer_AppStatus, didRemoveTimerAtIndex: Int) {
        if nil != self.delegate {
            self.delegate.timerEngine(self, didRemoveTimerAtIndex: didRemoveTimerAtIndex)
            self.savePrefs()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func appStatus(_ appStatus: LGV_Timer_AppStatus, didSelectTimer: TimerSettingTuple) {
        if nil != self.delegate {
            self.delegate.timerEngine(self, didSelectTimer: didSelectTimer)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func appStatus(_ appStatus: LGV_Timer_AppStatus, didDeselectTimer: TimerSettingTuple) {
        if nil != self.delegate {
            self.delegate.timerEngine(self, didDeselectTimer: didDeselectTimer)
        }
    }
    
    // MARK: - Sequence Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    subscript(_ index: Int) -> TimerSettingTuple {
        return self.appStatus[index]
    }
    
    /* ################################################################## */
    /**
     */
    func indexOf(_ inUID: String) -> Int {
        return self.appStatus.indexOf(inUID)
    }
    
    /* ################################################################## */
    /**
     */
    func indexOf(_ inObject: TimerSettingTuple) -> Int {
        return self.appStatus.indexOf(inObject)
    }
    
    /* ################################################################## */
    /**
     */
    func contains(_ inObject: TimerSettingTuple) -> Bool {
        return self.appStatus.contains(inObject)
    }
    
    /* ################################################################## */
    /**
     */
    func contains(_ inUID: String) -> Bool {
        return self.appStatus.contains(inUID)
    }
    
    /* ################################################################## */
    /**
     */
    func makeIterator() -> AnyIterator<TimerSettingTuple> {
        var nextIndex = 0
        
        // Return a "bottom-up" iterator for the list.
        return AnyIterator() {
            if nextIndex == self.count {
                return nil
            }
            nextIndex += 1
            return self[nextIndex - 1]
        }
    }
    
    /* ################################################################## */
    /**
     */
    func append(_ inObject: TimerSettingTuple) {
        self.appStatus.append(inObject)
    }
    
    /* ################################################################## */
    /**
     */
    func remove(at index: Int) {
        DispatchQueue.main.async {
            if nil != self.delegate {
                let timerToBeRemoved = self[index]
                self.delegate.timerEngine(self, willRemoveTimer: timerToBeRemoved)
            }
        }
        self.appStatus.remove(at: index)
    }
    
    // MARK: - Callback Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @objc func timerCallback(_ inTimer: Timer) {
        if 0.0 < self.selectedTimer.lastTick {
            if let selectedTimer = self.selectedTimer {
                if .Alarm == selectedTimer.timerStatus {
                    if type(of: self).timerAlarmInterval <= (Date.timeIntervalSinceReferenceDate - self.selectedTimer.lastTick) {
                        self.selectedTimer.lastTick = Date.timeIntervalSinceReferenceDate
                        DispatchQueue.main.async {
                            if nil != self.delegate {
                                self.delegate.timerSetting(selectedTimer, alarm: self._alarmCount)
                            }
                        }
                        self._alarmCount += 1
                    }
                } else {
                    if (.Stopped != selectedTimer.timerStatus) && (.Paused != selectedTimer.timerStatus) {
                        if type(of: self).timerTickInterval <= (Date.timeIntervalSinceReferenceDate - self.selectedTimer.lastTick) {
                            self.selectedTimer.lastTick = Date.timeIntervalSinceReferenceDate
                            let oldTime: Int = selectedTimer.currentTime
                            selectedTimer.currentTime = Swift.max(0, oldTime - 1)
                            DispatchQueue.main.async {
                                if nil != self.delegate {
                                    self.delegate.timerSetting(selectedTimer, changedCurrentTimeFrom: oldTime)
                                }
                                
                                let oldStatus = selectedTimer.timerStatus
                                switch selectedTimer.currentTime {
                                case 0:
                                    self._alarmCount = 0
                                    selectedTimer.timerStatus = .Alarm
                                case 1...selectedTimer.timeSetPodiumFinal:
                                    selectedTimer.timerStatus = .FinalRun
                                case (selectedTimer.timeSetPodiumFinal + 1)...selectedTimer.timeSetPodiumWarn:
                                    selectedTimer.timerStatus = .WarnRun
                                default:
                                    selectedTimer.timerStatus = .Running
                                }
                                
                                if oldStatus != selectedTimer.timerStatus {
                                    if nil != self.delegate {
                                        self.delegate.timerSetting(selectedTimer, changedTimerStatusFrom: oldStatus)
                                    }
                                }
                           }
                        }
                    } else {
                        self.selectedTimer.lastTick = 0.0
                    }
                }
            }
        }
    }
}
