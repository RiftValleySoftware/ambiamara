/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_BasicGCDTimer
import CoreHaptics

/* ###################################################################################################################################### */
// MARK: - The Main Container View Controller for the Running Timer -
/* ###################################################################################################################################### */
/**
 */
class RiValT_RunningTimer_ContainerViewController: UIViewController {
    /* ############################################################## */
    /**
     The number of seconds to wait before the toolbar auto-hides.
     */
    private static let _autoHidePeriodInSeconds = TimeInterval(3)

    /* ############################################################## */
    /**
     The period of the auto-hide duration.
     */
    private static let _autoHideAnimationDurationInSeconds = TimeInterval(0.5)

    /* ############################################################## */
    /**
     Used to instantiate (if necessary).
     */
    static let storyboardID = "RiValT_RunningTimer_ContainerViewController"
    
    /* ############################################################## */
    /**
     Used to fetch in a segue.
     */
    static let segueID = "run-timer"
    
    /* ################################################################## */
    /**
     This will provide haptic/audio feedback for subtle events.
     */
    private let _selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    
    /* ################################################################## */
    /**
     This will provide haptic/audio feedback for more significant events.
     */
    private let _impactFeedbackGenerator = UIImpactFeedbackGenerator()
    
    /* ############################################################## */
    /**
     */
    private var _autoHideTimer: RVS_BasicGCDTimer?

    /* ############################################################## */
    /**
     The running timer.
     */
    weak var timer: Timer?
    
    /* ############################################################## */
    /**
     This contains the running timer for numerical format.
     */
    @IBOutlet weak var numericalTimerContainerView: UIView?

    /* ############################################################## */
    /**
     This is the toolbar that may (or may not) be displayed at the bottom of the screen.
     */
    @IBOutlet weak var controlToolbar: UIToolbar?

    /* ############################################################## */
    /**
     The "Play" or "Pause" toolbar button.
     */
    @IBOutlet weak var playPauseToolbarItem: UIBarButtonItem?

    /* ############################################################## */
    /**
     The "Stop" toolbar button.
     */
    @IBOutlet weak var stopToolbarItem: UIBarButtonItem?

    /* ############################################################## */
    /**
     The "Fast Forward" toolbar button.
     */
    @IBOutlet weak var fastForwardToolbarItem: UIBarButtonItem?

    /* ############################################################## */
    /**
     The "Rewind" toolbar button.
     */
    @IBOutlet weak var rewindToolbarItem: UIBarButtonItem?
    
