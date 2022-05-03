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
// MARK: - About AmbiaMara Screen View Controller -
/* ###################################################################################################################################### */
/**
 This is the view controller for the about screen.
 */
class RVS_SettingsAmbiaMara_PopoverViewController: UIViewController {
    /* ################################################################## */
    /**
     The storyboard ID for this controller.
     */
    static let storyboardID = "RVS_SettingsAmbiaMara_PopoverViewController"
    
    /* ################################################################## */
    /**
     This references the presenting view controller.
    */
    weak var myController: RVS_SetTimerAmbiaMara_ViewController?
    
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
    
    /* ################################################################## */
    /**
     The switch that controls whether or not the running timer will display a digital countdown.
    */
    @IBOutlet weak var popoverDisplayDigitsSwitch: UISwitch?
    
    /* ################################################################## */
    /**
     The label for the switch is actually a button.
    */
    @IBOutlet weak var popoverDisplayDigitsSwitchLabelButton: UIButton?
    
    /* ################################################################## */
    /**
     The switch that controls whether or not the running timer will display three "traffic lights."
    */
    @IBOutlet weak var popoverDisplayTrafficLightsSwitch: UISwitch?
    
    /* ################################################################## */
    /**
     The label for the switch is actually a button.
    */
    @IBOutlet weak var popoverDisplayTrafficLightsSwitchLabelButton: UIButton?
    
    /* ################################################################## */
    /**
     The switch that controls whether or not the running timer start immediately, or as paused.
    */
    @IBOutlet weak var popoverStartImmediatelySwitch: UISwitch?
    
    /* ################################################################## */
    /**
     The label for the switch is actually a button.
    */
    @IBOutlet weak var popoverStartImmediatelySwitchLabelButton: UIButton?

