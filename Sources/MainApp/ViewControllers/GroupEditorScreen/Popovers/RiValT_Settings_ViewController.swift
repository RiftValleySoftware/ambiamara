/*
 © Copyright 2018-2026, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import Combine
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
     The controller that "owns" this instance.
     */
    weak var myOwner: RiValT_GroupEditor_ViewController?
    
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
    /// The checkbox for the "Combine Timers" preference.
    @IBOutlet weak var combineTimersCheckbox: RVS_Checkbox?
    
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
     This is the stack view that has the "Show Toolbar" pref.
     */
    @IBOutlet weak var showToolbarStackView: UIStackView?
    
    /* ############################################################## */
    /**
     This is the stack view that has the "Auto-Hide" checkbox. It only appears, if the "Show Toolbar" pref is on.
     */
    @IBOutlet weak var autoHideStackView: UIStackView?
    
    /* ############################################################## */
    /**
     This calculates the size needed for the popover, and sets the property, which causes the popover to change.
     */
    private func _setPreferredContentSize() {
        guard let stack = self.showAboutScreenButton?.superview as? UIStackView else { return }
        let width = adaptivePopoverWidth(for: popoverContentWidth(stack) + 32)
        // UIButton needs an explicit wrapping width to report a multiline intrinsic height.
        for row in stack.arrangedSubviews where !row.isHidden {
            let buttons = (row as? UIStackView)?.arrangedSubviews.compactMap { $0 as? UIButton }
                ?? [row as? UIButton].compactMap { $0 }
            for button in buttons {
                let siblingsWidth = (row as? UIStackView).map { rowStack in
                    rowStack.arrangedSubviews.filter { $0 !== button && !$0.isHidden }
                        .map { popoverContentWidth($0) }.reduce(0, +) + rowStack.spacing
                } ?? 0
                let labelWidth = max(1, width - 32 - siblingsWidth)
                if button.titleLabel?.preferredMaxLayoutWidth != labelWidth {
                    button.titleLabel?.preferredMaxLayoutWidth = labelWidth
                    button.invalidateIntrinsicContentSize()
                }
            }
        }
        let height = stack.systemLayoutSizeFitting(
            CGSize(width: width - 32, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height + 32
        guard preferredContentSize != CGSize(width: width, height: ceil(height)) else { return }
        
        UIView.animate(withDuration: 0.3) {
            self.preferredContentSize = CGSize(width: width, height: ceil(height))
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
        self.combineTimersCheckbox?.isOn = RiValT_Settings().combineTimers
        self.showToolbarCheckbox?.isOn = RiValT_Settings().displayToolbar
        self.autoHideToolbarCheckbox?.isOn = RiValT_Settings().autoHideToolbar
        if ProcessInfo().isMacCatalystApp {
            self.autoHideStackView?.isHidden = true
            self.showToolbarStackView?.isHidden = true
        } else {
            self.autoHideStackView?.isHidden = !RiValT_Settings().displayToolbar
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad, !ProcessInfo.processInfo.isMacCatalystApp {
            addWatchRemoteSetting()
        }
        if let stack = self.showAboutScreenButton?.superview as? UIStackView {
            configureWrapping(in: stack)
        }
        self._setPreferredContentSize()
    }

    /// Keep translated settings readable when the window cannot accommodate their natural width.
    private func configureWrapping(in view: UIView) {
        if let button = view as? UIButton {
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.lineBreakMode = .byWordWrapping
        }
        view.subviews.forEach { configureWrapping(in: $0) }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _setPreferredContentSize()
    }
    
    private var watchStatusObserver: AnyCancellable?

    /// On iPad, turning on the remote makes this host discoverable by its short Bluetooth name.
    private func addWatchRemoteSetting() {
        guard let about = showAboutScreenButton, let stack = about.superview as? UIStackView,
              let index = stack.arrangedSubviews.firstIndex(of: about) else { return }
        let remote = RiValT_BluetoothRemote.shared
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        let toggle = UISwitch()
        toggle.setContentCompressionResistancePriority(.required, for: .horizontal)
        toggle.setContentHuggingPriority(.required, for: .horizontal)
        toggle.isOn = remote.isEnabled
        toggle.accessibilityLabel = "SLUG-ACC-WATCH-REMOTE-LABEL".localizedVariant
        toggle.accessibilityHint = "SLUG-ACC-WATCH-REMOTE-HINT".localizedVariant
        watchStatusObserver = remote.$hostingIssue.sink { [weak self, weak label, weak toggle] issue in
            if let issue {
                label?.text = issue
            } else if toggle?.isOn == true {
                label?.text = String(format: "SLUG-WATCH-REMOTE-NAME".localizedVariant, remote.hostName)
            } else {
                label?.text = "SLUG-WATCH-REMOTE".localizedVariant
            }
            self?.view.setNeedsLayout()
        }
        toggle.addAction(UIAction { [weak toggle] _ in
            if let toggle { remote.setEnabled(toggle.isOn) }
        }, for: .valueChanged)
        let row = UIStackView(arrangedSubviews: [label, toggle])
        row.alignment = .center
        row.spacing = 8
        stack.insertArrangedSubview(row, at: index)
        row.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
    }

    /* ############################################################## */
    /**
     Called after the popover has disappeared.
     
     - parameter inIsAnimated: True, if the disappearance was animated.
     */
    override func viewDidDisappear(_ inIsAnimated: Bool) {
        super.viewDidDisappear(inIsAnimated)
        self.myOwner?.updateToolbar()
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
    /// Save the checkbox state, or toggle the checkbox when its label is tapped.
    @IBAction func combineTimersCheckboxValueChanged(_ inButton: UIControl) {
        guard let checkbox = inButton as? RVS_Checkbox
        else {
            self.selectionHaptic()
            self.combineTimersCheckbox?.setOn(!(combineTimersCheckbox?.isOn ?? false), animated: true)
            self.combineTimersCheckbox?.sendActions(for: .valueChanged)
            return
        }

        RiValT_Settings().combineTimers = checkbox.isOn
        self.myOwner?.collectionView?.reloadData()
        self.watchDelegate?.publishSnapshot()
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
        if let callUpon = (self.presentingViewController as? UINavigationController)?.viewControllers.first as? RiValT_GroupEditor_ViewController {
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
        let messageText = "SLUG-ADVISORY-ALERT-BODY".localizedVariant
        
        let alertController = UIAlertController(title: "SLUG-ADVISORY-ALERT-HEADER".localizedVariant, message: messageText, preferredStyle: .alert)

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

        cancelAction.setAccessibility(label: "SLUG-ACC-TOOLBAR-ADVISORY-OK-LABEL", hint: "SLUG-ACC-TOOLBAR-ADVISORY-OK-HINT")
        alertController.addAction(cancelAction)

        self.impactHaptic(1.0)

        alertController.localizeStuff()

        self.present(alertController, animated: true, completion: nil)
    }
}
