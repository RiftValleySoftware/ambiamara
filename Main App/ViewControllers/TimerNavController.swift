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
     - returns: The associated timer object (accessor)
     */
    var timerObject: TimerSettingTuple! {
        get {
            return self._timerObject
        }
        
        set {
            self._timerObject = newValue
            if let controller = self.topViewController as? A_TimerNavBaseController {
                controller.timerObject = self._timerObject
            }
        }
    }
    
    /* ################################################################################################################################## */
    /// - returns: the index number for this timer instance (1-based).
    var timerNumber: Int {
        return Timer_AppDelegate.appDelegateObject.timerEngine.indexOf(self.timerObject.uid) + 1
    }
    
    /* ################################################################## */
    /**
     - returns: The text for the tab bar icon/item
     */
    var tabBarText: String {
        if let topController = self.topViewController as? A_TimerNavBaseController {
            return topController.tabBarText
        }
        return ""
    }
    
    /* ################################################################## */
    /**
     - returns: an image to display in the tab bar
     */
    var tabBarImage: UIImage {
        if let topController = self.topViewController as? A_TimerNavBaseController {
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
                if !self.timerObject.selected {
                    self.timerObject.selected = true
                }
                newViewController.timerObject = self.timerObject
            }
        }
    }
}
