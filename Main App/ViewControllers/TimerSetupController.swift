/**
 © Copyright 2018, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

/* ###################################################################################################################################### */
/**
 */

import UIKit
import AudioToolbox
import AVKit

/* ###################################################################################################################################### */
/**
 */
class TimerSetupController: A_TimerSetPickerController {
    @IBOutlet weak var timerModeSegmentedSwitch: UISegmentedControl!
    @IBOutlet weak var podiumModeContainerView: UIView!
    @IBOutlet weak var warningThresholdLabel: UILabel!
    @IBOutlet weak var warningThresholdTimePicker: UIPickerView!
    @IBOutlet weak var finalThresholdLabel: UILabel!
    @IBOutlet weak var finalThresholdTimePicker: UIPickerView!
    @IBOutlet weak var colorPickerContainerView: UIView!
    @IBOutlet weak var colorThemePicker: UIPickerView!
    @IBOutlet weak var podiumModeItemsConstraint: NSLayoutConstraint!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var alarmSetupButton: TimerSoundModeButton!
    @IBOutlet weak var colorDisplayLabel: UILabel!
    
    /* ################################################################## */
    /**
     */
    func setUpPickerViews() {
        self.podiumModeContainerView.isHidden = (.Digital == self.timerObject.displayMode)
        self.colorPickerContainerView.isHidden = (.Podium == self.timerObject.displayMode)
    }
    
    /* ################################################################################################################################## */
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view will appear.
     */
    override func viewWillAppear(_ animated: Bool) {
        // Make sure that our red is always less than our yellow.
        var maxValInt = Swift.max(0, Swift.min(self.timerObject.timeSetPodiumFinal, self.timerObject.timeSetPodiumWarn - 1))
        if 0 == maxValInt {
            maxValInt = Swift.min(TimerSettingTuple.calcPodiumModeFinalThresholdForTimerValue(self.timerObject.timeSet), self.timerObject.timeSetPodiumWarn - 1)
        }
        
        self.timerObject.timeSetPodiumFinal = maxValInt

        self.warningThresholdLabel.text = self.warningThresholdLabel.text?.localizedVariant
        self.finalThresholdLabel.text = self.finalThresholdLabel.text?.localizedVariant
        self.doneButton.setTitle(self.doneButton.title(for: UIControl.State.normal)?.localizedVariant, for: UIControl.State.normal)
        self.colorDisplayLabel.text = self.colorDisplayLabel.text?.localizedVariant
        
        self.timerModeSegmentedSwitch.selectedSegmentIndex = self.timerObject.displayMode.rawValue
        
        self.setUpPickerViews()
        
        self.warningThresholdTimePicker.reloadAllComponents()
        self.finalThresholdTimePicker.reloadAllComponents()
        self.colorThemePicker.reloadAllComponents()
        
        var timeSetWarnInt = self.timerObject.timeSetPodiumWarn
        if 0 >= timeSetWarnInt {
            timeSetWarnInt = TimerSettingTuple.calcPodiumModeWarningThresholdForTimerValue(self.timerObject.timeSet)
            self.timerObject.timeSetPodiumWarn = timeSetWarnInt
        }
        let timeSetWarn = TimeTuple(timeSetWarnInt)
        var timeSetFinalInt = self.timerObject.timeSetPodiumFinal
        if 0 >= timeSetFinalInt {
            timeSetFinalInt = TimerSettingTuple.calcPodiumModeFinalThresholdForTimerValue(self.timerObject.timeSet)
            self.timerObject.timeSetPodiumFinal = timeSetFinalInt
        }
        
        let timeSetFinal = TimeTuple(timeSetFinalInt)
        self.warningThresholdTimePicker.selectRow(timeSetWarn.hours, inComponent: Components.Hours.rawValue, animated: true)
        self.warningThresholdTimePicker.selectRow(timeSetWarn.minutes, inComponent: Components.Minutes.rawValue, animated: true)
        self.warningThresholdTimePicker.selectRow(timeSetWarn.seconds, inComponent: Components.Seconds.rawValue, animated: true)
        self.finalThresholdTimePicker.selectRow(timeSetFinal.hours, inComponent: Components.Hours.rawValue, animated: true)
        self.finalThresholdTimePicker.selectRow(timeSetFinal.minutes, inComponent: Components.Minutes.rawValue, animated: true)
        self.finalThresholdTimePicker.selectRow(timeSetFinal.seconds, inComponent: Components.Seconds.rawValue, animated: true)
        
        // This ensures that we force the display to portrait (for this screen only).
        Timer_AppDelegate.lockOrientation(.portrait, andRotateTo: .portrait)
        self.colorThemePicker.selectRow(self.timerObject.colorTheme, inComponent: 0, animated: true)
        
        self.navigationController?.navigationBar.tintColor = self.view.tintColor
        
        self.alarmSetupButton.isMusicOn = .Music == self.timerObject.soundMode
        self.alarmSetupButton.isSoundOn = .Sound == self.timerObject.soundMode
        self.alarmSetupButton.isTicksOn = self.timerObject.audibleTicks
        self.alarmSetupButton.isVibrateOn = (.VibrateOnly == self.timerObject.alertMode || .Both == self.timerObject.alertMode)
        self.colorThemePicker.reloadAllComponents()
        self.warningThresholdTimePicker.reloadAllComponents()
        self.finalThresholdTimePicker.reloadAllComponents()
        
        super.viewWillAppear(animated)
    }
    
