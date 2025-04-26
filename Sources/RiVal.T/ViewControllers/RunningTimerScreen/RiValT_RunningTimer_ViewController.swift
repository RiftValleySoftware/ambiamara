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
// MARK: - The Main View Controller for the Running Timer -
/* ###################################################################################################################################### */
/**
 */
class RiValT_RunningTimer_ViewController: RiValT_Base_ViewController {
    /* ############################################################## */
    /**
     Used to instantiate (if necessary).
     */
    static let storyboardID = "RiValT_RunningTimer_ViewController"
    
    /* ############################################################## */
    /**
     Used to fetch in a segue.
     */
    static let segueID = "run-timer"

    /* ############################################################## */
    /**
     The running timer.
     */
    weak var timer: Timer?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RiValT_RunningTimer_ViewController {
    /* ############################################################## */
    /**
     Called, when the view hierarchy has been loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /* ############################################################## */
    /**
     Called before the screen is displayed.
     
     - parameter inIsAnimated: True, if animated.
     */
    override func viewWillAppear(_ inIsAnimated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        super.viewWillAppear(inIsAnimated)
    }
    
    /* ############################################################## */
    /**
     Called before the screen is hidden.
     
     - parameter inIsAnimated: True, if animated.
     */
    override func viewWillDisappear(_ inIsAnimated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        super.viewWillDisappear(inIsAnimated)
    }
}
