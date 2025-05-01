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
    private static let _autoHideAnimationDurationInSeconds = TimeInterval(0.25)

    /* ############################################################## */
    /**
     The repeat rate of the alarm "pulses."
     */
    private static let _alarmDurationInSeconds = TimeInterval(0.85)
    
    /* ############################################################## */
    /**
     The number of milliseconds to allow for timer leeway.
     */
    private static let _leewayInMilliseconds = 25

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
    
    /* ############################################################## */
    /**
     The timer that is set when the alarm is sounding.
     */
    private var _alarmTimer: RVS_BasicGCDTimer?

    /* ################################################################## */
    /**
     This is the audio player (for playing alarm sounds).
    */
    private var _audioPlayer: AVAudioPlayer!
    
    /* ############################################################## */
    /**
     If the slider is up, it will be stored here.
     */
    private weak var _timeSetSlider: UISlider?
    
    /* ############################################################## */
    /**
     If this is true, then the next transition will suppress its flash (used for switching timers).
     */
    private var _suppressFlash: Bool = false

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
     This is our circular display instance.
     */
    weak var circularDisplayController: RiValT_RunningTimer_Circular_ViewController?
    
    /* ############################################################## */
    /**
     This is our stoplights display instance.
     */
    weak var stoplightDisplayController: RiValT_RunningTimer_Stoplights_ViewController?

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
     This contains the running timer for circular format.
     */
    @IBOutlet weak var circularContainerView: UIView?
    
    /* ############################################################## */
    /**
     This contains the running timer for stoplight format.
     */
    @IBOutlet weak var stoplightTimerContainerView: UIView?

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
    
    /* ############################################################## */
    /**
     The long-press gesture recognizer, for setting the value directly.
     */
    @IBOutlet var dragValueLongPressGestureRecognizer: UILongPressGestureRecognizer?
    
    /* ############################################################## */
    /**
     The view to which the recognizer is attached.
     */
    @IBOutlet weak var longPressDetectionView: UIView?
    
    /* ############################################################## */
    /**
     The view that is used to contain the slider to set the time.
     This is not available in Toolbar Displayed Mode.
     */
    @IBOutlet weak var timeSetSwipeContainerView: UIView?
    
    /* ############################################################## */
    /**
     This label displays the time in the slider.
     */
    @IBOutlet weak var timeSetDisplayLabel: UILabel?
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension RiValT_RunningTimer_ContainerViewController {
    /* ############################################################## */
    /**
     If we are in a multi-timer group, this is the previous timer.
     */
    var prevTimer: Timer? {
        guard let group = self.timer?.group,
              let myIndex = self.timer?.indexPath?.item,
              1 < group.count,
              myIndex > 0,
              0 < group[myIndex - 1].startingTimeInSeconds
        else { return nil }
        
        return group[myIndex - 1]
    }
    
    /* ############################################################## */
    /**
     If we are in a multi-timer group, this is the next timer.
     */
    var nextTimer: Timer? {
        guard let group = self.timer?.group,
              let myIndex = self.timer?.indexPath?.item,
              1 < group.count,
              myIndex < group.count - 1,
              0 < group[myIndex + 1].startingTimeInSeconds
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
    
    /* ############################################################## */
    /**
     If we are in a multi-timer group, true, if this is the last timer.
     */
    var isLastTimer: Bool { self.lastTimer == self.timer }
    
    /* ############################################################## */
    /**
     If true, we are dragging the set slider.
     */
    var isDragging: Bool { nil != self._timeSetSlider }
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
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []) // This line ensures that the sound will play, even with the ringer off.
        self.view?.backgroundColor = isHighContrastMode ? .systemBackground : .black

        self._selectionFeedbackGenerator.prepare()
        self._impactFeedbackGenerator.prepare()
        self._alarmTimer = RVS_BasicGCDTimer(timeIntervalInSeconds: Self._alarmDurationInSeconds,
                                             delegate: self,
                                             leewayInMilliseconds: Self._leewayInMilliseconds * 2,
                                             onlyFireOnce: false
        )

        let appearance = UIToolbarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.backgroundImage = nil
        self.controlToolbar?.standardAppearance = appearance
        self.controlToolbar?.scrollEdgeAppearance = appearance
        
        if let tapper = self.singleTapGestureRecognizer,
           let leftSwipe = self.leftSwipeGestureRecognizer,
           let rightSwipe = self.rightSwipeGestureRecognizer,
           let doubleTapper = self.doubleTapGestureRecognizer,
           let longo = self.dragValueLongPressGestureRecognizer {
            tapper.require(toFail: doubleTapper)
            leftSwipe.require(toFail: tapper)
            rightSwipe.require(toFail: tapper)
            longo.require(toFail: tapper)
        }
        
        self.timer?.tickHandler = self.tickHandler
        self.timer?.transitionHandler = self.transitionHandler
        self.setToolbarEnablements()
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
        } else {
            self.timer?.stop()
        }
        
        self.exposeCurrentDisplay()
        self.updateDisplays()
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
        self.timer?.stop()
        self._audioPlayer?.stop()
        self._audioPlayer = nil
        self._autoHideTimer?.invalidate()
        self._autoHideTimer = nil
        self._alarmTimer?.invalidate()
        self._alarmTimer = nil
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
        } else if let destination = inSegue.destination as? RiValT_RunningTimer_Circular_ViewController {
            destination.myContainer = self
            self.circularDisplayController = destination
        } else if let destination = inSegue.destination as? RiValT_RunningTimer_Stoplights_ViewController {
            destination.myContainer = self
            self.stoplightDisplayController = destination
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
     This shows the current display, and hides the others.
     */
    func exposeCurrentDisplay() {
        guard let group = self.timer?.group else { return }
        
        switch group.displayType {
        case .circular:
            self.numericalTimerContainerView?.isHidden = true
            self.circularContainerView?.isHidden = false
            self.stoplightTimerContainerView?.isHidden = true

        case .numerical:
            self.numericalTimerContainerView?.isHidden = false
            self.circularContainerView?.isHidden = true
            self.stoplightTimerContainerView?.isHidden = true

        case .stoplights:
            self.numericalTimerContainerView?.isHidden = true
            self.circularContainerView?.isHidden = true
            self.stoplightTimerContainerView?.isHidden = false
        }
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
        self._alarmTimer?.isRunning = false
        if self.timer?.isTimerAtStart ?? false,
           let prevTimer = self.prevTimer {
            self.timer?.tickHandler = nil
            self.timer?.transitionHandler = nil
            self.timer?.stop()
            self.timer = nil
            prevTimer.stop()
            prevTimer.tickHandler = self.tickHandler
            prevTimer.transitionHandler = self.transitionHandler
            prevTimer.isSelected = true
            self.timer = prevTimer
            if let row = self.timer?.indexPath?.row {
                self.flashTimerNumber(row)
            }
        } else if self.timer?.isTimerInAlarm ?? false,
                  self.isLastTimer,
                  1 < self.count,
                  let resetTimer = self.firstTimer {
            self.timer?.stop()
            resetTimer.stop()
            resetTimer.tickHandler = self.tickHandler
            resetTimer.transitionHandler = self.transitionHandler
            resetTimer.isSelected = true
            self.timer = resetTimer
            self.flashTimerNumber(0)
        } else {
            self.timer?.stop()
        }
        
        self.updateDisplays()
    }
    
    /* ############################################################## */
    /**
     This stops the timer, and dismisses the screen.
     */
    func stopHit() {
        self._alarmTimer?.isRunning = false
        self._alarmTimer?.invalidate()
        self._alarmTimer = nil
        self._autoHideTimer?.isRunning = false
        self._autoHideTimer?.invalidate()
        self._autoHideTimer = nil
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
        self._alarmTimer?.isRunning = false
        if self.timer?.isTimerRunning ?? false {
            self.flashCyan()
            self.timer?.pause()
            self.updateDisplays()
        } else {
            if self.timer?.isTimerPaused ?? false {
                self.flashGreen()
                self.timer?.resume()
            } else if self.timer?.isTimerInAlarm ?? false,
                      let oldRow = self.timer?.indexPath?.row,
                      let timer = self.firstTimer {
                self.timer?.stop()
                self.timer = nil
                timer.stop()
                timer.isSelected = true
                timer.tickHandler = self.tickHandler
                timer.transitionHandler = self.transitionHandler
                self.timer = timer
                if let row = self.timer?.indexPath?.row,
                   row != oldRow {
                    self.flashTimerNumber(row)
                }
            } else {
                self.flashGreen()
                self.impactHaptic()
                self.timer?.start()
           }
            self.updateDisplays()
        }
    }

    /* ############################################################## */
    /**
     This pushes the timer to the end (alarm state).
     */
    func fastForwardHit() {
        self._alarmTimer?.isRunning = false
        if self.timer?.isTimerAtStart ?? false || self.timer?.isTimerAtEnd ?? false,
           !(self.timer?.isTimerRunning ?? false),
           let nextTimer = self.nextTimer {
            self.timer?.tickHandler = nil
            self.timer?.transitionHandler = nil
            self.timer?.stop()
            self.timer = nil
            nextTimer.stop()
            nextTimer.tickHandler = self.tickHandler
            nextTimer.transitionHandler = self.transitionHandler
            nextTimer.isSelected = true
            self.timer = nextTimer
            if let row = self.timer?.indexPath?.row {
                self.flashTimerNumber(row)
            }
        } else {
            self.timer?.end()
        }
        
        self.updateDisplays()
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
     This flashes the given timer number, in an expanding and fading image.
     */
    func flashTimerNumber(_ inNumber: Int) {
        guard let view = view else { return }
        
        let timerLabel = UILabel()
        view.addSubview(timerLabel)
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        timerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        timerLabel.text = isHighContrastMode ? "" : String(inNumber + 1)    // No flash for high contrast.
        timerLabel.textAlignment = .center
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.font = .monospacedDigitSystemFont(ofSize: view.bounds.size.height * 3, weight: .bold)
        timerLabel.transform = timerLabel.transform.scaledBy(x: 0.1, y: 0.1)
        timerLabel.textColor = UIColor(named: "Paused-Color")

        flasherView?.backgroundColor = UIColor(named: "Paused-Color")
        UIView.animate(withDuration: Self._flashDurationInSeconds,
                       animations: { [weak self] in
                                        timerLabel.transform = CGAffineTransform.identity
                                        timerLabel.alpha = 0.0
                                        self?.flasherView?.backgroundColor = .clear
                                    },
                       completion: { _ in timerLabel.removeFromSuperview() }
        )
    }

    /* ############################################################## */
    /**
     This enables (or disables) toolbar items, as necessary for the current state.
     */
    func setToolbarEnablements() {
        guard let timer = self.timer else { return }
        self.stopToolbarItem?.isEnabled = true
        self.fastForwardToolbarItem?.isEnabled = !(self.timer?.isTimerInAlarm ?? false)
        self.rewindToolbarItem?.isEnabled = (self.timer?.isTimerInAlarm ?? false) || ((self.timer?.currentTime ?? 0) < (self.timer?.startingTimeInSeconds ?? 0)) || (nil != self.prevTimer)
        self.playPauseToolbarItem?.image = UIImage(systemName: "\(timer.isTimerRunning ? "pause" : "play").fill")
    }

    /* ############################################################## */
    /**
     Updates all the embeds.
     */
    func updateDisplays() {
        self.setToolbarEnablements()
        self.numericalDisplayController?.updateUI()
        self.circularDisplayController?.updateUI()
        self.stoplightDisplayController?.updateUI()
    }
    
    /* ############################################################## */
    /**
     Called when this timer reaches the end.
     */
    func alarmReached() {
        self._alarmTimer?.isRunning = false
        if nil != self.nextTimer {
            self.triggerTransitionAlarm()
        } else {
            self.triggerFinalAlarm()
        }
    }
    
    /* ############################################################## */
    /**
     Called when this timer transitions to the next timer.
     */
    func triggerTransitionAlarm() {
        if let timer = self.nextTimer {
            self._suppressFlash = true
            self.timer?.tickHandler = nil
            self.timer?.transitionHandler = nil
            self.playTransitionSound()
            self.timer?.stop()
            self.timer = nil
            timer.isSelected = true
            timer.stop()
            self.timer = timer
            self.timer?.start()
            if .warning == timer.timerMode {
                self.flashYellow()
            } else if .final == timer.timerMode {
                self.flashRed()
            }
            self.updateDisplays()
            self.timer?.tickHandler = self.tickHandler
            self.timer?.transitionHandler = self.transitionHandler
        } else {
            self._suppressFlash = false
            self.flashRed(true)
        }
    }

    /* ############################################################## */
    /**
     Called when all timers in the group are done.
     */
    func triggerFinalAlarm() {
        self._suppressFlash = false
        self.flashRed(true)
        self.playAlarmSound()
        self._alarmTimer?.isRunning = true
    }
    
    /* ############################################################## */
    /**
     This just plays an alarm sound, vibrates the phone, or does nothing.
     */
    func playAlarmSound() {
        guard let soundType = self.timer?.group?.soundType else { return }
        switch soundType {
        case .sound(soundFileName: let soundFileURLString):
            if !(self._audioPlayer?.isPlaying ?? false),
               let actualURLString = RiValT_Settings.soundURIs.first(where: { $0.contains(soundFileURLString) }),
               let soundURL = URL(string: actualURLString) {
                self.playThisSound(soundURL, numberOfRepeats: -1)
            }

        case .vibrate:
            self._audioPlayer?.stop()  // Belt and suspenders.
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)

        case .soundVibrate(soundFileName: let soundFileURLString):
            if !(self._audioPlayer?.isPlaying ?? false),
               let actualURLString = RiValT_Settings.soundURIs.first(where: { $0.contains(soundFileURLString) }),
               let soundURL = URL(string: actualURLString) {
                self.playThisSound(soundURL, numberOfRepeats: -1)
            }
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            
        case .none:
            self._audioPlayer?.stop()
        }
    }
    
    /* ############################################################## */
    /**
     This just plays the transition sound.
     */
    func playTransitionSound() {
        if let transitionSoundURLString = self.timer?.group?.transitionSoundFilename,
           let actualURLString = RiValT_Settings.transitionSoundURIs.first(where: { $0.contains(transitionSoundURLString) }),
           let transitionSoundURL = URL(string: actualURLString) {
            self.playThisSound(transitionSoundURL, numberOfRepeats: 0)
        }
    }

    /* ################################################################## */
    /**
     This plays any sound, using a given URL.
     
     - parameter inSoundURL: This is the URI to the sound resource.
     - parameter inRepeatCount: The number of times to repeat. -1 (continuous), if not provided.
     */
    func playThisSound(_ inSoundURL: URL, numberOfRepeats inRepeatCount: Int = -1) {
        if let audioPlayer = try? AVAudioPlayer(contentsOf: inSoundURL) {
            audioPlayer.numberOfLoops = inRepeatCount
            self._audioPlayer = audioPlayer
            audioPlayer.play()
        }
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
        self._alarmTimer?.isRunning = false
        self._audioPlayer?.stop()
        if !RiValT_Settings().displayToolbar {
            self.fastForwardHit()
            self.updateDisplays()
        }
    }
    
    /* ############################################################## */
    /**
     Called when the user does a left-swipe
     
     - parameter: Ignored.
     */
    @IBAction func leftSwipeReceived(_: Any) {
        self._alarmTimer?.isRunning = false
        self._audioPlayer?.stop()
        if !RiValT_Settings().displayToolbar {
            self.rewindHit()
            self.updateDisplays()
        }
    }
    
    /* ############################################################## */
    /**
     Called when the user taps on the screen twice.
     
     - parameter: Ignored.
     */
    @IBAction func doubleTapReceived(_: Any) {
        self._alarmTimer?.isRunning = false
        self._audioPlayer?.stop()
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
        self._alarmTimer?.isRunning = false
        self._audioPlayer?.stop()
        if !RiValT_Settings().displayToolbar {
            self.playPauseHit()
        } else if RiValT_Settings().autoHideToolbar {
            self.showToolbar()
        }
        self.updateDisplays()
    }
    
    /* ############################################################## */
    /**
     The long-press on the bottom of the screen was detected.
     
     - parameter inGestureRecognizer: The gesture recognizer that was triggered.
     */
    @IBAction func longPressGestureDetected(_ inGestureRecognizer: UILongPressGestureRecognizer) {
        /* ############################################################## */
        /**
         This prepares the time set slider.
         - parameter atThisLocation: A float, from 0, to 1, with the starting thumb location (0 is left, 1 is right).
         */
        func _prepareSlider(atThisLocation inLocation: Float) {
            guard let timeSetSwipeDetectorView = self.timeSetSwipeContainerView,
                  let timer = self.timer
            else { return }
            
            self._timeSetSlider?.removeFromSuperview()
            self._timeSetSlider = nil
            
            let slider = UISlider()
            slider.maximumValue = Float(timer.startingTimeInSeconds)
            slider.minimumValue = 0.0
            slider.value = inLocation

            timeSetSwipeDetectorView.addSubview(slider)
            slider.translatesAutoresizingMaskIntoConstraints = false
            slider.leadingAnchor.constraint(equalTo: timeSetSwipeDetectorView.leadingAnchor).isActive = true
            slider.trailingAnchor.constraint(equalTo: timeSetSwipeDetectorView.trailingAnchor).isActive = true
            slider.centerYAnchor.constraint(equalTo: timeSetSwipeDetectorView.centerYAnchor).isActive = true
            self.timeSetDisplayLabel?.isHidden = false
            self.timeSetDisplayLabel?.text = !timer.timerDisplay.isEmpty ? timer.timerDisplay : "0"
            self._timeSetSlider = slider
        }
        
        /* ########################################################## */
        /**
         Sets the timer to the given percentage.
         
         - parameter location: The 0 -> 1 location.
         */
        func _setTimerTo(location inLocation: Float) {
            guard let timer = self.timer,
                  (0...1).contains(inLocation)
            else { return }
            
            let lastTime = timer.currentTime
            let currentTime = timer.startingTimeInSeconds - Int(round(Float(timer.startingTimeInSeconds) * inLocation))
            
            if currentTime != lastTime {
                self.selectionHaptic()
                timer.pause()
                timer.currentTime = currentTime
                self._timeSetSlider?.value = Float(timer.startingTimeInSeconds - currentTime)
            }
            
            self.timeSetDisplayLabel?.text = !timer.timerDisplay.isEmpty ? timer.timerDisplay : "0"
            self.updateDisplays()
        }
        
        guard let detectionView = self.longPressDetectionView,
              !detectionView.isHidden,
              let timer = self.timer
        else {
            inGestureRecognizer.state = .cancelled
            self.timeSetDisplayLabel?.isHidden = true
            self._timeSetSlider?.removeFromSuperview()
            self._timeSetSlider = nil
            self.updateDisplays()
            return
        }
        
        let gestureLocation = inGestureRecognizer.location(ofTouch: 0, in: detectionView)
        let location = Float(gestureLocation.x / detectionView.bounds.size.width)
        
        switch inGestureRecognizer.state {
        case .began:
            if (0...1).contains(location) {
                self.impactHaptic(1.0)
                if !timer.isTimerRunning {
                    timer.start()
                    timer.pause()
                }
                _prepareSlider(atThisLocation: location)
            }
            
            fallthrough

        case .changed:
            _setTimerTo(location: location)

        default:
            self.impactHaptic()
            self.timeSetDisplayLabel?.isHidden = true
            self._timeSetSlider?.removeFromSuperview()
            self._timeSetSlider = nil
            if timer.isTimerAtStart {
                timer.stop()
            }
            self.updateDisplays()
        }
    }
    
    /* ############################################################## */
    /**
     One of the toolbar controls was hit.
     
     - parameter inSender: The item that was activated.
     */
    @IBAction func toolbarItemHit(_ inSender: UIBarButtonItem) {
        self._alarmTimer?.isRunning = false
        self._audioPlayer?.stop()
        self.showToolbar()
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
        
        self.updateDisplays()
    }
    
    /* ############################################################## */
    /**
     This is called by the model, and represents one "tick" of the timer.
     
     - parameter: The timer instance (ignored).
     */
    func tickHandler(_: Timer) {
        if !self.isDragging {
            self.selectionHaptic()
            self.updateDisplays()
        }
    }

    /* ############################################################## */
    /**
     This is called by the model, and represents a transition, from one state to another.
     
     - parameter inTimer: The timer instance.
     - parameter: The state the timer is moving from (ignored).
     - parameter inToMode: The new timer state.
     */
    func transitionHandler(_ inTimer: Timer, _ inFromMode: TimerEngine.Mode, _ inToMode: TimerEngine.Mode) {
        if !self.isDragging,
           .stopped != inFromMode {
            self.impactHaptic(1.0)
            switch inToMode {
            case .countdown:
                if !self._suppressFlash {
                    self.flashGreen()
                } else {
                    self._suppressFlash = false
                }

            case .warning:
                if !self._suppressFlash {
                    self.flashYellow()
                } else {
                    self._suppressFlash = false
                }
                
            case .final:
                if !self._suppressFlash {
                    self.flashRed()
                } else {
                    self._suppressFlash = false
                }
                
            case .alarm:
                self.alarmReached()
                
            case .paused, .stopped:
                if !self.isDragging {
                    self.flashCyan()
                }
            }
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
            switch inTimer {
            case self?._autoHideTimer:
                #if DEBUG
                    print("Triggering the auto-hide timer")
                #endif
                self?.hideToolbar()
                
            case self?._alarmTimer:
                #if DEBUG
                    print("Triggering the alarm timer")
                #endif
                self?.flashRed(true)
                guard let soundType = self?.timer?.group?.soundType else { return }
                switch soundType {
                case .vibrate, .soundVibrate:
                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                    
                default:
                    break
                }
            default:
                break
            }
        }
    }
}
