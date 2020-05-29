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
class TimerRuntimeViewController: A_TimerNavBaseController {
    /* ################################################################################################################################## */
    // MARK: - Private Instance Properties
    /* ################################################################################################################################## */
    /// The height, as a multiplier, of the dual mode "traffic lights" section
    private let _stoplightDualModeHeightFactor: CGFloat = 0.15
    /// The maximum width, as a multiplier, of the podium mode "traffic lights" section
    private let _stoplightMaxWidthFactor: CGFloat = 0.2
    /// The volume as a multiplier, of each audible "tick."
    private let _tickVolume: Float = 0.015
    /// Tracks the last value, so we make sure we don't "blink" until we're supposed to.
    private var _originalValue: Int = 0
    
    /* ################################################################################################################################## */
    // MARK: - Internal Constant Instance Properties
    /* ################################################################################################################################## */
    /// The name of the pause button image.
    let pauseButtonImageName = "Phone-Pause"
    /// The name of the start button image.
    let startButtonImageName = "Phone-Start"
    /// The name of the "unlit" podium mode traffic light image.
    let offStoplightImageName = "OffLight"
    /// The name of the "green" podium mode traffic light image.
    let greenStoplightImageName = "GreenLight"
    /// The name of the "yellow" podium mode traffic light image.
    let yellowStoplightImageName = "YellowLight"
    /// The name of the "red" podium mode traffic light image.
    let redStoplightImageName = "RedLight"
    
    /* ################################################################################################################################## */
    // MARK: - Internal Instance Properties
    /* ################################################################################################################################## */
    /// The container view for the podium/dual mode lights
    var stoplightContainerView: UIView! = nil
    /// The red light image
    var redLight: UIImageView! = nil
    /// The yellow light image
    var yellowLight: UIImageView! = nil
    /// The green light image
    var greenLight: UIImageView! = nil
    /// The controller that controls this
    var myHandler: TimerSetController! = nil
    /// The audio player that handles songs and sounds
    var audioPlayer: AVAudioPlayer!
    /// The audio player that handles each tick
    var tickPlayer: AVAudioPlayer!

    /* ################################################################################################################################## */
    // MARK: - IB Properties
    /* ################################################################################################################################## */
    /// The pause button in the control bar
    @IBOutlet weak var pauseButton: UIBarButtonItem!
    /// The stop button in the control bar
    @IBOutlet weak var stopButton: UIBarButtonItem!
    /// The reset button in the control bar
    @IBOutlet weak var resetButton: UIBarButtonItem!
    /// The "fast-forward-to-end" button in the control bar
    @IBOutlet weak var endButton: UIBarButtonItem!
    /// The navigation item for this instance
    @IBOutlet weak var navItem: UINavigationItem!
    /// The time display
    @IBOutlet weak var timeDisplay: LED_ClockView!
    /// The view that displays the flashing lights
    @IBOutlet weak var flasherView: UIView!
    /// The navigation bar item for this instance
    @IBOutlet weak var navBarItem: UINavigationItem!
    /// The navigation bar for this instance
    @IBOutlet weak var myNavigationBar: UINavigationBar!

    /// The gesture recognizer for single taps
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    /// The gesture recognizer for left-swipes
    @IBOutlet var resetSwipeRecognizer: UISwipeGestureRecognizer!
    /// The gesture recognizer for right-swipes
    @IBOutlet var endSwipeRecognizer: UISwipeGestureRecognizer!
    
    /* ################################################################################################################################## */
    // MARK: - Private Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Bring in the setup screen.
     */
    private func _setUpDisplay() {
        if nil != pauseButton {
            pauseButton.image = UIImage(named: .Paused == timerObject.timerStatus ? startButtonImageName: pauseButtonImageName)
            pauseButton.isEnabled = (0 < timerObject.currentTime)
        }
        
        if nil != resetButton {
            resetButton.isEnabled = (timerObject.currentTime < timerObject.timeSet)
        }
        
        if nil != endButton {
            endButton.isEnabled = (0 < timerObject.currentTime)
        }
        
        if .Podium != timerObject.displayMode && nil != timeDisplay {
            if _originalValue != timerObject.currentTime {
                _originalValue = timerObject.currentTime
                timeDisplay.hours = TimeInstance(timerObject.currentTime).hours
                timeDisplay.minutes = TimeInstance(timerObject.currentTime).minutes
                timeDisplay.seconds = TimeInstance(timerObject.currentTime).seconds
                timeDisplay.setNeedsDisplay()
            }
        }
        
        if .Digital != timerObject.displayMode && nil != stoplightContainerView {
            switch timerObject.timerStatus {
            case .Paused:
                greenLight.isHighlighted = false
                yellowLight.isHighlighted = false
                redLight.isHighlighted = false
                
            case .Running:
                greenLight.isHighlighted = true
                yellowLight.isHighlighted = false
                redLight.isHighlighted = false
                
            case .WarnRun:
                greenLight.isHighlighted = false
                yellowLight.isHighlighted = true
                redLight.isHighlighted = false
                
            case .FinalRun:
                greenLight.isHighlighted = false
                yellowLight.isHighlighted = false
                redLight.isHighlighted = true
                
            case .Alarm:
                greenLight.isHighlighted = false
                yellowLight.isHighlighted = false
                redLight.isHighlighted = false
                
            default:
                break
            }
        }
    }
    
