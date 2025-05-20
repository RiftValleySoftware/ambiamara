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
 
 It displays three round circles, and highlights each one, as that threshold is reached.
 */
class RiValT_RunningTimer_Stoplights_ViewController: RiValT_RunningTimer_Base_ViewController {
    /* ############################################################## */
    /**
     The opacity, when the display is disabled.
     */
    private static let _disabledOpacity = CGFloat(0.25)

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
        let duration = self.timer?.isTimerRunning ?? false ? 0.5 : 0
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations: {
            if self.timer?.isTimerInAlarm ?? false {
                self.redLightImageView?.alpha = 1.0
                self.yellowLightImageView?.alpha = 1.0
                self.greenLightImageView?.alpha = 1.0
            } else if !(self.timer?.isTimerRunning ?? false) {
                self.redLightImageView?.alpha = Self._disabledOpacity
                self.yellowLightImageView?.alpha = Self._disabledOpacity
                self.greenLightImageView?.alpha = Self._disabledOpacity
            } else if self.timer?.isTimerInFinal ?? false {
                self.redLightImageView?.alpha = 1.0
                self.yellowLightImageView?.alpha = Self._disabledOpacity
                self.greenLightImageView?.alpha = Self._disabledOpacity
            } else if self.timer?.isTimerInWarning ?? false {
                self.redLightImageView?.alpha = Self._disabledOpacity
                self.yellowLightImageView?.alpha = 1.0
                self.greenLightImageView?.alpha = Self._disabledOpacity
            } else if self.timer?.isTimerRunning ?? false {
                self.redLightImageView?.alpha = Self._disabledOpacity
                self.yellowLightImageView?.alpha = Self._disabledOpacity
                self.greenLightImageView?.alpha = 1.0
            } else {
                self.redLightImageView?.alpha = Self._disabledOpacity
                self.yellowLightImageView?.alpha = Self._disabledOpacity
                self.greenLightImageView?.alpha = Self._disabledOpacity
            }
        })
    }
}
