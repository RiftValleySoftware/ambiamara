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
    private static var _stoplightDimmedAlpha = CGFloat(0.15)

    /* ############################################################## */
    /**
     */
    private static var _stoplightPausedAlpha = CGFloat(0.35)

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
    private var _timer: RVS_BasicGCDTimer?
    
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
        
        _soundSelection = Bundle.main.paths(forResourcesOfType: "mp3", inDirectory: nil).sorted()

        trafficLightsContainerView?.isHidden = !RVS_AmbiaMara_Settings().showStoplights
        digitalDisplayContainerView?.isHidden = !RVS_AmbiaMara_Settings().showDigits
        
        if RVS_AmbiaMara_Settings().showDigits {
            digitalDisplayContainerView?.autoLayoutAspectConstraint(aspectRatio: 0.2)?.isActive = true
            digitalDisplayViewHours?.radix = 10
            digitalDisplayViewMinutes?.radix = 10
            digitalDisplayViewSeconds?.radix = 10
        }
        
        _timer = RVS_BasicGCDTimer(timeIntervalInSeconds: 0.25, delegate: self, leewayInMilliseconds: 50, onlyFireOnce: false, queue: .main, isWallTime: true)
        
        initializeTimer()
    }
    
    /* ############################################################## */
    /**
     */
    override func viewWillDisappear(_ inIsAnimated: Bool) {
        super.viewWillDisappear(inIsAnimated)
        pauseTimer()
        _timer = nil
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RVS_TimerAmbiaMara_ViewController {
    /* ############################################################## */
    /**
     */
    func initializeTimer() {
        let hours = 0 < RVS_AmbiaMara_Settings().currentTimer.startTimeAsComponents[0] ? RVS_AmbiaMara_Settings().currentTimer.startTimeAsComponents[0] : -2
        let minutes = 0 < RVS_AmbiaMara_Settings().currentTimer.startTimeAsComponents[1] ? RVS_AmbiaMara_Settings().currentTimer.startTimeAsComponents[1] : 0 < hours ? 0 : -2
        let seconds = 0 < RVS_AmbiaMara_Settings().currentTimer.startTimeAsComponents[2] ? RVS_AmbiaMara_Settings().currentTimer.startTimeAsComponents[2] : 0 < hours || 0 < minutes ? 0 : -2
        
        setTimeAs(hours: hours, minutes: minutes, seconds: seconds)

        if RVS_AmbiaMara_Settings().startTimerImmediately {
            startTimer()
        } else {
            pauseTimer()
        }
    }
    
    /* ############################################################## */
    /**
     */
    func startTimer() {
        _startingTime = Date()
        _tickTime = 0
        continueTimer()
        determineCurrentLEDColor()
        determineCurrentTrafficLightColor()
    }
    
    /* ############################################################## */
    /**
     */
    func pauseTimer() {
        _timer?.isRunning = false
        stopSounds()
        determineCurrentLEDColor()
        determineCurrentTrafficLightColor()
    }
    
    /* ############################################################## */
    /**
     */
    func continueTimer() {
        determineCurrentLEDColor(_tickTime)
        determineCurrentTrafficLightColor(_tickTime)
        _timer?.isRunning = true
    }
    
    /* ############################################################## */
    /**
     */
    func stopTimer() {
        navigationController?.popViewController(animated: true)
    }
    
    /* ############################################################## */
    /**
     */
    func stopSounds() {
        _isSoundPlaying = false
    }

    /* ############################################################## */
    /**
     */
    func alarm() {
        _timer?.isRunning = false
        if RVS_AmbiaMara_Settings().alarmMode {
            _isSoundPlaying = true
        }
        setTimeAs(hours: -2, minutes: -2, seconds: -2)
    }
    
    /* ############################################################## */
    /**
     */
    func determineCurrentTrafficLightColor(_ inCurrentTime: Int = 0) {
        let coutdownTime = RVS_AmbiaMara_Settings().currentTimer.startTime - inCurrentTime
        
        guard _timer?.isRunning ?? false else {
            startLightImageView?.alpha = Self._stoplightPausedAlpha
            warnLightImageView?.alpha = Self._stoplightPausedAlpha
            finalLightImageView?.alpha = Self._stoplightPausedAlpha
            return
        }
        
        if coutdownTime > RVS_AmbiaMara_Settings().currentTimer.warnTime {
            startLightImageView?.alpha = 1.0
            warnLightImageView?.alpha = Self._stoplightDimmedAlpha
            finalLightImageView?.alpha = Self._stoplightDimmedAlpha
        } else if coutdownTime > RVS_AmbiaMara_Settings().currentTimer.finalTime {
            startLightImageView?.alpha = Self._stoplightDimmedAlpha
            warnLightImageView?.alpha = 1.0
            finalLightImageView?.alpha = Self._stoplightDimmedAlpha
        } else if coutdownTime > 0 {
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
     */
    func determineCurrentLEDColor(_ inCurrentTime: Int = 0) {
        let coutdownTime = RVS_AmbiaMara_Settings().currentTimer.startTime - inCurrentTime
        
        guard _timer?.isRunning ?? false else {
            digitalDisplayViewHours?.onGradientStartColor = Self._pausedLEDColor
            digitalDisplayViewMinutes?.onGradientStartColor = Self._pausedLEDColor
            digitalDisplayViewSeconds?.onGradientStartColor = Self._pausedLEDColor
            return
        }
        
        if coutdownTime <= RVS_AmbiaMara_Settings().currentTimer.finalTime {
            digitalDisplayViewHours?.onGradientStartColor = Self._finalLEDColor
            digitalDisplayViewMinutes?.onGradientStartColor = Self._finalLEDColor
            digitalDisplayViewSeconds?.onGradientStartColor = Self._finalLEDColor
        } else if coutdownTime <= RVS_AmbiaMara_Settings().currentTimer.warnTime {
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
     */
    func flashIfNecessary(_ inCurrentTime: Int) {
        determineCurrentLEDColor(inCurrentTime)
        determineCurrentTrafficLightColor(inCurrentTime)
        let previousTime = RVS_AmbiaMara_Settings().currentTimer.startTime - _tickTime
        let coutdownTime = RVS_AmbiaMara_Settings().currentTimer.startTime - inCurrentTime
        
        if previousTime > RVS_AmbiaMara_Settings().currentTimer.warnTime,
           coutdownTime <= RVS_AmbiaMara_Settings().currentTimer.warnTime {
            flashYellow()
        } else if previousTime > RVS_AmbiaMara_Settings().currentTimer.finalTime,
                  coutdownTime <= RVS_AmbiaMara_Settings().currentTimer.finalTime {
            flashRed()
        }
    }
    
    /* ############################################################## */
    /**
     */
    func flashGreen() {
        
    }
    
    /* ############################################################## */
    /**
     */
    func flashYellow() {
        
    }

    /* ############################################################## */
    /**
     */
    func flashRed() {
        
    }

    /* ############################################################## */
    /**
     */
    func setTimeAs(hours inHours: Int, minutes inMinutes: Int, seconds inSeconds: Int) {
        if RVS_AmbiaMara_Settings().showDigits {
            digitalDisplayViewMinutes?.hasLeadingZeroes = 0 < inHours
            digitalDisplayViewSeconds?.hasLeadingZeroes = 0 < inHours || 0 < inMinutes
            digitalDisplayViewHours?.value = inHours
            digitalDisplayViewMinutes?.value = inMinutes
            digitalDisplayViewSeconds?.value = inSeconds
        }
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
     */
    func basicGCDTimerCallback(_ timer: RVS_BasicGCDTimer) {
        guard let startingTime = _startingTime?.timeIntervalSince1970 else { return }
        var differenceInSeconds = Int(Date().timeIntervalSince1970 - startingTime)
        guard differenceInSeconds != _tickTime else { return }
        flashIfNecessary(differenceInSeconds)
        _tickTime = differenceInSeconds
        differenceInSeconds = RVS_AmbiaMara_Settings().currentTimer.startTime - differenceInSeconds
        
        let hours = Int(differenceInSeconds / (60 * 60))
        differenceInSeconds -= (hours * 60 * 60)
        let minutes = Int(differenceInSeconds / 60)
        differenceInSeconds -= (minutes * 60)
        let seconds = differenceInSeconds
        
        setTimeAs(hours: 0 < hours ? hours : -2, minutes: (0 < minutes || 0 < hours) ? minutes : -2, seconds: seconds)
        
        if 0 >= differenceInSeconds {
            alarm()
        }
    }
}
