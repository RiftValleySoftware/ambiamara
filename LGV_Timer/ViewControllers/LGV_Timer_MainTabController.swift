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
    var globalSettingsViewController: LGV_Timer_SettingsViewController! = nil
    var clockViewController: LGV_Timer_ClockViewController! = nil
    var timers: [LGV_Timer_TimerNavController] = []
    
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view has finished loading.
     */
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
            
            if let barItem = barController.tabBarItem {
                // Timers can be dynamically instantiated, so they have a decimal index that identifies each one.
                if type(of: barController) == LGV_Timer_TimerNavController.self {
                    let controller = barController as! LGV_Timer_TimerNavController
                    let count = self.timers.count
                    let localizedFormat = (barItem.title?.localizedVariant)!
                    let title = String(format: localizedFormat, count)
                    barItem.title = title
                    controller.viewControllers[0].navigationItem.title = title
                } else {
                    barItem.title = barItem.title?.localizedVariant
                }
            }
        }
    }
}

