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
    private var _backgroundGradientImage: UIImage? = UIImage(named: "Background-Gradient")

    /* ################################################################## */
    /**
     This is the background image view.
     */
    private var _myBackgroundGradientView: UIImageView?

    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This ensures that our navigation bar will be transparent.
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationItem.compactAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
        self.navigationItem.standardAppearance = appearance
        
        guard let view = self.view else { return }   // Oooh... If this fails, we in deep shit.
        
        self._myBackgroundGradientView = UIImageView()
        
        if let backgroundGradientView = self._myBackgroundGradientView {
            backgroundGradientView.image = self._backgroundGradientImage
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