    /* ################################################################## */
    /**
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.alarmSetupButton.setNeedsDisplay()
    }
    
    /* ################################################################## */
    /**
     Called when the view will disappear.
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Don't forget to reset when view is being removed
        Timer_AppDelegate.lockOrientation(.all)
    }
    
    /* ################################################################## */
    /**
     Called when we are about to bring in the setup controller.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationController = segue.destination as? Timer_SetupSoundsViewController {
            destinationController.timerObject = self.timerObject
        }
    }

    /* ################################################################################################################################## */
    // MARK: - @IBAction Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBAction func modeSegmentedControlChanged(_ sender: UISegmentedControl) {
        self.timerObject.displayMode = TimerDisplayMode(rawValue: sender.selectedSegmentIndex)!
        self.setUpPickerViews()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func doneButtonHit(_: Any! = nil) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /* ################################################################################################################################## */
    /**
     This method adds all the accessibility stuff.
     */
    override func addAccessibilityStuff() {
        super.addAccessibilityStuff()

        for trailer in ["Digits", "Lights", "Both"].enumerated() {
            let imageName = "TimerModeImages-" + trailer.element
            if let image = UIImage(named: imageName) {
                image.accessibilityLabel = ("LGV_TIMER-ACCESSIBILITY-SEGMENTED-TIMER-MODE-" + trailer.element + "-LABEL").localizedVariant
                self.timerModeSegmentedSwitch.setImage(image, forSegmentAt: trailer.offset)
            }
        }
        
        self.warningThresholdLabel.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-SET-WARN-TIME-PICKER-LABEL".localizedVariant
        self.warningThresholdLabel.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-SET-WARN-TIME-PICKER-HINT".localizedVariant
        
        self.finalThresholdLabel.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-SET-FINAL-TIME-PICKER-LABEL".localizedVariant
        self.finalThresholdLabel.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-SET-FINAL-TIME-PICKER-HINT".localizedVariant
        
        self.alarmSetupButton.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-ALARM-SETUP-BUTTON-HINT".localizedVariant
        
        var accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-ALARM-SETUP-BUTTON-LABEL".localizedVariant

        switch self.timerObject.soundMode {
        case .Sound:
            accessibilityLabel += "LGV_TIMER-ACCESSIBILITY-SOUND-SET".localizedVariant
        case .Music:
            accessibilityLabel += "LGV_TIMER-ACCESSIBILITY-SONG-SET".localizedVariant
        case .Silent:
            accessibilityLabel += "LGV_TIMER-ACCESSIBILITY-SILENT-SET".localizedVariant
        }
        
        if .VibrateOnly == self.timerObject.alertMode || .Both == self.timerObject.alertMode {
            accessibilityLabel += "LGV_TIMER-ACCESSIBILITY-VIBRATE-SET".localizedVariant
        }
        
        if self.timerObject.audibleTicks {
            accessibilityLabel += "LGV_TIMER-ACCESSIBILITY-TICKS-SET".localizedVariant
        }
        
        self.alarmSetupButton.accessibilityLabel = accessibilityLabel

        self.doneButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-DONE-BUTTON-LABEL".localizedVariant
        self.doneButton.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-DONE-BUTTON-HINT".localizedVariant
        
        UIAccessibility.post(notification: .layoutChanged, argument: self.timerModeSegmentedSwitch)
    }

