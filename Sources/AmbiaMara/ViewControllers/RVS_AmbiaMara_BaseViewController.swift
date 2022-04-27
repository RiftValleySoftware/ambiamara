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
// MARK: - Base Class View Controller -
/* ###################################################################################################################################### */
/**
 This is a base class that provides a background gradient, and "watermark" image.
 It should be the base for all screens.
 */
class RVS_AmbiaMara_BaseViewController: UIViewController {
    /* ############################################################## */
    /**
     The alpha to use for normal contrast (center image "watermark").
     */
    private static let _watermarkAlpha = CGFloat(0.015)
    
    /* ############################################################## */
    /**
     The sizing coefficient to use. This compares against the screen size (center image "watermark").
     */
    private static let _watermarkSizeCoefficient = CGFloat(0.6)
    
    /* ############################################################## */
    /**
     This can be overloaded or set, to provide the image to be used as a background gradient.
     */
    private var _backgroundGradientImage: UIImage? = UIImage(named: "Background-Gradient")
    
    /* ############################################################## */
    /**
     This can be overloaded or set, to provide the image to be used as a "watermark."
     */
    private var _watermarkImage: UIImage? = UIImage(named: "CenterImage")

    /* ################################################################## */
    /**
     This is the background image view.
     */
    private var _myBackgroundGradientView: UIImageView?

    /* ################################################################## */
    /**
     This is the background center image view.
     */
    private var _myCenterImageView: UIImageView?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RVS_AmbiaMara_BaseViewController {
    /* ################################################################## */
    /**
     Called when the view hierarchy has been completed.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tabBarItemTitle = tabBarItem?.title?.localizedVariant,
           !tabBarItemTitle.isEmpty {
            tabBarController?.navigationItem.title = tabBarItemTitle
        } else {
            navigationItem.title = (navigationItem.title ?? "ERROR").localizedVariant
        }

        if let view = view {
            _myBackgroundGradientView = UIImageView()
            if let backgroundGradientView = _myBackgroundGradientView,
               let backGroundImage = _backgroundGradientImage {
                backgroundGradientView.image = backGroundImage
                backgroundGradientView.translatesAutoresizingMaskIntoConstraints = false
                backgroundGradientView.contentMode = .scaleToFill
                view.insertSubview(backgroundGradientView, at: 0)
                
                backgroundGradientView.translatesAutoresizingMaskIntoConstraints = false
                backgroundGradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
                backgroundGradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
                backgroundGradientView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                backgroundGradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                
                // No watermark for high contrast or reduced transparency mode.
                if !isHighContrastMode,
                   !isReducedTransparencyMode {
                    _myCenterImageView = UIImageView()
                    if let centerImageView = _myCenterImageView,
                       let centerImage = _watermarkImage {
                        centerImageView.image = centerImage
                        centerImageView.alpha = Self._watermarkAlpha
                        centerImageView.translatesAutoresizingMaskIntoConstraints = false
                        centerImageView.contentMode = .scaleAspectFit
                        centerImageView.tintColor = .label
                        backgroundGradientView.insertSubview(centerImageView, at: 1)

                        centerImageView.centerXAnchor.constraint(equalTo: backgroundGradientView.centerXAnchor).isActive = true
                        centerImageView.centerYAnchor.constraint(equalTo: backgroundGradientView.centerYAnchor).isActive = true
                        
                        centerImageView.widthAnchor.constraint(lessThanOrEqualTo: backgroundGradientView.widthAnchor,
                                                               multiplier: Self._watermarkSizeCoefficient).isActive = true
                        centerImageView.heightAnchor.constraint(lessThanOrEqualTo: backgroundGradientView.heightAnchor,
                                                                multiplier: Self._watermarkSizeCoefficient).isActive = true

                        if let aspectConstraint = centerImageView.autoLayoutAspectConstraint(aspectRatio: 1.0) {
                            aspectConstraint.isActive = true
                            backgroundGradientView.addConstraint(aspectConstraint)
                        }
                    }
                }
            }
        }
    }
}
