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
// MARK: - About AmbiaMara Screen View Controller -
/* ###################################################################################################################################### */
/**
 This is the view controller for the about screen.
 */
class RVS_AboutAmbiaMara_ViewController: RVS_AmbiaMara_BaseViewController {
    /* ################################################################## */
    /**
     The switch that controls whether or not the popover help is shown when touching the labels.
    */
    @IBOutlet weak var popoverHelpSettingsSwitch: UISwitch?
    
    /* ################################################################## */
    /**
     The label for the switch is actually a button.
    */
    @IBOutlet weak var popoverHelpSettingsSwitchLabelButton: UIButton?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RVS_AboutAmbiaMara_ViewController {
    /* ################################################################## */
    /**
     Called when the hierarchy has loaded. We use this to set the screen up, and apply accessibility.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        popoverHelpSettingsSwitch?.isOn = RVS_AmbiaMara_Settings().useGuidancePopovers
        popoverHelpSettingsSwitchLabelButton?.setTitle(popoverHelpSettingsSwitchLabelButton?.title(for: .normal)?.localizedVariant, for: .normal)

        popoverHelpSettingsSwitch?.accessibilityLabel = "SLUG-ACC-SHOW-HELP-SWITCH".localizedVariant
        popoverHelpSettingsSwitchLabelButton?.accessibilityLabel = "SLUG-ACC-SHOW-HELP-SWITCH".localizedVariant
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension RVS_AboutAmbiaMara_ViewController {
    /* ################################################################## */
    /**
     The switch or button for popover help was hit.
     - parameter inSender: the switch or the button.
    */
    @IBAction func popoverHelpSettingsSwitchChanged(_ inSender: UIControl) {
        if let switcher = inSender as? UISwitch {
            RVS_AmbiaMara_Settings().useGuidancePopovers = switcher.isOn
        } else {
            popoverHelpSettingsSwitch?.setOn(!(popoverHelpSettingsSwitch?.isOn ?? true), animated: true)
            popoverHelpSettingsSwitch?.sendActions(for: .valueChanged)
        }
    }
}