    /// MARK: - UIPickerViewDataSource Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return (self.colorThemePicker == pickerView) ? 1: super.numberOfComponents(in: pickerView)
    }
    
    /* ################################################################## */
    /**
     */
    override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.colorThemePicker == pickerView {
            return Timer_AppDelegate.appDelegateObject.timerEngine.colorLabelArray.count
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
        return pickerView.bounds.size.height / ((self.colorThemePicker == pickerView) ? 3.0: 4.0)
    }
    
    /* ################################################################## */
    /**
     */
    override func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return (self.colorThemePicker == pickerView) ? pickerView.bounds.size.width: super.pickerView(pickerView, widthForComponent: component)
    }
    
    /* ################################################################## */
    /**
     */
    override func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if self.colorThemePicker == pickerView {
            let width = self.pickerView(pickerView, widthForComponent: component)
            let height = self.pickerView(pickerView, rowHeightForComponent: component)
            let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: height))
            let ret = UIView(frame: frame)
            ret.backgroundColor = Timer_AppDelegate.appDelegateObject.timerEngine.colorLabelArray[row].backgroundColor
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
                    var maxValInt = Swift.max(0, Swift.min(self.timerObject.timeSetPodiumFinal, self.timerObject.timeSetPodiumWarn - 1))
                    if 0 == maxValInt {
                        maxValInt = Swift.min(TimerSettingTuple.calcPodiumModeFinalThresholdForTimerValue(self.timerObject.timeSet), self.timerObject.timeSetPodiumWarn - 1)
                    }
                    
                    self.timerObject.timeSetPodiumFinal = maxValInt
                    let maxVal = TimeTuple(maxValInt)
                    
                    self.finalThresholdTimePicker.selectRow(maxVal.hours, inComponent: Components.Hours.rawValue, animated: true)
                    self.finalThresholdTimePicker.selectRow(maxVal.minutes, inComponent: Components.Minutes.rawValue, animated: true)
                    self.finalThresholdTimePicker.selectRow(maxVal.seconds, inComponent: Components.Seconds.rawValue, animated: true)
                } else {
                    var maxValInt = Swift.max(0, self.timerObject.timeSet - 1)
                    
                    if 0 == maxValInt {
                        maxValInt = Swift.min(TimerSettingTuple.calcPodiumModeWarningThresholdForTimerValue(self.timerObject.timeSet), self.timerObject.timeSetPodiumWarn - 1)
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
                    var maxValInt = Swift.max(0, self.timerObject.timeSetPodiumWarn - 1)
                    
                    if 0 == maxValInt {
                        maxValInt = Swift.min(TimerSettingTuple.calcPodiumModeFinalThresholdForTimerValue(self.timerObject.timeSet), self.timerObject.timeSetPodiumWarn - 1)
                    }
                    
                    let maxVal = TimeTuple(maxValInt)
                    
                    pickerView.selectRow(maxVal.hours, inComponent: Components.Hours.rawValue, animated: true)
                    pickerView.selectRow(maxVal.minutes, inComponent: Components.Minutes.rawValue, animated: true)
                    pickerView.selectRow(maxVal.seconds, inComponent: Components.Seconds.rawValue, animated: true)
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func pickerView(_ inPickerView: UIPickerView, accessibilityLabelForComponent inComponent: Int) -> String? {
        if 1 == inPickerView.numberOfComponents {
            return "LGV_TIMER-ACCESSIBILITY-COLOR-PICKER-LABEL".localizedVariant + ", " + "LGV_TIMER-ACCESSIBILITY-COLOR-PICKER-HINT".localizedVariant
        } else {
            return super.pickerView(inPickerView, accessibilityLabelForComponent: inComponent)
        }
    }
}
