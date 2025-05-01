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

/* ###################################################################################################################################### */
// MARK: - The Main View Controller for the "About" screen -
/* ###################################################################################################################################### */
/**
 */
class RiValT_About_ViewController: RiValT_Base_ViewController {
    /* ################################################################## */
    /**
     The app icon is displayed here.
     */
    @IBOutlet weak var appIconImageView: UIImageView?
    
    /* ################################################################## */
    /**
     This is the main about text.
     */
    @IBOutlet weak var aboutText: UITextView?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RiValT_About_ViewController {
    /* ############################################################## */
    /**
     Called when the view hierarchy has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        if let image = Bundle.main.appIcon {
            appIconImageView?.image = image
        } else {
            appIconImageView?.isHidden = true
        }
        navigationItem.title = String(format: "SLUG-NAME-VERSION-FORMAT".localizedVariant, Bundle.main.appDisplayName, Bundle.main.appVersionString, Bundle.main.appVersionBuildString)
    }
}
