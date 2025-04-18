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
// MARK: - The Main View Controller for the Timer Edit -
/* ###################################################################################################################################### */
/**
 */
class RiValT_EditTimer_ViewController: RiValT_Base_ViewController {
    /* ############################################################## */
    /**
     */
    weak var timer: Timer?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RiValT_EditTimer_ViewController {
    /* ############################################################## */
    /**
     Called when the view has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /* ############################################################## */
    /**
     Called when the view is about to appear
     
     - parameter inIsAnimated: True, if the appearance is animated.
     */
    override func viewWillAppear(_ inIsAnimated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        super.viewWillAppear(inIsAnimated)
    }
}