    /* ################################################################## */
    /**
     This plays whatever alert sound has been chosen by the user.
     */
    private func _playAlertSound() {
        if nil == audioPlayer {
            var soundUrl: URL!
            
            switch timerObject.soundMode {
            case .Sound:
                soundUrl = URL(string: Timer_AppDelegate.appDelegateObject.timerEngine.soundSelection[timerObject.soundID].urlEncodedString ?? "")
                
            case.Music:
                soundUrl = URL(string: timerObject.songURLString)
                
            default:
                break
            }
            
            if nil != soundUrl {
                playThisSound(soundUrl)
            }
        }
    }
    
    /* ################################################################## */
    /**
     This plays a "tick" sound.
     
     - parameter times: Optional. Default is 1. This is how many times the tick will be repeated (quick succession).
     */
    private func _playTickSound(times inTimes: Int = 1) {
        if nil == audioPlayer, timerObject.audibleTicks {
            let soundUrl: URL! = URL(string: Timer_AppDelegate.appDelegateObject.timerEngine.tickURI.urlEncodedString ?? "")
            
            if nil != soundUrl {
                playThisSound(soundUrl, times: inTimes)
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
                    self.tickPlayer?.volume = self._tickVolume * Float(inTimes)
                    self.tickPlayer?.numberOfLoops = inTimes
                    self.tickPlayer?.play()
                } catch {
                }
            }
        } else {
            do {
                if nil == audioPlayer {
                    try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []) // This line ensures that the sound will play, even with the ringer off.
                    try audioPlayer = AVAudioPlayer(contentsOf: inSoundURL)
                    audioPlayer?.numberOfLoops = -1   // Repeat indefinitely
                }
                audioPlayer?.play()
            } catch {
            }
        }
    }
    
    /* ################################################################## */
    /**
     If the audio player is going, this pauses it. Nothing happens if no audio player is going.
     */
    func pauseAudioPlayer() {
        if nil != audioPlayer {
            audioPlayer?.pause()
        }
    }
    
    /* ################################################################## */
    /**
     This terminates the audio player. Nothing happens if no audio player is going.
     */
    func stopAudioPlayer() {
        if nil != audioPlayer {
            audioPlayer?.stop()
            audioPlayer = nil
        }
    }

    /* ################################################################################################################################## */
    // MARK: - Instance Override Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     - returns true, indicating that X-phones should hide the Home Bar.
     */
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    /* ################################################################################################################################## */
    // MARK: - Internal Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This pauses a running timer, without dismissing the screen, or resetting the timer.
     
     It will flash the display a "subdued" red.
     */
    func pauseTimer() {
        flashDisplay(UIColor.red.withAlphaComponent(0.5), duration: 0.5)
        Timer_AppDelegate.appDelegateObject.timerEngine.pauseTimer()
    }
    
    /* ################################################################## */
    /**
     This continues a paused timer.
     
     It will flash the display a "subdued" green.
     */
    func continueTimer() {
        flashDisplay(UIColor.green.withAlphaComponent(0.5), duration: 0.5)
        Timer_AppDelegate.appDelegateObject.timerEngine.continueTimer()
    }
    
    /* ################################################################## */
    /**
     This stops a running timer, and dismisses the screen.
     
     It will flash the display a bright red.
     */
    func stopTimer() {
        flashDisplay(UIColor.red, duration: 0.5)
        stopAudioPlayer()
        Timer_AppDelegate.appDelegateObject.timerEngine.stopTimer()
        navigationController?.popViewController(animated: false)
    }
    
    /* ################################################################## */
    /**
     This forces the timer to immediately complete its time, and go into alarm mode.
     */
    func endTimer() {
        stopAudioPlayer()
        Timer_AppDelegate.appDelegateObject.timerEngine.endTimer()
    }
    
    /* ################################################################## */
    /**
     This resets the timer to its starting value, but does not dismiss the screen.
     
     If the timer is paused, this will flash a "subdued" white. If not, it will flash a "subdued" red.
     */
    func resetTimer() {
        stopAudioPlayer()
        if .Paused != timerObject.timerStatus {
            flashDisplay(UIColor.red.withAlphaComponent(0.5), duration: 0.5)
        } else {
            flashDisplay(UIColor.white.withAlphaComponent(0.5), duration: 0.5)
        }
        
        Timer_AppDelegate.appDelegateObject.timerEngine.resetTimer()
    }
    
    /* ################################################################## */
    /**
     This forces the timer to update to match the current timer state.
     */
    func updateTimer() {
        _setUpDisplay()
        
        if let timeDisplay = timeDisplay {
            timeDisplay.accessibilityLabel = timerObject.currentQuickSpeakableTime

            timeDisplay.isHidden = (.Podium == timerObject.displayMode) || (.Alarm == timerObject.timerStatus)
            if nil != stoplightContainerView {
                stoplightContainerView.isHidden = (.Alarm == timerObject.timerStatus)
            }
            
            if .Alarm == timerObject.timerStatus {
                UIApplication.shared.isIdleTimerDisabled = false // Toggle this to "wake" the touch sensor. The system can put it into a "resting" mode, so two touches are required.
                UIApplication.shared.isIdleTimerDisabled = true
                flashDisplay()
                _playAlertSound()
                if .VibrateOnly == timerObject.alertMode || .Both == timerObject.alertMode {
                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     This is called to "play" a tick sound.
     
     - parameter times: Optional. Default is 1. This is how many times the tick will be repeated (quick succession).
     */
    func tick(times inTimes: Int = 1) {
        _playTickSound(times: inTimes)
    }

    /* ################################################################## */
    /**
     This flashes the display, depending on the current state of the timer.
     */
    func flashDisplay(_ inUIColor: UIColor! = nil, duration: TimeInterval = 0.75) {
        DispatchQueue.main.async {
            if nil != inUIColor {
                self.flasherView.backgroundColor = inUIColor
            } else {
                switch self.timerObject.timerStatus {
                case .WarnRun:  // If we are transitioning into the "warning" state, we flash yellow.
                    self.flasherView.backgroundColor = UIColor.yellow
                case.FinalRun:  // If we are transitioning into the "final" state, we flash orange.
                    self.flasherView.backgroundColor = UIColor.orange
                default:        // Otherwise, we are probably in alarm mode, and should flash red.
                    self.flasherView.backgroundColor = UIColor.red
                }
            }
            
            // This is a pulsed brightness animation, with a fast attack, and slow decay.
            self.flasherView.isHidden = false
            self.flasherView.alpha = 1.0
            UIView.animate(withDuration: duration, animations: {
                self.flasherView.alpha = 0.0
            })
        }
    }
    
    /* ################################################################## */
    /**
     This will transition the timer to a following timer, if one is set up.
     
     - parameter inNextTimerIndex: The next timer index. If 0 or greater, then we will cascade to that timer. If less than 0, we ignore.
     */
    func cascadeToNextTimer(_ inNextTimerIndex: Int) {
        if  0 <= inNextTimerIndex, let navigationController = navigationController as? TimerNavController {
            navigationController.selectNextTimer = inNextTimerIndex
            stopTimer()
        }
    }
    
    /* ################################################################################################################################## */
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called after the view has finished loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tapRecognizer.require(toFail: resetSwipeRecognizer)
        tapRecognizer.require(toFail: endSwipeRecognizer)

        let tempRect = CGRect(origin: CGPoint.zero, size: CGSize(width: 75, height: 75))
        
        if .Digital != timerObject.displayMode {
            stoplightContainerView = UIView(frame: tempRect)
            stoplightContainerView.isUserInteractionEnabled = false
            
            greenLight = UIImageView(frame: tempRect)
            yellowLight = UIImageView(frame: tempRect)
            redLight = UIImageView(frame: tempRect)
            
            stoplightContainerView.addSubview(greenLight)
            stoplightContainerView.addSubview(yellowLight)
            stoplightContainerView.addSubview(redLight)
            
            greenLight.contentMode = .scaleAspectFit
            yellowLight.contentMode = .scaleAspectFit
            redLight.contentMode = .scaleAspectFit
            
            greenLight.image = UIImage(named: offStoplightImageName)
            yellowLight.image = UIImage(named: offStoplightImageName)
            redLight.image = UIImage(named: offStoplightImageName)
            greenLight.highlightedImage = UIImage(named: greenStoplightImageName)
            yellowLight.highlightedImage = UIImage(named: yellowStoplightImageName)
            redLight.highlightedImage = UIImage(named: redStoplightImageName)
            
            view.addSubview(stoplightContainerView)
        }
        
        if let backgroundColor = Timer_AppDelegate.appDelegateObject.timerEngine.colorLabelArray[timerObject.colorTheme].backgroundColor {
            timeDisplay.activeSegmentColor = backgroundColor
        }

        timeDisplay.inactiveSegmentColor = UIColor.white.withAlphaComponent(0.1)
        setNeedsUpdateOfHomeIndicatorAutoHidden()
        updateTimer()
    }
    
    /* ################################################################## */
    /**
     Called when the view is about to set up its layout.
     */
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if nil != stoplightContainerView {
            let verticalPadding: CGFloat = (.Dual == timerObject.displayMode) ? 4: 0
            var containerRect = view.bounds.inset(by: view.safeAreaInsets)
            var maxWidth = (containerRect.size.width * _stoplightMaxWidthFactor)
            
            if .Dual == timerObject.displayMode {
                maxWidth = min(maxWidth, containerRect.size.height * _stoplightDualModeHeightFactor)
                containerRect.origin.y = containerRect.size.height - (maxWidth + (verticalPadding * 2))
                containerRect.size.height = maxWidth + (verticalPadding * 2)
            }
            
            stoplightContainerView.frame = containerRect
            
            let yPos = (containerRect.size.height / 2) - ((maxWidth / 2) + verticalPadding)
            let stopLightSize = CGSize(width: maxWidth, height: maxWidth)
            let greenPos = CGPoint(x: (containerRect.size.width / 4) - (maxWidth / 2), y: yPos)
            let yellowPos = CGPoint(x: (containerRect.size.width / 2) - (maxWidth / 2), y: yPos )
            let redPos = CGPoint(x: (containerRect.size.width - (containerRect.size.width / 4)) - (maxWidth / 2), y: yPos)
            
            let greenFrame = CGRect(origin: greenPos, size: stopLightSize)
            let yellowFrame = CGRect(origin: yellowPos, size: stopLightSize)
            let redFrame = CGRect(origin: redPos, size: stopLightSize)
            
            greenLight.frame = greenFrame
            yellowLight.frame = yellowFrame
            redLight.frame = redFrame
        }

        _originalValue = 0
        
        updateTimer()
    }
    
    /* ################################################################## */
    /**
     Called just before the view appears.
     */
    override func viewWillAppear(_ animated: Bool) {
        setUpShop()
        super.viewWillAppear(animated)
        if let navigationController = navigationController as? TimerNavController {
            navigationController.selectNextTimer = -1
        }
        Timer_AppDelegate.recordOriginalBrightness()    // This will record any original brightness, and force our screen brightness to maximum during presentation.
    }
    
    /* ################################################################## */
    /**
     Called just before the view disappears.
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        closeUpShop()
    }
    
    /* ################################################################## */
    /**
     Prepares the timer screen.
     */
    func setUpShop() {
        UIApplication.shared.isIdleTimerDisabled = true
        hidesBottomBarWhenPushed = true
        tabBarController?.tabBar.isHidden = true

        if Timer_AppDelegate.appDelegateObject.timerEngine.appState.showControlsInRunningTimer {
            myNavigationBar.tintColor = view.tintColor
            myNavigationBar.backgroundColor = UIColor.black
            myNavigationBar.barTintColor = UIColor.black
        } else {
            myNavigationBar.isHidden = true
        }

        if let navController = navigationController {
            navController.navigationBar.isHidden = true
        }

        Timer_AppDelegate.appDelegateObject.currentTimer = self
        Timer_AppDelegate.appDelegateObject.timerEngine.selectedTimerUID = timerObject.uid
        Timer_AppDelegate.appDelegateObject.timerEngine.startTimer()
    }
    
    /* ################################################################## */
    /**
     This closes up our various things, and makes things reappear.
     */
    func closeUpShop() {
        myHandler.runningTimer = nil
        if let navController = navigationController {
            navController.navigationBar.isHidden = false
        }
        
        tabBarController?.tabBar.isHidden = false
        hidesBottomBarWhenPushed = false   // We need to do this, or the tab bar will be hidden in the next screen.

        Timer_AppDelegate.restoreOriginalBrightness()   // Restore whatever brightness was set before.
        Timer_AppDelegate.appDelegateObject.currentTimer = nil
        UIApplication.shared.isIdleTimerDisabled = false
    }

    /* ################################################################################################################################## */
    /**
     This method adds all the accessibility stuff.
     */
    override func addAccessibilityStuff() {
        super.addAccessibilityStuff()
        
        view.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-SCREEN-LABEL".localizedVariant
        view.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-SCREEN-HINT".localizedVariant
        
        flasherView.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-ALARM-LABEL".localizedVariant
        flasherView.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-ALARM-HINT".localizedVariant
        
        stopButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-STOP-BUTTON-LABEL".localizedVariant
        stopButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-STOP-BUTTON-HINT".localizedVariant
        
        resetButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-REWIND-BUTTON-LABEL".localizedVariant
        resetButton.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-REWIND-BUTTON-HINT".localizedVariant
        
        endButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-END-BUTTON-LABEL".localizedVariant
        endButton.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-END-BUTTON-HINT".localizedVariant
        
        pauseButton.accessibilityLabel = (.Running == timerObject.timerStatus ? "LGV_TIMER-ACCESSIBILITY-PAUSE-BUTTON-LABEL" : "LGV_TIMER-ACCESSIBILITY-START-BUTTON-LABEL").localizedVariant
        pauseButton.accessibilityHint = (.Running == timerObject.timerStatus ? "LGV_TIMER-ACCESSIBILITY-PAUSE-BUTTON-HINT" : "LGV_TIMER-ACCESSIBILITY-START-BUTTON-HINT").localizedVariant

        timeDisplay.isAccessibilityElement = true
        timeDisplay.accessibilityLabel = timerObject.currentQuickSpeakableTime

        view.accessibilityElements = [timeDisplay as Any, stopButton as Any, resetButton as Any, endButton as Any, pauseButton as Any, flasherView as Any]
        
        UIAccessibility.post(notification: .layoutChanged, argument: timeDisplay)
    }

    /* ################################################################################################################################## */
    // MARK: - IB Action Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the stop button has been hit.
     
     - parameter: Ignored, and optional.
     */
    @IBAction func stopButtonHit(_: Any! = nil) {
        if .Alarm == timerObject.timerStatus, 0 <= Timer_AppDelegate.appDelegateObject.appState.nextTimer {
            cascadeToNextTimer(Timer_AppDelegate.appDelegateObject.appState.nextTimer)
        } else {
            stopTimer()
        }
    }
    
    /* ################################################################## */
    /**
     Called when the end button has been hit (or the right-swipe gesture has happened).
     
     - parameter: Ignored, and optional.
     */
    @IBAction func endButtonHit(_: Any! = nil) {
        if .Alarm == timerObject.timerStatus {
            resetTimer()
        } else {
            endTimer()
        }
    }
    
    /* ################################################################## */
    /**
     Called when the reset button has been hit (or the left-swipe gesture has happened).
     
     - parameter: Ignored, and optional.
     */
    @IBAction func resetButtonHit(_: Any! = nil) {
        if (.Paused == timerObject.timerStatus) && (timerObject.timeSet == timerObject.currentTime) {
            stopTimer()
        } else {
            resetTimer()
        }
    }
    
    /* ################################################################## */
    /**
     Called when the pause button has been hit (or the tap gesture has happened).
     
     - parameter: Ignored, and optional.
     */
    @IBAction func pauseButtonHit(_: Any! = nil) {
        if .Paused == timerObject.timerStatus {
            continueTimer()
        } else if (.Podium == timerObject.displayMode) && (.Stopped != timerObject.timerStatus) {
            resetTimer()
        } else {
            pauseTimer()
        }
    }
    
    /* ################################################################## */
    /**
     Called when the tap gesture has happened.
     
     - parameter: Ignored, and optional.
     */
    @IBAction func tapInView(_: Any! = nil) {
        if .Alarm == timerObject.timerStatus {
            if 0 <= Timer_AppDelegate.appDelegateObject.appState.nextTimer {
                cascadeToNextTimer(Timer_AppDelegate.appDelegateObject.appState.nextTimer)
            } else {
                resetButtonHit()
            }
        } else {
            pauseButtonHit()
        }
    }
}
