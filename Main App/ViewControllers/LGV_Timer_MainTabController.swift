//
//  LGV_Timer_MainTabController.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 5/24/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//
/* ###################################################################################################################################### */
/**
 */

import UIKit

/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_MainTabController: SwipeableTabBarController, LGV_Timer_TimerEngineDelegate {
    /// This tracks our timer setup controllers. It gives us quick access to them.
    var activeTimerSetConrollers:[LGV_Timer_TimerSetController] = []
    var timerEngine: LGV_Timer_TimerEngine! = nil
    
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view has finished loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = 0
        self.timerEngine = LGV_Timer_TimerEngine(delegate: self)
        self.viewControllers?[0].tabBarItem.title = self.viewControllers?[0].tabBarItem.title?.localizedVariant
        self.updateTimers()
        self.delegate = self
        self.isSwipeEnabled = false // We disable the swipe, because we'll be providing our own.
    }
    
    // MARK: - Internal Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This function rebuilds the entire timer hierarchy from scratch.
     */
    func updateTimers() {
        DispatchQueue.main.async {
            self.activeTimerSetConrollers = []
            
            while 1 < (self.viewControllers?.count)! {
                self.viewControllers?.remove(at: 1)
            }
            
            for timer in self.timerEngine {
                self.addTimer(timer)
            }
            
            self.moreNavigationController.navigationBar.tintColor = self.navigationController?.navigationBar.tintColor
            if let barStyle = self.navigationController?.navigationBar.barStyle {
                self.moreNavigationController.navigationBar.barStyle = barStyle
            }
            self.moreNavigationController.navigationBar.barTintColor = self.navigationController?.navigationBar.barTintColor
            self.moreNavigationController.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
            self.moreNavigationController.view.tintColor = UIColor.black
            
            self.customizableViewControllers = []
            
            if let timerListNavController = self.viewControllers?[0] as? LGV_Timer_TimerSettingsNavController {
                if let timerSettingsController = timerListNavController.viewControllers[0] as? LGV_Timer_SettingsViewController {
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
     
     :param: inTimer The timer View Controller to add.
     */
    func addTimerToList(_ inTimer:LGV_Timer_TimerSetController) {
        for timerView in self.activeTimerSetConrollers {
            if timerView == inTimer {
                return
            }
        }
        
        self.self.activeTimerSetConrollers.append(inTimer)
    }
    
    /* ################################################################## */
    /**
     This removes a timer view controller from our list.
     
     :param: inTimer The timer View Controller to remove.
     */
    func removeTimerFromList(_ inTimer:LGV_Timer_TimerSetController) {
        var index: Int = 0
        
        for timerView in self.activeTimerSetConrollers {
            if timerView == inTimer {
                self.activeTimerSetConrollers.remove(at: index)
                return
            }
            index += 1
        }
    }
    
    /* ################################################################## */
    /**
     This fetches a timer View Controller from our tracking list, based on the timer object passed in.
     
     :param: timerObject The TimerSettingTuple of the View Controller.
     */
    func getTimerScreen(_ timerObject: TimerSettingTuple) -> LGV_Timer_TimerSetController! {
        for timerView in self.activeTimerSetConrollers {
            if timerView.timerObject.uid == timerObject.uid {
                return timerView
            }
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     */
    func selectTimer(_ inTimerIndex: Int) {
        let timerIndex = 1 + inTimerIndex
        DispatchQueue.main.async {
            if self.selectedViewController != self.viewControllers?[timerIndex] {
                #if DEBUG
                    print("Turning On Ignore Select From Watch.")
                #endif
                self.selectedViewController = self.viewControllers?[timerIndex]
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
        let _ = self.timerEngine.createNewTimer()
    }
    
    /* ################################################################## */
    /**
     */
    func addTimer(_ inTimerObject: TimerSettingTuple) {
        let storyboard = self.storyboard
        if nil != storyboard {
            let storyBoardID = "LGV_Timer_TimerNavController"
            if let timerController = storyboard!.instantiateViewController(withIdentifier: storyBoardID) as? LGV_Timer_TimerNavController {
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
    
    // MARK: - LGV_Timer_TimerEngineDelegate Protocol Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func timerEngine(_ timerEngine: LGV_Timer_TimerEngine, didAddTimer: TimerSettingTuple) {
        #if DEBUG
            print("Timer Added: \(didAddTimer)")
        #endif
        
        self.updateTimers()
        didAddTimer.selected = true
    }
    
    /* ################################################################## */
    /**
     */
    func timerEngine(_ timerEngine: LGV_Timer_TimerEngine, willRemoveTimer: TimerSettingTuple) {
        #if DEBUG
            print("Timer Will Be Removed: \(willRemoveTimer)")
        #endif
    }
    
    /* ################################################################## */
    /**
     */
    func timerEngine(_ timerEngine: LGV_Timer_TimerEngine, didRemoveTimerAtIndex: Int) {
        #if DEBUG
            print("Timer at index \(didRemoveTimerAtIndex) was removed.")
        #endif
        
        self.updateTimers()
    }
    
    /* ################################################################## */
    /**
     */
    func timerEngine(_ timerEngine: LGV_Timer_TimerEngine, didSelectTimer: TimerSettingTuple!) {
        #if DEBUG
            print("Timer Was Selected: \(didSelectTimer)")
        #endif
        
        var index = -1
        
        if nil != didSelectTimer {
            index = self.timerEngine.indexOf(didSelectTimer)
        }
        
        self.selectTimer(index)
    }
    
    /* ################################################################## */
    /**
     */
    func timerEngine(_ timerEngine: LGV_Timer_TimerEngine, didDeselectTimer: TimerSettingTuple) {
        #if DEBUG
            print("Timer Was Deselected: \(didDeselectTimer)")
        #endif
    }
    
    /* ################################################################## */
    /**
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
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedCurrentTimeFrom: Int) {
        #if DEBUG
            print("Timer (\(timerSetting)) Changed Current Time From: \(changedCurrentTimeFrom)")
        #endif
        
        if let controller = self.getTimerScreen(timerSetting) {
            controller.updateTimer()
            LGV_Timer_AppDelegate.appDelegateObject.sendTick()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimeSetFrom: Int) {
        #if DEBUG
            print("Timer (\(timerSetting)) Changed Set Time From: \(changedTimeSetFrom)")
        #endif
    }
    
    /* ################################################################## */
    /**
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedWarnTimeFrom: Int) {
        #if DEBUG
            print("Timer (\(timerSetting)) Changed Warning Time From: \(changedWarnTimeFrom)")
        #endif
    }
    
    /* ################################################################## */
    /**
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedFinalTimeFrom: Int) {
        #if DEBUG
            print("Timer (\(timerSetting)) Changed Final Time From: \(changedFinalTimeFrom)")
        #endif
    }
    
    /* ################################################################## */
    /**
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimerStatusFrom: TimerStatus) {
        #if DEBUG
            print("Timer (\(timerSetting)) Changed Timer Status From: \(changedTimerStatusFrom)")
        #endif
        
        if let controller = self.getTimerScreen(timerSetting) {
            if (.Running == timerSetting.timerStatus) && (.Stopped == changedTimerStatusFrom) {
                controller.startTimer()
                LGV_Timer_AppDelegate.appDelegateObject.sendStartMessage(timerUID: timerSetting.uid)
            } else {
                if (.Stopped == timerSetting.timerStatus) && ((.Alarm == changedTimerStatusFrom) || (.Running == changedTimerStatusFrom) || (.FinalRun == timerSetting.timerStatus) || (.WarnRun == changedTimerStatusFrom)) {
                    LGV_Timer_AppDelegate.appDelegateObject.sendStopMessage(timerUID: timerSetting.uid)
                }
               if .Dual == timerSetting.displayMode {
                    if ((.WarnRun == timerSetting.timerStatus) && (.Running == changedTimerStatusFrom)) || ((.FinalRun == timerSetting.timerStatus) && (.WarnRun == changedTimerStatusFrom)) {
                        if let runningTimer = controller.runningTimer {
                            runningTimer.flashDisplay()
                        }
                    }
                }
                
                controller.updateTimer()
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimerDisplayModeFrom: TimerDisplayMode) {
        #if DEBUG
            print("Timer (\(timerSetting)) Changed Display Mode From: \(changedTimerDisplayModeFrom)")
        #endif
    }
    
    /* ################################################################## */
    /**
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimerSoundIDFrom: Int) {
        #if DEBUG
            print("Timer (\(timerSetting)) Changed Sound ID From: \(changedTimerSoundIDFrom)")
        #endif
    }
    
    /* ################################################################## */
    /**
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimerAlertModeFrom: AlertMode) {
        #if DEBUG
            print("Timer (\(timerSetting)) Changed Alert Mode From: \(changedTimerAlertModeFrom)")
        #endif
    }
    
    /* ################################################################## */
    /**
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimerColorThemeFrom: Int) {
        #if DEBUG
            print("Timer (\(timerSetting)) Changed Color Theme From: \(changedTimerColorThemeFrom)")
        #endif
    }
}

