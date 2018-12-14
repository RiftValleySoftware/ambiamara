/**
 © Copyright 2018, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

/* ###################################################################################################################################### */

import UIKit
import AudioToolbox
import AVKit

/* ###################################################################################################################################### */
/**
 */
class TimerRuntimeViewController: TimerNavBaseController {
    // MARK: - Private Instance Properties
    /* ################################################################################################################################## */
    private let _stoplightDualModeHeightFactor: CGFloat = 0.15
    private let _stoplightMaxWidthFactor: CGFloat = 0.2
    private let _tickVolume: Float = 0.005
    private var _originalValue: Int = 0                         ///< Tracks the last value, so we make sure we don't "blink" until we're supposed to.
    
    // MARK: - Internal Constant Instance Properties
    /* ################################################################################################################################## */
    let pauseButtonImageName = "Phone-Pause"
    let startButtonImageName = "Phone-Start"
    let offStoplightImageName = "OffLight"
    let greenStoplightImageName = "GreenLight"
    let yellowStoplightImageName = "YellowLight"
    let redStoplightImageName = "RedLight"
    
    // MARK: - Internal Instance Properties
    /* ################################################################################################################################## */
    var stoplightContainerView: UIView! = nil
    var redLight: UIImageView! = nil
    var yellowLight: UIImageView! = nil
    var greenLight: UIImageView! = nil
    var myHandler: TimerSetController! = nil
    var audioPlayer: AVAudioPlayer!
    var tickPlayer: AVAudioPlayer!

    // MARK: - IB Properties
    /* ################################################################################################################################## */
    @IBOutlet weak var pauseButton: UIBarButtonItem!
    @IBOutlet weak var stopButton: UIBarButtonItem!
    @IBOutlet weak var resetButton: UIBarButtonItem!
    @IBOutlet weak var endButton: UIBarButtonItem!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var timeDisplay: LED_ClockView!
    @IBOutlet weak var flasherView: UIView!
    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var myNavigationBar: UINavigationBar!

    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    @IBOutlet var resetSwipeRecognizer: UISwipeGestureRecognizer!
    @IBOutlet var endSwipeRecognizer: UISwipeGestureRecognizer!
    
