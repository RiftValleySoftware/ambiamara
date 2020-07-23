/**
 © Copyright 2018, The Great Rift Valley Software Company. All rights reserved.

 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.

 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import MediaPlayer
import RVS_BasicGCDTimer

/* ################################################################################################################################## */
// MARK: - LGV_Timer_TimerEngineDelegate Protocol -
/* ###################################################################################################################################### */
/**
 This protocol allows observers of the engine.
 */
protocol TimerEngineDelegate: class {
    /* ################################################################## */
    /**
     Called when we add a new timer.
     
     - parameter timerEngine: The TimerEngine instance that is calling this.
     - parameter didAddTimer: The timer setting that was added.
     */
    func timerEngine(_ timerEngine: TimerEngine, didAddTimer: TimerSettingTuple)

    /* ################################################################## */
    /**
     Called just before we remove a timer from the timer engine.
     
     - parameter timerEngine: The TimerEngine instance that is calling this.
     - parameter willRemoveTimer: The timer instance that will be removed.
     */
    func timerEngine(_ timerEngine: TimerEngine, willRemoveTimer: TimerSettingTuple)

    /* ################################################################## */
    /**
     Called just after we removed a timer from the timer engine.
     
     - parameter timerEngine: The TimerEngine instance that is calling this.
     - parameter didRemoveTimerAtIndex: The index of the timer that was removed.
     */
    func timerEngine(_ timerEngine: TimerEngine, didRemoveTimerAtIndex: Int)

    /* ################################################################## */
    /**
     Called when we select a timer.
     
     - parameter timerEngine: The TimerEngine instance that is calling this.
     - parameter didSelectTimer: The timer instance that was selected. It can be nil, if no timer was selected.
     */
    func timerEngine(_ timerEngine: TimerEngine, didSelectTimer: TimerSettingTuple!)

    /* ################################################################## */
    /**
     Called when we deselect a timer.
     
     - parameter timerEngine: The TimerEngine instance that is calling this.
     - parameter didSelectTimer: The timer instance that was deselected.
     */
    func timerEngine(_ timerEngine: TimerEngine, didDeselectTimer: TimerSettingTuple)

    /* ################################################################## */
    /**
     Called when a timer alarm goes off.
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter alarm: The index of the triggered alarm.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, alarm: Int)

    /* ################################################################## */
    /**
     Called when a timer time changes (ticks).
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter changedCurrentTimeFrom: The time (in epoch seconds) that was the original time.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, tick: Int)

    /* ################################################################## */
    /**
     Called when a timer set time is changed.
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter changedTimeSetFrom: The time (in epoch seconds) that was the original set time.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedCurrentTimeFrom: Int)

    /* ################################################################## */
    /**
     Called when a timer warning time is changed.
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter changedWarnTimeFrom: The time (in epoch seconds) that was the original warning time.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimeSetFrom: Int)

    /* ################################################################## */
    /**
     Called when a timer final time is changed.
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter changedWarnTimeFrom: The time (in epoch seconds) that was the original final time.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedWarnTimeFrom: Int)

    /* ################################################################## */
    /**
     Called when a timer status changes (normal, warning, final, alarm).
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter changedTimerStatusFrom: The original status.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedFinalTimeFrom: Int)

    /* ################################################################## */
    /**
     Called when a timer display mode changes (podium, digital, dual).
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter changedTimerDisplayModeFrom: The original mode.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimerStatusFrom: TimerStatus)

    /* ################################################################## */
    /**
     Called when a timer display mode changes (podium, digital, dual).
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter changedTimerDisplayModeFrom: The original mode.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimerDisplayModeFrom: TimerDisplayMode)

    /* ################################################################## */
    /**
     Called when a timer sound ID changes.
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter changedTimerSoundIDFrom: The original sound ID.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimerSoundIDFrom: Int)

    /* ################################################################## */
    /**
     Called when a timer's song URL changes.
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter changedTimerSongURLFrom: The original song URL.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimerSongURLFrom: String)

    /* ################################################################## */
    /**
     Called when a timer's next timer ID changes.
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter changedSucceedingTimerIDFrom: The original succeeding timer ID.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedSucceedingTimerIDFrom: Int)

    /* ################################################################## */
    /**
     Called when a timer's alert mode (sound, song, silent) changes.
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter changedTimerAlertModeFrom: The original alert mode.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimerAlertModeFrom: AlertMode)

    /* ################################################################## */
    /**
     Called when a timer's sound mode (sound, vibrate, silent) changes.
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter changedTimerSoundModeFrom: The original sound mode.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimerSoundModeFrom: SoundMode)

    /* ################################################################## */
    /**
     Called when a timer's audible ticks setting changes.
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter changedAudibleTicksFrom: The original audible ticks setting.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedAudibleTicksFrom: Bool)

    /* ################################################################## */
    /**
     Called when a timer's color theme changes.
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter changedTimerColorThemeFrom: The original color theme setting.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimerColorThemeFrom: Int)
}

/* ###################################################################################################################################### */
/**
 This class is the "heart" of the timer. It contains the timer state, settings, and stored prefs for all the timers.
 */
class TimerEngine: NSObject, Sequence, LGV_Timer_StateDelegate {
    /// We increment by tenths of a second.
    static let timerInterval: TimeInterval = 0.1
    /// Each "tick" is 1 second.
    static let timerTickInterval: TimeInterval = 1.0
    /// The alarm repeats every second.
    static let timerAlarmInterval: TimeInterval = 1.0
    
