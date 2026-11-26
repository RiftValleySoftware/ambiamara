/*
 © Copyright 2018-2026, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import CoreHaptics
import RVS_UIKit_Toolbox
import RVS_Generic_Swift_Toolbox

extension UIAlertAction {
    /// Set the spoken name and consequence of an alert action using localization keys.
    func setAccessibility(label: String, hint: String) {
        accessibilityLabel = label.localizedVariant
        accessibilityHint = hint.localizedVariant
    }
}

/* ###################################################################################################################################### */
// MARK: - Special Extension for localization -
/* ###################################################################################################################################### */
extension UIViewController {
    /* ################################################################## */
    /**
     This recursively localizes what it can, in the view hierarchy, starting at the given view.
     
     - parameter inView: The starting view.
     */
    func localizeStuff(_ inView: UIView? = nil) {
        guard let view = inView ?? self.view else { return }
        view.accessibilityLabel = view.accessibilityLabel?.localizedVariant
        view.accessibilityHint = view.accessibilityHint?.localizedVariant
        if let button = view as? UIButton {
            if var buttonConfiguration = button.configuration {
                buttonConfiguration.title = buttonConfiguration.title?.localizedVariant
                buttonConfiguration.subtitle = buttonConfiguration.subtitle?.localizedVariant
                button.configuration = buttonConfiguration
            } else {
                button.setTitle(button.title(for: .normal)?.localizedVariant, for: .normal)
                button.setTitle(button.title(for: .highlighted)?.localizedVariant, for: .highlighted)
                button.setTitle(button.title(for: .disabled)?.localizedVariant, for: .disabled)
            }
        } else if let view = view as? UILabel {
            view.text = view.text?.localizedVariant
        } else if let view = view as? UITextField {
            view.text = view.text?.localizedVariant
            view.placeholder = view.placeholder?.localizedVariant
        } else if let view = view as? UITextView {
            view.text = view.text?.localizedVariant
            if let view = view as? RVS_PlaceholderTextView {
                view.placeholder = view.placeholder.localizedVariant
            }
        } else if let view = inView as? UISegmentedControl {
            for index in 0..<view.numberOfSegments {
                view.setTitle(view.titleForSegment(at: index)?.localizedVariant, forSegmentAt: index)
            }
        }
        
        view.subviews.forEach { self.localizeStuff($0) }
    }
}

/* ###################################################################################################################################### */
// MARK: - Baseline View Controller Class -
/* ###################################################################################################################################### */
/**
 This provides basic utilities and UI for all screens in the app.
 */
class RiValT_Base_ViewController: UIViewController {
    /* ################################################################## */
    /**
     The lightest light, when light.
     */
    private static let _lightModeMax = CGFloat(0.95)

    /* ################################################################## */
    /**
     The darkest dark, when light.
     */
    private static let _lightModeMin = CGFloat(0.58)

    /* ################################################################## */
    /**
     The lightest light, when dark.
     */
    private static let _darkModeMax = CGFloat(0.25)

    /* ################################################################## */
    /**
     The darkest dark, when dark.
     */
    private static let _darkModeMin = CGFloat(0.1)

    /* ################################################################## */
    /**
     This will provide haptic/audio feedback for subtle events.
     */
    private let _selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    
    /* ################################################################## */
    /**
     This will provide haptic/audio feedback for more significant events.
     */
    private let _impactFeedbackGenerator = UIImpactFeedbackGenerator()

