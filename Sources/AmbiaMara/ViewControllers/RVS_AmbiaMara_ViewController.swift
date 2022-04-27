/*
 © Copyright 2018-2022, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_Generic_Swift_Toolbox

/* ###################################################################################################################################### */
// MARK: - Initial View Controller -
/* ###################################################################################################################################### */
/**
 */
class RVS_AmbiaMara_ViewController: RVS_AmbiaMara_BaseViewController {
    /* ################################################################## */
    /**
     The period that we use for the "fade in" animation.
    */
    private static let _fadeAnimationPeriod = CGFloat(1.0)

    /* ################################################################## */
    /**
     The "startup" logo that we fade out.
    */
    @IBOutlet weak var startupLogo: UIImageView?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RVS_AmbiaMara_ViewController {
    /* ############################################################## */
    /**
     Called when the view is about to appear.
     We use this to start the "fade in" animation.
     
     - parameter inIsAnimated: True, if the transition is to be animated (ignored, but sent to the superclass).
     */
    override func viewWillAppear(_ inIsAnimated: Bool) {
        super.viewWillAppear(inIsAnimated)
        fadeInAnimation()
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RVS_AmbiaMara_ViewController {
    /* ################################################################## */
    /**
     This handles the "fade in" animation. This only happens, the first time.
     */
    func fadeInAnimation() {
        view.layoutIfNeeded()
        if let startupLogo = startupLogo {
            startupLogo.alpha = 1.0
            view.layoutIfNeeded()
            UIView.animate(withDuration: Self._fadeAnimationPeriod,
                           animations: { [weak self] in
                                            startupLogo.alpha = 0.0
                                            self?.view.layoutIfNeeded()
                                        },
                           completion: { [weak self] _ in
                                            DispatchQueue.main.async {
                                                startupLogo.removeFromSuperview()
                                                self?.startupLogo = nil
                                            }
                                        }
            )
        }
    }
}
