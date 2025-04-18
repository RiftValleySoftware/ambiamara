/*
 © Copyright 2018-2022, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_UIKit_Toolbox

/* ###################################################################################################################################### */
// MARK: - About AmbiaMara Screen View Controller -
/* ###################################################################################################################################### */
/**
 This is the view controller for the about screen.
 */
class RVS_SettingsAmbiaMara_PopoverViewController: UIViewController {
    /* ################################################################## */
    /**
     The height of the popover, in display units, if voiceover is running.
     If voiceover is running, then we don't allow the toolbar to be hidden, so those controls are hidden.
     */
    private static let _voiceoverRunningHeightInDisplayUnits = CGFloat(162)

    /* ################################################################## */
    /**
     The height of the popover, if voiceover is not running.
     */
    private static let _regularHeightInDisplayUnits = CGFloat(270)

    /* ################################################################## */
    /**
     This will provide haptic/audio feedback for popover events.
     */
    private var _selectionFeedbackGenerator: UISelectionFeedbackGenerator?

    /* ################################################################## */
    /**
     The storyboard ID for this controller.
     */
    static let storyboardID = "RVS_SettingsAmbiaMara_PopoverViewController"
    
    /* ################################################################## */
    /**
     This references the presenting view controller.
    */
    weak var myController: RVS_SetTimerWrapper?
    
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
     The container for the toolbar display prefs.
    */
    @IBOutlet weak var toolbarContainerStackView: UIView?

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
     The container stack view for the auto-hide switch.
    */
    @IBOutlet weak var autoHideContainerStackView: UIView?
    
    /* ################################################################## */
    /**
     A label that acts as a "shim" for the auto-hide switch. We hide this, for Mac.
    */
    @IBOutlet weak var auotHideIndentLabel: UILabel?
    
    /* ################################################################## */
    /**
     The switch that sets whether or not the toolbar "hides," when running.
     This is disabled, if not in Toolbar Mode.
    */
    @IBOutlet weak var popoverDisplayAutoHideSwitch: UISwitch?

    /* ################################################################## */
    /**
     The label for the switch is actually a button.
    */
    @IBOutlet weak var popoverDisplayAutoHideSwitchLabelButton: UIButton?
    
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
// MARK: Class Variables
/* ###################################################################################################################################### */
extension RVS_SettingsAmbiaMara_PopoverViewController {
    /* ################################################################## */
    /**
     The popover height.
    */
    class var settingsPopoverHeightInDisplayUnits: CGFloat { UIAccessibility.isVoiceOverRunning ? Self._voiceoverRunningHeightInDisplayUnits : Self._regularHeightInDisplayUnits }
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
        popoverStartImmediatelySwitch?.isOn = RVS_AmbiaMara_Settings().startTimerImmediately
        popoverDisplayToolbarSwitch?.isOn = RVS_AmbiaMara_Settings().displayToolbar
        popoverDisplayAutoHideSwitch?.isOn = RVS_AmbiaMara_Settings().autoHideToolbar
        popoverDisplayAutoHideSwitch?.isEnabled = RVS_AmbiaMara_Settings().displayToolbar
        popoverDisplayAutoHideSwitchLabelButton?.isEnabled = RVS_AmbiaMara_Settings().displayToolbar
        timerModeSegmentedSwitch?.selectedSegmentIndex = RVS_AmbiaMara_Settings().stoplightMode ? 1 : 0

        popoverStartImmediatelySwitchLabelButton?.setTitle(popoverStartImmediatelySwitchLabelButton?.title(for: .normal)?.localizedVariant, for: .normal)
        popoverDisplayToolbarSwitchLabelButton?.setTitle(popoverDisplayToolbarSwitchLabelButton?.title(for: .normal)?.localizedVariant, for: .normal)
        popoverDisplayAutoHideSwitchLabelButton?.setTitle(popoverDisplayAutoHideSwitchLabelButton?.title(for: .normal)?.localizedVariant, for: .normal)
        aboutAmbiaMaraButton?.setTitle(aboutAmbiaMaraButton?.title(for: .normal)?.localizedVariant, for: .normal)
        
        popoverStartImmediatelySwitchLabelButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        popoverStartImmediatelySwitchLabelButton?.titleLabel?.minimumScaleFactor = 0.5
        popoverDisplayToolbarSwitchLabelButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        popoverDisplayToolbarSwitchLabelButton?.titleLabel?.minimumScaleFactor = 0.5
        popoverDisplayAutoHideSwitchLabelButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        popoverDisplayAutoHideSwitchLabelButton?.titleLabel?.minimumScaleFactor = 0.5
        aboutAmbiaMaraButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        aboutAmbiaMaraButton?.titleLabel?.minimumScaleFactor = 0.5
        
        popoverStartImmediatelySwitch?.accessibilityHint = "SLUG-ACC-POPOVER-START-IMMEDIATELY-SWITCH".accessibilityLocalizedVariant
        popoverStartImmediatelySwitchLabelButton?.accessibilityHint = "SLUG-ACC-POPOVER-START-IMMEDIATELY-SWITCH".accessibilityLocalizedVariant
        
        popoverDisplayToolbarSwitch?.accessibilityHint = "SLUG-ACC-POPOVER-SHOW-TOOLBAR-SETTING-SWITCH".accessibilityLocalizedVariant
        popoverDisplayToolbarSwitchLabelButton?.accessibilityHint = "SLUG-ACC-POPOVER-SHOW-TOOLBAR-SETTING-SWITCH".accessibilityLocalizedVariant
        
