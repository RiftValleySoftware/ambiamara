/**
 © Copyright 2018, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit

/* ###################################################################################################################################### */
/**
 This is an abstract (not really, as Swift doesn't actually support abstract) base class for our various view controllers.
 */
class A_TimerNavBaseController: A_TimerBaseViewController {
    /// This is a special class for an "inverted color" label.
    class InvertedMaskLabel: UILabel {
        /**
         Called to draw the label
         
         - parameter in: The rect in which to draw.
         */
        override func drawText(in rect: CGRect) {
            guard let gc = UIGraphicsGetCurrentContext() else { return }
            gc.saveGState()
            UIColor.white.setFill()
            UIRectFill(rect)
            gc.setBlendMode(.clear)
            super.drawText(in: rect)
            gc.restoreGState()
        }
    }

    /* ################################################################################################################################## */
    // MARK: - Class Constants
    /* ################################################################################################################################## */
    /// These specify the bounds of the tab bar icons (We draw our own custom ones).
    /// The maximum tab icon width, in display units
    static let s_g_maxTabIconWidth: CGFloat = 48
    /// The maximum tab icon height, in display units
    static let s_g_maxTabIconHeight: CGFloat = 32
    /// The maximum tab font size
    static let s_g_maxTabFontSize: CGFloat = 32
    /// The picker element padding, in display units
    static let s_g_pickerElementPaddingInDisplayUnits: CGFloat = 4
    /// The divisor to be used when separating picker elements
    static let s_g_pickerElementHeightDivisor: CGFloat = 4

    /* ################################################################################################################################## */
    /// This contains a reference to our timer object.
    var timerObject: TimerSettingTuple! = nil
    
    /// This has the index number for this timer instance (1-based).
    var timerNumber: Int {
        return Timer_AppDelegate.appDelegateObject.timerEngine.indexOf(self.timerObject)
    }
    
    /* ################################################################################################################################## */
    // MARK: - Instance Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This supplies a dynamically-created image for the Tab Bar.
     */
    var tabBarImage: UIImage! {
        var displayedString = ""
        let timerNumber = self.timerNumber
        if (0 <= self.timerNumber) && (Timer_AppDelegate.appDelegateObject.timerEngine.count > self.timerNumber) {
            let prefs = Timer_AppDelegate.appDelegateObject.timerEngine[timerNumber]
            let timeTuple = TimeInstance(prefs.timeSet)
            
            if 0 < timeTuple.hours {
                displayedString = String(format: "%02d:%02d:%02d", timeTuple.hours, timeTuple.minutes, timeTuple.seconds)
            } else {
                if 0 < timeTuple.minutes {
                    displayedString = String(format: "%02d:%02d", timeTuple.minutes, timeTuple.seconds)
                } else {
                    displayedString = String(format: "%02d", timeTuple.seconds)
                }
            }
            
            return Self.textAsImage(drawText: displayedString as NSString)
        } else {
            return UIImage(named: "List")
        }
    }
    
    /* ################################################################## */
    /**
     This supplies a dynamically-created title for the Tab Bar.
     */
    var tabBarText: String {
        return String(format: "LGV_TIMER-TIMER-TITLE-FORMAT".localizedVariant, self.timerNumber + 1)
    }
    
    /* ################################################################## */
    /**
     This adds the accessibility title.
     */
    override func viewDidLoad() {
        self.navigationItem.title?.accessibilityHint = self.timerObject.setSpeakableTime
        super.viewDidLoad()
    }
    
    /* ################################################################################################################################## */
    // MARK: - Private Class Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Creates an image with the given text.
     */
    class func textAsImage(drawText text: NSString) -> UIImage {
        var ret: UIImage! = nil
        
        let imageSize = CGSize(width: s_g_maxTabIconWidth, height: s_g_maxTabIconHeight)
        let nudge: CGFloat = 1.1
        let textColor = UIColor.gray
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        var fontSize: CGFloat = s_g_maxTabFontSize
        var stringSize: CGSize = CGSize.zero
        var textFontAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.paragraphStyle: style
            ]
        
