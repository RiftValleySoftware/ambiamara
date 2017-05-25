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
            if type(of: barController) == LGV_Timer_SettingsViewController.self {
                self.globalSettingsViewController = barController as! LGV_Timer_SettingsViewController
            } else {
                if type(of: barController) == LGV_Timer_ClockViewController.self {
                    self.clockViewController = barController as! LGV_Timer_ClockViewController
                } else {
                    if type(of: barController) == LGV_Timer_TimerNavController.self {
                        self.timers.append(barController as! LGV_Timer_TimerNavController)
                        (barController as! LGV_Timer_TimerNavController).timerNumber = self.timers.count
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
                    barItem.image = controller.tabBarImage
                } else {
                    barItem.title = barItem.title?.localizedVariant
                }
            }
        }
    }
}

