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
 This is the view controller for the main timer settings screen.
 */
class TimerSetupController: A_TimerSetPickerController {
    /// The timer mode segmented controller
    @IBOutlet weak var timerModeSegmentedSwitch: UISegmentedControl!
    /// The container for the podium mode controls
    @IBOutlet weak var podiumModeContainerView: UIView!
    /// The label for the warning threshold picker
    @IBOutlet weak var warningThresholdLabel: UILabel!
    /// The picker for the warning threshold time
    @IBOutlet weak var warningThresholdTimePicker: UIPickerView!
    /// The label for the final threshold picker
    @IBOutlet weak var finalThresholdLabel: UILabel!
    /// The final threshold picker
    @IBOutlet weak var finalThresholdTimePicker: UIPickerView!
    /// The container for the color selection picker
    @IBOutlet weak var colorPickerContainerView: UIView!
    /// The picker for selecting a color theme
    @IBOutlet weak var colorThemePicker: UIPickerView!
    /// The constraint that pushes the podium mode stuff below the color picker
    @IBOutlet weak var podiumModeItemsConstraint: NSLayoutConstraint!
    /// The dismiss/done button
    @IBOutlet weak var doneButton: UIButton!
    /// The setup button that brings in the alarm settings screen
    @IBOutlet weak var alarmSetupButton: TimerSoundModeButton!
    /// The label for the color display
    @IBOutlet weak var colorDisplayLabel: UILabel!
    
    /* ################################################################################################################################## */
    // MARK: - Internal Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This just sets up the picker views to the current settings
     */
    func setUpPickerViews() {
        podiumModeContainerView.isHidden = (.Digital == timerObject.displayMode)
        colorPickerContainerView.isHidden = (.Podium == timerObject.displayMode)
        warningThresholdTimePicker.setNeedsDisplay()
        finalThresholdTimePicker.setNeedsDisplay()
    }
    
