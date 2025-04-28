/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import AVKit
import RVS_BasicGCDTimer
import CoreHaptics

/* ###################################################################################################################################### */
// MARK: - The Main Container View Controller for the Running Timer -
/* ###################################################################################################################################### */
/**
 This implements a "wrapper" for the running timer views.
 
 It embeds the timer display (either numerical, circular, or stoplight), and handles the user interaction (the timer embed is read-only).
 
 This view has the timer instance, which is referenced by the embedded views.
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
     The animation duration of the screen flashes.
     */
    private static let _flashDurationInSeconds = TimeInterval(0.75)

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
     The timer for automatically hiding the toolbar.
     */
    private var _autoHideTimer: RVS_BasicGCDTimer?

    /* ################################################################## */
    /**
     This is the audio player (for playing alarm sounds).
    */
    private var _audioPlayer: AVAudioPlayer!
    
    /* ############################################################## */
    /**
     The running timer.
     */
    weak var timer: Timer?
    
    /* ############################################################## */
    /**
     This is our numerical display instance.
     */
    weak var numericalDisplayController: RiValT_RunningTimer_Numerical_ViewController?
    
    /* ############################################################## */
    /**
     The view across the back that is filled with a color, during a "flash."
     */
    @IBOutlet weak var flasherView: UIView?
    
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
     The single-tap gesture recognizer.
     */
    @IBOutlet var singleTapGestureRecognizer: UITapGestureRecognizer?
    
    /* ############################################################## */
    /**
     The double-tap gesture recognizer.
     */
    @IBOutlet var doubleTapGestureRecognizer: UITapGestureRecognizer?
    
    /* ############################################################## */
    /**
     The left-swipe gesture recognizer.
     */
    @IBOutlet var leftSwipeGestureRecognizer: UISwipeGestureRecognizer?
    
    /* ############################################################## */
    /**
     The right-swipe gesture recognizer.
     */
    @IBOutlet var rightSwipeGestureRecognizer: UISwipeGestureRecognizer?
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension RiValT_RunningTimer_ContainerViewController {
    /* ############################################################## */
    /**
     If we are in a multi-timer group, this is the next timer.
     */
    var nextTimer: Timer? {
        guard let group = self.timer?.group,
              let myIndex = self.timer?.indexPath?.item,
              myIndex < group.count - 1
        else { return nil }
        
        return group[myIndex + 1]
    }
    
    /* ############################################################## */
    /**
     If we are in a multi-timer group, this how many timers.
     */
    var count: Int { self.timer?.group?.count ?? 0 }
    
    /* ############################################################## */
    /**
     If we are in a multi-timer group, this is the first timer.
     */
    var firstTimer: Timer? { self.timer?.group?.first }

    /* ############################################################## */
    /**
     If we are in a multi-timer group, this is the last timer.
     */
    var lastTimer: Timer? { self.timer?.group?.last }
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RiValT_RunningTimer_ContainerViewController {
    /* ############################################################## */
    /**
     Called, when the view hierarchy has been loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.controlToolbar?.isHidden = !RiValT_Settings().displayToolbar
        
        self.view?.backgroundColor = isHighContrastMode ? .systemBackground : .black
        
        self._selectionFeedbackGenerator.prepare()
        self._impactFeedbackGenerator.prepare()

        let appearance = UIToolbarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.backgroundImage = nil
        self.controlToolbar?.standardAppearance = appearance
        self.controlToolbar?.scrollEdgeAppearance = appearance
        
        if let tapper = self.singleTapGestureRecognizer,
           let doubleTapper = self.doubleTapGestureRecognizer {
            tapper.require(toFail: doubleTapper)
        }
        
        self.timer?.tickHandler = self.tickHandler
        self.timer?.transitionHandler = self.transitionHandler
        if self.timer?.isTimerPaused ?? false {
            self.playPauseToolbarItem?.image = UIImage(systemName: "play.fill")
        } else {
            self.playPauseToolbarItem?.image = UIImage(systemName: "pause.fill")
        }
    }
    
    /* ############################################################## */
    /**
     Called before the screen is displayed.
     
     - parameter inIsAnimated: True, if animated.
     */
    override func viewWillAppear(_ inIsAnimated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        super.viewWillAppear(inIsAnimated)
        if RiValT_Settings().startTimerImmediately {
            self.flashGreen()
            self.timer?.start()
        }
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
     This will assign us as the "owner" of our embedded displays.
     
     - parameter inSegue: The segue instance.
     - parameter sender: Ignored.
     */
    override func prepare(for inSegue: UIStoryboardSegue, sender: Any?) {
        if let destination = inSegue.destination as? RiValT_RunningTimer_Numerical_ViewController {
            destination.myContainer = self
            self.numericalDisplayController = destination
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RiValT_RunningTimer_ContainerViewController {
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
        guard RiValT_Settings().displayToolbar
        else {
            self.controlToolbar?.isHidden = true
            self.controlToolbar?.alpha = 1.0
            return
        }
        
        self.controlToolbar?.isHidden = false
        if RiValT_Settings().autoHideToolbar {
            self._autoHideTimer?.invalidate()
            self._autoHideTimer = nil

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
     This resets the timer to the start.
     */
    func rewindHit() {
        self.timer?.stop()
        self.playPauseToolbarItem?.image = UIImage(systemName: "play.fill")
    }
    
    /* ############################################################## */
    /**
     This stops the timer, and dismisses the screen.
     */
    func stopHit() {
        self.flashRed(true)
        if let timer = self.timer {
            self.timer = nil
            timer.transitionHandler = nil
            timer.tickHandler = nil
            timer.stop()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    /* ############################################################## */
    /**
     This either pauses a running timer, resumes a paused timer, or starts a stopped timer.
     */
    func playPauseHit() {
        if self.timer?.isTimerRunning ?? false {
            self.flashCyan()
            self.timer?.pause()
            self.playPauseToolbarItem?.image = UIImage(systemName: "play.fill")
        } else {
            if self.timer?.isTimerPaused ?? false {
                self.flashGreen()
                self.timer?.resume()
            } else if let timer = self.firstTimer {
                self.timer = nil
                timer.tickHandler = self.tickHandler
                timer.transitionHandler = self.transitionHandler
                timer.isSelected = true
                self.timer = timer
                self.timer?.start()
            }
            self.playPauseToolbarItem?.image = UIImage(systemName: "pause.fill")
        }
    }

    /* ############################################################## */
    /**
     This pushes the timer to the end (alarm state).
     */
    func fastForwardHit() {
        self.timer?.end()
        self.playPauseToolbarItem?.image = UIImage(systemName: "play.fill")
    }
    
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
    
    /* ############################################################## */
    /**
     Called when this timer reaches the end.
     */
    func alarmReached() {
        if let timer = self.nextTimer {
            self.triggerTransitionAlarm()
            self.timer = nil
            timer.tickHandler = self.tickHandler
            timer.transitionHandler = self.transitionHandler
            timer.isSelected = true
            self.timer = timer
            self.timer?.start()
        } else {
            self.triggerFinalAlarm()
        }
        self.numericalDisplayController?.updateUI()
    }
    
    /* ############################################################## */
    /**
     Called when this timer transitions to the next timer.
     */
    func triggerTransitionAlarm() {
        self.flashRed(true)
        print("TRANSITION")
    }

    /* ############################################################## */
    /**
     Called when all timers in the group are done.
     */
    func triggerFinalAlarm() {
        self.flashRed(true)
        print("FINAL ALARM")
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension RiValT_RunningTimer_ContainerViewController {
    /* ############################################################## */
    /**
     Called when the user does a right-swipe
     
     - parameter: Ignored.
     */
    @IBAction func rightSwipeReceived(_: Any) {
        if !RiValT_Settings().displayToolbar {
            self.flashRed()
            self.impactHaptic(1.0)
            self.timer?.end()
            self.numericalDisplayController?.updateUI()
        }
    }
    
    /* ############################################################## */
    /**
     Called when the user does a left-swipe
     
     - parameter: Ignored.
     */
    @IBAction func leftSwipeReceived(_: Any) {
        if !RiValT_Settings().displayToolbar {
            self.rewindHit()
            self.numericalDisplayController?.updateUI()
        }
    }
    
    /* ############################################################## */
    /**
     Called when the user taps on the screen twice.
     
     - parameter: Ignored.
     */
    @IBAction func doubleTapReceived(_: Any) {
        if !RiValT_Settings().displayToolbar {
            self.stopHit()
        }
    }
    
    /* ############################################################## */
    /**
     Called when the user taps on the screen once.
     
     - parameter: Ignored.
     */
    @IBAction func singleTapReceived(_: Any) {
        if !RiValT_Settings().displayToolbar {
            self.playPauseHit()
            self.numericalDisplayController?.updateUI()
        } else if RiValT_Settings().autoHideToolbar {
            self.showToolbar()
        }
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
        
        self.numericalDisplayController?.updateUI()
        self.showToolbar()
    }
    
    /* ############################################################## */
    /**
     This is called by the model, and represents one "tick" of the timer.
     
     - parameter: The timer instance (ignored).
     */
    func tickHandler(_: Timer) {
        self.selectionHaptic()
        self.numericalDisplayController?.updateUI()
    }

    /* ############################################################## */
    /**
     This is called by the model, and represents a transition, from one state to another.
     
     - parameter: The timer instance (ignored).
     - parameter: The state the timer is moving from (ignored).
     - parameter inToMode: The new timer state.
     */
    func transitionHandler(_: Timer, _: TimerEngine.Mode, _ inToMode: TimerEngine.Mode) {
        self.impactHaptic(1.0)
        switch inToMode {
        case .countdown:
            self.flashGreen()
            
        case .warning:
            self.flashYellow()
            
        case .final:
            self.flashRed()

        case .alarm:
            self.alarmReached()
            
        case .paused, .stopped:
            self.flashCyan()
        }
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
