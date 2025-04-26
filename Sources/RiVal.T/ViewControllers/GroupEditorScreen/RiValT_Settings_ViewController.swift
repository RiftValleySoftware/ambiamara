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
 */
class RiValT_Settings_ViewController: RiValT_Base_ViewController {
    /* ############################################################## */
    /**
     The storyboard ID for instantiating the class.
     */
    static let storyboardID = "RiValT_Settings_ViewController"
    
    /* ############################################################## */
    /**
     */
    @IBOutlet weak var startImmediatelyCheckbox: RVS_Checkbox?
    
    /* ############################################################## */
    /**
     */
    @IBOutlet weak var startImmediatelyLabelButton: UIButton?
    
    /* ############################################################## */
    /**
     */
    @IBOutlet weak var oneTapEditCheckbox: RVS_Checkbox?
    
    /* ############################################################## */
    /**
     */
    @IBOutlet weak var oneTapEditLabelButton: UIButton?

    /* ############################################################## */
    /**
     */
    @IBOutlet weak var showToolbarCheckbox: RVS_Checkbox?
    
    /* ############################################################## */
    /**
     */
    @IBOutlet weak var showToolbarLabelButton: UIButton?
    
    /* ############################################################## */
    /**
     */
    @IBOutlet weak var autoHideToolbarCheckbox: RVS_Checkbox?
    
    /* ############################################################## */
    /**
     */
    @IBOutlet weak var autoHideToolbarLabelButton: UIButton?

    /* ############################################################## */
    /**
     */
    @IBOutlet weak var autoHideStackView: UIStackView?
    
    /* ############################################################## */
    /**
     This calculates the size needed for the popover, and sets the property, which causes the popover to change.
     */
    private func _setPreferredContentSize() {
        let height = (self.autoHideStackView?.isHidden ?? true) ? 138 : 176
        
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
        }
        
        self._setPreferredContentSize()
    }
    
    /* ############################################################## */
    /**
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
}