    /* ################################################################## */
    /**
     Sets up the screen before it is shown.
     */
    func setup() {
        // Make sure that our red is always less than our yellow.
        var maxValInt = Swift.max(0, Swift.min(timerObject.timeSetPodiumFinal, timerObject.timeSetPodiumWarn - 1))
        if 0 == maxValInt {
            maxValInt = Swift.min(TimerSettingTuple.calcPodiumModeFinalThresholdForTimerValue(timerObject.timeSet), timerObject.timeSetPodiumWarn - 1)
        }
        
        navigationItem.title = "LGV_TIMER-ACCESSIBILITY-SETTINGS-BUTTON-LABEL".localizedVariant

        timerObject.timeSetPodiumFinal = maxValInt

        warningThresholdLabel.text = warningThresholdLabel.text?.localizedVariant
        finalThresholdLabel.text = finalThresholdLabel.text?.localizedVariant
        colorDisplayLabel.text = colorDisplayLabel.text?.localizedVariant
        
        timerModeSegmentedSwitch.selectedSegmentIndex = timerObject.displayMode.rawValue
        if #available(iOS 13.0, *) {
            timerModeSegmentedSwitch.selectedSegmentTintColor = view.tintColor
            // White text.
            timerModeSegmentedSwitch.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
            timerModeSegmentedSwitch.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: view?.tintColor ?? UIColor.white], for: .normal)
        }

        setUpPickerViews()

        warningThresholdTimePicker.reloadAllComponents()
        finalThresholdTimePicker.reloadAllComponents()
        colorThemePicker.reloadAllComponents()
        
        var timeSetWarnInt = timerObject.timeSetPodiumWarn
        if 0 >= timeSetWarnInt {
            timeSetWarnInt = TimerSettingTuple.calcPodiumModeWarningThresholdForTimerValue(timerObject.timeSet)
            timerObject.timeSetPodiumWarn = timeSetWarnInt
        }
        let timeSetWarn = TimeInstance(timeSetWarnInt)
        var timeSetFinalInt = timerObject.timeSetPodiumFinal
        if 0 >= timeSetFinalInt {
            timeSetFinalInt = TimerSettingTuple.calcPodiumModeFinalThresholdForTimerValue(timerObject.timeSet)
            timerObject.timeSetPodiumFinal = timeSetFinalInt
        }
        
        let timeSetFinal = TimeInstance(timeSetFinalInt)
        warningThresholdTimePicker.selectRow(timeSetWarn.hours, inComponent: Components.Hours.rawValue, animated: true)
        warningThresholdTimePicker.selectRow(timeSetWarn.minutes, inComponent: Components.Minutes.rawValue, animated: true)
        warningThresholdTimePicker.selectRow(timeSetWarn.seconds, inComponent: Components.Seconds.rawValue, animated: true)
        finalThresholdTimePicker.selectRow(timeSetFinal.hours, inComponent: Components.Hours.rawValue, animated: true)
        finalThresholdTimePicker.selectRow(timeSetFinal.minutes, inComponent: Components.Minutes.rawValue, animated: true)
        finalThresholdTimePicker.selectRow(timeSetFinal.seconds, inComponent: Components.Seconds.rawValue, animated: true)
        
        // This ensures that we force the display to portrait (for this screen only).
        Timer_AppDelegate.lockOrientation(.portrait, andRotateTo: .portrait)
        colorThemePicker.selectRow(timerObject.colorTheme, inComponent: 0, animated: true)
        
        alarmSetupButton.isMusicOn = .Music == timerObject.soundMode
        alarmSetupButton.isSoundOn = .Sound == timerObject.soundMode
        alarmSetupButton.isTicksOn = timerObject.audibleTicks
        alarmSetupButton.isVibrateOn = (.VibrateOnly == timerObject.alertMode || .Both == timerObject.alertMode)
        colorThemePicker.reloadAllComponents()
        warningThresholdTimePicker.reloadAllComponents()
        finalThresholdTimePicker.reloadAllComponents()
    }

    /* ################################################################################################################################## */
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view will appear.
     */
    override func viewWillAppear(_ animated: Bool) {
        setup()
        super.viewWillAppear(animated)
    }
    
    /* ################################################################## */
    /**
     Called when the view is about to lay out its subviews. We use it to set the alarm setup button.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        alarmSetupButton.setNeedsDisplay()
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
            destinationController.timerObject = timerObject
            destinationController.daBoss = self
        }
    }

    /* ################################################################################################################################## */
    // MARK: - @IBAction Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the mode segmented control changes
     
     - parameter sender: ignored
     */
    @IBAction func modeSegmentedControlChanged(_ sender: UISegmentedControl) {
        timerObject.displayMode = TimerDisplayMode(rawValue: sender.selectedSegmentIndex)!
        setUpPickerViews()
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
                timerModeSegmentedSwitch.setImage(image, forSegmentAt: trailer.offset)
            }
        }
        
        warningThresholdLabel.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-SET-WARN-TIME-PICKER-LABEL".localizedVariant
        warningThresholdLabel.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-SET-WARN-TIME-PICKER-HINT".localizedVariant
        
        finalThresholdLabel.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-SET-FINAL-TIME-PICKER-LABEL".localizedVariant
        finalThresholdLabel.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-SET-FINAL-TIME-PICKER-HINT".localizedVariant
        
        alarmSetupButton.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-ALARM-SETUP-BUTTON-HINT".localizedVariant
        
        var accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-ALARM-SETUP-BUTTON-LABEL".localizedVariant

        switch timerObject.soundMode {
        case .Sound:
            accessibilityLabel += "LGV_TIMER-ACCESSIBILITY-SOUND-SET".localizedVariant
        case .Music:
            accessibilityLabel += "LGV_TIMER-ACCESSIBILITY-SONG-SET".localizedVariant
        case .Silent:
            accessibilityLabel += "LGV_TIMER-ACCESSIBILITY-SILENT-SET".localizedVariant
        }
        
        if .VibrateOnly == timerObject.alertMode || .Both == timerObject.alertMode {
            accessibilityLabel += "LGV_TIMER-ACCESSIBILITY-VIBRATE-SET".localizedVariant
        }
        
        if timerObject.audibleTicks {
            accessibilityLabel += "LGV_TIMER-ACCESSIBILITY-TICKS-SET".localizedVariant
        }
        
        alarmSetupButton.accessibilityLabel = accessibilityLabel
        
        UIAccessibility.post(notification: .layoutChanged, argument: timerModeSegmentedSwitch)
    }

    /* ################################################################################################################################## */
    // MARK: - UIPickerViewDataSource Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return (colorThemePicker == pickerView) ? 1: super.numberOfComponents(in: pickerView)
    }
    
    /* ################################################################## */
    /**
     */
    override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if colorThemePicker == pickerView {
            return Timer_AppDelegate.appDelegateObject.timerEngine.colorLabelArray.count
        } else {
            return super.pickerView(pickerView, numberOfRowsInComponent: component)
        }
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
    override func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickerView.bounds.size.height / ((colorThemePicker == pickerView) ? 3.0: 4.0)
    }
    
    /* ################################################################## */
    /**
     - parameter pickerView: The UIPickerView calling this
     - parameter widthForComponent: The 0-based index of the component.
     - returns: the width, in display units, of the referenced picker component
     */
    override func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return (colorThemePicker == pickerView) ? pickerView.bounds.size.width: super.pickerView(pickerView, widthForComponent: component)
    }
    
    /* ################################################################## */
    /**
     - parameter pickerView: The UIPickerView calling this
     - parameter viewForRow: The 0-based index of the row.
     - parameter forComponent: The 0-based index of the component.
     - parameter reusing: Any view being reused (ignored)
     - returns: a UIView, containing the picker cell.
     */
    override func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if colorThemePicker == pickerView {
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
     This is called when a picker row is selected, and sets the value for that picker.
     
     - parameter inPickerView: The UIPickerView being queried.
     - parameter inRow: The 0-based row index being selected.
     - parameter inComponent: The 0-based component index being selected.
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if colorThemePicker == pickerView {
            timerObject.colorTheme = row
        } else {
            let hours = pickerView.selectedRow(inComponent: Components.Hours.rawValue)
            let minutes = pickerView.selectedRow(inComponent: Components.Minutes.rawValue)
            let seconds = pickerView.selectedRow(inComponent: Components.Seconds.rawValue)
            if warningThresholdTimePicker == pickerView {
                if timerObject.timeSet > Int(TimeInstance(hours: hours, minutes: minutes, seconds: seconds)) {
                    timerObject.timeSetPodiumWarn = Int(TimeInstance(hours: hours, minutes: minutes, seconds: seconds))
                    var maxValInt = Swift.max(0, Swift.min(timerObject.timeSetPodiumFinal, timerObject.timeSetPodiumWarn - 1))
                    if 0 == maxValInt {
                        maxValInt = Swift.min(TimerSettingTuple.calcPodiumModeFinalThresholdForTimerValue(timerObject.timeSet), timerObject.timeSetPodiumWarn - 1)
                    }
                    
                    timerObject.timeSetPodiumFinal = maxValInt
                    let maxVal = TimeInstance(maxValInt)
                    
                    finalThresholdTimePicker.selectRow(maxVal.hours, inComponent: Components.Hours.rawValue, animated: true)
                    finalThresholdTimePicker.selectRow(maxVal.minutes, inComponent: Components.Minutes.rawValue, animated: true)
                    finalThresholdTimePicker.selectRow(maxVal.seconds, inComponent: Components.Seconds.rawValue, animated: true)
                } else {
                    var maxValInt = Swift.max(0, timerObject.timeSet - 1)
                    
                    if 0 == maxValInt {
                        maxValInt = Swift.min(TimerSettingTuple.calcPodiumModeWarningThresholdForTimerValue(timerObject.timeSet), timerObject.timeSetPodiumWarn - 1)
                    }
                    
                    let maxVal = TimeInstance(maxValInt)
                    
                    pickerView.selectRow(maxVal.hours, inComponent: Components.Hours.rawValue, animated: true)
                    pickerView.selectRow(maxVal.minutes, inComponent: Components.Minutes.rawValue, animated: true)
                    pickerView.selectRow(maxVal.seconds, inComponent: Components.Seconds.rawValue, animated: true)
                }
            } else {
                if (0 == timerObject.timeSetPodiumWarn) || (0 == timerObject.timeSet) || (timerObject.timeSetPodiumWarn > Int(TimeInstance(hours: hours, minutes: minutes, seconds: seconds))) {
                    if (0 == timerObject.timeSetPodiumWarn) || (0 == timerObject.timeSet) {
                        timerObject.timeSetPodiumFinal =  0
                        pickerView.selectRow(0, inComponent: Components.Hours.rawValue, animated: true)
                        pickerView.selectRow(0, inComponent: Components.Minutes.rawValue, animated: true)
                        pickerView.selectRow(0, inComponent: Components.Seconds.rawValue, animated: true)
                    } else {
                        timerObject.timeSetPodiumFinal = Int(TimeInstance(hours: hours, minutes: minutes, seconds: seconds))
                    }
                } else {
                    var maxValInt = Swift.max(0, timerObject.timeSetPodiumWarn - 1)
                    
                    if 0 == maxValInt {
                        maxValInt = Swift.min(TimerSettingTuple.calcPodiumModeFinalThresholdForTimerValue(timerObject.timeSet), timerObject.timeSetPodiumWarn - 1)
                    }
                    
                    let maxVal = TimeInstance(maxValInt)
                    
                    pickerView.selectRow(maxVal.hours, inComponent: Components.Hours.rawValue, animated: true)
                    pickerView.selectRow(maxVal.minutes, inComponent: Components.Minutes.rawValue, animated: true)
                    pickerView.selectRow(maxVal.seconds, inComponent: Components.Seconds.rawValue, animated: true)
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     - parameter: The UIPickerView calling this (ignored)
     - parameter accessibilityLabelForComponent: The 0-based index of the component.
     - returns: The accessibility label for the given component.
     */
    override func pickerView(_ inPickerView: UIPickerView, accessibilityLabelForComponent inComponent: Int) -> String? {
        if 1 == inPickerView.numberOfComponents {
            return "LGV_TIMER-ACCESSIBILITY-COLOR-PICKER-LABEL".localizedVariant + ", " + "LGV_TIMER-ACCESSIBILITY-COLOR-PICKER-HINT".localizedVariant
        } else {
            return super.pickerView(inPickerView, accessibilityLabelForComponent: inComponent)
        }
    }
}