    /** This contains our color theme palette. */
    private static let _sviewBundleName = "ColorThemes"
    
    /* ################################################################################################################################## */
    // MARK: - Private Static Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /** This is the key for the app status prefs used by this app. */
    private static let _appStatePrefsKey: String = "AmbiaMara_AppState"
    
    /// This is true, if the timer is "ticking" (running).
    private var _timerTicking: Bool = false
    /// The time of the first tick
    private var _firstTick: TimeInterval = 0.0
    /// The number of times the alarm has "rung."
    private var _alarmCount: Int = 0
    
    /* ################################################################################################################################## */
    // MARK: - Internal Enums
    /* ################################################################################################################################## */
    /* ################################################################## */
    /** These are the keys we use for our timer prefs dictionary. */
    enum TimerPrefKeys: String {
        /// The set time
        case TimeSet
        /// The set time for timer warning.
        case TimeSetPodiumWarn
        /// The set time for timer final.
        case TimeSetPodiumFinal
        /// The timer display mode (podium, digital, dual)
        case DisplayMode
        /// The index of the selected color theme.
        case ColorTheme
        /// The alert mode (silent, vibrate, sound)
        case AlertMode
        /// The sound mode (music, sound, silent)
        case SoundMode
        /// The ID of a selected sound
        case SoundID
        /// The URL of a selected song
        case SongURLString
        /// The ID of a "next timer."
        case SucceedingTimerID
        /// True, if the timer has audible "ticks."
        case AudibleTicks
        /// A unique ID for the setting.
        case UID
    }
    
    /* ################################################################################################################################## */
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
    
    /* ################################################################################################################################## */
    // MARK: - Private Instance Properties
    /* ################################################################################################################################## */
    /** This will contain the UILabels that are used for the color theme. */
    private var _colorLabelArray: [UILabel] = []
    
    // MARK: - Instance Properties
    /* ################################################################################################################################## */
    /// This is any delegate for this engine. It is a weak reference, in order to inhibit reference loops.
    weak var delegate: TimerEngineDelegate!
    /// This is the current application state. It is the "heart" of the timer.
    var appState: LGV_Timer_State!
    /// This is the current selected timer (GCD timer).
    var gcdTimer: RVS_BasicGCDTimer!
    /// This aggregates our available sounds.
    var soundSelection: [String] = []
    /// This is the URI to the selected "tick" sound.
    var tickURI: String = ""
    
    /* ################################################################################################################################## */
    // MARK: - Instance Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This simply returns true, if a timer is currently selected.
     */
    var timerSelected: Bool {
        return appState.timerSelected
    }
    
