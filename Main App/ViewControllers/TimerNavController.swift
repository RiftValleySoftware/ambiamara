//
//  LGV_Timer_TimerNavController.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 5/24/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//  This is proprietary code. Copying and reuse are not allowed. It is being opened to provide sample code.
//
/* ###################################################################################################################################### */
/**
 */

import UIKit

/* ###################################################################################################################################### */
/**
 */
class TimerNavController: UINavigationController, UINavigationControllerDelegate {
    private var _timerObject: TimerSettingTuple! = nil
    
    /* ################################################################## */
    /**
     */
    var timerObject: TimerSettingTuple! {
        get {
            return self._timerObject
        }
        
        set {
            self._timerObject = newValue
            if let controller = self.topViewController as? TimerNavBaseController {
                controller.timerObject = self._timerObject
            }
        }
    }
    
    /* ################################################################################################################################## */
    /// This has the index number for this timer instance (1-based).
    var timerNumber: Int {
        return Timer_AppDelegate.appDelegateObject.timerEngine.indexOf(self.timerObject.uid) + 1
    }
    
    /* ################################################################## */
    /**
     */
    var tabBarText: String {
        if let topController = self.topViewController as? TimerNavBaseController {
            return topController.tabBarText
        }
        return ""
    }
    
    /* ################################################################## */
    /**
     */
    var tabBarImage: UIImage {
        if let topController = self.topViewController as? TimerNavBaseController {
            return topController.tabBarImage
        }
        return UIImage()
    }
    
    /* ################################################################## */
    /**
     */
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if self == navigationController {
            if let newViewController = viewController as? TimerSetPickerController {
                if !self.timerObject.selected {
                    self.timerObject.selected = true
                }
                newViewController.timerObject = self.timerObject
            }
        }
    }
}
