/*
 © Copyright 2018-2022, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_Generic_Swift_Toolbox

/* ###################################################################################################################################### */
// MARK: - Set Audible and Visual Alarm View Controller -
/* ###################################################################################################################################### */
/**
 This is the view controller for the alarm setup screen.
 */
class RVS_SetAlarmAmbiaMara_ViewController: RVS_AmbiaMara_BaseViewController {
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
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RVS_SetAlarmAmbiaMara_ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alarmModeSegmentedSwitch?.selectedSegmentTintColor = .white
        alarmModeSegmentedSwitch?.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        alarmModeSegmentedSwitch?.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        alarmModeSegmentedSwitch?.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.25)], for: .disabled)

        vibrateSwitchLabelButton?.setTitle(vibrateSwitchLabelButton?.title(for: .normal)?.localizedVariant, for: .normal)
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension RVS_SetAlarmAmbiaMara_ViewController {
    /* ################################################################## */
    /**
     Called when the alarm mode is changed.
     
     - parameter inSegmentedSwitch: The segmented switch that changed.
    */
    @IBAction func alarmModeSegmentedSwitchHit(_ inSegmentedSwitch: UISegmentedControl) {
    }
    
    /* ################################################################## */
    /**
     Called when the vibrate switch, or its label, changes.
     
     - parameter inSender: The switch that changed, or the label button..
    */
    @IBAction func vibrateSwitchChanged(_ inSender: UIControl) {
        if let vibrateSwitch = inSender as? UISwitch {
            print("Vibrate is\(vibrateSwitch.isOn ? "" : " not") on.")
        } else {
            vibrateSwitch?.setOn(!(vibrateSwitch?.isOn ?? true), animated: true)
            vibrateSwitch?.sendActions(for: .valueChanged)
        }
    }
}