    /* ################################################################## */
    /**
     This returns the currently selected timer (or nil, if no timer is selected).
     */
    var selectedTimer: TimerSettingTuple! {
        return appState.selectedTimer
    }
    
    /* ################################################################## */
    /**
     This returns (or changes) the 0-based index of the selected timer. It will be nil if the timer index is out of range.
     */
    var selectedTimerIndex: Int! {
        get {
            let index = appState.selectedTimerIndex
            if index >= timers.count || 0 > index {
                return nil
            }
            
            return index
        }
        set { appState.selectedTimerIndex = newValue }
    }

    /* ################################################################## */
    /**
     This returns the UID of the selected timer object.
     */
    var selectedTimerUID: String {
        get { return appState.selectedTimerUID }
        set { appState.selectedTimerUID = newValue }
    }
    
    /* ################################################################## */
    /**
     This returns true, if we have no timers (We should always have at least one, but belt and suspenders).
     */
    var isEmpty: Bool {
        return appState.isEmpty
    }
    
    /* ################################################################## */
    /**
     This returns the array of timer objects.
     */
    var timers: [TimerSettingTuple] {
        get { return appState.timers }
        set { appState.timers = newValue }
    }
    
    /* ################################################################## */
    /**
     This returns how many timers we have.
     */
    var count: Int {
        return appState.count
    }
    
    /* ################################################################## */
    /**
     This return true, if we currently have a ticking timer.
     */
    var timerActive: Bool {
        get { return nil != gcdTimer }
        
        set {
            if nil == gcdTimer {
                gcdTimer = RVS_BasicGCDTimer(timeIntervalInSeconds: Self.timerInterval, delegate: self, leewayInMilliseconds: 0, onlyFireOnce: false, context: nil, queue: nil, isWallTime: true)
                gcdTimer.isRunning = true
            } else if nil != gcdTimer {
                gcdTimer.isRunning = false
                gcdTimer = nil
            }
        }
    }
    
    /* ################################################################## */
    /**
     This returns the actual elapsed time (in a standard interval) since the timer started.
     */
    var actualTimeSinceStart: TimeInterval {
        if timerSelected && (0.0 < _firstTick) {
            return Date.timeIntervalSinceReferenceDate - _firstTick
        } else {
            return 0.0
        }
    }
    
    /* ################################################################## */
    /**
     Returns the color palettes.
     */
    var colorLabelArray: [UILabel] {
        if _colorLabelArray.isEmpty {
            // The first index is white.
            let label = UILabel()
            label.backgroundColor = UIColor.white
            _colorLabelArray = [label]
            // We generate a series of colors, fully saturated, from red (orangeish) to red (purpleish).
            for hue: CGFloat in stride(from: 0.0, to: 1.0, by: 0.05) {
                let color = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
                let label = UILabel()
                label.backgroundColor = color
                _colorLabelArray.append(label)
            }
        }
        
        return _colorLabelArray
    }

    /* ################################################################################################################################## */
    // MARK: - Private Class Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This creates a timer tuple from the persistent stored data sent in.
     */
    private class func _convertStorageToTimer(_ inTimer: NSDictionary) -> TimerSettingTuple {
        let tempSetting: TimerSettingTuple = defaultTimer
        
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
        
        if let soundMode = inTimer.object(forKey: TimerPrefKeys.SoundMode.rawValue) as? NSNumber {
            if let soundModeType = SoundMode(rawValue: soundMode.intValue) {
                tempSetting.soundMode = soundModeType
            }
        }
        
        if let soundID = inTimer.object(forKey: TimerPrefKeys.SoundID.rawValue) as? NSNumber {
            tempSetting.soundID = soundID.intValue
        }
        
        if let songURLString = inTimer.object(forKey: TimerPrefKeys.SongURLString.rawValue) as? String {
            tempSetting.songURLString = songURLString
        }

