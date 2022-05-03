/*
 © Copyright 2018-2022, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import AVKit
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
    /* ################################################################################################################################## */
    // MARK: Private Static Properties
    /* ################################################################################################################################## */
    /* ############################################################## */
    /**
     */
    private static var _pausedLEDColor: UIColor? = UIColor(named: "Paused-Color")
    
    /* ############################################################## */
    /**
     */
    private static var _initialLEDColor: UIColor? = UIColor(named: "Start-Color")
    
    /* ############################################################## */
    /**
     */
    private static var _warnLEDColor: UIColor? = UIColor(named: "Warn-Color")
    
    /* ############################################################## */
    /**
     */
    private static var _finalLEDColor: UIColor? = UIColor(named: "Final-Color")

    /* ############################################################## */
    /**
     */
    private static var _flashDuration = TimeInterval(0.75)

    /* ############################################################## */
    /**
     */
    private static var _alarmDuration = TimeInterval(0.85)

    /* ############################################################## */
    /**
     */
    private static var _stoplightDimmedAlpha = CGFloat(0.15)

    /* ############################################################## */
    /**
     */
    private static var _stoplightPausedAlpha = CGFloat(0.35)

    /* ############################################################## */
    /**
     */
    private static var _centerAlignmentToolbarOffsetInDisplayUnits = CGFloat(40)

    /* ################################################################################################################################## */
    // MARK: Private Stored Instance Properties
    /* ################################################################################################################################## */
    /* ############################################################## */
    /**
     */
    private var _timer: RVS_BasicGCDTimer?
    
    /* ############################################################## */
    /**
     */
    private var _alarmTimer: RVS_BasicGCDTimer?

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
     */
    private var _startingTime: Date?
    
    /* ############################################################## */
    /**
     */
    private var _tickTime: Int = 0
    
    /* ################################################################## */
    /**
     If true, then the currently selected sound is playing.
    */
    private var _isSoundPlaying: Bool = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?._audioPlayer?.stop()
                self?._audioPlayer = nil
                
                if self?._isSoundPlaying ?? false,
                   let selectedURLString = self?._soundSelection[RVS_AmbiaMara_Settings().selectedSoundIndex],
                   let url = URL(string: selectedURLString) {
                    self?.playThisSound(url)
                }
            }
        }
    }

    /* ############################################################## */
    /**
     True, if the timer is currently in "alarm" state.
     */
    private var _isAlarming: Bool = false {
        didSet {
            if !_isAlarming {
                _alarmTimer?.isRunning = false
                _timer?.isRunning = false
                stopSounds()
                _startingTime = Date()
                _tickTime = 0
                setDigitDisplayTime()
                setTimerDisplay()
                setUpToolbar()
            } else {
                _timer?.isRunning = false
                _alarmTimer?.isRunning = true
                setUpToolbar()
                flashRed()
                if RVS_AmbiaMara_Settings().alarmMode {
                    _isSoundPlaying = true
                }
                setDigitalTimeAs(hours: 0, minutes: 0, seconds: 0)
            }
        }
    }

    /* ################################################################################################################################## */
    // MARK: Internal IB Stored Properties
    /* ################################################################################################################################## */
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

    /* ############################################################## */
    /**
     */
    @IBOutlet weak var backgroundTapGestureRecognizer: UITapGestureRecognizer?

    /* ############################################################## */
    /**
     */
    @IBOutlet weak var backgroundLeftSwipeGestureRecognizer: UISwipeGestureRecognizer!

    /* ############################################################## */
    /**
     */
    @IBOutlet weak var backgroundRightSwipeGestureRecognizer: UISwipeGestureRecognizer!

    /* ############################################################## */
    /**
     */
    @IBOutlet weak var controlToolbar: UIToolbar?

    /* ############################################################## */
    /**
     */
    @IBOutlet weak var playPauseToolbarItem: UIBarButtonItem?

    /* ############################################################## */
    /**
     */
    @IBOutlet weak var stopToolbarItem: UIBarButtonItem?

    /* ############################################################## */
    /**
     */
    @IBOutlet weak var fastForwardBarButtonItem: UIBarButtonItem!

    /* ############################################################## */
    /**
     */
    @IBOutlet weak var rewindToolbarItem: UIBarButtonItem!
    
    /* ############################################################## */
    /**
     */
    @IBOutlet weak var centerAlignmentConstraint: NSLayoutConstraint?

    /* ############################################################## */
    /**
     */
    @IBOutlet weak var flasherView: UIView!
}

