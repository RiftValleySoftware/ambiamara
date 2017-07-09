//
//  LGV_Timer_TimerNavController.swift
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
class LGV_Timer_TimerNavController: UINavigationController, UINavigationControllerDelegate {
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
            if let controller = self.topViewController as? LGV_Timer_TimerNavBaseController {
                controller.timerObject = self._timerObject
            }
        }
    }
    
    /* ################################################################################################################################## */
    /// This has the index number for this timer instance (1-based).
    var timerNumber: Int {
        get {
            return LGV_Timer_AppDelegate.appDelegateObject.timerEngine.prefs.getIndexOfTimer(self.timerObject.uid) + 1
        }
    }
    
    /* ################################################################## */
    /**
     */
    var tabBarText: String {
        get {
            if let topController = self.topViewController as? LGV_Timer_TimerNavBaseController {
                return topController.tabBarText
            }
            return ""
        }
    }
    
    /* ################################################################## */
    /**
     */
    var tabBarImage: UIImage {
        get {
            if let topController = self.topViewController as? LGV_Timer_TimerNavBaseController {
                return topController.tabBarImage
            }
            return UIImage()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if self == navigationController {
            if let newViewController = viewController as? LGV_Timer_TimerSetPickerController {
                newViewController.timerObject = self.timerObject
            }
        }
    }
}
