/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import AVKit
import RVS_Generic_Swift_Toolbox
import RVS_UIKit_Toolbox
import RVS_BasicGCDTimer

/* ###################################################################################################################################### */
// MARK: - The Main View Controller for the Numerical Running Timer -
/* ###################################################################################################################################### */
/**
 */
class RiValT_RunningTimer_Base_ViewController: RiValT_Base_ViewController {
    /* ############################################################## */
    /**
     The animation duration of the screen flashes.
     */
    private static let _flashDurationInSeconds = TimeInterval(0.75)

    /* ################################################################## */
    /**
     This is the audio player (for playing alarm sounds).
    */
    private var _audioPlayer: AVAudioPlayer!
    
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
     The view across the back that is filled with a color, during a "flash."
     */
    @IBOutlet weak var flasherView: UIView?
    
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
     Called before the screen is displayed.
     
     - parameter inIsAnimated: True, if animated.
     */
    override func viewWillAppear(_ inIsAnimated: Bool) {
//        Commented out, while developing.
//        self.navigationController?.isNavigationBarHidden = true
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
    
    /* ############################################################## */
    /**
     This should be overriden, to refresh the display.
     */
    @objc func updateUI() { }
    
    /* ############################################################## */
    /**
     This flashes the screen briefly cyan (pause)
     */
    func flashCyan() {
        self.flasherView?.backgroundColor = UIColor(named: "Paused-Color")
        self.impactHaptic(1.0)
        UIView.animate(withDuration: Self._flashDurationInSeconds,
                       animations: { [weak self] in
                                        self?.flasherView?.backgroundColor = .clear
                                    },
                       completion: nil
        )
    }
    
    /* ############################################################## */
    /**
     This flashes the screen briefly green
     */
    func flashGreen() {
        self.flasherView?.backgroundColor = UIColor(named: "Start-Color")
        self.impactHaptic()
        UIView.animate(withDuration: Self._flashDurationInSeconds,
                       animations: { [weak self] in
                                        self?.flasherView?.backgroundColor = .clear
                                    },
                       completion: nil
        )
    }

    /* ############################################################## */
    /**
     This flashes the screen briefly yellow
     */
    func flashYellow() {
        self.flasherView?.backgroundColor = UIColor(named: "Warn-Color")
        self.impactHaptic()
        UIView.animate(withDuration: Self._flashDurationInSeconds,
                       animations: { [weak self] in
                                        self?.flasherView?.backgroundColor = .clear
                                    },
                       completion: nil
        )
    }

    /* ############################################################## */
    /**
     This flashes the screen briefly red
     */
    func flashRed(_ inIsHard: Bool = false) {
        self.impactHaptic(inIsHard ? 1.0 : 0.5)
        self.flasherView?.backgroundColor = UIColor(named: "Final-Color")
        UIView.animate(withDuration: Self._flashDurationInSeconds,
                       animations: { [weak self] in
                                        self?.flasherView?.backgroundColor = .clear
                                    },
                       completion: nil
        )
    }
}