/* ###################################################################################################################################### */
// MARK: Private Computed Properties
/* ###################################################################################################################################### */
extension RVS_TimerAmbiaMara_ViewController {
    /* ############################################################## */
    /**
     - returns: True, if the timer is currently running.
     */
    private var _isTimerRunning: Bool { _timer?.isRunning ?? false }

    /* ############################################################## */
    /**
     - returns: True, if the current time is at the "starting gate."
     */
    private var _isAtStart: Bool {
        guard let startingTime = _startingTime?.timeIntervalSince1970 else { return false }
        let differenceInSeconds = Int(Date().timeIntervalSince1970 - startingTime)
        return 0 <= (RVS_AmbiaMara_Settings().currentTimer.startTime - differenceInSeconds)
    }

    /* ############################################################## */
    /**
     - returns: True, if the current time is within the "warning" window.
     */
    private var _isWarning: Bool {
        guard let startingTime = _startingTime?.timeIntervalSince1970 else { return false }
        let differenceInSeconds = Int(Date().timeIntervalSince1970 - startingTime)
        return (RVS_AmbiaMara_Settings().currentTimer.startTime - differenceInSeconds) <= RVS_AmbiaMara_Settings().currentTimer.warnTime
    }

    /* ############################################################## */
    /**
     - returns: True, if the current time is within the "final countdown" window.
     */
    private var _isFinal: Bool {
        guard let startingTime = _startingTime?.timeIntervalSince1970 else { return false }
        let differenceInSeconds = Int(Date().timeIntervalSince1970 - startingTime)
        return (RVS_AmbiaMara_Settings().currentTimer.startTime - differenceInSeconds) <= RVS_AmbiaMara_Settings().currentTimer.finalTime
    }
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RVS_TimerAmbiaMara_ViewController {
    /* ################################################################## */
    /**
     - returns true, indicating that X-phones should hide the Home Bar.
     */
    override var prefersHomeIndicatorAutoHidden: Bool { true }

    /* ############################################################## */
    /**
     Called when the hierarchy is loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Makes the toolbar background transparent.
        controlToolbar?.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        controlToolbar?.setShadowImage(UIImage(), forToolbarPosition: .any)
        _soundSelection = Bundle.main.paths(forResourcesOfType: "mp3", inDirectory: nil).sorted()
        
        trafficLightsContainerView?.isHidden = !RVS_AmbiaMara_Settings().showStoplights
        digitalDisplayContainerView?.isHidden = !RVS_AmbiaMara_Settings().showDigits
        
        controlToolbar?.isHidden = !RVS_AmbiaMara_Settings().displayToolbar
        centerAlignmentConstraint?.constant = RVS_AmbiaMara_Settings().displayToolbar ? Self._centerAlignmentToolbarOffsetInDisplayUnits : 0

        if RVS_AmbiaMara_Settings().showDigits {
            digitalDisplayContainerView?.autoLayoutAspectConstraint(aspectRatio: 0.2)?.isActive = true
            digitalDisplayViewHours?.radix = 10
            digitalDisplayViewMinutes?.radix = 10
            digitalDisplayViewSeconds?.radix = 10
        }
        
        _timer = RVS_BasicGCDTimer(timeIntervalInSeconds: 0.25, delegate: self, leewayInMilliseconds: 50, onlyFireOnce: false, queue: .main, isWallTime: true)
        _alarmTimer = RVS_BasicGCDTimer(timeIntervalInSeconds: Self._alarmDuration, delegate: self, leewayInMilliseconds: 50, onlyFireOnce: false, queue: .main)

        initializeTimer()
    }
    
    /* ############################################################## */
    /**
     Called when the view is about to appear.
     - parameter inIsAnimated: True, if the appearance is animated.
     */
    override func viewWillAppear(_ inIsAnimated: Bool) {
        super.viewWillAppear(inIsAnimated)
        navigationController?.isNavigationBarHidden = true
        UIApplication.shared.isIdleTimerDisabled = true // This makes sure we don't fall asleep.
    }
    
    /* ############################################################## */
    /**
     Called when the view is about to disappear.
     - parameter inIsAnimated: True, if the disappearance is animated.
     */
    override func viewWillDisappear(_ inIsAnimated: Bool) {
        super.viewWillDisappear(inIsAnimated)
        UIApplication.shared.isIdleTimerDisabled = false
        stopAlarm()
        pauseTimer()
        _timer = nil
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension RVS_TimerAmbiaMara_ViewController {
    /* ############################################################## */
    /**
     Called if the background was tapped. This is how we start/pause/continue the timer.
     - parameter: ignored.
     */
    @IBAction func backgroundTapped(_: UITapGestureRecognizer) {
        if _isAlarming {
            stopAlarm()
        } else if _isTimerRunning {
            flashRed()
            pauseTimer()
        } else if 0 == _tickTime {
            startTimer()
        } else {
            if !_isWarning,
               !_isFinal {
                flashGreen()
            }
            continueTimer()
        }
    }

    /* ############################################################## */
    /**
     The user swiped the timer.
     
     - parameter inGestureRecognizer: The swipe gesture recognizer.
     */
    @IBAction func swipeGestureReceived(_ inGestureRecognizer: UISwipeGestureRecognizer) {
        if inGestureRecognizer == backgroundLeftSwipeGestureRecognizer {
            if !_isTimerRunning,
               _isAtStart {
                stopTimer()
            } else {
                if _isAlarming {
                    _isAlarming = false
                } else {
                    resetTimer()
                }
            }
            setUpToolbar()
        } else {
            if _isAlarming {
                _isAlarming = false
            } else {
                _isAlarming = true
            }
        }
    }

    /* ############################################################## */
    /**
     One of the toolbar controls was hit.
     
     - parameter inSender: The item that was activated.
     */
    @IBAction func toolbarItemHit(_ inSender: UIBarButtonItem) {
        if stopToolbarItem == inSender {
            stopTimer()
        } else if rewindToolbarItem == inSender {
            resetTimer()
        } else if fastForwardBarButtonItem == inSender {
            _isAlarming = true
        } else if playPauseToolbarItem == inSender {
            if _isTimerRunning {
                flashRed()
                pauseTimer()
            } else {
                if 0 == _tickTime {
                    startTimer()
                } else {
                    continueTimer()
                }
            }
            
            setUpToolbar()
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RVS_TimerAmbiaMara_ViewController {
    /* ################################################################## */
    /**
     This sets up the toolbar, by adding all the timers.
    */
    func setUpToolbar() {
        rewindToolbarItem?.isEnabled = !_isAtStart
        fastForwardBarButtonItem?.isEnabled = !_isAlarming
        playPauseToolbarItem?.isEnabled = !_isAlarming

        if _isTimerRunning {
            playPauseToolbarItem?.image = UIImage(systemName: "pause.fill")
        } else {
            playPauseToolbarItem?.image = UIImage(systemName: "play.fill")
        }
    }

    /* ############################################################## */
    /**
     This initializes the timer screen.
     */
    func initializeTimer() {
        let hours = 0 < RVS_AmbiaMara_Settings().currentTimer.startTimeAsComponents[0] ? RVS_AmbiaMara_Settings().currentTimer.startTimeAsComponents[0] : -2
        let minutes = 0 < RVS_AmbiaMara_Settings().currentTimer.startTimeAsComponents[1] ? RVS_AmbiaMara_Settings().currentTimer.startTimeAsComponents[1] : 0 < hours ? 0 : -2
        let seconds = 0 < RVS_AmbiaMara_Settings().currentTimer.startTimeAsComponents[2] ? RVS_AmbiaMara_Settings().currentTimer.startTimeAsComponents[2] : 0 < hours || 0 < minutes ? 0 : -2
        
        if RVS_AmbiaMara_Settings().showDigits && RVS_AmbiaMara_Settings().showStoplights,
           let digitHeightAnchor = digitsInternalContainerView?.heightAnchor {
            trafficLightsContainerView?.heightAnchor.constraint(equalTo: digitHeightAnchor, multiplier: 0.5).isActive = true
        }
        setDigitalTimeAs(hours: hours, minutes: minutes, seconds: seconds)

        resetTimer()

        if RVS_AmbiaMara_Settings().startTimerImmediately {
            startTimer()
        } else {
            pauseTimer()
        }
    }
    
    /* ############################################################## */
    /**
     This stops the alarm, sets the timer to zero, and pauses it.
     */
    func stopAlarm() {
        _isAlarming = false
    }
    
    /* ############################################################## */
    /**
     This starts the timer from scratch.
     */
    func startTimer() {
        if let timer = _timer { // Force an immediate update.
            _startingTime = Date()
            _tickTime = 0
            timer.isRunning = true
            setTimerDisplay()
            setUpToolbar()
        }
    }

    /* ############################################################## */
    /**
     This sets the timer to scratch, but does not start it.
     */
    func resetTimer() {
        _isAlarming = false
        _startingTime = Date()
        _tickTime = 0
        _timer?.isRunning = false
        setTimerDisplay()
        setUpToolbar()
    }

    /* ############################################################## */
    /**
     Pauses the timer, without resetting anything.
     Any playing sounds are stopped.
     */
    func pauseTimer() {
        _timer?.isRunning = false
        stopSounds()
        setTimerDisplay()
        setUpToolbar()
    }
    
    /* ############################################################## */
    /**
     Continues the timer, setting the counter to the last time.
     - parameter takeElapsedTimeIntoAccount: If true, then we don't reset the timer to the last time.
                                             Instead, we take the time between the last tick, and now, into account.
     */
    func continueTimer(takeElapsedTimeIntoAccount: Bool = false) {
        flashGreen()
        setTimerDisplay()
        if !takeElapsedTimeIntoAccount {
            _startingTime = Date().addingTimeInterval(-TimeInterval(_tickTime))
            _tickTime = 0
        }
        _timer?.isRunning = true
        if let timer = _timer { // Force an immediate update.
            basicGCDTimerCallback(timer)
        }
    }
    
    /* ############################################################## */
    /**
     Stops the timer, by popping the screen.
     */
    func stopTimer() {
        navigationController?.popViewController(animated: true)
    }
    
    /* ############################################################## */
    /**
     Stops any playing sounds.
     */
    func stopSounds() {
        _isSoundPlaying = false
    }
    
    /* ############################################################## */
    /**
     */
    func setTimerDisplay() {
        guard let startingTime = _startingTime?.timeIntervalSince1970 else { return }
        let differenceInSeconds = Int(Date().timeIntervalSince1970 - startingTime)
        let currentTime = RVS_AmbiaMara_Settings().currentTimer.startTime - differenceInSeconds
        setDigitDisplayTime()
        determineTrafficLightColor(currentTime)
        determineDigitLEDColor(currentTime)
    }
    
    /* ############################################################## */
    /**
     This determines the proper color for the "traffic lights."
     - parameter inCurrentTime: Optional. Default is 0. This is the elapsed time, in seconds.
     */
    func determineTrafficLightColor(_ inCurrentTime: Int = 0) {
        guard RVS_AmbiaMara_Settings().showStoplights else { return }
        
        guard _isTimerRunning else {
            startLightImageView?.alpha = Self._stoplightPausedAlpha
            warnLightImageView?.alpha = Self._stoplightPausedAlpha
            finalLightImageView?.alpha = Self._stoplightPausedAlpha
            return
        }
        
        if inCurrentTime > RVS_AmbiaMara_Settings().currentTimer.warnTime {
            startLightImageView?.alpha = 1.0
            warnLightImageView?.alpha = Self._stoplightDimmedAlpha
            finalLightImageView?.alpha = Self._stoplightDimmedAlpha
        } else if inCurrentTime > RVS_AmbiaMara_Settings().currentTimer.finalTime {
            startLightImageView?.alpha = Self._stoplightDimmedAlpha
            warnLightImageView?.alpha = 1.0
            finalLightImageView?.alpha = Self._stoplightDimmedAlpha
        } else if inCurrentTime > 0 {
            startLightImageView?.alpha = Self._stoplightDimmedAlpha
            warnLightImageView?.alpha = Self._stoplightDimmedAlpha
            finalLightImageView?.alpha = 1.0
        } else {
            startLightImageView?.alpha = Self._stoplightDimmedAlpha
            warnLightImageView?.alpha = Self._stoplightDimmedAlpha
            finalLightImageView?.alpha = Self._stoplightDimmedAlpha
        }
    }
    
    /* ############################################################## */
    /**
     This determines the proper color for the digit "LEDs."
     - parameter inCurrentTime: Optional. Default is 0. This is the elapsed time, in seconds.
     */
    func determineDigitLEDColor(_ inCurrentTime: Int = 0) {
        guard RVS_AmbiaMara_Settings().showDigits else { return }
        
        guard _isTimerRunning else {
            digitalDisplayViewHours?.onGradientStartColor = Self._pausedLEDColor
            digitalDisplayViewMinutes?.onGradientStartColor = Self._pausedLEDColor
            digitalDisplayViewSeconds?.onGradientStartColor = Self._pausedLEDColor
            return
        }
        
        if inCurrentTime <= RVS_AmbiaMara_Settings().currentTimer.finalTime {
            digitalDisplayViewHours?.onGradientStartColor = Self._finalLEDColor
            digitalDisplayViewMinutes?.onGradientStartColor = Self._finalLEDColor
            digitalDisplayViewSeconds?.onGradientStartColor = Self._finalLEDColor
        } else if inCurrentTime <= RVS_AmbiaMara_Settings().currentTimer.warnTime {
            digitalDisplayViewHours?.onGradientStartColor = Self._warnLEDColor
            digitalDisplayViewMinutes?.onGradientStartColor = Self._warnLEDColor
            digitalDisplayViewSeconds?.onGradientStartColor = Self._warnLEDColor
        } else {
            digitalDisplayViewHours?.onGradientStartColor = Self._initialLEDColor
            digitalDisplayViewMinutes?.onGradientStartColor = Self._initialLEDColor
            digitalDisplayViewSeconds?.onGradientStartColor = Self._initialLEDColor
        }
    }
    
    /* ############################################################## */
    /**
     This will flash the screen, for transitions between timer states.
     It will also set the colors for the digits and/or traffic lights.
     - parameter inCurrentTime: The elapsed time, in seconds.
     */
    func flashIfNecessary() {
        // Look for a threshold crossing.
        let previousTime = RVS_AmbiaMara_Settings().currentTimer.startTime - _tickTime
        
        if previousTime > RVS_AmbiaMara_Settings().currentTimer.warnTime,
           _isWarning {
            flashYellow()
        } else if previousTime > RVS_AmbiaMara_Settings().currentTimer.finalTime,
                  _isFinal {
            flashRed()
        }
    }
    
    /* ############################################################## */
    /**
     This flashes the screen briefly green
     */
    func flashGreen() {
        flasherView?.backgroundColor = UIColor(named: "Start-Color")
        UIView.animate(withDuration: Self._flashDuration, animations: {
            self.flasherView?.backgroundColor = .clear
        })
    }
    
    /* ############################################################## */
    /**
     This flashes the screen briefly yellow
     */
    func flashYellow() {
        flasherView?.backgroundColor = UIColor(named: "Warn-Color")
        UIView.animate(withDuration: Self._flashDuration, animations: {
            self.flasherView?.backgroundColor = .clear
        })
    }

    /* ############################################################## */
    /**
     This flashes the screen briefly red
     */
    func flashRed() {
        flasherView?.backgroundColor = UIColor(named: "Final-Color")
        UIView.animate(withDuration: Self._flashDuration, animations: {
            self.flasherView?.backgroundColor = .clear
        })
    }

    /* ############################################################## */
    /**
     This sets the digits, directly.
     - parameter hours: The hour number
     - parameter minutes: The minute number
     - parameter seconds: The second number.
     */
    func setDigitalTimeAs(hours inHours: Int, minutes inMinutes: Int, seconds inSeconds: Int) {
        if RVS_AmbiaMara_Settings().showDigits {
            digitalDisplayViewMinutes?.hasLeadingZeroes = 0 < inHours
            digitalDisplayViewSeconds?.hasLeadingZeroes = 0 < inHours || 0 < inMinutes
            digitalDisplayViewHours?.value = inHours
            digitalDisplayViewMinutes?.value = inMinutes
            digitalDisplayViewSeconds?.value = inSeconds
        }
    }
    
    /* ############################################################## */
    /**
     This calculates the current time, and sets the digital display to that time.
     */
    func setDigitDisplayTime() {
        guard RVS_AmbiaMara_Settings().showDigits,
              let startingTime = _startingTime?.timeIntervalSince1970 else { return }
        
        var differenceInSeconds = RVS_AmbiaMara_Settings().currentTimer.startTime - Int(Date().timeIntervalSince1970 - startingTime)
        
        let hours = Int(differenceInSeconds / (60 * 60))
        differenceInSeconds -= (hours * 60 * 60)
        let minutes = Int(differenceInSeconds / 60)
        differenceInSeconds -= (minutes * 60)
        let seconds = differenceInSeconds
        
        setDigitalTimeAs(hours: 0 < hours ? hours : -2, minutes: (0 < minutes || 0 < hours) ? minutes : -2, seconds: seconds)
    }

    /* ################################################################## */
    /**
     This plays any sound, using a given URL.
     
     - parameter inSoundURL: This is the URI to the sound resource.
     */
    func playThisSound(_ inSoundURL: URL) {
        do {
            if nil == _audioPlayer {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []) // This line ensures that the sound will play, even with the ringer off.
                try _audioPlayer = AVAudioPlayer(contentsOf: inSoundURL)
                _audioPlayer?.numberOfLoops = -1
            }
            _audioPlayer?.play()
        } catch {
            #if DEBUG
                print("ERROR! Attempt to play sound failed: \(String(describing: error))")
            #endif
        }
    }
}

/* ###################################################################################################################################### */
// MARK: RVS_BasicGCDTimerDelegate Conformance
/* ###################################################################################################################################### */
extension RVS_TimerAmbiaMara_ViewController: RVS_BasicGCDTimerDelegate {
    /* ############################################################## */
    /**
     Called when the timer fires.
     
     - parameter inTimer: The timer
     */
    func basicGCDTimerCallback(_ inTimer: RVS_BasicGCDTimer) {
        guard _isTimerRunning || _isAlarming else { return }
        guard !_isAlarming else {
            if RVS_AmbiaMara_Settings().useVibrate {
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            }
            flashRed()
            return
        }
        setUpToolbar()
        setTimerDisplay()
        guard let startingTime = _startingTime?.timeIntervalSince1970 else { return }
        let differenceInSeconds = Int(Date().timeIntervalSince1970 - startingTime)
        guard differenceInSeconds != _tickTime else { return }
        flashIfNecessary()
        _tickTime = differenceInSeconds

        setDigitDisplayTime()
        
        if 0 >= (RVS_AmbiaMara_Settings().currentTimer.startTime - differenceInSeconds) {
            _isAlarming = true
        }
    }
}
