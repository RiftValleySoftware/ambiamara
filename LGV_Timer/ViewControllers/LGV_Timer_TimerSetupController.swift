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
import AudioToolbox

/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_TimerSetupController: LGV_Timer_TimerSetPickerController {
    @IBOutlet weak var timerModeLabel: UILabel!
    @IBOutlet weak var timerModeSegmentedSwitch: UISegmentedControl!
    @IBOutlet weak var podiumModeContainerView: UIView!
    @IBOutlet weak var warningThresholdLabel: UILabel!
    @IBOutlet weak var warningThresholdTimePicker: UIPickerView!
    @IBOutlet weak var finalThresholdLabel: UILabel!
    @IBOutlet weak var finalThresholdTimePicker: UIPickerView!
    @IBOutlet weak var colorPickerContainerView: UIView!
    @IBOutlet weak var colorThemePickerLabel: UILabel!
    @IBOutlet weak var colorThemePicker: UIPickerView!
    @IBOutlet weak var alertModeLabel: UILabel!
    @IBOutlet weak var alertModeSegmentedSwitch: UISegmentedControl!
    @IBOutlet weak var soundSelectionLabel: UILabel!
    @IBOutlet weak var soundSelectionSegmentedSwitch: UISegmentedControl!
    
    /* ################################################################## */
    /**
     */
    func setUpPickerViews() {
        self.podiumModeContainerView.isHidden = (self.timerObject.displayMode == .Digital)
        self.soundSelectionSegmentedSwitch.isEnabled = ((.Silent != self.timerObject.alertMode) && (.VibrateOnly != self.timerObject.alertMode))
    }
    
    /* ################################################################## */
    /**
     */
    class private func _playAlertSound(_ inSoundID: Int) {
        if let soundUrl = Bundle.main.url(forResource: String(format: "Sound-%02d", inSoundID), withExtension: "aiff") {
            var soundId: SystemSoundID = 0
            
            AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundId)
            
            AudioServicesAddSystemSoundCompletion(soundId, nil, nil, { (soundId, clientData) -> Void in
                AudioServicesDisposeSystemSoundID(soundId)
            }, nil)
            AudioServicesPlaySystemSound(soundId)
        }
    }
    
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view will appear.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.warningThresholdLabel.text = self.warningThresholdLabel.text?.localizedVariant
        self.finalThresholdLabel.text = self.finalThresholdLabel.text?.localizedVariant
        self.colorThemePickerLabel.text = self.colorThemePickerLabel.text?.localizedVariant
        self.alertModeLabel.text = self.alertModeLabel.text?.localizedVariant
        self.timerModeLabel.text = self.timerModeLabel.text?.localizedVariant
        self.soundSelectionLabel.text = self.soundSelectionLabel.text?.localizedVariant
        
        for segment in 0..<self.timerModeSegmentedSwitch.numberOfSegments {
            self.timerModeSegmentedSwitch.setTitle(self.timerModeSegmentedSwitch.titleForSegment(at: segment)?.localizedVariant, forSegmentAt: segment)
        }
        
        for segment in 0..<self.alertModeSegmentedSwitch.numberOfSegments {
            self.alertModeSegmentedSwitch.setTitle(self.alertModeSegmentedSwitch.titleForSegment(at: segment)?.localizedVariant, forSegmentAt: segment)
        }
        
        for segment in 0..<self.soundSelectionSegmentedSwitch.numberOfSegments {
            self.soundSelectionSegmentedSwitch.setTitle(self.soundSelectionSegmentedSwitch.titleForSegment(at: segment)?.localizedVariant, forSegmentAt: segment)
        }
        
        self.timerModeSegmentedSwitch.selectedSegmentIndex = self.timerObject.displayMode.rawValue
        self.alertModeSegmentedSwitch.selectedSegmentIndex = self.timerObject.alertMode.rawValue
        self.soundSelectionSegmentedSwitch.selectedSegmentIndex = self.timerObject.soundID
        
        self.setUpPickerViews()
        
        self.warningThresholdTimePicker.reloadAllComponents()
        self.finalThresholdTimePicker.reloadAllComponents()
        self.colorThemePicker.reloadAllComponents()
        
        var timeSetWarnInt = self.timerObject.timeSetPodiumWarn
        if 0 >= timeSetWarnInt {
            timeSetWarnInt = LGV_Timer_StaticPrefs.calcPodiumModeWarningThresholdForTimerValue(self.timerObject.timeSet)
            self.timerObject.timeSetPodiumWarn = timeSetWarnInt
        }
        let timeSetWarn = TimeTuple(timeSetWarnInt)
        var timeSetFinalInt = self.timerObject.timeSetPodiumFinal
        if 0 >= timeSetFinalInt {
            timeSetFinalInt = LGV_Timer_StaticPrefs.calcPodiumModeFinalThresholdForTimerValue(self.timerObject.timeSet)
            self.timerObject.timeSetPodiumFinal = timeSetFinalInt
        }
        
        let timeSetFinal = TimeTuple(timeSetFinalInt)
        self.warningThresholdTimePicker.selectRow(timeSetWarn.hours, inComponent: Components.Hours.rawValue, animated: true)
        self.warningThresholdTimePicker.selectRow(timeSetWarn.minutes, inComponent: Components.Minutes.rawValue, animated: true)
        self.warningThresholdTimePicker.selectRow(timeSetWarn.seconds, inComponent: Components.Seconds.rawValue, animated: true)
        self.finalThresholdTimePicker.selectRow(timeSetFinal.hours, inComponent: Components.Hours.rawValue, animated: true)
        self.finalThresholdTimePicker.selectRow(timeSetFinal.minutes, inComponent: Components.Minutes.rawValue, animated: true)
        self.finalThresholdTimePicker.selectRow(timeSetFinal.seconds, inComponent: Components.Seconds.rawValue, animated: true)
        s_g_LGV_Timer_AppDelegatePrefs.updateTimer(self.timerObject)
        
        // This ensures that we force the display to portrait (for this screen only).
        LGV_Timer_AppDelegate.lockOrientation(.portrait, andRotateTo: .portrait)
        self.colorThemePicker.selectRow(self.timerObject.colorTheme, inComponent: 0, animated: true)
        self.navigationController?.navigationBar.tintColor = self.view.tintColor
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
     */
    @IBAction func modeSegmentedControlChanged(_ sender: UISegmentedControl) {
        self.timerObject.displayMode = TimerDisplayMode(rawValue: sender.selectedSegmentIndex)!
        s_g_LGV_Timer_AppDelegatePrefs.updateTimer(self.timerObject)
        self.setUpPickerViews()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func soundSelectionChanged(_ sender: UISegmentedControl) {
        self.timerObject.soundID = sender.selectedSegmentIndex
        type(of: self)._playAlertSound(self.timerObject.soundID)
        s_g_LGV_Timer_AppDelegatePrefs.updateTimer(self.timerObject)
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func alertModeChanged(_ sender: UISegmentedControl) {
        self.timerObject.alertMode = AlertMode(rawValue: sender.selectedSegmentIndex)!
        s_g_LGV_Timer_AppDelegatePrefs.updateTimer(self.timerObject)
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
        if self.colorThemePicker == pickerView {
            self.timerObject.colorTheme = row
        } else {
            let hours = pickerView.selectedRow(inComponent: Components.Hours.rawValue)
            let minutes = pickerView.selectedRow(inComponent: Components.Minutes.rawValue)
            let seconds = pickerView.selectedRow(inComponent: Components.Seconds.rawValue)
            if self.warningThresholdTimePicker == pickerView {
                if self.timerObject.timeSet > Int(TimeTuple(hours: hours, minutes: minutes, seconds: seconds)) {
                    self.timerObject.timeSetPodiumWarn = Int(TimeTuple(hours: hours, minutes: minutes, seconds: seconds))
                } else {
                    var maxValInt = max(0, self.timerObject.timeSet - 1)
                    
                    if 0 == maxValInt {
                        maxValInt = LGV_Timer_StaticPrefs.calcPodiumModeWarningThresholdForTimerValue(self.timerObject.timeSet)
                    }
                    
                    let maxVal = TimeTuple(maxValInt)
                    
                    pickerView.selectRow(maxVal.hours, inComponent: Components.Hours.rawValue, animated: true)
                    pickerView.selectRow(maxVal.minutes, inComponent: Components.Minutes.rawValue, animated: true)
                    pickerView.selectRow(maxVal.seconds, inComponent: Components.Seconds.rawValue, animated: true)
                }
            } else {
                if (0 == self.timerObject.timeSetPodiumWarn) || (0 == self.timerObject.timeSet) || (self.timerObject.timeSetPodiumWarn > Int(TimeTuple(hours: hours, minutes: minutes, seconds: seconds))) {
                    if (0 == self.timerObject.timeSetPodiumWarn) || (0 == self.timerObject.timeSet) {
                        self.timerObject.timeSetPodiumFinal =  0
                        pickerView.selectRow(0, inComponent: Components.Hours.rawValue, animated: true)
                        pickerView.selectRow(0, inComponent: Components.Minutes.rawValue, animated: true)
                        pickerView.selectRow(0, inComponent: Components.Seconds.rawValue, animated: true)
                    } else {
                        self.timerObject.timeSetPodiumFinal = Int(TimeTuple(hours: hours, minutes: minutes, seconds: seconds))
                    }
                } else {
                    var maxValInt = max(0, self.timerObject.timeSetPodiumWarn - 1)
                    
                    if 0 == maxValInt {
                        maxValInt = LGV_Timer_StaticPrefs.calcPodiumModeFinalThresholdForTimerValue(self.timerObject.timeSet)
                    }
                    
                    let maxVal = TimeTuple(maxValInt)
                    
                    pickerView.selectRow(maxVal.hours, inComponent: Components.Hours.rawValue, animated: true)
                    pickerView.selectRow(maxVal.minutes, inComponent: Components.Minutes.rawValue, animated: true)
                    pickerView.selectRow(maxVal.seconds, inComponent: Components.Seconds.rawValue, animated: true)
                }
            }
        }
        
        s_g_LGV_Timer_AppDelegatePrefs.updateTimer(self.timerObject)
    }
}