        // We decrease the font size until we have something that fits.
        while 0 < fontSize {
            if let textFont = UIFont(name: "Let's Go Digital", size: fontSize) {
                textFontAttributes[NSAttributedString.Key.font] = textFont
                
                stringSize = text.size(withAttributes: textFontAttributes)
                
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
 This is a special version of the controller that handles a time picker.
 */
class A_TimerSetPickerController: A_TimerNavBaseController, UIPickerViewDelegate, UIPickerViewDataSource, UIPickerViewAccessibilityDelegate {
    /// The enum for the various components of the displayed time
    enum Components: Int {
        /// Hours
        case Hours = 0
        /// Minutes
        case Minutes
        /// Seconds
        case Seconds
    }
    
    /* ################################################################################################################################## */
    // MARK: - UIPickerViewDelegate Methods
    /* ################################################################################################################################## */    
    /* ################################################################## */
    /**
     - parameter pickerView: The UIPickerView calling this
     - parameter rowHeightForComponent: The 0-based index of the component.
     - returns: the height, in display units, of the referenced picker component rows
     */
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickerView.bounds.size.height / Self.s_g_pickerElementHeightDivisor
    }
    
    /* ################################################################## */
    /**
     - parameter pickerView: The UIPickerView calling this
     - parameter widthForComponent: The 0-based index of the component.
     - returns: the width, in display units, of the referenced picker component
     */
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return (pickerView.bounds.size.width / 3.0) - Self.s_g_pickerElementPaddingInDisplayUnits
    }
    
    /* ################################################################## */
    /**
     - parameter pickerView: The UIPickerView calling this
     - parameter viewForRow: The 0-based index of the row.
     - parameter forComponent: The 0-based index of the component.
     - parameter reusing: Any view being reused (ignored)
     - returns: a UIView, containing the picker cell.
     */
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let ret = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.pickerView(pickerView, widthForComponent: component), height: self.pickerView(pickerView, rowHeightForComponent: component))))
        
        ret.backgroundColor = UIAccessibility.isDarkerSystemColorsEnabled ? self.view.tintColor : UIColor.clear
        
        var text = ""
        
        if let thisComponent = Components(rawValue: component) {
            switch thisComponent {
            case .Hours:
                if 0 == row {
                } else {
                    if 1 == row {
                        text = String(format: "LGV_TIMER-TIME-PICKER-HOUR-FORMAT".localizedVariant, row)
                    } else {
                        text = String(format: "LGV_TIMER-TIME-PICKER-HOURS-FORMAT".localizedVariant, row)
                    }
                }
            case .Minutes:
                if 0 == row {
                } else {
                    if 1 == row {
                        text = String(format: "LGV_TIMER-TIME-PICKER-MINUTE-FORMAT".localizedVariant, row)
                    } else {
                        text = String(format: "LGV_TIMER-TIME-PICKER-MINUTES-FORMAT".localizedVariant, row)
                    }
                }
            case .Seconds:
                if 0 == row {
                } else {
                    if 1 == row {
                        text = String(format: "LGV_TIMER-TIME-PICKER-SECOND-FORMAT".localizedVariant, row)
                    } else {
                        text = String(format: "LGV_TIMER-TIME-PICKER-SECONDS-FORMAT".localizedVariant, row)
                    }
                }
            }
        }

        if UIAccessibility.isDarkerSystemColorsEnabled {
            let invertedLabel = InvertedMaskLabel(frame: ret.bounds)
            invertedLabel.font = UIFont.systemFont(ofSize: self.pickerView(pickerView, rowHeightForComponent: component))
            invertedLabel.adjustsFontSizeToFitWidth = true
            invertedLabel.textAlignment = .center
            invertedLabel.baselineAdjustment = .alignCenters
            invertedLabel.text = text
            
            ret.mask = invertedLabel
        } else {
            let label = UILabel(frame: ret.bounds)
            
            label.font = UIFont.systemFont(ofSize: self.pickerView(pickerView, rowHeightForComponent: component))
            label.adjustsFontSizeToFitWidth = true
            label.textAlignment = .center
            label.baselineAdjustment = .alignCenters
            label.backgroundColor = UIColor.clear
            label.textColor = self.view.tintColor
            label.text = text
            
            ret.addSubview(label)
        }
        
        return ret
    }
    
    /* ################################################################################################################################## */
    // MARK: - UIPickerViewDataSource Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     - parameter: The UIPickerView calling this (ignored)
     
     - returns: 3 (always)
     */
    func numberOfComponents(in _: UIPickerView) -> Int {
        return 3
    }
    
    /* ################################################################## */
    /**
     - parameter: The UIPickerView calling this (ignored)
     - parameter numberOfRowsInComponent: The 0-based index of the component.
     - returns either 24 (hours) or 60 (minutes and seconds)
     */
    func pickerView(_: UIPickerView, numberOfRowsInComponent inComponent: Int) -> Int {
        var ret: Int = 0
        
        if let thisComponent = Components(rawValue: inComponent) {
            switch thisComponent {
            case .Hours:
                ret = 24
            default:
                ret = 60
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - parameter: The UIPickerView calling this (ignored)
     - parameter accessibilityLabelForComponent: The 0-based index of the component.
     - returns: The accessibility label for the given component.
     */
    func pickerView(_ inPickerView: UIPickerView, accessibilityLabelForComponent inComponent: Int) -> String? {
        var ret: String?
        
        let row = inPickerView.selectedRow(inComponent: inComponent)
        ret = ""
        
        if let thisComponent = Components(rawValue: inComponent) {
            switch thisComponent {
            case .Hours:
                let initialText = "LGV_TIMER-ACCESSIBILITY-PICKER-HOURS-TITLE-LABEL".localizedVariant
                
                if 1 == row {
                    ret = initialText + String(format: "LGV_TIMER-TIME-PICKER-HOUR-FORMAT".localizedVariant, row)
                } else {
                    ret = initialText + String(format: "LGV_TIMER-TIME-PICKER-HOURS-FORMAT".localizedVariant, row)
                }
            case .Minutes:
                let initialText = "LGV_TIMER-ACCESSIBILITY-PICKER-MINUTES-TITLE-LABEL".localizedVariant
                
                if 1 == row {
                    ret = initialText + String(format: "LGV_TIMER-TIME-PICKER-MINUTE-FORMAT".localizedVariant, row)
                } else {
                    ret = initialText + String(format: "LGV_TIMER-TIME-PICKER-MINUTES-FORMAT".localizedVariant, row)
                }
            default:
                let initialText = "LGV_TIMER-ACCESSIBILITY-PICKER-SECONDS-TITLE-LABEL".localizedVariant
                
                if 1 == row {
                    ret = initialText + String(format: "LGV_TIMER-TIME-PICKER-SECOND-FORMAT".localizedVariant, row)
                } else {
                    ret = initialText + String(format: "LGV_TIMER-TIME-PICKER-SECONDS-FORMAT".localizedVariant, row)
                }
            }
        }
        
        return ret
    }
}
