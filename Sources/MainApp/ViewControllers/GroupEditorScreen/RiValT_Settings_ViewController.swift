/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_Generic_Swift_Toolbox
import RVS_UIKit_Toolbox
import RVS_Checkbox

/* ###################################################################################################################################### */
// MARK: - The Main Page View Controller for the Settings Screen -
/* ###################################################################################################################################### */
/**
 This is a simple popover that shows a list of checkboxes and buttons, affecting global app preferences.
 */
class RiValT_Settings_ViewController: RiValT_Base_ViewController {
    /* ############################################################## */
    /**
     The storyboard ID for instantiating the class.
     */
    static let storyboardID = "RiValT_Settings_ViewController"
    
    /* ############################################################## */
    /**
     The checkbox for the "Start Immediately" preference.
     */
    @IBOutlet weak var startImmediatelyCheckbox: RVS_Checkbox?
    
    /* ############################################################## */
    /**
     The label for the preference. It is actually a button, which toggles the setting.
     */
    @IBOutlet weak var startImmediatelyLabelButton: UIButton?
    
    /* ############################################################## */
    /**
     The checkbox for the "One-Tap Edit" preference.
     */
    @IBOutlet weak var oneTapEditCheckbox: RVS_Checkbox?
    
    /* ############################################################## */
    /**
     The label for the preference. It is actually a button, which toggles the setting.
     */
    @IBOutlet weak var oneTapEditLabelButton: UIButton?
    
    /* ############################################################## */
    /**
     The checkbox for the "Show Toolbar" preference.
     */
    @IBOutlet weak var showToolbarCheckbox: RVS_Checkbox?
    
    /* ############################################################## */
    /**
     The label for the preference. It is actually a button, which toggles the setting.
     */
    @IBOutlet weak var showToolbarLabelButton: UIButton?
    
    /* ############################################################## */
    /**
     The checkbox for the "Auto-Hide Toolbar" preference.
     */
    @IBOutlet weak var autoHideToolbarCheckbox: RVS_Checkbox?
    
    /* ############################################################## */
    /**
     The label for the preference. It is actually a button, which toggles the setting.
     */
    @IBOutlet weak var autoHideToolbarLabelButton: UIButton?
    
    /* ############################################################## */
    /**
     This is a button that brings in the "About" screen.
     */
    @IBOutlet weak var showAboutScreenButton: UIButton?
    
    /* ############################################################## */
    /**
     This is the stack view that has the "Auto-Hide" checkbox. It only appears, if
     */
    @IBOutlet weak var autoHideStackView: UIStackView?
    
    /* ############################################################## */
    /**
     This calculates the size needed for the popover, and sets the property, which causes the popover to change.
     */
    private func _setPreferredContentSize() {
        let height = (self.autoHideStackView?.isHidden ?? true) ? 168 : 206
        
        UIView.animate(withDuration: 0.3) {
            self.preferredContentSize = CGSize(width: 270, height: height)
        }
    }
    
    /* ############################################################## */
    /**
     Called when the view has loaded.
     */
    override func viewDidLoad() {
        self.overrideUserInterfaceStyle = isDarkMode ? .light : .dark
        super.viewDidLoad()
        self.startImmediatelyCheckbox?.isOn = RiValT_Settings().startTimerImmediately
        self.oneTapEditCheckbox?.isOn = RiValT_Settings().oneTapEditing
        self.showToolbarCheckbox?.isOn = RiValT_Settings().displayToolbar
        self.autoHideToolbarCheckbox?.isOn = RiValT_Settings().autoHideToolbar
        self.autoHideStackView?.isHidden = !RiValT_Settings().displayToolbar
        self._setPreferredContentSize()
    }
    
    /* ############################################################## */
    /**
     Called when the preference is changed.
     
     If the calling item is a button, the checkbox is toggled.
     
     - parameter inButton: The button (or chackbox).
     */
    @IBAction func startImmediatelyCheckboxValueChanged(_ inButton: UIControl) {
        guard let checkbox = inButton as? RVS_Checkbox
        else {
            self.selectionHaptic()
            self.startImmediatelyCheckbox?.setOn(!(startImmediatelyCheckbox?.isOn ?? false), animated: true)
            self.startImmediatelyCheckbox?.sendActions(for: .valueChanged)
            return
        }
        
        RiValT_Settings().startTimerImmediately = checkbox.isOn
    }
    
