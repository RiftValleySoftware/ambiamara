/*
 © Copyright 2018-2022, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_Generic_Swift_Toolbox

/* ###################################################################################################################################### */
// MARK: - Set Audible and Visual Alarm Popover View Controller -
/* ###################################################################################################################################### */
/**
 This is the view controller for the alarm setup popover.
 */
class RVS_SetAlarmAmbiaMara_PopoverViewController: RVS_AmbiaMara_BaseViewController {
    /* ################################################################## */
    /**
     The size of the picker font
    */
    private static let _pickerFont = UIFont.boldSystemFont(ofSize: 20)

    /* ################################################################## */
    /**
     The storyboard ID for this controller.
     */
    static let storyboardID = "RVS_SetAlarmAmbiaMara_ViewController"
    
    /* ################################################################## */
    /**
     This aggregates our available sounds.
     The sounds are files, stored in the resources, so this simply gets them, and stores them as path URIs.
    */
    var soundSelection: [String] = []
    
    /* ################################################################## */
    /**
     This references the presenting view controller.
    */
    weak var myController: RVS_SetTimerAmbiaMara_ViewController?
    
    /* ################################################################## */
    /**
     The segmented switch that controls the alarm mode.
    */
    @IBOutlet weak var alarmModeSegmentedSwitch: UISegmentedControl?

    /* ################################################################## */
    /**
     The stach view that holds the vibrate switch.
    */
    @IBOutlet weak var vibrateSwitchStackView: UIView?

    /* ################################################################## */
    /**
     The vibrate switch (only available on iPhones).
    */
    @IBOutlet weak var vibrateSwitch: UISwitch?
    
    /* ################################################################## */
    /**
     The label for the switch is actually a button, that toggles the switch.
    */
    @IBOutlet weak var vibrateSwitchLabelButton: UIButton?

    /* ################################################################## */
    /**
     The picker view for the sounds. Only shown if the seg switch is set to sound.
    */
    @IBOutlet weak var soundsPickerView: UIPickerView?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RVS_SetAlarmAmbiaMara_PopoverViewController {
    /* ################################################################## */
    /**
     Called when the hierarchy has loaded. We set up the initial states, and all the localization and accessibility.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alarmModeSegmentedSwitch?.selectedSegmentTintColor = .white
        alarmModeSegmentedSwitch?.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        alarmModeSegmentedSwitch?.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        alarmModeSegmentedSwitch?.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.25)], for: .disabled)

        vibrateSwitchLabelButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        vibrateSwitchLabelButton?.titleLabel?.minimumScaleFactor = 0.5
        
        vibrateSwitchLabelButton?.setTitle(vibrateSwitchLabelButton?.title(for: .normal)?.localizedVariant, for: .normal)
        vibrateSwitch?.isOn = RVS_AmbiaMara_Settings().useVibrate
        
        alarmModeSegmentedSwitch?.accessibilityLabel = "SLUG-ACC-ALARM-SET-MODE-SWITCH-LABEL".localizedVariant
        alarmModeSegmentedSwitch?.accessibilityHint = "SLUG-ACC-ALARM-SET-MODE-SWITCH-HINT".localizedVariant
        
        vibrateSwitch?.accessibilityLabel = "SLUG-ACC-ALARM-SET-VIBRATE-SWITCH".localizedVariant
        vibrateSwitchLabelButton?.accessibilityLabel = "SLUG-ACC-ALARM-SET-VIBRATE-SWITCH".localizedVariant

        alarmModeSegmentedSwitch?.selectedSegmentIndex = RVS_AmbiaMara_Settings().alarmMode ? 1 : 0
        soundsPickerView?.isHidden = 0 == alarmModeSegmentedSwitch?.selectedSegmentIndex
        
        soundSelection = Bundle.main.paths(forResourcesOfType: "mp3", inDirectory: nil).sorted()
        
        soundsPickerView?.selectRow(RVS_AmbiaMara_Settings().selectedSoundIndex, inComponent: 0, animated: false)
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension RVS_SetAlarmAmbiaMara_PopoverViewController {
    /* ################################################################## */
    /**
     Called when the alarm mode is changed.
     
     - parameter inSegmentedSwitch: The segmented switch that changed.
    */
    @IBAction func alarmModeSegmentedSwitchHit(_ inSegmentedSwitch: UISegmentedControl) {
        RVS_AmbiaMara_Settings().alarmMode = 1 == inSegmentedSwitch.selectedSegmentIndex
        soundsPickerView?.isHidden = 0 == inSegmentedSwitch.selectedSegmentIndex
        myController?.setAlarmIcon()
    }
    
    /* ################################################################## */
    /**
     Called when the vibrate switch, or its label, changes.
     
     - parameter inSender: The switch that changed, or the label button..
    */
    @IBAction func vibrateSwitchChanged(_ inSender: UIControl) {
        if let vibrateSwitch = inSender as? UISwitch {
            RVS_AmbiaMara_Settings().useVibrate = vibrateSwitch.isOn
        } else {
            vibrateSwitch?.setOn(!(vibrateSwitch?.isOn ?? true), animated: true)
            vibrateSwitch?.sendActions(for: .valueChanged)
        }
    }
}

/* ###################################################################################################################################### */
// MARK: UIPickerViewDataSource Conformance
/* ###################################################################################################################################### */
extension RVS_SetAlarmAmbiaMara_PopoverViewController: UIPickerViewDataSource {
    /* ################################################################## */
    /**
     - parameter in: The picker view (ignored).
     
     - returns the number of components (always 1)
    */
    func numberOfComponents(in: UIPickerView) -> Int { 1 }
    