        if let succeedingTimerID = inTimer.object(forKey: TimerPrefKeys.SucceedingTimerID.rawValue) as? NSNumber {
            tempSetting.succeedingTimerID = succeedingTimerID.intValue
        }

        if let audibleTicks = inTimer.object(forKey: TimerPrefKeys.AudibleTicks.rawValue) as? NSNumber {
            tempSetting.audibleTicks = audibleTicks.boolValue
        }

        if let uid = inTimer.object(forKey: TimerPrefKeys.UID.rawValue) as? NSString {
            tempSetting.uid = uid as String
        } else {
            tempSetting.uid = NSUUID().uuidString
        }
        
        tempSetting.timerStatus = .Stopped
        
        return tempSetting
    }
    
    /* ################################################################################################################################## */
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
        _loadPrefs()
        timerActive = true
    }
    
    /* ################################################################## */
    /**
     We make sure we clean up after ourselves.
     */
    deinit {
        timerActive = false
        
        savePrefs()
        var index = 0
        
        for timer in timers where nil != delegate {
            DispatchQueue.main.async {
                self.delegate?.timerEngine(self, willRemoveTimer: timer)
                self.delegate?.timerEngine(self, didRemoveTimerAtIndex: index)
            }
            index += 1
        }
    }
    
    /* ################################################################################################################################## */
    // MARK: - Private Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This method loads the main prefs into our instance storage.
     
     NOTE: This will overwrite any unsaved changes to the current _loadedPrefs property.
     */
    private func _loadPrefs() {
        appState = LGV_Timer_State(delegate: self)
        // Pick up our beeper sounds.
        soundSelection = Bundle.main.paths(forResourcesOfType: "mp3", inDirectory: nil)
        soundSelection.sort()
        // Pick up the audible ticks sound.
        tickURI = Bundle.main.path(forResource: "tick", ofType: "aiff") ?? ""
        
        if  let temp = UserDefaults.standard.object(forKey: Self._appStatePrefsKey) as? Data,
            let temp2 = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(temp) as? LGV_Timer_State {
            appState = temp2
            appState.delegate = self
            timers.forEach {
                $0.timerStatus = .Stopped
                $0.storedColor = getIndexedColorThemeColor($0.colorTheme)
                $0.handler = appState
            }
        }
        
        // We are not allowed to have zero timers.
        if timers.isEmpty {
            let temp = createNewTimer()
            temp.storedColor = getIndexedColorThemeColor(temp.colorTheme)
        }
        
        // If we are in restricted media mode, then we don't allow any of our timers to be in Music mode.
        for timer in timers where .Music == timer.soundMode {  // Only ones that are set to Music get changed.
            #if targetEnvironment(macCatalyst)  // Catalyst won't allow us to access the music library. Boo!
                timer.soundMode = .Silent
            #else
                timer.soundMode = (.denied == MPMediaLibrary.authorizationStatus() || .restricted == MPMediaLibrary.authorizationStatus()) ? .Silent : timer.soundMode
            #endif
        }

        selectedTimerIndex = -1    // Start in the Timer List tab.
        savePrefs()    // Make sure that we save in the proper format.
    }
    