    /* ############################################################## */
    /**
     Called when the preference is changed.
     
     If the calling item is a button, the checkbox is toggled.
     
     - parameter inButton: The button (or chackbox).
     */
    @IBAction func oneTapEditCheckboxValueChanged(_ inButton: UIControl) {
        guard let checkbox = inButton as? RVS_Checkbox
        else {
            self.selectionHaptic()
            self.oneTapEditCheckbox?.setOn(!(oneTapEditCheckbox?.isOn ?? false), animated: true)
            self.oneTapEditCheckbox?.sendActions(for: .valueChanged)
            return
        }
        
        RiValT_Settings().oneTapEditing = checkbox.isOn
    }
    
    /* ############################################################## */
    /**
     Called when the preference is changed.
     
     If the calling item is a button, the checkbox is toggled.
     
     - parameter inButton: The button (or chackbox).
     */
    @IBAction func showToolbarCheckboxValueChanged(_ inButton: UIControl) {
        guard let checkbox = inButton as? RVS_Checkbox
        else {
            self.selectionHaptic()
            self.showToolbarCheckbox?.setOn(!(showToolbarCheckbox?.isOn ?? false), animated: true)
            self.showToolbarCheckbox?.sendActions(for: .valueChanged)
            return
        }
        
        if checkbox.isOn {
            self.autoHideToolbarCheckbox?.setOn(true, animated: true)
            RiValT_Settings().displayToolbar = true
            RiValT_Settings().autoHideToolbar = true
            self.autoHideStackView?.isHidden = false
        } else {
            self.autoHideStackView?.isHidden = true
            RiValT_Settings().displayToolbar = false
            RiValT_Settings().autoHideToolbar = false
            self.displayAdvisoryAlert()
        }
        
        self._setPreferredContentSize()
    }
    
    /* ############################################################## */
    /**
     Called when the preference is changed.
     
     If the calling item is a button, the checkbox is toggled.
     
     - parameter inButton: The button (or chackbox).
     */
    @IBAction func autoHideToolbarCheckboxValueChanged(_ inButton: UIControl) {
        guard let checkbox = inButton as? RVS_Checkbox
        else {
            self.selectionHaptic()
            self.autoHideToolbarCheckbox?.setOn(!(autoHideToolbarCheckbox?.isOn ?? false), animated: true)
            self.autoHideToolbarCheckbox?.sendActions(for: .valueChanged)
            return
        }
        
        RiValT_Settings().autoHideToolbar = checkbox.isOn
    }
    
    /* ############################################################## */
    /**
     Called when the "Show About" button is hit.
     
     - parameter inButton: The button item (ignored).
     */
    @IBAction func aboutButtonHit(_ inButton: UIButton) {
        if let callUpon = (self.presentingViewController as? UINavigationController)?.viewControllers.first as? RiValT_MultiTimer_ViewController {
            self.impactHaptic()
            callUpon.openAboutScreen()
            self.dismiss(animated: true)
        }
    }
    
    /* ############################################################## */
    /**
     This displays the "advisory" alert, if the toolbar pref is turned off.
     */
    func displayAdvisoryAlert() {
        let messageText = "SLUG-ADVISORY-ALERT-BODY"
        
        let alertController = UIAlertController(title: "SLUG-ADVISORY-ALERT-HEADER", message: messageText, preferredStyle: .alert)
        
        // This simply displays the main message as left-aligned.
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left

        let attributedMessageText = NSMutableAttributedString(
            string: messageText,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.callout),
                NSAttributedString.Key.foregroundColor: UIColor.label
            ]
        )
        
        alertController.setValue(attributedMessageText, forKey: "attributedMessage")

        let cancelAction = UIAlertAction(title: "SLUG-OK-BUTTON-TEXT".localizedVariant, style: .cancel, handler: nil)

        alertController.addAction(cancelAction)

        self.impactHaptic(1.0)

        alertController.localizeStuff()

        present(alertController, animated: true, completion: nil)
    }
}