    /* ################################################################## */
    /**
     The button that shows us the about screen.
    */
    @IBOutlet weak var aboutAmbiaMaraButton: UIButton?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RVS_SettingsAmbiaMara_PopoverViewController {
    /* ################################################################## */
    /**
     Called when the hierarchy has loaded. We use this to set the screen up, and apply accessibility.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        popoverHelpSettingsSwitch?.isOn = RVS_AmbiaMara_Settings().useGuidancePopovers
        popoverDisplayDigitsSwitch?.isOn = RVS_AmbiaMara_Settings().showDigits
        popoverDisplayTrafficLightsSwitch?.isOn = RVS_AmbiaMara_Settings().showStoplights
        popoverStartImmediatelySwitch?.isOn = RVS_AmbiaMara_Settings().startTimerImmediately

        popoverHelpSettingsSwitchLabelButton?.setTitle(popoverHelpSettingsSwitchLabelButton?.title(for: .normal)?.localizedVariant, for: .normal)
        popoverDisplayDigitsSwitchLabelButton?.setTitle(popoverDisplayDigitsSwitchLabelButton?.title(for: .normal)?.localizedVariant, for: .normal)
        popoverDisplayTrafficLightsSwitchLabelButton?.setTitle(popoverDisplayTrafficLightsSwitchLabelButton?.title(for: .normal)?.localizedVariant, for: .normal)
        popoverStartImmediatelySwitchLabelButton?.setTitle(popoverStartImmediatelySwitchLabelButton?.title(for: .normal)?.localizedVariant, for: .normal)
        aboutAmbiaMaraButton?.setTitle(aboutAmbiaMaraButton?.title(for: .normal)?.localizedVariant, for: .normal)

        popoverHelpSettingsSwitchLabelButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        popoverHelpSettingsSwitchLabelButton?.titleLabel?.minimumScaleFactor = 0.5
        popoverDisplayDigitsSwitchLabelButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        popoverDisplayDigitsSwitchLabelButton?.titleLabel?.minimumScaleFactor = 0.5
        popoverDisplayTrafficLightsSwitchLabelButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        popoverDisplayTrafficLightsSwitchLabelButton?.titleLabel?.minimumScaleFactor = 0.5
        popoverStartImmediatelySwitchLabelButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        popoverStartImmediatelySwitchLabelButton?.titleLabel?.minimumScaleFactor = 0.5
        aboutAmbiaMaraButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        aboutAmbiaMaraButton?.titleLabel?.minimumScaleFactor = 0.5

        popoverHelpSettingsSwitch?.accessibilityLabel = "SLUG-ACC-SHOW-HELP-SWITCH".localizedVariant
        popoverHelpSettingsSwitchLabelButton?.accessibilityLabel = "SLUG-ACC-SHOW-HELP-SWITCH".localizedVariant
        
        popoverDisplayDigitsSwitch?.accessibilityLabel = "SLUG-ACC-POPOVER-DIGITS-SWITCH".localizedVariant
        popoverDisplayDigitsSwitchLabelButton?.accessibilityLabel = "SLUG-ACC-POPOVER-DIGITS-SWITCH".localizedVariant
        
        popoverDisplayTrafficLightsSwitch?.accessibilityLabel = "SLUG-ACC-POPOVER-STOPLIGHTS-SWITCH".localizedVariant
        popoverDisplayTrafficLightsSwitchLabelButton?.accessibilityLabel = "SLUG-ACC-POPOVER-STOPLIGHTS-SWITCH".localizedVariant
        
        popoverStartImmediatelySwitch?.accessibilityLabel = "SLUG-ACC-POPOVER-START-IMMEDIATELY-SWITCH".localizedVariant
        popoverStartImmediatelySwitchLabelButton?.accessibilityLabel = "SLUG-ACC-POPOVER-START-IMMEDIATELY-SWITCH".localizedVariant

        aboutAmbiaMaraButton?.accessibilityLabel = "SLUG-ACC-ABOUT-AMBIAMARA-BUTTON".localizedVariant
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension RVS_SettingsAmbiaMara_PopoverViewController {
    /* ################################################################## */
    /**
     This dismisses the popover, and shows the about screen.
     - parameter: ignored.
    */
    @IBAction func showAboutScreen(_: Any) {
        dismiss(animated: true, completion: { [weak self] in self?.myController?.showAboutScreen()})
    }
    
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
    
    /* ################################################################## */
    /**
     The switch or button for digital display was hit.
     - parameter inSender: the switch or the button.
    */
    @IBAction func popoverDisplayDigitsSwitchChanged(_ inSender: UIControl) {
        if let switcher = inSender as? UISwitch {
            RVS_AmbiaMara_Settings().showDigits = switcher.isOn
        } else {
            popoverDisplayDigitsSwitch?.setOn(!(popoverDisplayDigitsSwitch?.isOn ?? true), animated: true)
            popoverDisplayDigitsSwitch?.sendActions(for: .valueChanged)
        }
    }
    
    /* ################################################################## */
    /**
     The switch or button for traffic lights display was hit.
     - parameter inSender: the switch or the button.
    */
    @IBAction func popoverDisplayTrafficLightsSwitchChanged(_ inSender: UIControl) {
        if let switcher = inSender as? UISwitch {
            RVS_AmbiaMara_Settings().showStoplights = switcher.isOn
        } else {
            popoverDisplayTrafficLightsSwitch?.setOn(!(popoverDisplayTrafficLightsSwitch?.isOn ?? true), animated: true)
            popoverDisplayTrafficLightsSwitch?.sendActions(for: .valueChanged)
        }
    }
    
    /* ################################################################## */
    /**
     The switch or button for start immediately was hit.
     - parameter inSender: the switch or the button.
    */
    @IBAction func popoverStartImmediatelySwitchChanged(_ inSender: UIControl) {
        if let switcher = inSender as? UISwitch {
            RVS_AmbiaMara_Settings().startTimerImmediately = switcher.isOn
        } else {
            popoverStartImmediatelySwitch?.setOn(!(popoverStartImmediatelySwitch?.isOn ?? true), animated: true)
            popoverStartImmediatelySwitch?.sendActions(for: .valueChanged)
        }
    }
}