    /* ################################################################## */
    /**
     The layer with the background gradient.
     */
    weak var gradientLayer: CALayer?
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension RiValT_Base_ViewController {
    /* ################################################################## */
    /**
     This references the main app delegate.
     
     It's an implicit optional, because the whole shebang goes into the crapper, if it doesn't work.
     */
    weak var appDelegateInstance: RiValT_AppDelegate! { RiValT_AppDelegate.appDelegateInstance }

    /* ################################################################## */
    /**
     This references the iOS app instance of the Watch Delegate class.
     
     It's an implicit optional, because the whole shebang goes into the crapper, if it doesn't work.
     */
    weak var watchDelegate: RiValT_WatchDelegate! { self.appDelegateInstance.watchDelegate }

    /* ################################################################## */
    /**
     This is the application-global timer model.
     
     It's an implicit optional, because the whole shebang goes into the crapper, if it doesn't work.
     */
    weak var timerModel: TimerModel! { self.watchDelegate.timerModel }
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RiValT_Base_ViewController {
    /* ################################################################## */
    /**
     Called when the view hierarchy has been set up.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // This ensures that our navigation bar will be transparent.
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        self.navigationItem.compactAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
        self.navigationItem.standardAppearance = appearance
        
        self._selectionFeedbackGenerator.prepare()
        self._impactFeedbackGenerator.prepare()
        
        self.navigationItem.title = self.navigationItem.title?.localizedVariant
        self.navigationItem.backButtonDisplayMode = .minimal
        self.localizeStuff()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationController = self.navigationController,
           let index = navigationController.viewControllers.firstIndex(of: self),
           index > 0,
           self.navigationItem.leftBarButtonItem == nil {
            // Use a regular item: UIKit's generated Back button retains its own Glass background.
            let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(self.goBack))
            backButton.accessibilityLabel = "SLUG-ACC-BACK-LABEL".localizedVariant
            backButton.accessibilityHint = "SLUG-ACC-BACK-HINT".localizedVariant
            if #available(iOS 26.0, *) {
                backButton.hidesSharedBackground = true
            }
            self.navigationItem.hidesBackButton = true
            self.navigationItem.leftBarButtonItem = backButton
        }
        self.hideBarItemBackgrounds()
    }

    @objc private func goBack() {
        self.navigationController?.popViewController(animated: true)
    }

    /// Configure storyboard items before presentation, and refresh after returning from a popover.
    private func hideBarItemBackgrounds() {
        guard #available(iOS 26.0, *) else { return }
        let buttons = (self.navigationItem.leftBarButtonItems ?? []) + (self.navigationItem.rightBarButtonItems ?? [])
        buttons.forEach { $0.hidesSharedBackground = true }
        self.toolbarItems?.forEach { $0.hidesSharedBackground = true }
        self.navigationController?.toolbar.items?.forEach { $0.hidesSharedBackground = true }
        func configureToolbars(in view: UIView) {
            if let toolbar = view as? UIToolbar {
                toolbar.items?.forEach { $0.hidesSharedBackground = true }
            }
            view.subviews.forEach { configureToolbars(in: $0) }
        }
        configureToolbars(in: self.view)
    }

    // Opening About or a settings popover can temporarily make the editor's Play action unavailable.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.hideBarItemBackgrounds()
        self.watchDelegate?.publishSnapshot()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.watchDelegate?.publishSnapshot()
    }

    /* ################################################################## */
    /**
     Called when the view has laid out its subviews.
     
     We use this to set the background.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.gradientLayer?.removeFromSuperlayer()
        guard !self.isHighContrastMode,
              let view = self.view
        else { return }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            (self.isDarkMode ? UIColor(white: Self._darkModeMax, alpha: 1.0) : UIColor(white: Self._lightModeMax, alpha: 1.0)).cgColor,
            (self.isDarkMode ? UIColor(white: Self._darkModeMin, alpha: 1.0) : UIColor(white: Self._lightModeMin, alpha: 1.0)).cgColor
        ]
        gradientLayer.frame = view.frame
        self.gradientLayer = gradientLayer

        view.layer.insertSublayer(gradientLayer, at: 0)
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RiValT_Base_ViewController {
    /* ################################################################## */
    /**
     Triggers a selection haptic.
     */
    func selectionHaptic() {
        self._selectionFeedbackGenerator.selectionChanged()
        self._selectionFeedbackGenerator.prepare()
    }
    
    /* ################################################################## */
    /**
     Triggers an impact haptic.
     
     - parameter inIntensity: 0.0 -> 1.0, with 0 being the least, and 1 being the most. Optional (default is 0.5)
     */
    func impactHaptic(_ inIntensity: CGFloat = 0.5) {
        self._impactFeedbackGenerator.impactOccurred(intensity: inIntensity)
        self._impactFeedbackGenerator.prepare()
    }
    
    /* ################################################################## */
    /**
     This updates the stored timer model.
     */
    func updateSettings() {
        RiValT_Settings().timerModel = RiValT_AppDelegate.appDelegateInstance?.timerModel.asArray ?? []
        self.watchDelegate?.updateSettings()
    }
}

/* ###################################################################################################################################### */
// MARK: UIPopoverPresentationControllerDelegate Conformance
/* ###################################################################################################################################### */
extension RiValT_Base_ViewController: UIPopoverPresentationControllerDelegate {
    /* ################################################################## */
    /**
     Called to ask if there's any possibility of this being displayed in another way.
     
     - parameter for: The presentation controller we're talking about.
     - returns: No way, Jose.
     */
    func adaptivePresentationStyle(for: UIPresentationController) -> UIModalPresentationStyle { .none }
    
    /* ################################################################## */
    /**
     Called to ask if there's any possibility of this being displayed in another way (when the screen is rotated).
     
     - parameter for: The presentation controller we're talking about.
     - parameter traitCollection: The traits, describing the new orientation.
     - returns: No way, Jose.
     */
    func adaptivePresentationStyle(for: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle { .none }

    /* ################################################################## */
    /**
     Called to allow us to do something before dismissing a popover.
     
     - parameter: ignored.
     
     - returns: True (all the time).
     */
    func popoverPresentationControllerShouldDismissPopover(_: UIPopoverPresentationController) -> Bool { true }
    
    /* ################################################################## */
    /**
     Called to allow us to do something before displaying a popover.
     
     - parameter: ignored.
     */
    func prepareForPopoverPresentation(_: UIPopoverPresentationController) { }
}

/* ###################################################################################################################################### */
// MARK: - Popover sizing -
/* ###################################################################################################################################### */
extension RiValT_Base_ViewController {
    /// Measure visible content without allowing its current frame to compress the requested width.
    func popoverContentWidth(_ content: UIView) -> CGFloat {
        guard !content.isHidden else { return 0 }
        if let stack = content as? UIStackView {
            let children = stack.arrangedSubviews.filter { !$0.isHidden }
            let widths = children.map { popoverContentWidth($0) }
            if stack.axis == .horizontal {
                return widths.reduce(0, +) + stack.spacing * CGFloat(max(0, children.count - 1))
            }
            return widths.max() ?? 0
        }
        if let label = content as? UILabel {
            return label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        }
        return max(0, content.intrinsicContentSize.width)
    }

    /// Use the presenting window, so Split View and window resizing also limit the popover.
    func adaptivePopoverWidth(for contentWidth: CGFloat) -> CGFloat {
        let host = presentingViewController?.viewIfLoaded ?? viewIfLoaded?.window
        let availableWidth = host.map { $0.bounds.inset(by: $0.safeAreaInsets).width } ?? 302
        return min(ceil(max(270, contentWidth)), max(1, availableWidth - 32))
    }
}