    /* ############################################################## */
    /**
     Called, when the view hierarchy has been loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.controlToolbar?.isHidden = !RiValT_Settings().displayToolbar
        
        self._selectionFeedbackGenerator.prepare()
        self._impactFeedbackGenerator.prepare()

        let appearance = UIToolbarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.backgroundImage = nil
        self.controlToolbar?.standardAppearance = appearance
        self.controlToolbar?.scrollEdgeAppearance = appearance
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
     Called when the view will rearrange its view hierarchy.
     */
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.showToolbar()
    }

    /* ############################################################## */
    /**
     Called before the screen is hidden.
     
     - parameter inIsAnimated: True, if animated.
     */
    override func viewWillDisappear(_ inIsAnimated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        super.viewWillDisappear(inIsAnimated)
        self._autoHideTimer?.invalidate()
        self._autoHideTimer = nil
    }
    
    /* ################################################################## */
    /**
     Embeds the Numerical Display
     */
    override func prepare(for inSegue: UIStoryboardSegue, sender: Any?) {
        if let destination = inSegue.destination as? RiValT_RunningTimer_Numerical_ViewController {
            destination.myContainer = self
        }
    }

    /* ################################################################## */
    /**
     Triggers a selection haptic.
     */
    func selectionHaptic() {
        self._selectionFeedbackGenerator.selectionChanged()
        self._selectionFeedbackGenerator.prepare()
    }
    
    /* ################################################################## */
    /**
     Triggers an impact haptic.
     
     - parameter inIntensity: 0.0 -> 1.0, with 0 being the least, and 1 being the most. Optional (default is 0.5)
     */
    func impactHaptic(_ inIntensity: CGFloat = 0.5) {
        self._impactFeedbackGenerator.impactOccurred(intensity: inIntensity)
        self._impactFeedbackGenerator.prepare()
    }

    /* ############################################################## */
    /**
     This animates the toolbar into visibility.
     */
    func showToolbar() {
        self._autoHideTimer?.invalidate()
        self._autoHideTimer = nil

        guard RiValT_Settings().displayToolbar,
              RiValT_Settings().autoHideToolbar
        else {
            self.controlToolbar?.alpha = 1.0
            return
        }
        
        self._autoHideTimer = RVS_BasicGCDTimer(timeIntervalInSeconds: Self._autoHidePeriodInSeconds,
                                                delegate: self,
                                                leewayInMilliseconds: 100,
                                                onlyFireOnce: true,
                                                queue: .main, isWallTime: true)
        self._autoHideTimer?.isRunning = true

        if 1.0 > (self.controlToolbar?.alpha ?? 1) {
            self.controlToolbar?.alpha = 0.0
            view.layoutIfNeeded()
            UIView.animate(withDuration: Self._autoHideAnimationDurationInSeconds,
                           animations: { [weak self] in
                                            self?.controlToolbar?.alpha = 1.0
                                            self?.view.layoutIfNeeded()
                                        },
                           completion: nil
            )
        }
    }
    
    /* ############################################################## */
    /**
     This animates the toolbar into invisibility.
     */
    func hideToolbar() {
        self._autoHideTimer?.invalidate()
        self._autoHideTimer = nil
        self.controlToolbar?.alpha = 1.0
        
        guard RiValT_Settings().displayToolbar,
              RiValT_Settings().autoHideToolbar
        else { return }

        view.layoutIfNeeded()
        UIView.animate(withDuration: Self._autoHideAnimationDurationInSeconds,
                       animations: { [weak self] in
                                        self?.controlToolbar?.alpha = 0.0
                                        self?.view.layoutIfNeeded()
                                    },
                       completion: nil
        )
    }
    
    /* ############################################################## */
    /**
     */
    func rewindHit() {
        
    }
    
    /* ############################################################## */
    /**
     */
    func stopHit() {
        
    }
    
    /* ############################################################## */
    /**
     */
    func playPauseHit() {
        
    }

    /* ############################################################## */
    /**
     */
    func fastForwardHit() {
        
    }

    /* ############################################################## */
    /**
     One of the toolbar controls was hit.
     
     - parameter inSender: The item that was activated.
     */
    @IBAction func toolbarItemHit(_ inSender: UIBarButtonItem) {
        self.selectionHaptic()
        if stopToolbarItem == inSender {
            self.stopHit()
        } else if rewindToolbarItem == inSender {
            rewindHit()
        } else if fastForwardToolbarItem == inSender {
            fastForwardHit()
        } else if playPauseToolbarItem == inSender {
            self.playPauseHit()
        }
        
        self.showToolbar()
    }
}

/* ###################################################################################################################################### */
// MARK: RVS_BasicGCDTimerDelegate Conformance
/* ###################################################################################################################################### */
extension RiValT_RunningTimer_ContainerViewController: RVS_BasicGCDTimerDelegate {
    /* ############################################################## */
    /**
     Called when the timer fires.
     
     - parameter inTimer: The timer
     */
    func basicGCDTimerCallback(_ inTimer: RVS_BasicGCDTimer) {
        DispatchQueue.main.async { [weak self] in
            guard self?._autoHideTimer != inTimer else {
                #if DEBUG
                    print("Triggering the auto-hide timer")
                #endif
                self?.hideToolbar()

                return
            }
        }
    }
}
