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
class LGV_Timer_TimerSetupController: LGV_Timer_TimerSetPickerController {
    @IBOutlet weak var keepDeviceAwakeLabel: UILabel!
    @IBOutlet weak var keepDeviceAwakeSwitch: UISwitch!
    @IBOutlet weak var timerModeSegmentedSwitch: UISegmentedControl!
    @IBOutlet weak var podiumModeContainerView: UIView!
    @IBOutlet weak var warningThresholdLabel: UILabel!
    @IBOutlet weak var warningThresholdTimePicker: UIPickerView!
    @IBOutlet weak var finalThresholdLabel: UILabel!
    @IBOutlet weak var finalThresholdTimePicker: UIPickerView!
    
    var timerNumber: Int = 0
    
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view will appear.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.keepDeviceAwakeLabel.text = self.keepDeviceAwakeLabel.text?.localizedVariant
        self.warningThresholdLabel.text = self.warningThresholdLabel.text?.localizedVariant
        self.finalThresholdLabel.text = self.finalThresholdLabel.text?.localizedVariant
        
        for segment in 0..<self.timerModeSegmentedSwitch.numberOfSegments {
            self.timerModeSegmentedSwitch.setTitle(self.timerModeSegmentedSwitch.titleForSegment(at: segment)?.localizedVariant, forSegmentAt: segment)
        }
        
        let timers = s_g_LGV_Timer_AppDelegatePrefs.timers
        self.keepDeviceAwakeSwitch.isOn = timers[self.timerNumber].keepsDeviceAwake
        self.timerModeSegmentedSwitch.selectedSegmentIndex = timers[self.timerNumber].displayMode.rawValue
        var timeSetWarnInt = timers[self.timerNumber].timeSetPodiumWarn
        if 0 >= timeSetWarnInt {
            timeSetWarnInt = LGV_Timer_StaticPrefs.calcPodiumModeWarningThresholdForTimerValue(timers[self.timerNumber].timeSet)
            timers[self.timerNumber].timeSetPodiumWarn = timeSetWarnInt
        }
        let timeSetWarn = TimeTuple(timeSetWarnInt)
        var timeSetFinalInt = timers[self.timerNumber].timeSetPodiumFinal
        if 0 >= timeSetFinalInt {
            timeSetFinalInt = LGV_Timer_StaticPrefs.calcPodiumModeFinalThresholdForTimerValue(timers[self.timerNumber].timeSet)
            timers[self.timerNumber].timeSetPodiumFinal = timeSetFinalInt
        }
        let timeSetFinal = TimeTuple(timeSetFinalInt)
        self.warningThresholdTimePicker.selectRow(timeSetWarn.hours, inComponent: Components.Hours.rawValue, animated: true)
        self.warningThresholdTimePicker.selectRow(timeSetWarn.minutes, inComponent: Components.Minutes.rawValue, animated: true)
        self.warningThresholdTimePicker.selectRow(timeSetWarn.seconds, inComponent: Components.Seconds.rawValue, animated: true)
        self.finalThresholdTimePicker.selectRow(timeSetFinal.hours, inComponent: Components.Hours.rawValue, animated: true)
        self.finalThresholdTimePicker.selectRow(timeSetFinal.minutes, inComponent: Components.Minutes.rawValue, animated: true)
        self.finalThresholdTimePicker.selectRow(timeSetFinal.seconds, inComponent: Components.Seconds.rawValue, animated: true)
        s_g_LGV_Timer_AppDelegatePrefs.timers = timers
        
        // This ensures that we force the display to portrait (for this screen only).
        LGV_Timer_AppDelegate.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    /* ################################################################## */
    /**
     Called when the view will disappear.
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Don't forget to reset when view is being removed
        LGV_Timer_AppDelegate.lockOrientation(.all)
    }
    
    // MARK: - @IBAction Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the keep device awake switch is hit.
     
     :param: sender The switch object.
     */
    @IBAction func keepDeviceAwakeSwitchHit(_ sender: UISwitch) {
        let timers = s_g_LGV_Timer_AppDelegatePrefs.timers
        timers[self.timerNumber].keepsDeviceAwake = sender.isOn
        s_g_LGV_Timer_AppDelegatePrefs.timers = timers
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func modeSegmentedControlChanged(_ sender: UISegmentedControl) {
        let timers = s_g_LGV_Timer_AppDelegatePrefs.timers
        timers[self.timerNumber].displayMode = TimerDisplayMode(rawValue: sender.selectedSegmentIndex)!
        s_g_LGV_Timer_AppDelegatePrefs.timers = timers
    }
    
    /// MARK: - UIPickerViewDelegate Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let timers = s_g_LGV_Timer_AppDelegatePrefs.timers
        let hours = pickerView.selectedRow(inComponent: Components.Hours.rawValue)
        let minutes = pickerView.selectedRow(inComponent: Components.Minutes.rawValue)
        let seconds = pickerView.selectedRow(inComponent: Components.Seconds.rawValue)
        if self.warningThresholdTimePicker == pickerView {
            if timers[self.timerNumber].timeSet > Int(TimeTuple(hours: hours, minutes: minutes, seconds: seconds)) {
                timers[self.timerNumber].timeSetPodiumWarn = Int(TimeTuple(hours: hours, minutes: minutes, seconds: seconds))
            } else {
                var maxValInt = max(0, timers[self.timerNumber].timeSet - 1)
                
                if 0 == maxValInt {
                    maxValInt = LGV_Timer_StaticPrefs.calcPodiumModeWarningThresholdForTimerValue(timers[self.timerNumber].timeSet)
                }
                
                let maxVal = TimeTuple(maxValInt)
                
                pickerView.selectRow(maxVal.hours, inComponent: Components.Hours.rawValue, animated: true)
                pickerView.selectRow(maxVal.minutes, inComponent: Components.Minutes.rawValue, animated: true)
                pickerView.selectRow(maxVal.seconds, inComponent: Components.Seconds.rawValue, animated: true)
            }
        } else {
            if timers[self.timerNumber].timeSetPodiumWarn > Int(TimeTuple(hours: hours, minutes: minutes, seconds: seconds)) {
                timers[self.timerNumber].timeSetPodiumFinal = Int(TimeTuple(hours: hours, minutes: minutes, seconds: seconds))
            } else {
                var maxValInt = max(0, timers[self.timerNumber].timeSetPodiumWarn - 1)
                
                if 0 == maxValInt {
                    maxValInt = LGV_Timer_StaticPrefs.calcPodiumModeFinalThresholdForTimerValue(timers[self.timerNumber].timeSet)
                }
                
                let maxVal = TimeTuple(maxValInt)
                
                pickerView.selectRow(maxVal.hours, inComponent: Components.Hours.rawValue, animated: true)
                pickerView.selectRow(maxVal.minutes, inComponent: Components.Minutes.rawValue, animated: true)
                pickerView.selectRow(maxVal.seconds, inComponent: Components.Seconds.rawValue, animated: true)
            }
        }
        
        s_g_LGV_Timer_AppDelegatePrefs.timers = timers
    }
}
