/**
 © Copyright 2018, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

/* ###################################################################################################################################### */
/**
 */

import UIKit

/* ###################################################################################################################################### */
/**
 */
class Timer_MainTabController: SwipeableTabBarController, TimerEngineDelegate {
    /// This tracks our timer setup controllers. It gives us quick access to them.
    var activeTimerSetControllers: [TimerSetController] = []
    /// The "haert" of the timer.
    var timerEngine: TimerEngine! = nil
    
    /* ################################################################## */
    /**
     We do this, to intercept the call, and make sure that we close any open settings.
     */
    override var selectedViewController: UIViewController? {
        get {
            return super.selectedViewController
        }
        
        set {
            if newValue != super.selectedViewController,
                let viewController = super.selectedViewController as? UINavigationController {
                viewController.popToRootViewController(animated: false)
                Timer_AppDelegate.lockOrientation(.all)
            }
            
            super.selectedViewController = newValue
        }
    }
    
    /* ################################################################################################################################## */
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view has finished loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = 0
        self.timerEngine = TimerEngine(delegate: self)
        self.viewControllers?[0].tabBarItem.title = self.viewControllers?[0].tabBarItem.title?.localizedVariant
        self.updateTimers()
        self.delegate = self
        self.isSwipeEnabled = false // We disable the swipe, because we'll be providing our own.
    }
    
    /* ################################################################################################################################## */
    // MARK: - Internal Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This function rebuilds the entire timer hierarchy from scratch.
     */
    func updateTimers() {
        DispatchQueue.main.async {
            self.activeTimerSetControllers = []
            
            while 1 < (self.viewControllers?.count)! {
                self.viewControllers?.remove(at: 1)
            }
            
            self.timerEngine.forEach {
                self.addTimer($0)
            }
            
            self.moreNavigationController.navigationBar.tintColor = self.navigationController?.navigationBar.tintColor
            if let barStyle = self.navigationController?.navigationBar.barStyle {
                self.moreNavigationController.navigationBar.barStyle = barStyle
            }
            self.moreNavigationController.navigationBar.barTintColor = self.navigationController?.navigationBar.barTintColor
            self.moreNavigationController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            self.moreNavigationController.view.tintColor = UIColor.black
            
            self.customizableViewControllers = []
            
            if let timerListNavController = self.viewControllers?[0] as? TimerSettingsNavController {
                if let timerSettingsController = timerListNavController.viewControllers[0] as? Timer_SettingsViewController {
                    if nil != timerSettingsController.timerTableView {
                        timerSettingsController.timerTableView.reloadData()
                    }
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     This adds a single timer base View Controller to our tracking list.
     
     - parameter inTimer: The timer View Controller to add.
     */
    func addTimerToList(_ inTimer: TimerSetController) {
        for timerView in self.activeTimerSetControllers where timerView == inTimer {
            return
        }
        
        self.activeTimerSetControllers.append(inTimer)
    }
    
    /* ################################################################## */
    /**
     This removes a timer view controller from our list.
     
     - parameter inTimer: The timer View Controller to remove.
     */
    func removeTimerFromList(_ inTimer: TimerSetController) {
        for i in self.activeTimerSetControllers.enumerated() where i.element == inTimer {
            self.activeTimerSetControllers.remove(at: i.offset)
            break
        }
    }
    
    /* ################################################################## */
    /**
     This fetches a timer View Controller from our tracking list, based on the timer object passed in.
     
     - parameter timerObject: The TimerSettingTuple of the View Controller.
     */
    func getTimerScreen(_ timerObject: TimerSettingTuple) -> TimerSetController! {
        for timerView in self.activeTimerSetControllers where timerView.timerObject.uid == timerObject.uid {
            return timerView
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     Select the timer.
     
     - parameter inTimerIndex: The 0-based index of the timer to be selected.
     - parameter andStartTimer: If true (optional, and default is false), the timer will be started, as soon as it's selected.
     */
    func selectTimer(_ inTimerIndex: Int, andStartTimer inStartTimer: Bool = false) {
        let timerIndex = 1 + inTimerIndex
        DispatchQueue.main.async {
            if self.selectedViewController != self.viewControllers?[timerIndex] {
                #if DEBUG
                    print("Turning On Ignore Select From Watch.")
                #endif
                self.selectedViewController = self.viewControllers?[timerIndex]
                if inStartTimer {
                    #if DEBUG
                        print("Starting Selected Timer.")
                    #endif
                    
                    self.timerEngine.startTimer()
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func deleteTimer(_ inTimerIndex: Int) {
        let timer = self.timerEngine[inTimerIndex]
        timer.seppuku()
    }
    
    /* ################################################################## */
    /**
     */
    func addNewTimer() {
        _ = self.timerEngine.createNewTimer()
    }
    
    /* ################################################################## */
    /**
     */
    func addTimer(_ inTimerObject: TimerSettingTuple) {
        let storyboard = self.storyboard
        if nil != storyboard {
            let storyBoardID = "LGV_Timer_TimerNavController"
            if let timerController = storyboard!.instantiateViewController(withIdentifier: storyBoardID) as? TimerNavController {
                timerController.timerObject = inTimerObject
                timerController.delegate = timerController
                let timerTitle = timerController.tabBarText
                timerController.tabBarItem.title = timerTitle
                timerController.tabBarItem.image = timerController.tabBarImage
                timerController.tabBarItem.selectedImage = timerController.tabBarImage
                timerController.navigationBar.topItem?.title = timerTitle
                self.viewControllers?.append(timerController)
            }
        }
    }
    
    /* ################################################################## */
    /**
     This is used by the "cascading timer" functionality.
     
     Call this method to select a timer, and start it going.
     
     - parameter inIndex: The 0-based index of the next timer to be selected and started.
     */
    func selectAndStartTimerAtIndex(_ inIndex: Int) {
        assert(0 <= inIndex, "Timer Index Must be 0 or greater!")
        #if DEBUG
            print("Cascading the timer to timer number \(inIndex + 1)")
        #endif
        self.selectTimer(inIndex, andStartTimer: true)
    }
    
    /* ################################################################################################################################## */
    // MARK: - TimerEngineDelegate Protocol Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when we add a new timer.
     
     - parameter timerEngine: The TimerEngine instance that is calling this.
     - parameter didAddTimer: The timer setting that was added.
     */
    func timerEngine(_ timerEngine: TimerEngine, didAddTimer: TimerSettingTuple) {
        #if DEBUG
            print("Timer Added: \(didAddTimer)")
        #endif
        
        self.updateTimers()
        didAddTimer.selected = true
    }
    
    /* ################################################################## */
    /**
     Called just before we remove a timer from the timer engine.
     
     - parameter timerEngine: The TimerEngine instance that is calling this.
     - parameter willRemoveTimer: The timer instance that will be removed.
     */
    func timerEngine(_ timerEngine: TimerEngine, willRemoveTimer: TimerSettingTuple) {
        #if DEBUG
            print("Timer Will Be Removed: \(willRemoveTimer)")
        #endif
    }
    
    /* ################################################################## */
    /**
     Called just after we removed a timer from the timer engine.
     
     - parameter timerEngine: The TimerEngine instance that is calling this.
     - parameter didRemoveTimerAtIndex: The index of the timer that was removed.
     */
    func timerEngine(_ timerEngine: TimerEngine, didRemoveTimerAtIndex: Int) {
        #if DEBUG
            print("Timer at index \(didRemoveTimerAtIndex) was removed.")
        #endif
        
        self.updateTimers()
    }
    
    /* ################################################################## */
    /**
     Called when we select a timer.
     
     - parameter timerEngine: The TimerEngine instance that is calling this.
     - parameter didSelectTimer: The timer instance that was selected. It can be nil, if no timer was selected.
     */
    func timerEngine(_ timerEngine: TimerEngine, didSelectTimer: TimerSettingTuple!) {
        #if DEBUG
        print("Timer Was Selected: \(String(describing: didSelectTimer))")
        #endif
        
        var index = -1
        
        if nil != didSelectTimer {
            index = self.timerEngine.indexOf(didSelectTimer)
        }
        
        self.selectTimer(index)
    }
    
    /* ################################################################## */
    /**
     Called when we deselect a timer.
     
     - parameter timerEngine: The TimerEngine instance that is calling this.
     - parameter didSelectTimer: The timer instance that was deselected.
     */
    func timerEngine(_ timerEngine: TimerEngine, didDeselectTimer: TimerSettingTuple) {
        #if DEBUG
            print("Timer Was Deselected: \(didDeselectTimer)")
        #endif
    }
    
    /* ################################################################## */
    /**
     Called when a timer alarm goes off.
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter alarm: The index of the triggered alarm.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, alarm: Int) {
        #if DEBUG
            print("Timer (\(timerSetting)) Alarm: \(alarm)")
        #endif
        
        if let controller = self.getTimerScreen(timerSetting) {
            controller.updateTimer()
        }
    }
    
    /* ################################################################## */
    /**
     Called when a timer "ticks."
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter tick: The number of ticks to be made (for when we are in a final mode).
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, tick inTimes: Int) {
        #if DEBUG
        print("Timer (\(timerSetting)) Tick: \(inTimes)")
        #endif
        if let controller = self.getTimerScreen(timerSetting) {
            if timerSetting.audibleTicks {
                controller.tick(times: inTimes)
            }
        }
    }

    /* ################################################################## */
    /**
     Called when a timer time changes (ticks).
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter changedCurrentTimeFrom: The time (in epoch seconds) that was the original time.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedCurrentTimeFrom: Int) {
        #if DEBUG
            print("Timer (\(timerSetting)) Changed Current Time From: \(changedCurrentTimeFrom)")
        #endif
        
        if let controller = self.getTimerScreen(timerSetting) {
            controller.updateTimer()
            Timer_AppDelegate.appDelegateObject.sendTick()
        }
    }
    
    /* ################################################################## */
    /**
     Called when a timer set time is changed.
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter changedTimeSetFrom: The time (in epoch seconds) that was the original set time.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimeSetFrom: Int) {
        #if DEBUG
            print("Timer (\(timerSetting)) Changed Set Time From: \(changedTimeSetFrom)")
        #endif
    }
    
    /* ################################################################## */
    /**
     Called when a timer warning time is changed.
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter changedWarnTimeFrom: The time (in epoch seconds) that was the original warning time.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedWarnTimeFrom: Int) {
        #if DEBUG
            print("Timer (\(timerSetting)) Changed Warning Time From: \(changedWarnTimeFrom)")
        #endif
    }
    
    /* ################################################################## */
    /**
     Called when a timer final time is changed.
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter changedWarnTimeFrom: The time (in epoch seconds) that was the original final time.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedFinalTimeFrom: Int) {
        #if DEBUG
            print("Timer (\(timerSetting)) Changed Final Time From: \(changedFinalTimeFrom)")
        #endif
    }
    
    /* ################################################################## */
    /**
     Called when a timer status changes (normal, warning, final, alarm).
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter changedTimerStatusFrom: The original status.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimerStatusFrom: TimerStatus) {
        #if DEBUG
            print("Timer (\(timerSetting)) Changed Timer Status From: \(changedTimerStatusFrom)")
        #endif
        
        if let controller = self.getTimerScreen(timerSetting) {
            if (.Running == timerSetting.timerStatus) && (.Stopped == changedTimerStatusFrom) {
                controller.startTimer()
                Timer_AppDelegate.appDelegateObject.sendStartMessage(timerUID: timerSetting.uid)
            } else {
                if (.Stopped == timerSetting.timerStatus) && ((.Alarm == changedTimerStatusFrom) || (.Running == changedTimerStatusFrom) || (.FinalRun == timerSetting.timerStatus) || (.WarnRun == changedTimerStatusFrom)) {
                    Timer_AppDelegate.appDelegateObject.sendStopMessage(timerUID: timerSetting.uid)
                }
                
                controller.updateTimer()

                if .Dual == timerSetting.displayMode {
                    if ((.WarnRun == timerSetting.timerStatus) && (.Running == changedTimerStatusFrom)) || ((.FinalRun == timerSetting.timerStatus) && (.WarnRun == changedTimerStatusFrom)) {
                        if let runningTimer = controller.runningTimer {
                            runningTimer.flashDisplay()
                        }
                    }
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called when a timer display mode changes (podium, digital, dual).
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter changedTimerDisplayModeFrom: The original mode.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimerDisplayModeFrom: TimerDisplayMode) {
        #if DEBUG
            print("Timer (\(timerSetting)) Changed Display Mode From: \(changedTimerDisplayModeFrom)")
        #endif
    }
    
    /* ################################################################## */
    /**
     Called when a timer sound ID changes.
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter changedTimerSoundIDFrom: The original sound ID.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimerSoundIDFrom: Int) {
        #if DEBUG
            print("Timer (\(timerSetting)) Changed Sound ID From: \(changedTimerSoundIDFrom)")
        #endif
    }
 
    /* ################################################################## */
    /**
     Called when a timer's song URL changes.
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter changedTimerSongURLFrom: The original song URL.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimerSongURLFrom: String) {
        #if DEBUG
        print("Timer (\(timerSetting)) Changed Song URL From: \(changedTimerSongURLFrom)")
        #endif
    }

    /* ################################################################## */
    /**
     Called when a timer's next timer ID changes.
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter changedSucceedingTimerIDFrom: The original succeeding timer ID.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedSucceedingTimerIDFrom: Int) {
        #if DEBUG
            print("Timer (\(timerSetting)) Changed Next Timer ID From: \(changedSucceedingTimerIDFrom)")
        #endif
    }

    /* ################################################################## */
    /**
     Called when a timer's alert mode (sound, song, silent) changes.
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter changedTimerAlertModeFrom: The original alert mode.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimerAlertModeFrom: AlertMode) {
        #if DEBUG
            print("Timer (\(timerSetting)) Changed Alert Mode From: \(changedTimerAlertModeFrom)")
        #endif
    }

    /* ################################################################## */
    /**
     Called when a timer's sound mode (sound, vibrate, silent) changes.
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter changedTimerSoundModeFrom: The original sound mode.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimerSoundModeFrom: SoundMode) {
        #if DEBUG
            print("Timer (\(timerSetting)) Changed Sound Mode From: \(changedTimerSoundModeFrom)")
        #endif
    }

    /* ################################################################## */
    /**
     Called when a timer's audible ticks setting changes.
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter changedAudibleTicksFrom: The original audible ticks setting.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedAudibleTicksFrom: Bool) {
        #if DEBUG
            print("Timer (\(timerSetting)) Changed Audible Ticks From: \(changedAudibleTicksFrom ? "true" : "false")")
        #endif
    }

    /* ################################################################## */
    /**
     Called when a timer's color theme changes.
     
     - parameter timerSetting: The Timer setting that is affected by this call.
     - parameter changedTimerColorThemeFrom: The original color theme setting.
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimerColorThemeFrom: Int) {
        #if DEBUG
            print("Timer (\(timerSetting)) Changed Color Theme From: \(changedTimerColorThemeFrom)")
        #endif
    }
}
