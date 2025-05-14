/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import CoreHaptics
import RVS_UIKit_Toolbox
import RVS_Generic_Swift_Toolbox

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
     The lightest light, when light.
     */
    static let lightModeMax = CGFloat(0.95)

    /* ################################################################## */
    /**
     The darkest dark, when light.
     */
    static let lightModeMin = CGFloat(0.58)

    /* ################################################################## */
    /**
     The lightest light, when dark.
     */
    static let darkModeMax = CGFloat(0.35)

    /* ################################################################## */
    /**
     The darkest dark, when dark.
     */
    static let darkModeMin = CGFloat(0.1)

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
        self.localizeStuff()
    }
    
    /* ################################################################## */
    /**
     Called when the view has laid out its subviews.
     
     We use this to set the background.
     */
    override func viewDidLayoutSubviews() {
        self.gradientLayer?.removeFromSuperlayer()
        guard !self.isHighContrastMode,
              let view = self.view
        else { return }
        
        // Create a new gradient layer
        let gradientLayer = CAGradientLayer()
        // Set the colors and locations for the gradient layer
        gradientLayer.colors = [
            (self.isDarkMode ? UIColor(white: Self.darkModeMax, alpha: 1.0) : UIColor(white: Self.lightModeMax, alpha: 1.0)).cgColor,
            (self.isDarkMode ? UIColor(white: Self.darkModeMin, alpha: 1.0) : UIColor(white: Self.lightModeMin, alpha: 1.0)).cgColor
        ]
        gradientLayer.frame = view.frame
        self.gradientLayer = gradientLayer

        // Add the gradient layer as a sublayer to the background view
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
