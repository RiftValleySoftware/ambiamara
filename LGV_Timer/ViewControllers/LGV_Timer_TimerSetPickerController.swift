//
//  LGV_Timer_TimerSetPickerController.swift
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
class LGV_Timer_TimerNavBaseController: LGV_Timer_TimerBaseViewController {
    // MARK: - Class Constants
    /* ################################################################################################################################## */
    /// These specify the bounds of the tab bar icons (We draw our own custom ones).
    static let s_g_maxTabIconWidth: CGFloat = 48
    static let s_g_maxTabIconHeight: CGFloat = 32
    static let s_g_maxTabFontSize: CGFloat = 32
    
    /* ################################################################################################################################## */
    /// This contains a reference to our timer object.
    var timerObject: TimerSettingTuple! = nil
    
    /// This has the index number for this timer instance (1-based).
    var timerNumber: Int {
        get {
            return s_g_LGV_Timer_AppDelegatePrefs.getIndexOfTimer(self.timerObject.uid) + 1
        }
    }
    
    // MARK: - Instance Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This supplies a dynamically-created image for the Tab Bar.
     */
    var tabBarImage: UIImage! {
        get {
            var displayedString = "";
            let timerNumber = max(0, self.timerNumber - 1)
            let prefs = s_g_LGV_Timer_AppDelegatePrefs.timers[timerNumber]
            let timeTuple = TimeTuple(prefs.timeSet)
            
            if 0 < timeTuple.hours {
                displayedString = String(format: "%02d:%02d:%02d", timeTuple.hours, timeTuple.minutes, timeTuple.seconds)
            } else {
                if 0 < timeTuple.minutes {
                    displayedString = String(format: "%02d:%02d", timeTuple.minutes, timeTuple.seconds)
                } else {
                    displayedString = String(format: "%02d", timeTuple.seconds)
                }
            }
            
            return type(of: self).textAsImage(drawText: displayedString as NSString)
        }
    }
    
    /* ################################################################## */
    /**
     This supplies a dynamically-created title for the Tab Bar.
     */
    var tabBarText: String {
        get {
            return String(format: "LGV_TIMER-TIMER-TITLE-FORMAT".localizedVariant, self.timerNumber)
        }
    }
    
    // MARK: - Private Class Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Creates an image with the given text.
     */
    class func textAsImage(drawText text: NSString) -> UIImage {
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

/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_TimerSetPickerController: LGV_Timer_TimerNavBaseController, UIPickerViewDelegate, UIPickerViewDataSource {
    enum Components: Int {
        case Hours = 0, Minutes, Seconds
    }
    
    // MARK: - Instance Calculated Properties
    /* ################################################################################################################################## */
    
    /// MARK: - UIPickerViewDelegate Methods
    /* ################################################################################################################################## */    
    /* ################################################################## */
    /**
     */
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickerView.bounds.size.height / 4.0
    }
    
    /* ################################################################## */
    /**
     */
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.bounds.size.width / 3.0
    }
    
    /* ################################################################## */
    /**
     */
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let ret = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.pickerView(pickerView, widthForComponent: component), height: self.pickerView(pickerView, rowHeightForComponent: component))))
        
        ret.font = UIFont.systemFont(ofSize: self.pickerView(pickerView, rowHeightForComponent: component))
        ret.adjustsFontSizeToFitWidth = true
        ret.backgroundColor = UIColor.clear
        ret.textColor = UIColor.white
        
        if let thisComponent = Components(rawValue: component) {
            switch(thisComponent) {
            case .Hours:
                if 0 == row {
                } else {
                    if 1 == row {
                        ret.text = String(format: "LGV_TIMER-TIME-PICKER-HOUR-FORMAT".localizedVariant, row)
                    } else {
                        ret.text = String(format: "LGV_TIMER-TIME-PICKER-HOURS-FORMAT".localizedVariant, row)
                    }
                }
            case .Minutes:
                if 0 == row {
                } else {
                    if 1 == row {
                        ret.text = String(format: "LGV_TIMER-TIME-PICKER-MINUTE-FORMAT".localizedVariant, row)
                    } else {
                        ret.text = String(format: "LGV_TIMER-TIME-PICKER-MINUTES-FORMAT".localizedVariant, row)
                    }
                }
            case .Seconds:
                if 0 == row {
                } else {
                    if 1 == row {
                        ret.text = String(format: "LGV_TIMER-TIME-PICKER-SECOND-FORMAT".localizedVariant, row)
                    } else {
                        ret.text = String(format: "LGV_TIMER-TIME-PICKER-SECONDS-FORMAT".localizedVariant, row)
                    }
                }
            }
        }
        
        return ret
    }
    
    /// MARK: - UIPickerViewDataSource Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    /* ################################################################## */
    /**
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var ret: Int = 0
        
        if let thisComponent = Components(rawValue: component) {
            switch(thisComponent) {
            case .Hours:
                ret = 24
            default:
                ret = 60
            }
        }
        
        return ret
    }
}

