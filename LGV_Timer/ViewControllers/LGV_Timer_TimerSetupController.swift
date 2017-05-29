//
//  LGV_Timer_TimerSetupController.swift
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
class LGV_Timer_TimerSetupController: LGV_Timer_TimerBaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    enum Components: Int {
        case Hours = 0, Minutes, Seconds
    }
    
    @IBOutlet weak var keepDeviceAwakeLabel: UILabel!
    @IBOutlet weak var keepDeviceAwakeSwitch: UISwitch!
    @IBOutlet weak var timeSetLabel: UILabel!
    @IBOutlet weak var setTimePickerView: UIPickerView!
    @IBOutlet weak var timerModeSegmentedSwitch: UISegmentedControl!
    @IBOutlet weak var setWarningTimePickerView: UIPickerView!
    @IBOutlet weak var setFinalTimePickerView: UIPickerView!
    
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view will appear.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.keepDeviceAwakeLabel.text = self.keepDeviceAwakeLabel.text?.localizedVariant
        self.timeSetLabel.text = self.timeSetLabel.text?.localizedVariant
        
        for segment in 0..<self.timerModeSegmentedSwitch.numberOfSegments {
            self.timerModeSegmentedSwitch.setTitle(self.timerModeSegmentedSwitch.titleForSegment(at: segment)?.localizedVariant, forSegmentAt: segment)
        }
        
        let timerNumber = max(0, ((self.navigationController as? LGV_Timer_TimerNavController)?.timerNumber)! - 1)
        let timers = s_g_LGV_Timer_AppDelegatePrefs.timers
        self.keepDeviceAwakeSwitch.isOn = timers[timerNumber].keepsDeviceAwake
        timers[timerNumber].hasBeenSet = true
        s_g_LGV_Timer_AppDelegatePrefs.timers = timers
        self.setTimePickerView.reloadAllComponents()
    }
    
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the keep device awake switch is hit.
     
     :param: sender The switch object.
     */
    @IBAction func keepDeviceAwakeSwitchHit(_ sender: UISwitch) {
        let timerNumber = max(0, ((self.navigationController as? LGV_Timer_TimerNavController)?.timerNumber)! - 1)
        let timers = s_g_LGV_Timer_AppDelegatePrefs.timers
        timers[timerNumber].keepsDeviceAwake = sender.isOn
        s_g_LGV_Timer_AppDelegatePrefs.timers = timers
    }
    
    /// MARK: - UIPickerViewDelegate Methods
    /* ################################################################################################################################## */
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.bounds.size.width / 3.0
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickerView.bounds.size.height / 4.0
    }
    
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    
    /// MARK: - UIPickerViewDataSource Methods
    /* ################################################################################################################################## */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
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
