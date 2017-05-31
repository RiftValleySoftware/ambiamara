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
    static let s_c_viewBundleName = "LGV_Timer_ColorThemes"
    
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
    
    var timerNumber: Int = 0
    var pickerPepperArray: [LGV_Timer_ColorThemeLabel]! = nil
    
    /* ################################################################## */
    /**
     */
    func setUpPickerViews() {
        let timers = s_g_LGV_Timer_AppDelegatePrefs.timers
        self.podiumModeContainerView.isHidden = (timers[self.timerNumber].displayMode == .Digital)
        self.colorPickerContainerView.isHidden = (timers[self.timerNumber].displayMode == .Podium)
        self.colorPickerContainerLayoutTopConstraint.constant = 8 + ((timers[self.timerNumber].displayMode == .Podium) ? 0 : self.colorPickerContainerView.bounds.size.height)
    }
    
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
        self.colorThemePickerLabel.text = self.colorThemePickerLabel.text?.localizedVariant

        for segment in 0..<self.timerModeSegmentedSwitch.numberOfSegments {
            self.timerModeSegmentedSwitch.setTitle(self.timerModeSegmentedSwitch.titleForSegment(at: segment)?.localizedVariant, forSegmentAt: segment)
        }
        
        let timers = s_g_LGV_Timer_AppDelegatePrefs.timers
        self.keepDeviceAwakeSwitch.isOn = timers[self.timerNumber].keepsDeviceAwake
        self.timerModeSegmentedSwitch.selectedSegmentIndex = timers[self.timerNumber].displayMode.rawValue
        
        self.setUpPickerViews()
        
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
        self.colorThemePicker.selectRow(timers[self.timerNumber].colorTheme, inComponent: 0, animated: true)
        s_g_LGV_Timer_AppDelegatePrefs.timers = timers
        
        // This ensures that we force the display to portrait (for this screen only).
        LGV_Timer_AppDelegate.lockOrientation(.portrait, andRotateTo: .portrait)
        self.pickerPepperArray = []
        if let view = UINib(nibName: type(of: self).s_c_viewBundleName, bundle: nil).instantiate(withOwner: self, options: nil)[0] as? UIView {
            if let subViews = view.subviews as? [LGV_Timer_ColorThemeLabel] {
                for subView in subViews {
                    self.pickerPepperArray.append(subView)
                }
            }
        }
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
        self.setUpPickerViews()
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
            if nil != self.pickerPepperArray {
                return self.pickerPepperArray.count
            } else {
                return 0
            }
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
            var ret: UIView! = view
            
            if (nil != self.pickerPepperArray) && (nil == ret) {
                ret = self.pickerPepperArray[row]
                if let label = ret as? UILabel {
                    label.text = label.text?.localizedVariant
                }
                
                let width = self.pickerView(pickerView, widthForComponent: component)
                let height = self.pickerView(pickerView, rowHeightForComponent: component)
                let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: height))
                
                ret.frame = frame
            }
            
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
        }
        
        s_g_LGV_Timer_AppDelegatePrefs.timers = timers
    }
}
