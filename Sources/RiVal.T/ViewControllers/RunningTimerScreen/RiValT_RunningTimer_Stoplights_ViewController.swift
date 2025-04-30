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
// MARK: - The Main View Controller for the Stoplights Running Timer -
/* ###################################################################################################################################### */
/**
 This implements the stoplights running timer display.
 */
class RiValT_RunningTimer_Stoplights_ViewController: RiValT_RunningTimer_Base_ViewController {
    /* ############################################################## */
    /**
     The stack view that contains the three stoplights.
     */
    @IBOutlet var stoplightContainerInternalView: UIView?

    /* ############################################################## */
    /**
     This contains the green "stoplight."
     */
    @IBOutlet weak var greenLightImageView: UIImageView?
    
    /* ############################################################## */
    /**
     This contains the yellow "stoplight."
     */
    @IBOutlet weak var yellowLightImageView: UIImageView?
    
    /* ############################################################## */
    /**
     This contains the red "stoplight."
     */
    @IBOutlet weak var redLightImageView: UIImageView?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RiValT_RunningTimer_Stoplights_ViewController {
    /* ############################################################## */
    /**
     This forces the display to refresh.
     */
    override func updateUI() {
        if !(self.timer?.isTimerRunning ?? false) {
            self.redLightImageView?.alpha = 0.25
            self.yellowLightImageView?.alpha = 0.25
            self.greenLightImageView?.alpha = 0.25
        } else if self.timer?.isTimerInFinal ?? false {
            self.redLightImageView?.alpha = 1.0
            self.yellowLightImageView?.alpha = 0.25
            self.greenLightImageView?.alpha = 0.25
        } else if self.timer?.isTimerInWarning ?? false {
            self.redLightImageView?.alpha = 0.25
            self.yellowLightImageView?.alpha = 1.0
            self.greenLightImageView?.alpha = 0.25
        } else if self.timer?.isTimerRunning ?? false {
            self.redLightImageView?.alpha = 0.25
            self.yellowLightImageView?.alpha = 0.25
            self.greenLightImageView?.alpha = 1.0
        } else {
            self.redLightImageView?.alpha = 0.25
            self.yellowLightImageView?.alpha = 0.25
            self.greenLightImageView?.alpha = 0.25
        }
    }
}
