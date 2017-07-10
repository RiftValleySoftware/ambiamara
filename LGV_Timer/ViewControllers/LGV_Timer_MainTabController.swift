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
class LGV_Timer_MainTabController: UITabBarController, UITabBarControllerDelegate, LGV_Timer_TimerEngineDelegate {
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view has finished loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = 0
        LGV_Timer_AppDelegate.appDelegateObject.timerEngine = LGV_Timer_TimerEngine(delegate: self)
        self.viewControllers?[0].tabBarItem.title = self.viewControllers?[0].tabBarItem.title?.localizedVariant
        // Pre-load our color labels.
        _ = LGV_Timer_AppDelegate.appDelegateObject.timerEngine.prefs.pickerPepperArray
        self.updateTimers()
        self.delegate = self
    }
    
    // MARK: - Internal Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func updateTimers() {
        while 1 < (self.viewControllers?.count)! {
            self.viewControllers?.remove(at: 1)
        }
        
        for timer in LGV_Timer_AppDelegate.appDelegateObject.timerEngine {
            self.addTimer(timer)
        }
        
        self.moreNavigationController.navigationBar.tintColor = self.navigationController?.navigationBar.tintColor
        if let barStyle = self.navigationController?.navigationBar.barStyle {
            self.moreNavigationController.navigationBar.barStyle = barStyle
        }
        self.moreNavigationController.navigationBar.barTintColor = self.navigationController?.navigationBar.barTintColor
        self.moreNavigationController.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.white]
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
    
    /* ################################################################## */
    /**
     */
    func selectTimer(_ inTimerIndex: Int) {
        let timerIndex = 1 + inTimerIndex
        self.selectedViewController = self.viewControllers?[timerIndex]
    }
    
    /* ################################################################## */
    /**
     */
    func deleteTimer(_ inTimerIndex: Int) {
        let timer = LGV_Timer_AppDelegate.appDelegateObject.timerEngine[inTimerIndex]
        timer.seppuku()
        LGV_Timer_AppDelegate.appDelegateObject.timerEngine.savePrefs()
        self.updateTimers()
    }
    
    /* ################################################################## */
    /**
     */
    func addNewTimer() {
        let _ = LGV_Timer_AppDelegate.appDelegateObject.timerEngine.createNewTimer()
        self.updateTimers()
        LGV_Timer_AppDelegate.appDelegateObject.sendRecalculateMessage()
        self.selectTimer(LGV_Timer_AppDelegate.appDelegateObject.timerEngine.count - 1)
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
    func timerEngine(_ timerEngine: LGV_Timer_TimerEngine, didSelectTimer: TimerSettingTuple) {
        #if DEBUG
            print("Timer Was Selected: \(didSelectTimer)")
        #endif
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
    }
    
    /* ################################################################## */
    /**
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedCurrentTimeFrom: Int) {
        #if DEBUG
            print("Timer (\(timerSetting)) Changed Current Time From: \(changedCurrentTimeFrom)")
        #endif
    }
    
    /* ################################################################## */
    /**
     */
    func timerSetting(_ timerSetting: TimerSettingTuple, changedTimerStatusFrom: TimerStatus) {
        #if DEBUG
            print("Timer (\(timerSetting)) Changed Timer Status From: \(changedTimerStatusFrom)")
        #endif
    }
}

