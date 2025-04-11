/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit

/* ###################################################################################################################################### */
// MARK: - Baseline View Controller Class -
/* ###################################################################################################################################### */
/**
 
 */
class RiValT_Base_ViewController: UIViewController {
    /* ############################################################## */
    /**
     This can be overloaded or set, to provide the image to be used as a background gradient.
     */
    private let _backgroundGradientImage: UIImage? = UIImage(named: "Background-Gradient")

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
