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
class LGV_Timer_MainTabController: UITabBarController, UITabBarControllerDelegate {
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view has finished loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = 0
        self.updateTimers()
        self.delegate = self
        self.viewControllers?[0].tabBarItem.title = self.viewControllers?[0].tabBarItem.title?.localizedVariant
        // Pre-load our color labels.
        _ = LGV_Timer_AppDelegate.appDelegateObject.timerEngine.prefs.pickerPepperArray
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
        
        for timer in LGV_Timer_AppDelegate.appDelegateObject.timerEngine.timers {
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
        LGV_Timer_AppDelegate.appDelegateObject.timerEngine.timers.remove(at: inTimerIndex)
        LGV_Timer_AppDelegate.appDelegateObject.timerEngine.prefs.savePrefs()
        self.updateTimers()
    }
    
    /* ################################################################## */
    /**
     */
    func addNewTimer() {
        var timers = LGV_Timer_AppDelegate.appDelegateObject.timerEngine.timers
        let newTimer = LGV_Timer_StaticPrefs.defaultTimer
        timers.append(newTimer)
        LGV_Timer_AppDelegate.appDelegateObject.timerEngine.timers = timers
        LGV_Timer_AppDelegate.appDelegateObject.timerEngine.prefs.savePrefs()
        
        self.addTimer(newTimer)
        self.updateTimers()
        LGV_Timer_AppDelegate.appDelegateObject.sendRecalculateMessage()
        self.selectTimer(timers.count - 1)
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
}

