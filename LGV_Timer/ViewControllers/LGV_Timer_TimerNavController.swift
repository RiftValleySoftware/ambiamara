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
    // MARK: - Class Constants
    /* ################################################################################################################################## */
    /// These specify the bounds of the tab bar icons (We draw our own custom ones).
    static let s_g_maxTabIconWidth: CGFloat = 48
    static let s_g_maxTabIconHeight: CGFloat = 32
    static let s_g_maxTabFontSize: CGFloat = 32
    
    // MARK: - Instance Properties
    /* ################################################################################################################################## */
    /// This has the index number for this timer instance (1-based).
    var timerNumber: Int = 0
    var timerObject: TimerSettingTuple! = nil
    
    // MARK: - Instance Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This supplies a dynamically-created image for the Tab Bar.
     */
    var tabBarImage: UIImage! {
        get {
            var displayedString = "ERROR";
            
            if nil != self.timerObject {
                displayedString = String(format: "%02d:%02d:%02d", TimeTuple(timerObject.timeSet).hours, TimeTuple(timerObject.timeSet).minutes, TimeTuple(timerObject.timeSet).seconds)
            }
            
            return type(of: self)._textAsImage(drawText: displayedString as NSString)
        }
    }
    
    /* ################################################################## */
    /**
     This supplies a dynamically-created title for the Tab Bar.
     */
    var tabBarText: String {
        get {
            if 0 < self.timerNumber {
                return String(format: "LGV_TIMER-TIMER-TITLE-FORMAT".localizedVariant, self.timerNumber)
            } else {
                return "LGV_TIMER-TIMER-TITLE-SINGLE".localizedVariant
            }
        }
    }
    
    // MARK: - Private Class Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Creates an image with the given text.
     */
    private class func _textAsImage(drawText text: NSString) -> UIImage {
        var ret: UIImage! = nil
        
        let imageSize = CGSize(width: s_g_maxTabIconWidth, height: s_g_maxTabIconHeight)
        let nudge: CGFloat = 1.1;
        let textColor = UIColor.gray
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        var fontSize: CGFloat = s_g_maxTabFontSize
        var stringSize: CGSize = CGSize.zero
        var textFontAttributes = [
            NSForegroundColorAttributeName: textColor,
            NSParagraphStyleAttributeName: style
            ] as [String : Any]
        
        // We decrease the font size until we have something that fits.
        while 0 < fontSize {
            if let textFont = UIFont(name: "Let's Go Digital", size: fontSize) {
                textFontAttributes[NSFontAttributeName] = textFont
                
                stringSize = text.size(attributes: textFontAttributes)
                
                if (imageSize.width >= stringSize.width) && (imageSize.height >= stringSize.height) {
                    break
                } else {
                    fontSize -= 0.125
                }
            } else {
                break
            }
        }
        
        text.draw(at: CGPoint(x: (imageSize.width - stringSize.width) / 2, y: ((imageSize.height - stringSize.height) / 2) + nudge), withAttributes: textFontAttributes)
        
        let textImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if nil != textImage {
            UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
            
            textImage!.draw(in: CGRect(origin: CGPoint.zero, size: imageSize))
            
            ret = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        return ret!
    }
}
