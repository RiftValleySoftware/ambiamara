//
//  LGV_Timer_TimerEngine.swift
//  X-Timer
//
//  Created by Chris Marshall on 7/9/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//  This is proprietary code. Copying and reuse are not allowed. It is being opened to provide sample code.
//

import UIKit

// MARK: - LGV_Timer_TimerEngineDelegate Protocol -
/* ###################################################################################################################################### */
/**
 This protocol allows observers of the engine.
 */
protocol TimerEngineDelegate: class {
    func timerEngine(_ timerEngine: TimerEngine, didAddTimer: TimerSettingTuple)
    func timerEngine(_ timerEngine: TimerEngine, willRemoveTimer: TimerSettingTuple)
    func timerEngine(_ timerEngine: TimerEngine, didRemoveTimerAtIndex: Int)
    func timerEngine(_ timerEngine: TimerEngine, didSelectTimer: TimerSettingTuple!)
    func timerEngine(_ timerEngine: TimerEngine, didDeselectTimer: TimerSettingTuple)
    
    func timerSetting(_ timerSetting: TimerSettingTuple, alarm: Int)
    func timerSetting(_ timerSetting: TimerSettingTuple, changedCurrentTimeFrom: Int)
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimeSetFrom: Int)
    func timerSetting(_ timerSetting: TimerSettingTuple, changedWarnTimeFrom: Int)
    func timerSetting(_ timerSetting: TimerSettingTuple, changedFinalTimeFrom: Int)
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimerStatusFrom: TimerStatus)
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimerDisplayModeFrom: TimerDisplayMode)
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimerSoundIDFrom: Int)
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimerAlertModeFrom: AlertMode)
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimerColorThemeFrom: Int)
}

/* ###################################################################################################################################### */
/**
 */
class TimerEngine: NSObject, Sequence, LGV_Timer_StateDelegate {
    static let timerInterval: TimeInterval = 0.1
    static let timerTickInterval: TimeInterval = 1.0
    static let timerAlarmInterval: TimeInterval = 1.0
    
    /** This contains our color theme palette. */
    private static let _sviewBundleName = "ColorThemes"
    
    // MARK: - Private Static Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /** This is the key for the prefs used by this app. */
    private static let _mainPrefsKey: String = "LGV_Timer_StaticPrefs"
    /** This is the key for the app status prefs used by this app. */
    private static let _appStatePrefsKey: String = "LGV_Timer_AppState"
    /** This is the key for the app status prefs used by this app. */
    private static let _oldPrefsKey: String = "TimerList"
    
    private var _timerTicking: Bool = false
    private var _firstTick: TimeInterval = 0.0
    private var _alarmCount: Int = 0
    
    // MARK: - Internal Enums
    /* ################################################################################################################################## */
    /* ################################################################## */
    /** These are the keys we use for our timer prefs dictionary. */
    enum TimerPrefKeys: String {
        case TimeSet
        case TimeSetPodiumWarn
        case TimeSetPodiumFinal
        case DisplayMode
        case ColorTheme
        case AlertMode
        case SoundID
        case UID
    }
    
    // MARK: - Internal Static Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This returns one default configurasion timer "tuple" object.
     */
    static var defaultTimer: TimerSettingTuple {
        let ret: TimerSettingTuple = TimerSettingTuple()
        return ret
    }
    
    // MARK: - Private Instance Properties
    /* ################################################################################################################################## */
    /** This will contain the UILabels that are used for the color theme. */
    private var _colorLabelArray: [UILabel] = []
    
    // MARK: - Instance Properties
    /* ################################################################################################################################## */
    weak var delegate: TimerEngineDelegate!
    var appState: LGV_Timer_State!
    var timer: Timer!
    
    // MARK: - Instance Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This simply returns true, if a timer is currently selected.
     */
    var timerSelected: Bool {
        return self.appState.timerSelected
    }
    
    /* ################################################################## */
    /**
     This returns the currently selected timer (or nil, if no timer is selected).
     */
    var selectedTimer: TimerSettingTuple! {
        return self.appState.selectedTimer
    }
    
    /* ################################################################## */
    /**
     This returns (or changes) the 0-based index of the selected timer.
     */
    var selectedTimerIndex: Int {
        get { return self.appState.selectedTimerIndex }
        set { self.appState.selectedTimerIndex = newValue }
    }
    
    /* ################################################################## */
    /**
     This returns the UID of the selected timer object.
     */
    var selectedTimerUID: String {
        get { return self.appState.selectedTimerUID }
        set { self.appState.selectedTimerUID = newValue }
    }
    
    /* ################################################################## */
    /**
     This returns true, if we have no timers (We should always have at least one, but belt and suspenders).
     */
    var isEmpty: Bool {
        return self.appState.isEmpty
    }
    
