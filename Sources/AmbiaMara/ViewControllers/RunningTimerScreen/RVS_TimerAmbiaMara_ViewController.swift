/*
 © Copyright 2018-2022, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_Generic_Swift_Toolbox
import RVS_RetroLEDDisplay
import RVS_BasicGCDTimer

/* ###################################################################################################################################### */
// MARK: - Running Timer View Controller -
/* ###################################################################################################################################### */
/**
 This is the view controller for the running timer screen.
 */
class RVS_TimerAmbiaMara_ViewController: UIViewController {
    /* ############################################################## */
    /**
     */
    @IBOutlet weak var digitalDisplayContainerView: UIView?

    /* ############################################################## */
    /**
     */
    @IBOutlet weak var digitsInternalContainerView: UIView?

    /* ############################################################## */
    /**
     */
    @IBOutlet weak var digitalDisplayViewHours: RVS_RetroLEDDigitalDisplay?

    /* ############################################################## */
    /**
     */
    @IBOutlet weak var digitalDisplayViewMinutes: RVS_RetroLEDDigitalDisplay?

    /* ############################################################## */
    /**
     */
    @IBOutlet weak var digitalDisplayViewSeconds: RVS_RetroLEDDigitalDisplay?

    /* ############################################################## */
    /**
     */
    @IBOutlet weak var trafficLightsContainerView: UIStackView?

    /* ############################################################## */
    /**
     */
    @IBOutlet weak var startLightImageView: UIImageView?

    /* ############################################################## */
    /**
     */
    @IBOutlet weak var warnLightImageView: UIImageView?

    /* ############################################################## */
    /**
     */
    @IBOutlet weak var finalLightImageView: UIImageView?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RVS_TimerAmbiaMara_ViewController {
    /* ############################################################## */
    /**
     Called when the hierarchy is loaded.
     */
    override func viewDidLoad() {
        trafficLightsContainerView?.isHidden = !RVS_AmbiaMara_Settings().showStoplights
        digitalDisplayContainerView?.isHidden = !RVS_AmbiaMara_Settings().showDigits
        
        let hours = 0 < RVS_AmbiaMara_Settings().currentTimer.startTimeAsComponents[0] ? RVS_AmbiaMara_Settings().currentTimer.startTimeAsComponents[0] : -2
        let minutes = 0 < RVS_AmbiaMara_Settings().currentTimer.startTimeAsComponents[1] ? RVS_AmbiaMara_Settings().currentTimer.startTimeAsComponents[1] : 0 < hours ? 0 : -2
        let seconds = 0 < RVS_AmbiaMara_Settings().currentTimer.startTimeAsComponents[2] ? RVS_AmbiaMara_Settings().currentTimer.startTimeAsComponents[2] : 0 < hours || 0 < minutes ? 0 : -2
        
        if RVS_AmbiaMara_Settings().showDigits {
            digitalDisplayContainerView?.autoLayoutAspectConstraint(aspectRatio: 0.2)?.isActive = true
            digitalDisplayViewHours?.radix = 10
            digitalDisplayViewMinutes?.radix = 10
            digitalDisplayViewSeconds?.radix = 10
        }
        
        setTimeAs(hours: hours, minutes: minutes, seconds: seconds)
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RVS_TimerAmbiaMara_ViewController {
    func setTimeAs(hours inHours: Int, minutes inMinutes: Int, seconds inSeconds: Int) {
        if RVS_AmbiaMara_Settings().showDigits {
            digitalDisplayViewMinutes?.hasLeadingZeroes = 0 < inHours
            digitalDisplayViewSeconds?.hasLeadingZeroes = 0 < inHours || 0 < inMinutes
            digitalDisplayViewHours?.value = inHours
            digitalDisplayViewMinutes?.value = inMinutes
            digitalDisplayViewSeconds?.value = inSeconds
        }
        
        if RVS_AmbiaMara_Settings().showStoplights {
            let hours = max(0, inHours)
            let minutes = max(0, inMinutes)
            let seconds = max(0, inSeconds)
            let totalTime = (hours * 60 * 60) + (minutes * 60) + seconds
            if totalTime >= RVS_AmbiaMara_Settings().currentTimer.startTime {
                startLightImageView?.alpha = 1.0
                warnLightImageView?.alpha = 0.15
                finalLightImageView?.alpha = 0.15
            } else if totalTime >= RVS_AmbiaMara_Settings().currentTimer.warnTime {
                startLightImageView?.alpha = 0.15
                warnLightImageView?.alpha = 1.0
                finalLightImageView?.alpha = 0.15
            } else if totalTime >= RVS_AmbiaMara_Settings().currentTimer.finalTime {
                startLightImageView?.alpha = 0.15
                warnLightImageView?.alpha = 0.15
                finalLightImageView?.alpha = 1.0
            }
        }
    }
}
