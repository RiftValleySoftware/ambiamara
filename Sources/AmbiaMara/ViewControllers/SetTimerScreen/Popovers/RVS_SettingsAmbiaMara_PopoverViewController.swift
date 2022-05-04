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
     The popover height.
    */
    static let settingsPopoverHeightInDisplayUnits = CGFloat(220)

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
     The switch that controls whether or not the running timer starts immediately, or as paused.
    */
    @IBOutlet weak var popoverStartImmediatelySwitch: UISwitch?
    
    /* ################################################################## */
    /**
     The label for the switch is actually a button.
    */
    @IBOutlet weak var popoverStartImmediatelySwitchLabelButton: UIButton?
    
    /* ################################################################## */
    /**
     The switch that controls whether or not the running timer has a toolbar, displayed at the top.
    */
    @IBOutlet weak var popoverDisplayToolbarSwitch: UISwitch?
    
    /* ################################################################## */
    /**
     The label for the switch is actually a button.
    */
    @IBOutlet weak var popoverDisplayToolbarSwitchLabelButton: UIButton?
    
    /* ################################################################## */
    /**
     The segmented switch that indicates whether digital or stoplight mode.
    */
    @IBOutlet weak var timerModeSegmentedSwitch: UISegmentedControl?

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
        popoverStartImmediatelySwitch?.isOn = RVS_AmbiaMara_Settings().startTimerImmediately
        popoverDisplayToolbarSwitch?.isOn = RVS_AmbiaMara_Settings().displayToolbar
        timerModeSegmentedSwitch?.selectedSegmentIndex = RVS_AmbiaMara_Settings().stoplightMode ? 1 : 0
        
        popoverHelpSettingsSwitchLabelButton?.setTitle(popoverHelpSettingsSwitchLabelButton?.title(for: .normal)?.localizedVariant, for: .normal)
        popoverStartImmediatelySwitchLabelButton?.setTitle(popoverStartImmediatelySwitchLabelButton?.title(for: .normal)?.localizedVariant, for: .normal)
        popoverDisplayToolbarSwitchLabelButton?.setTitle(popoverDisplayToolbarSwitchLabelButton?.title(for: .normal)?.localizedVariant, for: .normal)
        aboutAmbiaMaraButton?.setTitle(aboutAmbiaMaraButton?.title(for: .normal)?.localizedVariant, for: .normal)

        popoverHelpSettingsSwitchLabelButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        popoverHelpSettingsSwitchLabelButton?.titleLabel?.minimumScaleFactor = 0.5
        popoverStartImmediatelySwitchLabelButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        popoverStartImmediatelySwitchLabelButton?.titleLabel?.minimumScaleFactor = 0.5
        popoverDisplayToolbarSwitchLabelButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        popoverDisplayToolbarSwitchLabelButton?.titleLabel?.minimumScaleFactor = 0.5
        aboutAmbiaMaraButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        aboutAmbiaMaraButton?.titleLabel?.minimumScaleFactor = 0.5

        popoverHelpSettingsSwitch?.accessibilityLabel = "SLUG-ACC-SHOW-HELP-SWITCH".localizedVariant
        popoverHelpSettingsSwitchLabelButton?.accessibilityLabel = "SLUG-ACC-SHOW-HELP-SWITCH".localizedVariant
        
        popoverStartImmediatelySwitch?.accessibilityLabel = "SLUG-ACC-POPOVER-START-IMMEDIATELY-SWITCH".localizedVariant
        popoverStartImmediatelySwitchLabelButton?.accessibilityLabel = "SLUG-ACC-POPOVER-START-IMMEDIATELY-SWITCH".localizedVariant
        
        popoverDisplayToolbarSwitch?.accessibilityLabel = "SLUG-ACC-POPOVER-SHOW-TOOLBAR-SWITCH".localizedVariant
        popoverDisplayToolbarSwitchLabelButton?.accessibilityLabel = "SLUG-ACC-POPOVER-SHOW-TOOLBAR-SWITCH".localizedVariant

        aboutAmbiaMaraButton?.accessibilityLabel = "SLUG-ACC-ABOUT-AMBIAMARA-BUTTON".localizedVariant

        if let timerModeSegmentedSwitch = timerModeSegmentedSwitch {
            timerModeSegmentedSwitch.selectedSegmentTintColor = .white
            timerModeSegmentedSwitch.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
            timerModeSegmentedSwitch.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
            timerModeSegmentedSwitch.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.25)], for: .disabled)
            timerModeSegmentedSwitch.selectedSegmentIndex = RVS_AmbiaMara_Settings().stoplightMode ? 1 : 0
            timerModeSegmentedSwitch.accessibilityLabel = "SLUG-ACC-POPOVER-TIMER-MODE".localizedVariant
            timerModeSegmentedSwitchChanged(timerModeSegmentedSwitch)
        }
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
    
    /* ################################################################## */
    /**
     The switch or button for display toolbar was hit.
     - parameter inSender: the switch or the button.
    */
    @IBAction func popoverDisplayToolbarSwitchChanged(_ inSender: UIControl) {
        if let switcher = inSender as? UISwitch {
            RVS_AmbiaMara_Settings().displayToolbar = switcher.isOn
        } else {
            popoverDisplayToolbarSwitch?.setOn(!(popoverDisplayToolbarSwitch?.isOn ?? true), animated: true)
            popoverDisplayToolbarSwitch?.sendActions(for: .valueChanged)
        }
    }
    
    /* ################################################################## */
    /**
     The switch or button for timer mode was hit.
     - parameter inSender: the segmented control for the timer mode..
    */
    @IBAction func timerModeSegmentedSwitchChanged(_ inSender: UISegmentedControl) {
        RVS_AmbiaMara_Settings().stoplightMode = 0 < inSender.selectedSegmentIndex
    }
}