    /* ################################################################## */
    /**
     This returns the array of timer objects.
     */
    var timers: [TimerSettingTuple] {
        get { return self.appState.timers }
        set { self.appState.timers = newValue }
    }
    
    /* ################################################################## */
    /**
     This returns how many timers we have.
     */
    var count: Int {
        return self.appState.count
    }
    
    /* ################################################################## */
    /**
     This return true, if we currently have a ticking timer.
     */
    var timerActive: Bool {
        get { return nil != self.timer }
        
        set {
            if nil == self.timer {
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
     This returns the actual elapsed time (in a standard interval) since the timer started.
     */
    var actualTimeSinceStart: TimeInterval {
        if self.timerSelected && (0.0 < self._firstTick) {
            return Date.timeIntervalSinceReferenceDate - self._firstTick
        } else {
            return 0.0
        }
    }
    
    /* ################################################################## */
    /**
     Returns the color palettes.
     */
    var colorLabelArray: [UILabel] {
        if self._colorLabelArray.isEmpty {
            // The first index is white.
            let label = UILabel()
            label.backgroundColor = UIColor.white
            self._colorLabelArray = [label]
            // We generate a series of colors, fully saturated, from red (orangeish) to red (purpleish).
            for hue: CGFloat in stride(from: 0.0, to: 1.0, by: 0.05) {
                let color = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
                let label = UILabel()
                label.backgroundColor = color
                self._colorLabelArray.append(label)
            }
        }
        
        return self._colorLabelArray
    }
    
    /* ################################################################## */
    /**
     Returns the color for the indexed color theme.
     */
    func getIndexedColorThemeColor(_ index: Int) -> UIColor {
        var ret: UIColor
        
        let label = self.colorLabelArray[index]
        
        ret = label.textColor
        
        if let destColorSpace: CGColorSpace = CGColorSpace(name: CGColorSpace.sRGB) {
            if let newColor = ret.cgColor.converted(to: destColorSpace, intent: CGColorRenderingIntent.perceptual, options: nil) {
                ret = UIColor(cgColor: newColor)
            }
        }
        
        return ret
    }
    
    // MARK: - Private Class Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This creates a timer tuple from the persistent stored data sent in.
     */
    private class func _convertStorageToTimer(_ inTimer: NSDictionary) -> TimerSettingTuple {
        let tempSetting: TimerSettingTuple = self.defaultTimer
        
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
        
        tempSetting.timerStatus = .Stopped
        
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
     We instantiate this with a delegate -always
     
     - parameter delegate: The delegate object.
     */
    init(delegate: TimerEngineDelegate) {
        super.init()
        self.delegate = delegate
        self._loadPrefs()
        self.timerActive = true
    }
    
    /* ################################################################## */
    /**
     We make sure we clean up after ourselves.
     */
    deinit {
        self.timerActive = false
        
        self.savePrefs()
        var index = 0
        
        for timer in self.timers where nil != self.delegate {
            DispatchQueue.main.async {
                self.delegate.timerEngine(self, willRemoveTimer: timer)
                self.delegate.timerEngine(self, didRemoveTimerAtIndex: index)
            }
            index += 1
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
        self.appState = LGV_Timer_State(delegate: self)
        
        if let loadedPrefs = UserDefaults.standard.object(forKey: type(of: self)._mainPrefsKey) as? NSDictionary {
            var timers: [TimerSettingTuple] = []
            
            if let temp = loadedPrefs.object(forKey: type(of: self)._oldPrefsKey) as? NSArray {
                for index in 0..<temp.count {
                    if let arrayElement = temp[index] as? NSDictionary {
                        let temp: TimerSettingTuple = type(of: self)._convertStorageToTimer(arrayElement)
                        temp.timerStatus = .Stopped
                        temp.storedColor = self.getIndexedColorThemeColor(temp.colorTheme)
                        temp.handler = self.appState
                        timers.append(temp)
                    }
                }
            }
            
            if !timers.isEmpty {
                self.timers = timers
                UserDefaults.standard.removeObject(forKey: type(of: self)._mainPrefsKey)
                self.selectedTimerIndex = -1
            }
       } else {
            if let temp = UserDefaults.standard.object(forKey: type(of: self)._appStatePrefsKey) as? Data {
                if let temp2 = NSKeyedUnarchiver.unarchiveObject(with: temp) as? LGV_Timer_State {
                    self.appState = temp2
                    self.appState.delegate = self
                    for timer in self.appState.timers {
                        timer.timerStatus = .Stopped
                        timer.storedColor = self.getIndexedColorThemeColor(timer.colorTheme)
                        timer.handler = self.appState
                    }
                }
            }
        }
        
        // We are not allowed to have zero timers.
        if self.timers.isEmpty {
            let temp = self.createNewTimer()
            temp.storedColor = self.getIndexedColorThemeColor(temp.colorTheme)
       }
        
        self.selectedTimerIndex = -1
        self.savePrefs()
    }
    
    // MARK: - Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is a factory for creating a new timer object.
     
     - returns: a new timer object, instantiated with a zero time, and default characteristics.
     */
    func createNewTimer() -> TimerSettingTuple {
        let timer = self.appState.createNewTimer()
        return timer
    }
    
    /* ################################################################## */
    /**
     This method simply saves the main preferences Dictionary into the standard user defaults.
     */
    func savePrefs() {
        let appData = NSKeyedArchiver.archivedData(withRootObject: self.appState)
        UserDefaults.standard.set(appData, forKey: type(of: self)._appStatePrefsKey)
    }
    
    /* ################################################################## */
    /**
     Just what it says on the tin.
     Does nothing if no timer is selected.
     */
    func pauseTimer() {
        if let selectedTimer = self.selectedTimer {
            selectedTimer.timerStatus = .Paused
        }
    }
    
    /* ################################################################## */
    /**
     This will either start, or continue, the selected timer.
     Does nothing if no timer is selected.
     */
    func continueTimer() {
        if let selectedTimer = self.selectedTimer {
            if 0 >= selectedTimer.currentTime {
                self.startTimer()
            } else {
                if (0 < selectedTimer.timeSetPodiumWarn) && (0 < selectedTimer.timeSetPodiumWarn) && (selectedTimer.timeSetPodiumWarn > selectedTimer.timeSetPodiumWarn) {
                    switch selectedTimer.currentTime {
                    case 0...selectedTimer.timeSetPodiumFinal:
                        selectedTimer.timerStatus = .FinalRun
                    case (selectedTimer.timeSetPodiumFinal + 1)...selectedTimer.timeSetPodiumWarn:
                        selectedTimer.timerStatus = .WarnRun
                    default:
                        selectedTimer.timerStatus = .Running
                    }
                } else {
                    selectedTimer.timerStatus = .Running
                }
            }
       }
    }
    
    /* ################################################################## */
    /**
     This starts a selected timer from scratch.
     Does nothing if no timer is selected.
     */
    func startTimer() {
        if let selectedTimer = self.selectedTimer {
            selectedTimer.timerStatus = .Running
      }
    }
    
    /* ################################################################## */
    /**
     Stops a running selected timer.
     Does nothing if no timer is selected.
     */
    func stopTimer() {
        if let selectedTimer = self.selectedTimer {
            selectedTimer.timerStatus = .Stopped
        }
    }
    
    /* ################################################################## */
    /**
     This resets the selected timer, and returns it to "paused" mode.
     Does nothing if no timer is selected.
     */
    func resetTimer() {
        if let selectedTimer = self.selectedTimer {
            let oldStatus = selectedTimer.timerStatus
            selectedTimer.timerStatus = .Paused
            selectedTimer.currentTime = selectedTimer.timeSet
            selectedTimer.lastTick = 0.0
            selectedTimer.firstTick = 0.0
            self.appState.sendStatusUpdateMessage(selectedTimer, from: oldStatus)
        }
    }
    
    /* ################################################################## */
    /**
     This forces a timer to "finish," and enter alarm mode.
     Does nothing if no timer is selected.
     */
    func endTimer() {
        if let selectedTimer = self.selectedTimer {
            selectedTimer.currentTime = 0
            selectedTimer.timerStatus = .Alarm
        }
    }
    
    // MARK: - LGV_Timer_StateDelegate Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerStatus: TimerSettingTuple, from: TimerStatus) {
        if nil != self.delegate {
            self.delegate.timerSetting(didUpdateTimerStatus, changedTimerStatusFrom: from)
        }
        self.savePrefs()
    }
    
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerDisplayMode: TimerSettingTuple, from: TimerDisplayMode) {
        if nil != self.delegate {
            self.delegate.timerSetting(didUpdateTimerDisplayMode, changedTimerDisplayModeFrom: from)
        }
        self.savePrefs()
    }
    
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerCurrentTime: TimerSettingTuple, from: Int) {
        if nil != self.delegate {
            self.delegate.timerSetting(didUpdateTimerCurrentTime, changedCurrentTimeFrom: from)
        }
        self.savePrefs()
    }
    
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerWarnTime: TimerSettingTuple, from: Int) {
        if nil != self.delegate {
            self.delegate.timerSetting(didUpdateTimerWarnTime, changedWarnTimeFrom: from)
        }
        self.savePrefs()
    }
    
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerFinalTime: TimerSettingTuple, from: Int) {
        if nil != self.delegate {
            self.delegate.timerSetting(didUpdateTimerFinalTime, changedFinalTimeFrom: from)
        }
        self.savePrefs()
    }
    
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerTimeSet: TimerSettingTuple, from: Int) {
        if nil != self.delegate {
            self.delegate.timerSetting(didUpdateTimerTimeSet, changedTimeSetFrom: from)
        }
        self.savePrefs()
    }
    
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerSoundID: TimerSettingTuple, from: Int) {
        if nil != self.delegate {
            self.delegate.timerSetting(didUpdateTimerSoundID, changedTimerSoundIDFrom: from)
        }
        self.savePrefs()
    }
    
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerAlertMode: TimerSettingTuple, from: AlertMode) {
        if nil != self.delegate {
            self.delegate.timerSetting(didUpdateTimerAlertMode, changedTimerAlertModeFrom: from)
        }
        self.savePrefs()
    }
    
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerColorTheme: TimerSettingTuple, from: Int) {
        if nil != self.delegate {
            self.delegate.timerSetting(didUpdateTimerColorTheme, changedTimerColorThemeFrom: from)
        }
        self.savePrefs()
    }
    
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, didAddTimer: TimerSettingTuple) {
        if nil != self.delegate {
            self.delegate.timerEngine(self, didAddTimer: didAddTimer)
        }
        self.savePrefs()
    }
    
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, willRemoveTimer: TimerSettingTuple) {
        if nil != self.delegate {
            self.delegate.timerEngine(self, willRemoveTimer: willRemoveTimer)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, didRemoveTimerAtIndex: Int) {
        if nil != self.delegate {
            self.delegate.timerEngine(self, didRemoveTimerAtIndex: didRemoveTimerAtIndex)
        }
        self.savePrefs()
    }
    
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, didSelectTimer: TimerSettingTuple!) {
        if nil != self.delegate {
            self.delegate.timerEngine(self, didSelectTimer: didSelectTimer)
       }
        self.savePrefs()
    }
    
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, didDeselectTimer: TimerSettingTuple) {
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
        assert(index < self.appState.timers.count)
        return self.appState[index]
    }
    
    /* ################################################################## */
    /**
     */
    func indexOf(_ inUID: String) -> Int {
        return self.appState.indexOf(inUID)
    }
    
    /* ################################################################## */
    /**
     */
    func indexOf(_ inObject: TimerSettingTuple) -> Int {
        return self.appState.indexOf(inObject)
    }
    
    /* ################################################################## */
    /**
     */
    func contains(_ inObject: TimerSettingTuple) -> Bool {
        return self.appState.contains(inObject)
    }
    
    /* ################################################################## */
    /**
     */
    func contains(_ inUID: String) -> Bool {
        return self.appState.contains(inUID)
    }
    
    /* ################################################################## */
    /**
     */
    func makeIterator() -> AnyIterator<TimerSettingTuple> {
        var nextIndex = 0
        
        // Return a "bottom-up" iterator for the list.
        return AnyIterator {
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
        self.appState.append(inObject)
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
        self.appState.remove(at: index)
    }
    
    // MARK: - Callback Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @objc func timerCallback(_ inTimer: Timer) {
        DispatchQueue.main.async {
            if let selectedTimer = self.selectedTimer {
                if (.Stopped != selectedTimer.timerStatus) && (.Paused != selectedTimer.timerStatus) {
                    if .Alarm == selectedTimer.timerStatus {
                        if type(of: self).timerAlarmInterval <= (Date.timeIntervalSinceReferenceDate - self.selectedTimer.lastTick) {
                            self.selectedTimer.lastTick = Date.timeIntervalSinceReferenceDate
                            if nil != self.delegate {
                                self.delegate.timerSetting(selectedTimer, alarm: self._alarmCount)
                            }
                            self._alarmCount += 1
                        }
                    } else {
                        if type(of: self).timerTickInterval <= (Date.timeIntervalSinceReferenceDate - self.selectedTimer.lastTick) {
                            self.selectedTimer.lastTick = Date.timeIntervalSinceReferenceDate
                            selectedTimer.currentTime = Swift.max(0, selectedTimer.currentTime - 1)
                            if (0 < selectedTimer.timeSetPodiumWarn) && (0 < selectedTimer.timeSetPodiumFinal) && (selectedTimer.timeSetPodiumWarn > selectedTimer.timeSetPodiumFinal) {
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
                            } else {
                                if 0 == selectedTimer.currentTime {
                                    self._alarmCount = 0
                                    selectedTimer.timerStatus = .Alarm
                                } else {
                                    selectedTimer.timerStatus = .Running
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
