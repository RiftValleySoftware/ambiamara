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
class LGV_Timer_MainTabController: UITabBarController {
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
        self.viewControllers?[0].tabBarItem.title = self.viewControllers?[0].tabBarItem.title?.localizedVariant
        // Pre-load our color labels.
        _ = s_g_LGV_Timer_AppDelegatePrefs.pickerPepperArray
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
        
        for timer in s_g_LGV_Timer_AppDelegatePrefs.timers {
            self.addTimer(timer)
        }
    
        self.moreNavigationController.navigationBar.tintColor = self.navigationController?.navigationBar.tintColor
        if let barStyle = self.navigationController?.navigationBar.barStyle {
            self.moreNavigationController.navigationBar.barStyle = barStyle
        }
        self.moreNavigationController.navigationBar.barTintColor = self.navigationController?.navigationBar.barTintColor
        self.moreNavigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
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
        s_g_LGV_Timer_AppDelegatePrefs.timers.remove(at: inTimerIndex)
        s_g_LGV_Timer_AppDelegatePrefs.savePrefs()
        self.updateTimers()
    }
    
    /* ################################################################## */
    /**
     */
    func addNewTimer() {
        var timers = s_g_LGV_Timer_AppDelegatePrefs.timers
        let newTimer = LGV_Timer_StaticPrefs.defaultTimer
        timers.append(newTimer)
        s_g_LGV_Timer_AppDelegatePrefs.timers = timers
        s_g_LGV_Timer_AppDelegatePrefs.savePrefs()
        
        self.addTimer(newTimer)
        self.updateTimers()
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

