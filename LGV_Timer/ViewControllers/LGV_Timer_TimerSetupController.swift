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
    @IBOutlet weak var colorPickerContainerLayoutTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var colorPickerContainerView: UIView!
    @IBOutlet weak var colorThemePickerLabel: UILabel!
    @IBOutlet weak var colorThemePicker: UIPickerView!
    @IBOutlet weak var alertModeLabel: UILabel!
    @IBOutlet weak var alertModeSegmentedSwitch: UISegmentedControl!
    @IBOutlet weak var alertVolumeSlider: UISlider!
    
    var timerNumber: Int = 0
    
    /* ################################################################## */
    /**
     */
    func setUpPickerViews() {
        let timers = s_g_LGV_Timer_AppDelegatePrefs.timers
        self.podiumModeContainerView.isHidden = (timers[self.timerNumber].displayMode == .Digital)
        self.colorPickerContainerView.isHidden = (timers[self.timerNumber].displayMode == .Podium)
        self.colorPickerContainerLayoutTopConstraint.constant = 8 + ((timers[self.timerNumber].displayMode == .Podium) ? 0 : self.colorPickerContainerView.bounds.size.height)
    }
    
    /* ################################################################## */
    /**
     */
    func setUpAlertVolumeSlider() {
        let timers = s_g_LGV_Timer_AppDelegatePrefs.timers
        if (0 == timers[self.timerNumber].alertVolume) && (((timers[self.timerNumber].alertMode == .SoundOnly) || (timers[self.timerNumber].alertMode == .Both))) {
            timers[self.timerNumber].alertMode = .Silent
            self.alertModeSegmentedSwitch.selectedSegmentIndex = timers[self.timerNumber].alertMode.rawValue
            s_g_LGV_Timer_AppDelegatePrefs.timers = timers
        }
        self.alertVolumeSlider.value = Float(timers[self.timerNumber].alertVolume)
        self.alertVolumeSlider.isEnabled = ((timers[self.timerNumber].alertMode == .SoundOnly) || (timers[self.timerNumber].alertMode == .Both))
    }
    
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view will appear.
     */
    override func viewWillAppear(_ animated: Bool) {
        self.tabItemColor = LGV_Timer_StaticPrefs.prefs.pickerPepperArray[s_g_LGV_Timer_AppDelegatePrefs.timers[self.timerNumber].colorTheme].textColor
        super.viewWillAppear(animated)
        self.keepDeviceAwakeLabel.text = self.keepDeviceAwakeLabel.text?.localizedVariant
        self.warningThresholdLabel.text = self.warningThresholdLabel.text?.localizedVariant
        self.finalThresholdLabel.text = self.finalThresholdLabel.text?.localizedVariant
        self.colorThemePickerLabel.text = self.colorThemePickerLabel.text?.localizedVariant
        self.alertModeLabel.text = self.alertModeLabel.text?.localizedVariant
        
        for segment in 0..<self.timerModeSegmentedSwitch.numberOfSegments {
            self.timerModeSegmentedSwitch.setTitle(self.timerModeSegmentedSwitch.titleForSegment(at: segment)?.localizedVariant, forSegmentAt: segment)
        }
        
        for segment in 0..<self.alertModeSegmentedSwitch.numberOfSegments {
            self.alertModeSegmentedSwitch.setTitle(self.alertModeSegmentedSwitch.titleForSegment(at: segment)?.localizedVariant, forSegmentAt: segment)
        }
        
        let timers = s_g_LGV_Timer_AppDelegatePrefs.timers
        self.keepDeviceAwakeSwitch.isOn = timers[self.timerNumber].keepsDeviceAwake
        self.timerModeSegmentedSwitch.selectedSegmentIndex = timers[self.timerNumber].displayMode.rawValue
        self.alertModeSegmentedSwitch.selectedSegmentIndex = timers[self.timerNumber].alertMode.rawValue
        
        self.setUpPickerViews()
        self.setUpAlertVolumeSlider()
        
        self.warningThresholdTimePicker.reloadAllComponents()
        self.finalThresholdTimePicker.reloadAllComponents()
        self.colorThemePicker.reloadAllComponents()
        
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
        self.colorThemePicker.selectRow(timers[self.timerNumber].colorTheme, inComponent: 0, animated: true)
    }
    
    /* ################################################################## */
    /**
     Called when the view will disappear.
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LGV_Timer_MainTabController.s_c_pushTimerSettings = false
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
        self.setUpPickerViews()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func alertModeChanged(_ sender: UISegmentedControl) {
        let timers = s_g_LGV_Timer_AppDelegatePrefs.timers
        timers[self.timerNumber].alertMode = AlertMode(rawValue: sender.selectedSegmentIndex)!
        s_g_LGV_Timer_AppDelegatePrefs.timers = timers
        if (0 == timers[self.timerNumber].alertVolume) && ((.SoundOnly == timers[self.timerNumber].alertMode) || (.Both == timers[self.timerNumber].alertMode)) {
            timers[self.timerNumber].alertVolume = 1
            s_g_LGV_Timer_AppDelegatePrefs.timers = timers
        } else {
            if ((.Silent == timers[self.timerNumber].alertMode) || (.VibrateOnly == timers[self.timerNumber].alertMode)) {
                timers[self.timerNumber].alertVolume = 0
                s_g_LGV_Timer_AppDelegatePrefs.timers = timers
            }
        }
        self.setUpAlertVolumeSlider()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func alertVolumeChanged(_ sender: UISlider) {
        let timers = s_g_LGV_Timer_AppDelegatePrefs.timers
        timers[self.timerNumber].alertVolume = Int(sender.value)
        s_g_LGV_Timer_AppDelegatePrefs.timers = timers
        sender.value = Float(timers[self.timerNumber].alertVolume)
        if (0 == timers[self.timerNumber].alertVolume) && (((timers[self.timerNumber].alertMode == .SoundOnly) || (timers[self.timerNumber].alertMode == .Both))) {
            timers[self.timerNumber].alertMode = .Silent
            self.alertModeSegmentedSwitch.selectedSegmentIndex = timers[self.timerNumber].alertMode.rawValue
            s_g_LGV_Timer_AppDelegatePrefs.timers = timers
            self.setUpAlertVolumeSlider()
        }
    }
    
    /// MARK: - UIPickerViewDataSource Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return (self.colorThemePicker == pickerView) ? 1 : super.numberOfComponents(in: pickerView)
    }
    
    /* ################################################################## */
    /**
     */
    override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.colorThemePicker == pickerView {
            return LGV_Timer_StaticPrefs.prefs.pickerPepperArray.count
        } else {
            return super.pickerView(pickerView, numberOfRowsInComponent: component)
        }
    }
    
    /// MARK: - UIPickerViewDelegate Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickerView.bounds.size.height / ((self.colorThemePicker == pickerView) ? 3.0 : 4.0)
    }
    
    /* ################################################################## */
    /**
     */
    override func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return (self.colorThemePicker == pickerView) ? pickerView.bounds.size.width : super.pickerView(pickerView, widthForComponent: component)
    }
    
    /* ################################################################## */
    /**
     */
    override func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if self.colorThemePicker == pickerView {
            let width = self.pickerView(pickerView, widthForComponent: component)
            let height = self.pickerView(pickerView, rowHeightForComponent: component)
            let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: height))
            let ret: UILabel = UILabel(frame: frame)
            
            let swatchLabel = LGV_Timer_StaticPrefs.prefs.pickerPepperArray[row]
            ret.text = swatchLabel.text?.localizedVariant
            ret.backgroundColor = UIColor.clear
            ret.textAlignment = swatchLabel.textAlignment
            ret.font = swatchLabel.font
            ret.adjustsFontSizeToFitWidth = true
            ret.textColor = swatchLabel.textColor
            
            return ret
        } else {
            return super.pickerView(pickerView, viewForRow: row, forComponent: component, reusing: view)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let timers = s_g_LGV_Timer_AppDelegatePrefs.timers
        if self.colorThemePicker == pickerView {
            timers[self.timerNumber].colorTheme = row
            if let tabBarController = self.tabBarController {
                tabBarController.tabBar.tintColor = LGV_Timer_StaticPrefs.prefs.pickerPepperArray[timers[self.timerNumber].colorTheme].textColor
            }
        } else {
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
                if (0 == timers[self.timerNumber].timeSetPodiumWarn) || (0 == timers[self.timerNumber].timeSet) || (timers[self.timerNumber].timeSetPodiumWarn > Int(TimeTuple(hours: hours, minutes: minutes, seconds: seconds))) {
                    if (0 == timers[self.timerNumber].timeSetPodiumWarn) || (0 == timers[self.timerNumber].timeSet) {
                        timers[self.timerNumber].timeSetPodiumFinal =  0
                        pickerView.selectRow(0, inComponent: Components.Hours.rawValue, animated: true)
                        pickerView.selectRow(0, inComponent: Components.Minutes.rawValue, animated: true)
                        pickerView.selectRow(0, inComponent: Components.Seconds.rawValue, animated: true)
                    } else {
                        timers[self.timerNumber].timeSetPodiumFinal = Int(TimeTuple(hours: hours, minutes: minutes, seconds: seconds))
                    }
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
        }
        
        s_g_LGV_Timer_AppDelegatePrefs.timers = timers
    }
}
