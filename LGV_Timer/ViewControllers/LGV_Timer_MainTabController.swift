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
    // MARK: - Instance Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var globalSettingsViewController: LGV_Timer_SettingsViewController! = nil
    var clockViewController: LGV_Timer_ClockViewController! = nil
    var stopwatchViewController: LGV_Timer_StopwatchViewController! = nil
    
    // MARK: - Instance Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var timers: [LGV_Timer_TimerNavController] {
        get {
            var ret: [LGV_Timer_TimerNavController] = []
            
            if let count = self.viewControllers?.count {
                for viewControllerIndex in 3..<count {
                    if let viewController = self.viewControllers?[viewControllerIndex] as? LGV_Timer_TimerNavController {
                        ret.append(viewController)
                    }
                }
            }
            
            return ret
        }
    }
    
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view has finished loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for barController in self.viewControllers! {
            if let barItem = barController.tabBarItem {
                if type(of: barController) == LGV_Timer_SettingsViewController.self {
                    barItem.title = barItem.title?.localizedVariant
                    self.globalSettingsViewController = barController as! LGV_Timer_SettingsViewController
                    self.globalSettingsViewController.mainTabController = self
                } else {
                    if type(of: barController) == LGV_Timer_ClockViewController.self {
                        barItem.title = barItem.title?.localizedVariant
                        self.clockViewController = barController as! LGV_Timer_ClockViewController
                    } else {
                        if type(of: barController) == LGV_Timer_StopwatchViewController.self {
                            barItem.title = barItem.title?.localizedVariant
                            self.stopwatchViewController = barController as! LGV_Timer_StopwatchViewController
                        }
                    }
                }
            }
        }
        
        self.updateTimers()
    }
    
    // MARK: - Internal Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func updateTimers() {
        var index = 1
        
        let count = self.viewControllers!.count
        
        for _ in 3..<count {
            self.viewControllers?.remove(at: self.viewControllers!.count - 1)
        }
        
        // We dynamically instantiate timer objects, based on how many we have saved.
        for timer in s_g_LGV_Timer_AppDelegatePrefs.timers {
            let storyBoardID = "LGV_Timer_TimerNavController"
            let storyboard = self.storyboard
            if nil != storyboard {
                if let timerController = storyboard!.instantiateViewController(withIdentifier: storyBoardID) as? LGV_Timer_TimerNavController {
                    self.viewControllers?.append(timerController)
                    timerController.timerObject = timer
                    // For a singular timer, we don't have a timer number.
                    if 1 == s_g_LGV_Timer_AppDelegatePrefs.timers.count {
                        timerController.timerNumber = 0
                    } else {
                        timerController.timerNumber = index
                        index += 1
                    }
                    
                    let timerTitle = timerController.tabBarText
                    timerController.tabBarItem.title = timerTitle
                    timerController.tabBarItem.image = timerController.tabBarImage
                    timerController.navigationBar.topItem?.title = timerTitle
                }
            }
        }
        
        self.customizableViewControllers = []
    }
    
    /* ################################################################## */
    /**
     */
    func selectTimer(_ inTimerIndex: Int) {
        self.selectedIndex = 3 + inTimerIndex
    }
}

