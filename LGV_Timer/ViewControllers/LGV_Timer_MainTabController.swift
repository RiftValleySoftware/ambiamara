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
    static var s_c_pushTimerSettings: Bool = false
    
    // MARK: - Instance Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var timers: [LGV_Timer_TimerNavController] {
        get {
            var ret: [LGV_Timer_TimerNavController] = []
            
            if let count = self.viewControllers?.count {
                for viewControllerIndex in 1..<count {
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
                if type(of: barController) == LGV_Timer_TimerSettingsNavController.self {
                    barItem.title = barItem.title?.localizedVariant
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
        let count = self.viewControllers!.count
        
        for _ in 1..<count {
            self.viewControllers?.remove(at: self.viewControllers!.count - 1)
        }
        
        // We dynamically instantiate timer objects, based on how many we have saved.
        for _ in s_g_LGV_Timer_AppDelegatePrefs.timers {
            let storyBoardID = "LGV_Timer_TimerNavController"
            let storyboard = self.storyboard
            if nil != storyboard {
                if let timerController = storyboard!.instantiateViewController(withIdentifier: storyBoardID) as? LGV_Timer_TimerNavController {
                    self.viewControllers?.append(timerController)
                    
                    let timerTitle = timerController.tabBarText
                    timerController.tabBarItem.title = timerTitle
                    timerController.tabBarItem.image = timerController.tabBarImage
                    timerController.navigationBar.topItem?.title = timerTitle
                }
            }
        }
        type(of:self).s_c_pushTimerSettings = false
        self.customizableViewControllers = []
    }
    
    /* ################################################################## */
    /**
     */
    func selectTimer(_ inTimerIndex: Int, pushSettings: Bool) {
        type(of:self).s_c_pushTimerSettings = pushSettings
        let timerIndex = 1 + inTimerIndex
        self.selectedViewController = self.viewControllers?[timerIndex]
    }
}