    /* ################################################################## */
    /**
     - parameter: The picker view (ignored)
     - parameter numberOfRowsInComponent: The 0-based index of the component we are querying.
    */
    func pickerView(_: UIPickerView, numberOfRowsInComponent inComponent: Int) -> Int { soundSelection.count }
}

/* ###################################################################################################################################### */
// MARK: UIPickerViewDelegate Conformance
/* ###################################################################################################################################### */
extension RVS_SetAlarmAmbiaMara_PopoverViewController: UIPickerViewDelegate {
    /* ################################################################## */
    /**
     This is called when a row is selected.
     It verifies that the value is OK, and may change the selection, if not.
     - parameter inPickerView: The picker instance.
     - parameter didSelectRow: The 0-based row index, in the component.
     - parameter inComponent: The component that contains the selected row (0-based index).
    */
    func pickerView(_ inPickerView: UIPickerView, didSelectRow inRow: Int, inComponent: Int) {
        RVS_AmbiaMara_Settings().selectedSoundIndex = inRow
    }
    
    /* ################################################################## */
    /**
     This returns the view to display for the picker row.
     
     - parameter inPickerView: The picker instance.
     - parameter viewForRow: The 0-based row index to be displayed.
     - parameter forComponent: The 0-based component index for the row.
     - parameter reusing: If a view will be reused, we'll use that, instead.
     - returns: A new view, containing the row. If it is selected, it is displayed as reversed.
    */
    func pickerView(_ inPickerView: UIPickerView, viewForRow inRow: Int, forComponent inComponent: Int, reusing inView: UIView?) -> UIView {
        guard let soundUri = URL(string: soundSelection[inRow].urlEncodedString ?? "")?.lastPathComponent else { return UIView() }
        let label = UILabel()
        label.font = Self._pickerFont
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.text = soundUri.localizedVariant
        label.textAlignment = .center
        
        return label
    }
}

/* ###################################################################################################################################### */
// MARK: UIPickerViewAccessibilityDelegate Conformance
/* ###################################################################################################################################### */
extension RVS_SetAlarmAmbiaMara_PopoverViewController: UIPickerViewAccessibilityDelegate {
    /* ################################################################## */
    /**
     This returns the accessibility label for the picker component.
     
     - parameter: The picker instance (ignored).
     - parameter accessibilityLabelForComponent: The 0-based component index for the label (ignored).
     - returns: An accessibility string for the component.
    */
    func pickerView(_: UIPickerView, accessibilityLabelForComponent: Int) -> String? { "SLUG-ACC-SOUND-PICKER".localizedVariant }
}
