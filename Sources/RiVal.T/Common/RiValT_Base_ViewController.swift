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
    
    /* ############################################################## */
    /**
     This can be overloaded or set, to provide the image to be used as a background gradient.
     */
    var backgroundGradientImage: UIImage? = UIImage(named: "Background-Gradient")
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RiValT_Base_ViewController {
    /* ################################################################## */
    /**
     Called when the view hierarchy has been set up.
     
     We use this to set the background.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.navigationItem.title?.localizedVariant

        // This ensures that our navigation bar will be transparent.
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        self.navigationItem.compactAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
        self.navigationItem.standardAppearance = appearance
        
        self._selectionFeedbackGenerator.prepare()
        self._impactFeedbackGenerator.prepare()
        
        // Set the gradient background.
        if let view = self.view {
            let backgroundGradientView = UIImageView(image: self.backgroundGradientImage)
            backgroundGradientView.translatesAutoresizingMaskIntoConstraints = false
            backgroundGradientView.contentMode = .scaleToFill
            view.insertSubview(backgroundGradientView, at: 0)
            backgroundGradientView.translatesAutoresizingMaskIntoConstraints = false
            backgroundGradientView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            backgroundGradientView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            backgroundGradientView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            backgroundGradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        
        self.localizeStuff()
    }
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension RiValT_Base_ViewController {
    /* ################################################################## */
    /**
     This is the application-global timer model.
     
     It's an implicit optional, because the whole shebang goes into the crapper, if it doesn't work.
     */
    weak var timerModel: TimerModel! { RiValT_AppDelegate.appDelegateInstance?.timerModel }
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
