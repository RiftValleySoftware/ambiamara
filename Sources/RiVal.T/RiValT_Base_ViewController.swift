/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import CoreHaptics

/* ###################################################################################################################################### */
// MARK: - Baseline View Controller Class -
/* ###################################################################################################################################### */
/**
 This provides basic utilities and UI for all screens in the app.
 */
class RiValT_Base_ViewController: UIViewController {
    /* ############################################################## */
    /**
     This can be overloaded or set, to provide the image to be used as a background gradient.
     */
    private let _backgroundGradientImage: UIImage? = UIImage(named: "Background-Gradient")
    
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
     Called when the view hierarchy has been set up.
     
     We use this to set the background.
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
        
        // Set the gradient background.
        if let view = self.view {
            let backgroundGradientView = UIImageView(image: self._backgroundGradientImage)
            backgroundGradientView.translatesAutoresizingMaskIntoConstraints = false
            backgroundGradientView.contentMode = .scaleToFill
            view.insertSubview(backgroundGradientView, at: 0)
            
            backgroundGradientView.translatesAutoresizingMaskIntoConstraints = false
            backgroundGradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            backgroundGradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            backgroundGradientView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            backgroundGradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
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
}