    /* ################################################################################################################################## */
    // MARK: - Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Returns the color for the indexed color theme.
     */
    func getIndexedColorThemeColor(_ index: Int) -> UIColor {
        var ret: UIColor
        
        let label = colorLabelArray[index]
        
        ret = label.textColor
        
        if let destColorSpace: CGColorSpace = CGColorSpace(name: CGColorSpace.sRGB) {
            if let newColor = ret.cgColor.converted(to: destColorSpace, intent: CGColorRenderingIntent.perceptual, options: nil) {
                ret = UIColor(cgColor: newColor)
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This is a factory for creating a new timer object.
     
     - returns: a new timer object, instantiated with a zero time, and default characteristics.
     */
    func createNewTimer() -> TimerSettingTuple {
        let timer = appState.createNewTimer()
        return timer
    }
    
    /* ################################################################## */
    /**
     This method simply saves the main preferences Dictionary into the standard user defaults.
     */
    func savePrefs() {
        if  let temp = appState,
            let appData = try? NSKeyedArchiver.archivedData(withRootObject: temp, requiringSecureCoding: false) {
            UserDefaults.standard.set(appData, forKey: Self._appStatePrefsKey)
        }
    }
    
    /* ################################################################## */
    /**
     Just what it says on the tin.
     Does nothing if no timer is selected.
     */
    func pauseTimer() {
        if let selectedTimer = selectedTimer {
            selectedTimer.timerStatus = .Paused
        }
    }
    
    /* ################################################################## */
    /**
     This will either start, or continue, the selected timer.
     Does nothing if no timer is selected.
     */
    func continueTimer() {
        if let selectedTimer = selectedTimer {
            if 0 >= selectedTimer.currentTime {
                startTimer()
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
        if let selectedTimer = selectedTimer {
            selectedTimer.timerStatus = .Running
      }
    }
    
    /* ################################################################## */
    /**
     Stops a running selected timer.
     Does nothing if no timer is selected.
     */
    func stopTimer() {
        if let selectedTimer = selectedTimer {
            selectedTimer.timerStatus = .Stopped
        }
    }
    
    /* ################################################################## */
    /**
     This resets the selected timer, and returns it to "paused" mode.
     Does nothing if no timer is selected.
     */
    func resetTimer() {
        if let selectedTimer = selectedTimer {
            let oldStatus = selectedTimer.timerStatus
            selectedTimer.timerStatus = .Paused
            selectedTimer.currentTime = selectedTimer.timeSet
            selectedTimer.lastTick = 0.0
            selectedTimer.firstTick = 0.0
            appState.sendStatusUpdateMessage(selectedTimer, from: oldStatus)
        }
    }
    
    /* ################################################################## */
    /**
     This forces a timer to "finish," and enter alarm mode.
     Does nothing if no timer is selected.
     */
    func endTimer() {
        if let selectedTimer = selectedTimer {
            selectedTimer.currentTime = 0
            selectedTimer.timerStatus = .Alarm
        }
    }
    
    /* ################################################################################################################################## */
    // MARK: - LGV_Timer_StateDelegate Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the timer status changes
     
     - parameter appState: The instance that called this delegate method.
     - parameter didUpdateTimerStatus: The timer setting tuple that was affected.
     - parameter from: The original state before the change.
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerStatus: TimerSettingTuple, from: TimerStatus) {
        DispatchQueue.main.async {
            self.delegate?.timerSetting(didUpdateTimerStatus, changedTimerStatusFrom: from)
        }
        savePrefs()
    }
    
    /* ################################################################## */
    /**
     Called when the timer mode changes
     
     - parameter appState: The instance that called this delegate method.
     - parameter didUpdateTimerDisplayMode: The timer setting tuple that was affected.
     - parameter from: The original state before the change.
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerDisplayMode: TimerSettingTuple, from: TimerDisplayMode) {
        DispatchQueue.main.async {
            self.delegate?.timerSetting(didUpdateTimerDisplayMode, changedTimerDisplayModeFrom: from)
        }
        savePrefs()
    }
    
    /* ################################################################## */
    /**
     Called when the timer current time changes
     
     - parameter appState: The instance that called this delegate method.
     - parameter didUpdateTimerCurrentTime: The timer setting tuple that was affected.
     - parameter from: The original time before the change.
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerCurrentTime: TimerSettingTuple, from: Int) {
        DispatchQueue.main.async {
            self.delegate?.timerSetting(didUpdateTimerCurrentTime, changedCurrentTimeFrom: from)
        }
        savePrefs()
    }
    
    /* ################################################################## */
    /**
     Called when the timer warning time setting is changed
     
     - parameter appState: The instance that called this delegate method.
     - parameter didUpdateTimerWarnTime: The timer setting tuple that was affected.
     - parameter from: The original time before the change.
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerWarnTime: TimerSettingTuple, from: Int) {
        DispatchQueue.main.async {
            self.delegate?.timerSetting(didUpdateTimerWarnTime, changedWarnTimeFrom: from)
        }
        savePrefs()
    }
    
    /* ################################################################## */
    /**
     Called when the timer final time setting is changed
     
     - parameter appState: The instance that called this delegate method.
     - parameter didUpdateTimerFinalTime: The timer setting tuple that was affected.
     - parameter from: The original time before the change.
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerFinalTime: TimerSettingTuple, from: Int) {
        DispatchQueue.main.async {
            self.delegate?.timerSetting(didUpdateTimerFinalTime, changedFinalTimeFrom: from)
        }
        savePrefs()
    }
    
    /* ################################################################## */
    /**
     Called when the timer starting time setting is changed
     
     - parameter appState: The instance that called this delegate method.
     - parameter didUpdateTimerTimeSet: The timer setting tuple that was affected.
     - parameter from: The original time before the change.
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerTimeSet: TimerSettingTuple, from: Int) {
        DispatchQueue.main.async {
            self.delegate?.timerSetting(didUpdateTimerTimeSet, changedTimeSetFrom: from)
        }
        savePrefs()
    }
    
    /* ################################################################## */
    /**
     Called when the timer sound ID setting is changed
     
     - parameter appState: The instance that called this delegate method.
     - parameter didUpdateTimerSoundID: The timer setting tuple that was affected.
     - parameter from: The original ID before the change.
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerSoundID: TimerSettingTuple, from: Int) {
        DispatchQueue.main.async {
            self.delegate?.timerSetting(didUpdateTimerSoundID, changedTimerSoundIDFrom: from)
        }
        savePrefs()
    }
    
    /* ################################################################## */
    /**
     Called when the timer song URL setting is changed
     
     - parameter appState: The instance that called this delegate method.
     - parameter didUpdateTimerSongURL: The timer setting tuple that was affected.
     - parameter from: The original URL (as a String) before the change.
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerSongURL: TimerSettingTuple, from: String) {
        DispatchQueue.main.async {
            self.delegate?.timerSetting(didUpdateTimerSongURL, changedTimerSongURLFrom: from)
        }
        savePrefs()
    }

    /* ################################################################## */
    /**
     Called when the timer alert mode setting is changed
     
     - parameter appState: The instance that called this delegate method.
     - parameter didUpdateTimerAlertMode: The timer setting tuple that was affected.
     - parameter from: The original mode before the change.
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerAlertMode: TimerSettingTuple, from: AlertMode) {
        DispatchQueue.main.async {
            self.delegate?.timerSetting(didUpdateTimerAlertMode, changedTimerAlertModeFrom: from)
        }
        savePrefs()
    }

    /* ################################################################## */
    /**
     Called when the timer sound mode setting is changed
     
     - parameter appState: The instance that called this delegate method.
     - parameter didUpdateTimerSoundMode: The timer setting tuple that was affected.
     - parameter from: The original mode before the change.
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerSoundMode: TimerSettingTuple, from: SoundMode) {
        DispatchQueue.main.async {
            self.delegate?.timerSetting(didUpdateTimerSoundMode, changedTimerSoundModeFrom: from)
        }
        savePrefs()
    }

    /* ################################################################## */
    /**
     Called when the next timer ID setting is changed
     
     - parameter appState: The instance that called this delegate method.
     - parameter didUpdateSucceedingTimerID: The timer setting tuple that was affected.
     - parameter from: The original ID before the change.
     */
    func appState(_ appState: LGV_Timer_State, didUpdateSucceedingTimerID: TimerSettingTuple, from: Int) {
        DispatchQueue.main.async {
            self.delegate?.timerSetting(didUpdateSucceedingTimerID, changedSucceedingTimerIDFrom: from)
        }
        savePrefs()
    }

    /* ################################################################## */
    /**
     Called when the audible ticks setting is changed
     
     - parameter appState: The instance that called this delegate method.
     - parameter didUpdateAudibleTicks: The timer setting tuple that was affected.
     - parameter from: The original state before the change.
     */
    func appState(_ appState: LGV_Timer_State, didUpdateAudibleTicks: TimerSettingTuple, from: Bool) {
        DispatchQueue.main.async {
            self.delegate?.timerSetting(didUpdateAudibleTicks, changedAudibleTicksFrom: from)
        }
        savePrefs()
    }

    /* ################################################################## */
    /**
     Called when the color theme setting is changed
     
     - parameter appState: The instance that called this delegate method.
     - parameter didUpdateTimerColorTheme: The timer setting tuple that was affected.
     - parameter from: The original state before the change.
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerColorTheme: TimerSettingTuple, from: Int) {
        DispatchQueue.main.async {
            self.delegate?.timerSetting(didUpdateTimerColorTheme, changedTimerColorThemeFrom: from)
        }
        savePrefs()
    }

    /* ################################################################## */
    /**
     Called when a timer is added
     
     - parameter appState: The instance that called this delegate method.
     - parameter didAddTimer: The timer setting tuple that was affected.
     */
    func appState(_ appState: LGV_Timer_State, didAddTimer: TimerSettingTuple) {
        DispatchQueue.main.async {
            self.delegate?.timerEngine(self, didAddTimer: didAddTimer)
        }
        savePrefs()
    }
    
    /* ################################################################## */
    /**
     Called when a timer is about to be removed
     
     - parameter appState: The instance that called this delegate method.
     - parameter didAddTimer: The timer setting tuple that will be removed.
     */
    func appState(_ appState: LGV_Timer_State, willRemoveTimer: TimerSettingTuple) {
        DispatchQueue.main.async {
            self.delegate?.timerEngine(self, willRemoveTimer: willRemoveTimer)
        }
    }
    
    /* ################################################################## */
    /**
     Called when a timer was removed
     
     - parameter appState: The instance that called this delegate method.
     - parameter didRemoveTimerAtIndex: The 0-based index of the imer that was removed.
     */
    func appState(_ appState: LGV_Timer_State, didRemoveTimerAtIndex: Int) {
        DispatchQueue.main.async {
            self.delegate?.timerEngine(self, didRemoveTimerAtIndex: didRemoveTimerAtIndex)
        }
        savePrefs()
    }
    
    /* ################################################################## */
    /**
     Called when a timer was selected
     
     - parameter appState: The instance that called this delegate method.
     - parameter didSelectTimer: The timer setting tuple that was affected. It is optional, as it is possible to select no timer.
     */
    func appState(_ appState: LGV_Timer_State, didSelectTimer: TimerSettingTuple!) {
        DispatchQueue.main.async {
            self.delegate?.timerEngine(self, didSelectTimer: didSelectTimer)
        }
        savePrefs()
    }
    
    /* ################################################################## */
    /**
     Called when a timer was deselected
     
     - parameter appState: The instance that called this delegate method.
     - parameter didSelectTimer: The timer setting tuple that was affected.
     */
    func appState(_ appState: LGV_Timer_State, didDeselectTimer: TimerSettingTuple) {
        DispatchQueue.main.async {
            self.delegate?.timerEngine(self, didDeselectTimer: didDeselectTimer)
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
        assert(index < appState.timers.count)
        return appState[index]
    }

    /* ################################################################## */
    /**
     Get the index of an element by its UUID
     
     - parameter inUID: The UUID of the element we're looking for.
     - returns: The 0-based index of the given element.
     */
    func indexOf(_ inUID: String) -> Int {
        return appState.indexOf(inUID)
    }

    /* ################################################################## */
    /**
     Get the index of an element
     
     - parameter inObject: The element we're looking for.
     - returns: The 0-based index of the given element.
     */
    func indexOf(_ inObject: TimerSettingTuple) -> Int {
        return appState.indexOf(inObject)
    }

    /* ################################################################## */
    /**
     See if our settings contain an object.
     
     - parameter inObject: The element we're looking for.
     - returns: true, if the settings array contains the given object.
     */
    func contains(_ inObject: TimerSettingTuple) -> Bool {
        return appState.contains(inObject)
    }

    /* ################################################################## */
    /**
     See if our settings contain an object by its UUID.
     
     - parameter inUID: The UUID of the element we're looking for.
     - returns: true, if the settings array contains the given object.
     */
    func contains(_ inUID: String) -> Bool {
        return appState.contains(inUID)
    }
    
    /* ################################################################## */
    /**
     - returns: A new, initialized iterator of the settings.
     */
    func makeIterator() -> AnyIterator<TimerSettingTuple> {
        var nextIndex = 0
        
        // Return a "bottom-up" iterator for the list.
        return AnyIterator {
            if nextIndex == self.count {
                return nil
            }
            nextIndex += 1
            return self.appState[nextIndex - 1]
        }
    }
    
    /* ################################################################## */
    /**
     Append a new object to the end of our array.
     
     - parameter inObject: The object we're appending.
     */
    func append(_ inObject: TimerSettingTuple) {
        appState.append(inObject)
    }
    
    /* ################################################################## */
    /**
     Remove an object at the given 0-based index.
     
     - parameter at: The 0-based index of the object to be removed.
     */
    func remove(at index: Int) {
        DispatchQueue.main.async {
            if nil != self.delegate {
                let timerToBeRemoved = self[index]
                self.delegate?.timerEngine(self, willRemoveTimer: timerToBeRemoved)
            }
        }
        appState.remove(at: index)
    }
}

/* ###################################################################################################################################### */
// MARK: - RVS_BasicGCDTimerDelegate Conformance
/* ###################################################################################################################################### */
extension TimerEngine: RVS_BasicGCDTimerDelegate {
    /* ################################################################## */
    /**
     This is the callback that is made by the repeating timer.
     
     - parameter inTimer: The Timer object that is calling this.
     */
    func basicGCDTimerCallback(_ inTimer: RVS_BasicGCDTimer) {
        if let selectedTimer = selectedTimer {
            if (.Stopped != selectedTimer.timerStatus) && (.Paused != selectedTimer.timerStatus) {
                if .Alarm == selectedTimer.timerStatus {
                    if Self.timerAlarmInterval <= (Date.timeIntervalSinceReferenceDate - selectedTimer.lastTick) {
                        selectedTimer.lastTick = Date.timeIntervalSinceReferenceDate
                        DispatchQueue.main.async {
                            self.delegate?.timerSetting(selectedTimer, alarm: self._alarmCount)
                        }
                        _alarmCount += 1
                    }
                } else {
                    if Self.timerTickInterval <= (Date.timeIntervalSinceReferenceDate - selectedTimer.lastTick) {
                        selectedTimer.lastTick = Date.timeIntervalSinceReferenceDate
                        selectedTimer.currentTime = Swift.max(0, selectedTimer.currentTime - 1)
                        if (0 < selectedTimer.timeSetPodiumWarn) && (0 < selectedTimer.timeSetPodiumFinal) && (selectedTimer.timeSetPodiumWarn > selectedTimer.timeSetPodiumFinal) {
                            switch selectedTimer.currentTime {
                            case 0:
                                _alarmCount = 0
                                selectedTimer.timerStatus = .Alarm
                            case 1...selectedTimer.timeSetPodiumFinal:
                                DispatchQueue.main.async {
                                    self.delegate?.timerSetting(selectedTimer, tick: (.Digital == selectedTimer.displayMode ? 1 : 3))
                                }
                                selectedTimer.timerStatus = .FinalRun
                            case (selectedTimer.timeSetPodiumFinal + 1)...selectedTimer.timeSetPodiumWarn:
                                DispatchQueue.main.async {
                                    self.delegate?.timerSetting(selectedTimer, tick: (.Digital == selectedTimer.displayMode ? 1 : 2))
                                }
                                selectedTimer.timerStatus = .WarnRun
                            default:
                                selectedTimer.timerStatus = .Running
                                DispatchQueue.main.async {
                                    self.delegate?.timerSetting(selectedTimer, tick: 1)
                                }
                            }
                        } else {
                            if 0 == selectedTimer.currentTime {
                                _alarmCount = 0
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
