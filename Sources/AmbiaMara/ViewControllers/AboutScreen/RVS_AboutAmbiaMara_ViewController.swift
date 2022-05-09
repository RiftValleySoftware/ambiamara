/*
 © Copyright 2018-2022, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_Generic_Swift_Toolbox

/* ###################################################################################################################################### */
// MARK: - About AmbiaMara Screen View Controller -
/* ###################################################################################################################################### */
/**
 This is the view controller for the about screen.
 */
class RVS_AboutAmbiaMara_ViewController: RVS_AmbiaMara_BaseViewController {
    /* ################################################################## */
    /**
     This is the main about text.
    */
    @IBOutlet weak var aboutText: UITextView?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RVS_AboutAmbiaMara_ViewController {
    /* ################################################################## */
    /**
     Called when the hierarchy has loaded. We set up the text and localization.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = navigationItem.title?.localizedVariant
        if let text = aboutText?.text {
            aboutText?.text = NSLocalizedString(text, tableName: "Instructions", comment: "")
        }
    }
}
