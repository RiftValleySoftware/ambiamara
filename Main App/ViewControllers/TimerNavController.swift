/**
 © Copyright 2018, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

/* ###################################################################################################################################### */
/**
 */

import UIKit

/* ###################################################################################################################################### */
/**
 This is a class that implements a View Controller for your standard timer.
 */
class TimerNavController: UINavigationController, UINavigationControllerDelegate {
    /// This is the actual timer that we are associating with this controller
    private var _timerObject: TimerSettingTuple! = nil
    
    /* ################################################################## */
    /**
     Yuck. This is a semaphore. But since we don't have closures for navigation pops, we need to do this.
     
     This is set to 0 or greater by the running timer if there's a cascade. Otherwise, it is -1.
     */
    var selectNextTimer: Int = -1
    
    /* ################################################################## */
    /**
     - returns: The associated timer object (accessor)
     */
    var timerObject: TimerSettingTuple! {
        get {
            return _timerObject
        }
        
        set {
            _timerObject = newValue
            if let controller = topViewController as? A_TimerNavBaseController {
                controller.timerObject = _timerObject
            }
        }
    }
    
    /* ################################################################################################################################## */
    /// - returns: the index number for this timer instance (1-based).
    var timerNumber: Int {
        return Timer_AppDelegate.appDelegateObject.timerEngine.indexOf(timerObject.uid) + 1
    }
    
    /* ################################################################## */
    /**
     - returns: The text for the tab bar icon/item
     */
    var tabBarText: String {
        if let topController = topViewController as? A_TimerNavBaseController {
            return topController.tabBarText
        }
        return ""
    }
    
    /* ################################################################## */
    /**
     - returns: an image to display in the tab bar
     */
    var tabBarImage: UIImage {
        if let topController = topViewController as? A_TimerNavBaseController {
            return topController.tabBarImage
        }
        return UIImage()
    }
    
    /* ################################################################## */
    /**
     - returns: The navigation controller for this view controller.
     */
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if self == navigationController {
            if let newViewController = viewController as? A_TimerSetPickerController {
                if !timerObject.selected {
                    timerObject.selected = true
                }
                newViewController.timerObject = timerObject
            }
        }
    }
}
