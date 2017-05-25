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
class LGV_Timer_TimerNavController: UINavigationController {
    var timerNumber: Int = 0
    
    var tabBarImage: UIImage! {
        get {
            var ret: UIImage! = nil
            
            if let barImageOriginal = UIImage(named: "TimerOutline") {
                ret = type(of: self).textOverImage(drawText: String(format: "%d", self.timerNumber) as NSString, inImage: barImageOriginal)
            }
            
            return ret
        }
    }
    
    // MARK: - Class Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     From here: https://stackoverflow.com/questions/28906914/how-do-i-add-text-to-an-image-in-ios-swift
     
     Creates an image with the given text superimposed over it.
     */
    class func textOverImage(drawText text: NSString, inImage image: UIImage) -> UIImage {
        var ret: UIImage! = nil
        
        let nudge: CGFloat = 1.1;
        let textColor = UIColor.gray
        let textFont = UIFont(name: "Helvetica Bold", size: 10)!
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            NSParagraphStyleAttributeName: style
            ] as [String : Any]
        
        let textRect = text.boundingRect(with: image.size, options: NSStringDrawingOptions(), attributes: textFontAttributes, context: nil)
        
        text.draw(at: CGPoint(x: (image.size.width - textRect.size.width) / 2, y: ((image.size.height - textRect.size.height) / 2) + nudge), withAttributes: textFontAttributes)
        
        let textImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if nil != textImage {
            UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
            
            image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
            textImage!.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
            
            ret = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        return ret!
    }

    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view has finished loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
