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
    private let _tickVolume: Float = 0.005
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
                self.timeDisplay.hours = TimeInstance(self.timerObject.currentTime).hours
                self.timeDisplay.minutes = TimeInstance(self.timerObject.currentTime).minutes
                self.timeDisplay.seconds = TimeInstance(self.timerObject.currentTime).seconds
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
     This plays whatever alert sound has been chosen by the user.
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
     This plays a "tick" sound.
     
     - parameter times: Optional. Default is 1. This is how many times the tick will be repeated (quick succession).
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
                    self.tickPlayer?.volume = self._tickVolume * Float(inTimes)
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
        self.flashDisplay(UIColor.red.withAlphaComponent(0.5), duration: 0.5)
        Timer_AppDelegate.appDelegateObject.timerEngine.pauseTimer()
    }
    
    /* ################################################################## */
    /**
     This continues a paused timer.
     
     It will flash the display a "subdued" green.
     */
    func continueTimer() {
        self.flashDisplay(UIColor.green.withAlphaComponent(0.5), duration: 0.5)
        Timer_AppDelegate.appDelegateObject.timerEngine.continueTimer()
    }
    
    /* ################################################################## */
    /**
     This stops a running timer, and dismisses the screen.
     
     It will flash the display a bright red.
     */
    func stopTimer() {
        self.flashDisplay(UIColor.red, duration: 0.5)
        self.stopAudioPlayer()
        Timer_AppDelegate.appDelegateObject.timerEngine.stopTimer()
        navigationController?.popViewController(animated: true)
    }
    
    /* ################################################################## */
    /**
     This forces the timer to immediately complete its time, and go into alarm mode.
     */
    func endTimer() {
        self.stopAudioPlayer()
        Timer_AppDelegate.appDelegateObject.timerEngine.endTimer()
    }
    
    /* ################################################################## */
    /**
     This resets the timer to its starting value, but does not dismiss the screen.
     
     If the timer is paused, this will flash a "subdued" white. If not, it will flash a "subdued" red.
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
     This forces the timer to update to match the current timer state.
     */
    func updateTimer() {
        self._setUpDisplay()
        
        if let timeDisplay = self.timeDisplay {
            timeDisplay.accessibilityLabel = self.timerObject.currentQuickSpeakableTime

            timeDisplay.isHidden = (.Podium == self.timerObject.displayMode) || (.Alarm == self.timerObject.timerStatus)
            if nil != self.stoplightContainerView {
                self.stoplightContainerView.isHidden = (.Alarm == self.timerObject.timerStatus)
            }
            
            if .Alarm == self.timerObject.timerStatus {
                UIApplication.shared.isIdleTimerDisabled = false // Toggle this to "wake" the touch sensor. The system can put it into a "resting" mode, so two touches are required.
                UIApplication.shared.isIdleTimerDisabled = true
                self.flashDisplay()
                self._playAlertSound()
                if .VibrateOnly == self.timerObject.alertMode || .Both == self.timerObject.alertMode {
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
        self._playTickSound(times: inTimes)
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
        if  0 <= inNextTimerIndex,
            let navigationController = self.navigationController as? TimerNavController {
            Timer_AppDelegate.appDelegateObject.timerEngine.stopTimer()
            self.stopAudioPlayer()
            self.closeUpShop()
            navigationController.selectNextTimer = inNextTimerIndex
            navigationController.popViewController(animated: false)
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
        self.setNeedsUpdateOfHomeIndicatorAutoHidden()
        self.updateTimer()
    }
    
    /* ################################################################## */
    /**
     Called when the view is about to set up its layout.
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
     Called just before the view appears.
     */
    override func viewWillAppear(_ animated: Bool) {
        self.setUpShop()
        super.viewWillAppear(animated)
        if let navigationController = self.navigationController as? TimerNavController {
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
        self.closeUpShop()
    }
    
    /* ################################################################## */
    /**
     Prepares the timer screen.
     */
    func setUpShop() {
        UIApplication.shared.isIdleTimerDisabled = true
        self.hidesBottomBarWhenPushed = true
        self.tabBarController?.tabBar.isHidden = true

        if Timer_AppDelegate.appDelegateObject.timerEngine.appState.showControlsInRunningTimer {
            self.myNavigationBar.tintColor = self.view.tintColor
            self.myNavigationBar.backgroundColor = UIColor.black
            self.myNavigationBar.barTintColor = UIColor.black
        } else {
            self.myNavigationBar.isHidden = true
        }

        if let navController = self.navigationController {
            navController.navigationBar.isHidden = true
        }

        Timer_AppDelegate.appDelegateObject.currentTimer = self
        Timer_AppDelegate.appDelegateObject.timerEngine.selectedTimerUID = self.timerObject.uid
        Timer_AppDelegate.appDelegateObject.timerEngine.startTimer()
    }
    
    /* ################################################################## */
    /**
     This closes up our various things, and makes things reappear.
     */
    func closeUpShop() {
        self.myHandler.runningTimer = nil
        if let navController = self.navigationController {
            navController.navigationBar.isHidden = false
        }
        
        self.tabBarController?.tabBar.isHidden = false
        self.hidesBottomBarWhenPushed = false   // We need to do this, or the tab bar will be hidden in the next screen.

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

        self.timeDisplay.isAccessibilityElement = true
        self.timeDisplay.accessibilityLabel = self.timerObject.currentQuickSpeakableTime

        self.view.accessibilityElements = [self.timeDisplay as Any, self.stopButton as Any, self.resetButton as Any, self.endButton as Any, self.pauseButton as Any, self.flasherView as Any]
        
        UIAccessibility.post(notification: .layoutChanged, argument: self.timeDisplay)
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
        if .Alarm == self.timerObject.timerStatus, 0 <= Timer_AppDelegate.appDelegateObject.appState.nextTimer {
            self.cascadeToNextTimer(Timer_AppDelegate.appDelegateObject.appState.nextTimer)
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
        if .Alarm == self.timerObject.timerStatus {
            self.resetTimer()
        } else {
            self.endTimer()
        }
    }
    
    /* ################################################################## */
    /**
     Called when the reset button has been hit (or the left-swipe gesture has happened).
     
     - parameter: Ignored, and optional.
     */
    @IBAction func resetButtonHit(_: Any! = nil) {
        if (.Paused == self.timerObject.timerStatus) && (self.timerObject.timeSet == self.timerObject.currentTime) {
            self.stopTimer()
        } else {
            self.resetTimer()
        }
    }
    
    /* ################################################################## */
    /**
     Called when the pause button has been hit (or the tap gesture has happened).
     
     - parameter: Ignored, and optional.
     */
    @IBAction func pauseButtonHit(_: Any! = nil) {
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
     Called when the tap gesture has happened.
     
     - parameter: Ignored, and optional.
     */
    @IBAction func tapInView(_: Any! = nil) {
        if .Alarm == self.timerObject.timerStatus {
            if 0 <= Timer_AppDelegate.appDelegateObject.appState.nextTimer {
                self.cascadeToNextTimer(Timer_AppDelegate.appDelegateObject.appState.nextTimer)
            } else {
                self.stopButtonHit()
            }
        } else {
            self.pauseButtonHit()
        }
    }
}
