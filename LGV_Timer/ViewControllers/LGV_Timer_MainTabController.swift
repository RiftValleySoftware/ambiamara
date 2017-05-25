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
    var globalSettingsViewController: LGV_Timer_SettingsViewController! = nil
    var clockViewController: LGV_Timer_ClockViewController! = nil
    var timers: [LGV_Timer_TimerNavController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for barController in self.viewControllers! {
            if type(of: barController) == LGV_Timer_SettingsViewController.self {
                self.globalSettingsViewController = barController as! LGV_Timer_SettingsViewController
            } else {
                if type(of: barController) == LGV_Timer_ClockViewController.self {
                    self.clockViewController = barController as! LGV_Timer_ClockViewController
                } else {
                    if type(of: barController) == LGV_Timer_TimerNavController.self {
                        self.timers.append(barController as! LGV_Timer_TimerNavController)
                    }
                }
            }
            
            let barItem = barController.tabBarItem
            
            barItem?.title = barItem?.title?.localizedVariant
        }
    }
}