        popoverDisplayAutoHideSwitch?.accessibilityHint = "SLUG-ACC-POPOVER-AUTO-HIDE-SETTING-HINT".accessibilityLocalizedVariant
        popoverDisplayAutoHideSwitchLabelButton?.accessibilityHint = "SLUG-ACC-POPOVER-AUTO-HIDE-SETTING-HINT".accessibilityLocalizedVariant

        // Voiceover mode does not work well with gestures.
        if UIAccessibility.isVoiceOverRunning {
            toolbarContainerStackView?.isHidden = true
            auotHideIndentLabel?.isHidden = true
            autoHideContainerStackView?.isHidden = true
        } else {
            toolbarContainerStackView?.isHidden = false
            auotHideIndentLabel?.isHidden = false
            autoHideContainerStackView?.isHidden = false
        }

        aboutAmbiaMaraButton?.accessibilityHint = "SLUG-ACC-ABOUT-AMBIAMARA-BUTTON".accessibilityLocalizedVariant

        _selectionFeedbackGenerator = UISelectionFeedbackGenerator()
        _selectionFeedbackGenerator?.prepare()

        if let timerModeSegmentedSwitch = timerModeSegmentedSwitch {
            timerModeSegmentedSwitch.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
            timerModeSegmentedSwitch.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
            timerModeSegmentedSwitch.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.25)], for: .disabled)
            timerModeSegmentedSwitch.selectedSegmentIndex = RVS_AmbiaMara_Settings().stoplightMode ? 1 : 0
            timerModeSegmentedSwitch.accessibilityLabel = "SLUG-ACC-POPOVER-TIMER-MODE-LABEL".accessibilityLocalizedVariant
            timerModeSegmentedSwitch.accessibilityHint = "SLUG-ACC-POPOVER-TIMER-MODE-HINT".accessibilityLocalizedVariant + " " + "SLUG-ACC-POPOVER-TIMER-MODE-HINT-\(timerModeSegmentedSwitch.selectedSegmentIndex)".accessibilityLocalizedVariant
            timerModeSegmentedSwitchChanged(timerModeSegmentedSwitch)
        }
        
        for index in 0..<(timerModeSegmentedSwitch?.numberOfSegments ?? 0) {
            if let image = timerModeSegmentedSwitch?.imageForSegment(at: index) {
                image.accessibilityHint = "SLUG-ACC-POPOVER-TIMER-MODE-SEGMENT-\(index)-LABEL".accessibilityLocalizedVariant
            }
        }
    }

    /* ################################################################## */
    /**
     Called just before the screen disappears.
     
     - parameter inIsAnimated: True, if the disappearance is animated.
    */
    override func viewWillDisappear(_ inAnimated: Bool) {
        super.viewWillDisappear(inAnimated)
        if hapticsAreAvailable {
            _selectionFeedbackGenerator?.selectionChanged()
            _selectionFeedbackGenerator?.prepare()
        }
        myController?.currentDisplayedPopover = nil
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension RVS_SettingsAmbiaMara_PopoverViewController {
    /* ################################################################## */
    /**
     The auto-hide switch, or its label, was hit.
     - parameter inSender: The control that was selected.
    */
    @IBAction func popoverDisplayAutoHideSwitchHit(_ inSender: UIControl) {
        if let switcher = inSender as? UISwitch {
            if hapticsAreAvailable {
                _selectionFeedbackGenerator?.selectionChanged()
                _selectionFeedbackGenerator?.prepare()
            }
            RVS_AmbiaMara_Settings().autoHideToolbar = switcher.isOn
        } else {
            popoverDisplayAutoHideSwitch?.setOn(!(popoverDisplayAutoHideSwitch?.isOn ?? true), animated: true)
            popoverDisplayAutoHideSwitch?.sendActions(for: .valueChanged)
        }
    }

    /* ################################################################## */
    /**
     This dismisses the popover, and shows the about screen.
     - parameter: ignored.
    */
    @IBAction func showAboutScreen(_: Any) {
        myController?.showAboutScreen()
        if hapticsAreAvailable {
            _selectionFeedbackGenerator?.selectionChanged()
            _selectionFeedbackGenerator?.prepare()
        }
        dismiss(animated: false)
    }
    
    /* ################################################################## */
    /**
     The switch or button for start immediately was hit.
     - parameter inSender: the switch or the button.
    */
    @IBAction func popoverStartImmediatelySwitchChanged(_ inSender: UIControl) {
        if let switcher = inSender as? UISwitch {
            if hapticsAreAvailable {
                _selectionFeedbackGenerator?.selectionChanged()
                _selectionFeedbackGenerator?.prepare()
            }
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
            if hapticsAreAvailable {
                _selectionFeedbackGenerator?.selectionChanged()
                _selectionFeedbackGenerator?.prepare()
            }
            
            RVS_AmbiaMara_Settings().displayToolbar = switcher.isOn
            
            popoverDisplayAutoHideSwitch?.isEnabled = RVS_AmbiaMara_Settings().displayToolbar
            popoverDisplayAutoHideSwitchLabelButton?.isEnabled = RVS_AmbiaMara_Settings().displayToolbar
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
        if hapticsAreAvailable {
            _selectionFeedbackGenerator?.selectionChanged()
            _selectionFeedbackGenerator?.prepare()
        }
        RVS_AmbiaMara_Settings().stoplightMode = 0 < inSender.selectedSegmentIndex
    }
}
