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
class LGV_Timer_TimerSetPickerController: LGV_Timer_TimerBaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    enum Components: Int {
        case Hours = 0, Minutes, Seconds
    }
    
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

