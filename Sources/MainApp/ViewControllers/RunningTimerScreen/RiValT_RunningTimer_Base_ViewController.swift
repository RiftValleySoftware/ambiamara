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
// MARK: - The Main View Controller for the Numerical Running Timer -
/* ###################################################################################################################################### */
/**
 This is a common base class, for the embedded running timers.
 */
class RiValT_RunningTimer_Base_ViewController: RiValT_Base_ViewController {
    /* ################################################################## */
    /**
     This aggregates our available sounds.
     The sounds are files, stored in the resources, so this simply gets them, and stores them as path URIs.
    */
    private var _soundSelection: [String] = []
    
    /* ############################################################## */
    /**
     The embedding controller.
     */
    weak var myContainer: RiValT_RunningTimer_ContainerViewController?
    
    /* ############################################################## */
    /**
     - returns: True, if the timer is currently running.
     */
    private var _isTimerRunning: Bool { false }

    /* ############################################################## */
    /**
     - returns: True, if the current time is at the "starting gate."
     */
    private var _isAtStart: Bool { self.timer?.startingTimeInSeconds ?? 0 == self.timer?.currentTime ?? -1 }

    /* ############################################################## */
    /**
     - returns: True, if the current time is at the end.
     */
    private var _isAtEnd: Bool { 0 == self.timer?.currentTime }

    /* ############################################################## */
    /**
     - returns: True, if the current time is within the "warning" window.
     */
    private var _isWarning: Bool { false }

    /* ############################################################## */
    /**
     - returns: True, if the current time is within the "final countdown" window.
     */
    private var _isFinal: Bool { false }

    /* ############################################################## */
    /**
     The running timer.
     */
    weak var timer: Timer? { myContainer?.timer }
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RiValT_RunningTimer_Base_ViewController {
    /* ############################################################## */
    /**
     Called, when the view hierarchy has been loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backgroundGradientImageView?.removeFromSuperview()
        self.view?.backgroundColor = .clear
        self.view.isUserInteractionEnabled = false
    }
    
    /* ############################################################## */
    /**
     This should be overriden, to refresh the display.
     */
    @objc func updateUI() { }
}
