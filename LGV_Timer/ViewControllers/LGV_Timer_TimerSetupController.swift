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
    @IBOutlet weak var setWarningTimePickerView: UIPickerView!
    @IBOutlet weak var setFinalTimePickerView: UIPickerView!
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
        
        if let navController = self.navigationController as? LGV_Timer_TimerNavController {
            self.timerNumber = max(0, navController.self.timerNumber - 1)
            let timers = s_g_LGV_Timer_AppDelegatePrefs.timers
            self.keepDeviceAwakeSwitch.isOn = timers[self.timerNumber].keepsDeviceAwake
            self.timerModeSegmentedSwitch.selectedSegmentIndex = timers[self.timerNumber].displayMode.rawValue
            timers[self.timerNumber].hasBeenSet = true
            let timeSetWarn = TimeTuple(timers[self.timerNumber].timeSetPodiumWarn)
            let timeSetFinal = TimeTuple(timers[self.timerNumber].timeSetPodiumFinal)
            self.warningThresholdTimePicker.selectRow(timeSetWarn.hours, inComponent: Components.Hours.rawValue, animated: true)
            self.warningThresholdTimePicker.selectRow(timeSetWarn.minutes, inComponent: Components.Minutes.rawValue, animated: true)
            self.warningThresholdTimePicker.selectRow(timeSetWarn.seconds, inComponent: Components.Seconds.rawValue, animated: true)
            self.finalThresholdTimePicker.selectRow(timeSetFinal.hours, inComponent: Components.Hours.rawValue, animated: true)
            self.finalThresholdTimePicker.selectRow(timeSetFinal.minutes, inComponent: Components.Minutes.rawValue, animated: true)
            self.finalThresholdTimePicker.selectRow(timeSetFinal.seconds, inComponent: Components.Seconds.rawValue, animated: true)
            s_g_LGV_Timer_AppDelegatePrefs.timers = timers
        }
        
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
        if self.setWarningTimePickerView == pickerView {
            if timers[self.timerNumber].timeSet > Int(TimeTuple(hours: hours, minutes: minutes, seconds: seconds)) {
                timers[self.timerNumber].timeSetPodiumWarn = Int(TimeTuple(hours: hours, minutes: minutes, seconds: seconds))
            } else {
                let timeSetWarn = TimeTuple(timers[self.timerNumber].timeSetPodiumWarn)
                pickerView.selectRow(timeSetWarn.hours, inComponent: Components.Hours.rawValue, animated: true)
                pickerView.selectRow(timeSetWarn.minutes, inComponent: Components.Minutes.rawValue, animated: true)
                pickerView.selectRow(timeSetWarn.seconds, inComponent: Components.Seconds.rawValue, animated: true)
            }
        } else {
            if timers[self.timerNumber].timeSetPodiumWarn > Int(TimeTuple(hours: hours, minutes: minutes, seconds: seconds)) {
                timers[self.timerNumber].timeSetPodiumFinal = Int(TimeTuple(hours: hours, minutes: minutes, seconds: seconds))
            } else {
                let timeSetFinal = TimeTuple(timers[self.timerNumber].timeSetPodiumFinal)
                pickerView.selectRow(timeSetFinal.hours, inComponent: Components.Hours.rawValue, animated: true)
                pickerView.selectRow(timeSetFinal.minutes, inComponent: Components.Minutes.rawValue, animated: true)
                pickerView.selectRow(timeSetFinal.seconds, inComponent: Components.Seconds.rawValue, animated: true)
            }
        }
        
        s_g_LGV_Timer_AppDelegatePrefs.timers = timers
    }
}