    // MARK: - Private Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Bring in the setup screen.
     */
    private func _setUpDisplay() {
        if nil != self.pauseButton {
            self.pauseButton.image = UIImage(named: .Paused == self.timerObject.timerStatus ? self.startButtonImageName: self.pauseButtonImageName)
            self.pauseButton.isEnabled = (0 < self.timerObject.currentTime)
        }
        
        if nil != self.resetButton {
            self.resetButton.isEnabled = (self.timerObject.currentTime < self.timerObject.timeSet)
        }
        
        if nil != self.endButton {
            self.endButton.isEnabled = (0 < self.timerObject.currentTime)
        }
        
        if .Podium != self.timerObject.displayMode && nil != self.timeDisplay {
            if self._originalValue != self.timerObject.currentTime {
                self._originalValue = self.timerObject.currentTime
                self.timeDisplay.hours = TimeTuple(self.timerObject.currentTime).hours
                self.timeDisplay.minutes = TimeTuple(self.timerObject.currentTime).minutes
                self.timeDisplay.seconds = TimeTuple(self.timerObject.currentTime).seconds
                self.timeDisplay.setNeedsDisplay()
            }
        }
        
        if .Digital != self.timerObject.displayMode && nil != self.stoplightContainerView {
            switch self.timerObject.timerStatus {
            case .Paused:
                self.greenLight.isHighlighted = false
                self.yellowLight.isHighlighted = false
                self.redLight.isHighlighted = false
                
            case .Running:
                self.greenLight.isHighlighted = true
                self.yellowLight.isHighlighted = false
                self.redLight.isHighlighted = false
                
            case .WarnRun:
                self.greenLight.isHighlighted = false
                self.yellowLight.isHighlighted = true
                self.redLight.isHighlighted = false
                
            case .FinalRun:
                self.greenLight.isHighlighted = false
                self.yellowLight.isHighlighted = false
                self.redLight.isHighlighted = true
                
            case .Alarm:
                self.greenLight.isHighlighted = false
                self.yellowLight.isHighlighted = false
                self.redLight.isHighlighted = false
                
            default:
                break
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    private func _playAlertSound() {
        if nil == self.audioPlayer {
            var soundUrl: URL!
            
            switch self.timerObject.soundMode {
            case .Sound:
                soundUrl = URL(string: Timer_AppDelegate.appDelegateObject.timerEngine.soundSelection[self.timerObject.soundID].urlEncodedString ?? "")
                
            case.Music:
                soundUrl = URL(string: self.timerObject.songURLString)
                
            default:
                break
            }
            
            if nil != soundUrl {
                self.playThisSound(soundUrl)
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    private func _playTickSound(times inTimes: Int = 1) {
        if nil == self.audioPlayer, self.timerObject.audibleTicks {
            let soundUrl: URL! = URL(string: Timer_AppDelegate.appDelegateObject.timerEngine.tickURI.urlEncodedString ?? "")
            
            if nil != soundUrl {
                self.playThisSound(soundUrl, times: inTimes)
            }
        }
    }

    /* ################################################################## */
    /**
     This plays any sound, using a given URL.
     
     - parameter inSoundURL: This is the URI to the sound resource.
     - parameter times: Optional Int that specifies how many times the sound will play. Default is infinite loop.
     */
    func playThisSound(_ inSoundURL: URL, times inTimes: Int = 0) {
        if 0 < inTimes {   // Just this once...
            DispatchQueue.main.async {
                do {
                    try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []) // This line ensures that the sound will play, even with the ringer off.
                    try self.tickPlayer = AVAudioPlayer(contentsOf: inSoundURL)
                    self.tickPlayer?.volume = self._tickVolume
                    self.tickPlayer?.numberOfLoops = inTimes
                    self.tickPlayer?.play()
                } catch {
                }
            }
        } else {
            do {
                if nil == self.audioPlayer {
                    try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []) // This line ensures that the sound will play, even with the ringer off.
                    try self.audioPlayer = AVAudioPlayer(contentsOf: inSoundURL)
                    self.audioPlayer?.numberOfLoops = -1   // Repeat indefinitely
                }
                self.audioPlayer?.play()
            } catch {
            }
        }
    }
    
    /* ################################################################## */
    /**
     If the audio player is going, this pauses it. Nothing happens if no audio player is going.
     */
    func pauseAudioPlayer() {
        if nil != self.audioPlayer {
            self.audioPlayer?.pause()
        }
    }
    
    /* ################################################################## */
    /**
     This terminates the audio player. Nothing happens if no audio player is going.
     */
    func stopAudioPlayer() {
        if nil != self.audioPlayer {
            self.audioPlayer?.stop()
            self.audioPlayer = nil
        }
    }

    // MARK: - Internal Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func pauseTimer() {
        self.flashDisplay(UIColor.red.withAlphaComponent(0.5), duration: 0.5)
        Timer_AppDelegate.appDelegateObject.timerEngine.pauseTimer()
    }
    
    /* ################################################################## */
    /**
     */
    func continueTimer() {
        if Timer_AppDelegate.appDelegateObject.timerEngine.appState.showControlsInRunningTimer {
            self.navBarItem.title = ""
        }
        
        self.flashDisplay(UIColor.green.withAlphaComponent(0.5), duration: 0.5)
        Timer_AppDelegate.appDelegateObject.timerEngine.continueTimer()
    }
    
    /* ################################################################## */
    /**
     */
    func stopTimer() {
        self.flashDisplay(UIColor.red, duration: 0.5)
        self.stopAudioPlayer()
        Timer_AppDelegate.appDelegateObject.timerEngine.stopTimer()
    }
    
    /* ################################################################## */
    /**
     */
    func endTimer() {
        if Timer_AppDelegate.appDelegateObject.timerEngine.appState.showControlsInRunningTimer {
            self.navBarItem.title = ""
        }
        
        self.stopAudioPlayer()
        Timer_AppDelegate.appDelegateObject.timerEngine.endTimer()
    }
    
    /* ################################################################## */
    /**
     */
    func resetTimer() {
        self.stopAudioPlayer()
        if .Paused != self.timerObject.timerStatus {
            self.flashDisplay(UIColor.red.withAlphaComponent(0.5), duration: 0.5)
        } else {
            self.flashDisplay(UIColor.white.withAlphaComponent(0.5), duration: 0.5)
        }
        
        Timer_AppDelegate.appDelegateObject.timerEngine.resetTimer()
    }
    
    /* ################################################################## */
    /**
     */
    func updateTimer() {
        self._setUpDisplay()
        
        self.timeDisplay.accessibilityLabel = self.timerObject.currentQuickSpeakableTime
        self.timeDisplay.isAccessibilityElement = true

        self.timeDisplay.isHidden = (.Podium == self.timerObject.displayMode) || (.Alarm == self.timerObject.timerStatus)
        if nil != self.stoplightContainerView {
            self.stoplightContainerView.isHidden = (.Alarm == self.timerObject.timerStatus)
        }
        
        if .Alarm == self.timerObject.timerStatus {
            self.flashDisplay()
            self._playAlertSound()
            if .VibrateOnly == self.timerObject.alertMode || .Both == self.timerObject.alertMode {
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func tick(times inTimes: Int = 1) {
        self._playTickSound(times: inTimes)
    }

    /* ################################################################## */
    /**
     */
    func flashDisplay(_ inUIColor: UIColor! = nil, duration: TimeInterval = 0.75) {
        DispatchQueue.main.async {
            if nil != inUIColor {
                self.flasherView.backgroundColor = inUIColor
            } else {
                switch self.timerObject.timerStatus {
                case .WarnRun:
                    self.flasherView.backgroundColor = UIColor.yellow
                case.FinalRun:
                    self.flasherView.backgroundColor = UIColor.orange
                default:
                    self.flasherView.backgroundColor = UIColor.red
                }
            }
            
            self.flasherView.isHidden = false
            self.flasherView.alpha = 1.0
            UIView.animate(withDuration: duration, animations: {
                self.flasherView.alpha = 0.0
            })
        }
    }

    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tapRecognizer.require(toFail: resetSwipeRecognizer)
        self.tapRecognizer.require(toFail: endSwipeRecognizer)
        
        let tempRect = CGRect(origin: CGPoint.zero, size: CGSize(width: 75, height: 75))
        
        if .Digital != self.timerObject.displayMode {
            self.stoplightContainerView = UIView(frame: tempRect)
            self.stoplightContainerView.isUserInteractionEnabled = false
            
            self.greenLight = UIImageView(frame: tempRect)
            self.yellowLight = UIImageView(frame: tempRect)
            self.redLight = UIImageView(frame: tempRect)
            
            self.stoplightContainerView.addSubview(self.greenLight)
            self.stoplightContainerView.addSubview(self.yellowLight)
            self.stoplightContainerView.addSubview(self.redLight)
            
            self.greenLight.contentMode = .scaleAspectFit
            self.yellowLight.contentMode = .scaleAspectFit
            self.redLight.contentMode = .scaleAspectFit
            
            self.greenLight.image = UIImage(named: self.offStoplightImageName)
            self.yellowLight.image = UIImage(named: self.offStoplightImageName)
            self.redLight.image = UIImage(named: self.offStoplightImageName)
            self.greenLight.highlightedImage = UIImage(named: self.greenStoplightImageName)
            self.yellowLight.highlightedImage = UIImage(named: self.yellowStoplightImageName)
            self.redLight.highlightedImage = UIImage(named: self.redStoplightImageName)
            
            self.view.addSubview(self.stoplightContainerView)
        }
        
        if let backgroundColor = Timer_AppDelegate.appDelegateObject.timerEngine.colorLabelArray[self.timerObject.colorTheme].backgroundColor {
            self.timeDisplay.activeSegmentColor = backgroundColor
        }
        
        self.timeDisplay.inactiveSegmentColor = UIColor.white.withAlphaComponent(0.1)
        self.updateTimer()
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if nil != self.stoplightContainerView {
            let verticalPadding: CGFloat = (.Dual == self.timerObject.displayMode) ? 4: 0
            var containerRect = self.view.bounds.inset(by: self.view.safeAreaInsets)
            var maxWidth = (containerRect.size.width * self._stoplightMaxWidthFactor)
            
            if .Dual == self.timerObject.displayMode {
                maxWidth = min(maxWidth, containerRect.size.height * self._stoplightDualModeHeightFactor)
                containerRect.origin.y = containerRect.size.height - (maxWidth + (verticalPadding * 2))
                containerRect.size.height = maxWidth + (verticalPadding * 2)
            }
            
            self.stoplightContainerView.frame = containerRect
            
            let yPos = (containerRect.size.height / 2) - ((maxWidth / 2) + verticalPadding)
            let stopLightSize = CGSize(width: maxWidth, height: maxWidth)
            let greenPos = CGPoint(x: (containerRect.size.width / 4) - (maxWidth / 2), y: yPos)
            let yellowPos = CGPoint(x: (containerRect.size.width / 2) - (maxWidth / 2), y: yPos )
            let redPos = CGPoint(x: (containerRect.size.width - (containerRect.size.width / 4)) - (maxWidth / 2), y: yPos)
            
            let greenFrame = CGRect(origin: greenPos, size: stopLightSize)
            let yellowFrame = CGRect(origin: yellowPos, size: stopLightSize)
            let redFrame = CGRect(origin: redPos, size: stopLightSize)
            
            self.greenLight.frame = greenFrame
            self.yellowLight.frame = yellowFrame
            self.redLight.frame = redFrame
        }

        self._originalValue = 0
        
        self.updateTimer()
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = true
        super.viewWillAppear(animated)
        
        if Timer_AppDelegate.appDelegateObject.timerEngine.appState.showControlsInRunningTimer {
            self.myNavigationBar.tintColor = self.view.tintColor
            self.myNavigationBar.backgroundColor = UIColor.black
            self.myNavigationBar.barTintColor = UIColor.black
            self.myNavigationBar.isHidden = false
        } else {
            self.myNavigationBar.isHidden = true
        }
        
        Timer_AppDelegate.appDelegateObject.currentTimer = self
        Timer_AppDelegate.appDelegateObject.timerEngine.selectedTimerUID = self.timerObject.uid
        Timer_AppDelegate.appDelegateObject.timerEngine.startTimer()
        
        UIAccessibility.post(notification: .layoutChanged, argument: self.timeDisplay)
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillDisappear(_ animated: Bool) {
        self.myHandler.runningTimer = nil
        if let navController = self.navigationController {
            navController.navigationBar.isHidden = false
        }
        
        super.viewWillDisappear(animated)
        
        Timer_AppDelegate.appDelegateObject.currentTimer = nil
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    /* ################################################################################################################################## */
    /**
     This method adds all the accessibility stuff.
     */
    override func addAccessibilityStuff() {
        self.view.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-SCREEN-LABEL".localizedVariant
        self.view.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-SCREEN-HINT".localizedVariant
        
        self.flasherView.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-ALARM-LABEL".localizedVariant
        self.flasherView.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-ALARM-HINT".localizedVariant
        
        self.stopButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-STOP-BUTTON-LABEL".localizedVariant
        self.stopButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-STOP-BUTTON-HINT".localizedVariant
        
        self.resetButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-REWIND-BUTTON-LABEL".localizedVariant
        self.resetButton.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-REWIND-BUTTON-HINT".localizedVariant
        
        self.endButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-END-BUTTON-LABEL".localizedVariant
        self.endButton.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-END-BUTTON-HINT".localizedVariant
        
        self.pauseButton.accessibilityLabel = (.Running == self.timerObject.timerStatus ? "LGV_TIMER-ACCESSIBILITY-PAUSE-BUTTON-LABEL" : "LGV_TIMER-ACCESSIBILITY-START-BUTTON-LABEL").localizedVariant
        self.pauseButton.accessibilityHint = (.Running == self.timerObject.timerStatus ? "LGV_TIMER-ACCESSIBILITY-PAUSE-BUTTON-HINT" : "LGV_TIMER-ACCESSIBILITY-START-BUTTON-HINT").localizedVariant
    }

    // MARK: - IB Action Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBAction func stopButtonHit(_ sender: Any) {
        if .Alarm == self.timerObject.timerStatus {
            self.resetTimer()
            if 0 <= Timer_AppDelegate.appDelegateObject.appState.nextTimer, let myTabController = Timer_AppDelegate.appDelegateObject.mainTabController {
                Timer_AppDelegate.appDelegateObject.timerEngine.stopTimer()
                myTabController.timerEngine.selectedTimerIndex = Timer_AppDelegate.appDelegateObject.appState.nextTimer
            }
        }
        self.stopTimer()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func endButtonHit(_ sender: Any) {
        if .Alarm == self.timerObject.timerStatus {
            self.resetTimer()
        } else {
            self.endTimer()
        }
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func resetButtonHit(_ sender: Any) {
        if (.Paused == self.timerObject.timerStatus) && (self.timerObject.timeSet == self.timerObject.currentTime) {
            self.stopTimer()
        } else {
            self.resetTimer()
        }
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func pauseButtonHit(_ sender: Any! = nil) {
        if .Paused == self.timerObject.timerStatus {
            self.continueTimer()
        } else if (.Podium == self.timerObject.displayMode) && (.Stopped != self.timerObject.timerStatus) {
            self.resetTimer()
        } else {
            self.pauseTimer()
        }
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func tapInView(_ sender: Any) {
        if .Alarm == self.timerObject.timerStatus {
            self.resetTimer()
            if 0 <= Timer_AppDelegate.appDelegateObject.appState.nextTimer, let myTabController = Timer_AppDelegate.appDelegateObject.mainTabController {
                Timer_AppDelegate.appDelegateObject.timerEngine.stopTimer()
                myTabController.timerEngine.selectedTimerIndex = Timer_AppDelegate.appDelegateObject.appState.nextTimer
            }
        } else {
            self.pauseButtonHit()
        }
    }
}
