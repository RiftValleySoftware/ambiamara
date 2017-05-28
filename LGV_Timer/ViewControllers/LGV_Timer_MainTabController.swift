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
    var stopwatchViewController: LGV_Timer_StopwatchViewController! = nil
    
    // MARK: - Class Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     From here: https://stackoverflow.com/questions/28906914/how-do-i-add-text-to-an-image-in-ios-swift
     
     Creates an image with the given text superimposed over it.
     */
    class func textOverImage(drawText text: NSString, inImage image: UIImage, atPoint point: CGPoint! = nil) -> UIImage {
        let textColor = UIColor.black
        let textFont = UIFont(name: "Helvetica Bold", size: 10)!
        var atPoint: CGPoint! = point
        
        if nil == atPoint {
            atPoint = CGPoint(x: image.size.width / 2, y: image.size.height / 2)
        }
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            ] as [String : Any]
        
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let rect = CGRect(origin: atPoint, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
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
                    
                    timerController.tabBarItem.title = timerController.tabBarText
                    timerController.tabBarItem.image = timerController.tabBarImage
                }
            }
        }
        
        self.customizableViewControllers = []
    }
}

