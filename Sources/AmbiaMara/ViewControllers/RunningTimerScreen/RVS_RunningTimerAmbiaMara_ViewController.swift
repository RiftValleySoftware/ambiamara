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
class RVS_RunningTimerAmbiaMara_ViewController: UIViewController {
    /* ################################################################################################################################## */
    // MARK: Private Static Properties
    /* ################################################################################################################################## */
    /* ############################################################## */
    /**
     The color for the digital display, when in "Pause" mode.
     */
    private static let _pausedLEDColor: UIColor? = UIColor(named: "Paused-Color")
    
    /* ############################################################## */
    /**
     The opacity of the "traffic lights," when in "Paused" mode.
     */
    private static let _pausedStoplightAlpha = CGFloat(0.07)
    
    /* ############################################################## */
    /**
     The opacity of the currently active "traffic light," when the timer is running.
     */
    private static let _activeStoplightAlpha = CGFloat(1.0)
    
    /* ############################################################## */
    /**
     The opacity of the currently inactive "traffic lights," when the timer is running.
     */
    private static let _inactiveStoplightAlpha = CGFloat(0.15)

    /* ############################################################## */
    /**
     The color of the digits, when the timer is running, and is still in "Start" mode.
     */
    private static let _startLEDColor: UIColor? = UIColor(named: "Start-Color")
    
    /* ############################################################## */
    /**
     The color of the digits, when the timer is running, and is in "Warn" mode.
     */
    private static let _warnLEDColor: UIColor? = UIColor(named: "Warn-Color")
    
    /* ############################################################## */
    /**
     The color of the digits, when the timer is running, and is in "Final" mode.
     */
    private static let _finalLEDColor: UIColor? = UIColor(named: "Final-Color")

    /* ############################################################## */
    /**
     The animation duration of the screen flashes.
     */
    private static let _flashDurationInSeconds = TimeInterval(0.75)

    /* ############################################################## */
    /**
     The repeat rate of the alarm "pulses."
     */
    private static let _alarmDurationInSeconds = TimeInterval(0.85)

    /* ############################################################## */
    /**
     The time between timer checks.
     */
    private static let _clockPeriodInSeconds = TimeInterval(0.25)

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

    /* ################################################################################################################################## */
    // MARK: Private Stored Instance Properties
    /* ################################################################################################################################## */
    /* ############################################################## */
    /**
     The main timer instance.
     */
    private var _timer: RVS_BasicGCDTimer?
    
    /* ############################################################## */
    /**
     The timer that is set when the alarm is sounding.
     */
    private var _alarmTimer: RVS_BasicGCDTimer?
    
    /* ############################################################## */
    /**
     The timer that is used to trigger auto-hide (Toolbar On, Auto-Hide Working).
     */
    private var _autoHideTimer: RVS_BasicGCDTimer?

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
     When the timer is started (or continued), the initial time is set here.
     */
    private var _startingTime: Date?
    
    /* ############################################################## */
    /**
     This contains the elapsed time since start, in seconds.
     */
    private var _tickTimeInSeconds: Int = 0

    /* ################################################################## */
    /**
     This will provide haptic/audio feedback for continues and ticks.
     */
    private var _selectionFeedbackGenerator: UISelectionFeedbackGenerator?

    /* ################################################################## */
    /**
     This will provide haptic/audio feedback for gestures, alams, and transitions.
     */
    private var _feedbackGenerator: UIImpactFeedbackGenerator?

    /* ############################################################## */
    /**
     True, if the timer is currently in "alarm" state.
     */
    private var _isAlarming: Bool = false {
        didSet {
            if !_isAlarming,
               oldValue {
                _alarmTimer?.isRunning = false
                _timer?.isRunning = false
                flashCyan()
                resetTimer()
                setAutoHide()
            } else if _isAlarming,
                      !oldValue {
                _timer?.isRunning = false
                _alarmTimer?.isRunning = true
                determineDigitLEDColor()
                determineStoplightColor()
                setUpToolbar()
                showToolbar()
                flashRed()
                if RVS_AmbiaMara_Settings().alarmMode {
                    _isSoundPlaying = true
                }
                setDigitalTimeAs(hours: -2, minutes: -2, seconds: 0)
                determineStoplightColor()
            }
        }
    }
    
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
     This is used for the toolbar auto-hide.
     */
    private var _lastActivityTime: Date?

    /* ################################################################################################################################## */
    // MARK: Internal IB Stored Properties
    /* ################################################################################################################################## */
    /* ############################################################## */
    /**
     This is the main view, containing the digital display.
     */
    @IBOutlet weak var digitalDisplayContainerView: UIView?

    /* ############################################################## */
    /**
     The hours digit pair.
     */
    @IBOutlet weak var digitalDisplayViewHours: RVS_RetroLEDDigitalDisplay?

    /* ############################################################## */
    /**
     The minutes digit pair.
     */
    @IBOutlet weak var digitalDisplayViewMinutes: RVS_RetroLEDDigitalDisplay?

    /* ############################################################## */
    /**
     The seconds digit pair.
     */
    @IBOutlet weak var digitalDisplayViewSeconds: RVS_RetroLEDDigitalDisplay?
    
    /* ############################################################## */
    /**
     This is the toolbar that may (or may not) be displayed at the bottom of the screen.
     */
    @IBOutlet weak var controlToolbar: UIToolbar?

    /* ############################################################## */
    /**
     The "Play" of "Pause" toolbar button.
     */
    @IBOutlet weak var playPauseToolbarItem: UIBarButtonItem?

    /* ############################################################## */
    /**
     The "Stop" toolbar button.
     */
    @IBOutlet weak var stopToolbarItem: UIBarButtonItem?

    /* ############################################################## */
    /**
     The "Fast Forward"/"Next Timer" toolbar button.
     */
    @IBOutlet weak var fastForwardBarButtonItem: UIBarButtonItem?

    /* ############################################################## */
    /**
     The "Rewind"/"Previous Timer" toolbar button.
     */
    @IBOutlet weak var rewindToolbarItem: UIBarButtonItem?
    
    /* ############################################################## */
    /**
     The button in the center of the toolbar that indicates the timer index (if we have multiple timers).
     */
    @IBOutlet weak var timerIndicatorToolbarItem: UIBarButtonItem!
    
    /* ############################################################## */
    /**
     The filter that gives the "gas blur" effect.
     */
    @IBOutlet weak var blurFilterView: UIVisualEffectView!
    
    /* ############################################################## */
    /**
     The image that displays the "hex grid" over the digital display.
     */
    @IBOutlet weak var hexGridImageView: UIImageView?
    
    /* ############################################################## */
    /**
     The view across the back that is filled with a color, during a "flash."
     */
    @IBOutlet weak var flasherView: UIView?

    /* ############################################################## */
    /**
     The stack view that contains the digit pairs.
     */
    @IBOutlet var digitContainerInternalView: UIView?

    /* ############################################################## */
    /**
     The view that contains the three "traffic lights."
     */
    @IBOutlet weak var stoplightsContainerView: UIStackView?
    
    /* ############################################################## */
    /**
     The "traffic light" that is displayed during the "Start" phase of the timer.
     */
    @IBOutlet weak var startTrafficLightImageView: UIImageView?
    
    /* ############################################################## */
    /**
     The "traffic light" that is displayed during the "Warn" phase of the timer.
     */
    @IBOutlet weak var warnTrafficLightImageView: UIImageView?
    
    /* ############################################################## */
    /**
     The "traffic light" that is displayed during the "Final" phase of the timer.
     */
    @IBOutlet weak var finalTrafficLightImageView: UIImageView?
}

/* ###################################################################################################################################### */
// MARK: Private Computed Properties
/* ###################################################################################################################################### */
extension RVS_RunningTimerAmbiaMara_ViewController {
    /* ############################################################## */
    /**
     - returns: The remaining countdown time, in seconds.
     */
    private var remainingTime: Int { RVS_AmbiaMara_Settings().currentTimer.startTime - _tickTimeInSeconds }
    
    /* ############################################################## */
    /**
     - returns: True, if the timer is currently running.
     */
    private var _isTimerRunning: Bool { _timer?.isRunning ?? false }

    /* ############################################################## */
    /**
     - returns: True, if the current time is at the "starting gate."
     */
    private var _isAtStart: Bool { RVS_AmbiaMara_Settings().currentTimer.startTime <= remainingTime }

    /* ############################################################## */
    /**
     - returns: True, if the current time is at the end.
     */
    private var _isAtEnd: Bool { 0 >= remainingTime }

    /* ############################################################## */
    /**
     - returns: True, if the current time is within the "warning" window.
     */
    private var _isWarning: Bool { remainingTime <= RVS_AmbiaMara_Settings().currentTimer.warnTime }

    /* ############################################################## */
    /**
     - returns: True, if the current time is within the "final countdown" window.
     */
    private var _isFinal: Bool { remainingTime <= RVS_AmbiaMara_Settings().currentTimer.finalTime }
    
    /* ############################################################## */
    /**
     - returns: The index of the following timer. Nil, if no following timer.
                This "circles around," so the last timer points to the first timer.
     */
    private var _nextTimerIndex: Int? {
        guard 1 < RVS_AmbiaMara_Settings().numberOfTimers else { return nil }
        
        var nextIndex = RVS_AmbiaMara_Settings().currentTimerIndex + 1
        if nextIndex == RVS_AmbiaMara_Settings().numberOfTimers {
            nextIndex = 0
        }
        
        // Not valid, if no time set.
        guard 0 < RVS_AmbiaMara_Settings().timers[nextIndex].startTime else { return nil }
        
        return nextIndex
    }
    
    /* ############################################################## */
    /**
     - returns: The index of the previous timer. Nil, if no previous timer.
                This "circles around," so the first timer points to the last timer.
     */
    private var _previousTimerIndex: Int? {
        guard 1 < RVS_AmbiaMara_Settings().numberOfTimers else { return nil }
        
        var previousIndex = RVS_AmbiaMara_Settings().currentTimerIndex - 1
        if 0 > previousIndex {
            previousIndex = RVS_AmbiaMara_Settings().numberOfTimers - 1
        }
        
        // Not valid, if no time set.
        guard 0 < RVS_AmbiaMara_Settings().timers[previousIndex].startTime else { return nil }
        
        return previousIndex
    }
}

/* ###################################################################################################################################### */
// MARK: Private Class Functions
/* ###################################################################################################################################### */
extension RVS_RunningTimerAmbiaMara_ViewController {
    /* ################################################################## */
    /**
     This creates an array of [CGPoint](https://developer.apple.com/documentation/coregraphics/cgpoint), based on a 0,0 origin, that describe
     a hexagon, on its "side" (point facing up).
     
     - parameter inHowBig: The radius, in display units.
     
     - returns: an array of [CGPoint](https://developer.apple.com/documentation/coregraphics/cgpoint), that can be used to describe a path.
     */
    private class func _pointySideUpHexagon(_ inHowBig: CGFloat) -> [CGPoint] {
        let angle = CGFloat(60).radians
        let cx = CGFloat(inHowBig)  // x origin
        let cy = CGFloat(inHowBig)  // y origin
        let r = CGFloat(inHowBig)   // radius of circle
        var points = [CGPoint]()
        var minX: CGFloat = inHowBig * 2
        var maxX: CGFloat = 0
        for i in 0...6 {
            let x = cx + r * cos(angle * CGFloat(i) - CGFloat(30).radians)
            let y = cy + r * sin(angle * CGFloat(i) - CGFloat(30).radians)
            minX = min(minX, x)
            maxX = max(maxX, x)
            points.append(CGPoint(x: x, y: y))
        }
        
        for i in points.enumerated() {
            points[i.offset] = CGPoint(x: i.element.x - minX, y: i.element.y)
        }
        
        return points
    }
    
    /* ################################################################## */
    /**
     This returns a [CGMutablePath](https://developer.apple.com/documentation/coregraphics/cgmutablepath), describing a "pointy side up" hexagon.
     
     - parameter inHowBig: The radius, in display units.
     
     - returns: A [CGMutablePath](https://developer.apple.com/documentation/coregraphics/cgmutablepath), describing a "pointy side up" hexagon.
     */
    private class func _getHexPath(_ inHowBig: CGFloat) -> CGMutablePath {
        let path = CGMutablePath()
        let points = _pointySideUpHexagon(inHowBig)
        let cpg = points[0]
        path.move(to: cpg)
        points.forEach { path.addLine(to: $0) }
        path.closeSubpath()
        return path
    }
}

/* ###################################################################################################################################### */
// MARK: Private Instance Methods
/* ###################################################################################################################################### */
extension RVS_RunningTimerAmbiaMara_ViewController {
    /* ################################################################## */
    /**
     This class generates an overlay image of a faint "hex grid" that allows us to simulate an old-fashioned "fluorescent" display.
     
     - parameter inBounds: The main bounds of the screen, from which the array will be calculated.
     */
    private func _generateHexOverlayImage(_ inBounds: CGRect) -> UIImage? {
        let path = CGMutablePath()
        let sHexagonWidth = CGFloat(min(inBounds.size.width, inBounds.size.height) / 20)
        let radius: CGFloat = sHexagonWidth / 2
        
        let hexPath: CGMutablePath = Self._getHexPath(radius)
        let oneHexWidth = hexPath.boundingBox.size.width
        let oneHexHeight = hexPath.boundingBox.size.height
        
        let halfWidth = oneHexWidth / 2.0
        var nudgeX: CGFloat = 0
        let nudgeY: CGFloat = radius + ((oneHexHeight - oneHexWidth) * 2)
        
        var yOffset: CGFloat = 0
        while yOffset < inBounds.size.height {
            var xOffset = nudgeX
            while xOffset < inBounds.size.width {
                let transform = CGAffineTransform(translationX: xOffset, y: yOffset)
                path.addPath(hexPath, transform: transform)
                xOffset += oneHexWidth
            }
            
            nudgeX = (0 < nudgeX) ? 0: halfWidth
            yOffset += nudgeY
        }

        UIGraphicsBeginImageContextWithOptions(inBounds.size, false, 0.0)
        if let drawingContext = UIGraphicsGetCurrentContext() {
            drawingContext.addPath(path)
            drawingContext.setLineWidth(0.2)
            drawingContext.setStrokeColor(UIColor.black.withAlphaComponent(0.8).cgColor)
            drawingContext.setFillColor(UIColor.clear.cgColor)
            drawingContext.strokePath()
        }
        
        defer { UIGraphicsEndImageContext() }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RVS_RunningTimerAmbiaMara_ViewController {
    /* ################################################################## */
    /**
     - returns true, indicating that X-phones should hide the Home Bar.
     */
    override var prefersHomeIndicatorAutoHidden: Bool { true }

    /* ############################################################## */
    /**
     - returns true, indicating the status bar should be hidden.
     */
    override var prefersStatusBarHidden: Bool { true }
    
    /* ############################################################## */
    /**
     Called when the hierarchy is loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Makes the toolbar background transparent.
        controlToolbar?.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        controlToolbar?.setShadowImage(UIImage(), forToolbarPosition: .any)
        _soundSelection = Bundle.main.paths(forResourcesOfType: "mp3", inDirectory: nil).sorted { a, b in
                guard let soundUriA = URL(string: a.urlEncodedString ?? "")?.lastPathComponent,
                      let soundUriB = URL(string: b.urlEncodedString ?? "")?.lastPathComponent
                else { return false }
                return soundUriA < soundUriB
            }

        digitalDisplayViewHours?.radix = 10
        digitalDisplayViewMinutes?.radix = 10
        digitalDisplayViewSeconds?.radix = 10
        
        _selectionFeedbackGenerator = UISelectionFeedbackGenerator()
        _feedbackGenerator = UIImpactFeedbackGenerator()

        _timer = RVS_BasicGCDTimer(timeIntervalInSeconds: Self._clockPeriodInSeconds, delegate: self, leewayInMilliseconds: 50, onlyFireOnce: false, queue: .main, isWallTime: true)
        _alarmTimer = RVS_BasicGCDTimer(timeIntervalInSeconds: Self._alarmDurationInSeconds, delegate: self, leewayInMilliseconds: 50, onlyFireOnce: false, queue: .main)
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
        stoplightsContainerView?.isHidden = !RVS_AmbiaMara_Settings().stoplightMode
        digitalDisplayContainerView?.isHidden = RVS_AmbiaMara_Settings().stoplightMode
        controlToolbar?.isHidden = !RVS_AmbiaMara_Settings().displayToolbar
        
        // [ProcessInfo().isMacCatalystApp](https://developer.apple.com/documentation/foundation/nsprocessinfo/3362531-maccatalystapp)
        // is a general-purpose Mac detector, and works better than the precompiler targetEnvironment test.
        if ProcessInfo().isMacCatalystApp {
            blurFilterView?.isHidden = true  // Looks like crap on Mac.
        } else {
            blurFilterView?.isHidden = isHighContrastMode
        }
        hexGridImageView?.isHidden = isHighContrastMode
    }
    
    /* ############################################################## */
    /**
     Called when the view has appeared. We use this to start the timer (if necessary).
     - parameter inIsAnimated: True, if the appearance is animated.
     */
    override func viewDidAppear(_ inIsAnimated: Bool) {
        super.viewDidAppear(inIsAnimated)
        initializeTimer()
    }

    /* ############################################################## */
    /**
     Called when the view will rearrange its view hierarchy.
     */
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        digitalDisplayViewHours?.isHidden = 3600 > RVS_AmbiaMara_Settings().currentTimer.startTime
        digitalDisplayViewMinutes?.isHidden = 60 > RVS_AmbiaMara_Settings().currentTimer.startTime
        let imageSize = hexGridImageView?.image?.size ?? .zero
        if let bounds = digitContainerInternalView?.bounds,
           imageSize != bounds.size {
            hexGridImageView?.image = _generateHexOverlayImage(bounds)
        }
    }
    
    /* ############################################################## */
    /**
     Called when the view is about to disappear.
     - parameter inIsAnimated: True, if the disappearance is animated.
     */
    override func viewWillDisappear(_ inIsAnimated: Bool) {
        stopAlarm()
        pauseTimer()
        _timer?.invalidate()
        _timer = nil
        _alarmTimer?.invalidate()
        _alarmTimer = nil
        _autoHideTimer?.invalidate()
        _autoHideTimer = nil
        UIApplication.shared.isIdleTimerDisabled = false
        super.viewWillDisappear(inIsAnimated)
    }
    
    /* ############################################################## */
    /**
     This allows Catalyst apps to use the keyboard to control the timer, like gestures.
     
     - parameter inKeyPresses: The pressed keys.
     - parameter with: The event, creating the keypresses.
     */
    override func pressesBegan(_ inKeyPresses: Set<UIPress>, with inEvent: UIPressesEvent?) {
        var didHandleEvent = false
        for press in inKeyPresses {
            guard !didHandleEvent,
                  let key = press.key
            else { continue }
            
            switch key.charactersIgnoringModifiers {
            case UIKeyCommand.inputLeftArrow:
                didHandleEvent = true
                if _isTimerRunning || !(_isAtStart && !_isAtEnd) || 1 < RVS_AmbiaMara_Settings().numberOfTimers {
                    rewindHit()
                } else if _isAlarming {
                    didHandleEvent = true
                    _isAlarming = false
                }

            case UIKeyCommand.inputRightArrow:
                didHandleEvent = true
                if _isTimerRunning || !(_isAtStart && !_isAtEnd) || 1 < RVS_AmbiaMara_Settings().numberOfTimers {
                    fastForwardHit()
                } else if _isAlarming {
                    didHandleEvent = true
                    _isAlarming = false
                }

            case UIKeyCommand.inputEscape:
                stopTimer()

            case " ":
                didHandleEvent = true
                if _isTimerRunning {
                    pauseTimer()
                } else if _isAtStart {
                    startTimer()
                } else if _isAlarming {
                    _isAlarming = false
                } else {
                    continueTimer()
                }

            default:
                if _isAlarming {
                    didHandleEvent = true
                    _isAlarming = false
                }
            }
        }
        
        if !didHandleEvent {
            super.pressesBegan(inKeyPresses, with: inEvent)
        }
        
        setAutoHide()
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RVS_RunningTimerAmbiaMara_ViewController {
    /* ############################################################## */
    /**
     This animates the toolbar into visibility.
     */
    func showToolbar() {
        _autoHideTimer?.invalidate()
        _autoHideTimer = nil

        guard RVS_AmbiaMara_Settings().displayToolbar,
              RVS_AmbiaMara_Settings().autoHideToolbar
        else {
            controlToolbar?.alpha = 1.0
            return
        }

        if 1.0 > (controlToolbar?.alpha ?? 1) {
            controlToolbar?.alpha = 0.0
            view.layoutIfNeeded()
            UIView.animate(withDuration: Self._autoHideAnimationDurationInSeconds,
                           animations: { [weak self] in
                                            self?.controlToolbar?.alpha = 1.0
                                            self?.view.layoutIfNeeded()
                                        },
                           completion: { [weak self] _ in
                                            if self?._isTimerRunning ?? false {
                                                self?._autoHideTimer = RVS_BasicGCDTimer(timeIntervalInSeconds: Self._autoHidePeriodInSeconds, delegate: self, leewayInMilliseconds: 100, onlyFireOnce: true, queue: .main, isWallTime: true)
                                                self?._autoHideTimer?.isRunning = true
                                            }
                                        }
            )
        } else if _isTimerRunning {
            _autoHideTimer = RVS_BasicGCDTimer(timeIntervalInSeconds: Self._autoHidePeriodInSeconds, delegate: self, leewayInMilliseconds: 100, onlyFireOnce: true, queue: .main, isWallTime: true)
            _autoHideTimer?.isRunning = true
        }
    }
    
    /* ############################################################## */
    /**
     This animates the toolbar into invisibility.
     */
    func hideToolbar() {
        _autoHideTimer?.invalidate()
        _autoHideTimer = nil
        controlToolbar?.alpha = 1.0
        
        guard RVS_AmbiaMara_Settings().displayToolbar,
              RVS_AmbiaMara_Settings().autoHideToolbar
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
     This resets the autohide timer.
     */
    func setAutoHide() {
        showToolbar()
    }
    
    /* ############################################################## */
    /**
     See if we have another timer to which we can cascade.
     - parameter backwards: True, if this is a backwards cascade (previous timer). Default is false (next timer).
     - returns: True, if the timer cascaded. Can be ignored.
     */
    @discardableResult
    func cascadeTimer(backwards inUsePreviousTimer: Bool = false) -> Bool {
        if let nextTimerIndex = inUsePreviousTimer ? _previousTimerIndex : _nextTimerIndex {
            flashTimerNumber(nextTimerIndex + 1)
            _tickTimeInSeconds = 0
            RVS_AmbiaMara_Settings().currentTimerIndex = nextTimerIndex
            
            view.setNeedsLayout()
            initializeTimer()
            return true
        }
        
        return false
    }

    /* ################################################################## */
    /**
     This sets up the toolbar, by adding all the timers.
    */
    func setUpToolbar() {
        if _isAlarming || (!_isTimerRunning && _isAtStart || _isAtEnd),
           let nextTimerIndex = _nextTimerIndex {
            fastForwardBarButtonItem?.image = UIImage(systemName: "\(nextTimerIndex + 1).circle.fill")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large))
            fastForwardBarButtonItem?.isEnabled = true
            fastForwardBarButtonItem?.accessibilityLabel = String(format: "SLUG-ACC-TOOLBAR-FF-CASCADE-FORMAT".accessibilityLocalizedVariant, nextTimerIndex + 1)
        } else {
            fastForwardBarButtonItem?.image = UIImage(systemName: "forward.end.alt.fill")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large))
            fastForwardBarButtonItem?.isEnabled = (_isTimerRunning || nil != _nextTimerIndex)
            fastForwardBarButtonItem?.accessibilityLabel = "SLUG-ACC-TOOLBAR-FF-ALARM".accessibilityLocalizedVariant
        }
        
        if !_isTimerRunning,
           _isAtStart,
           let previousTimerIndex = _previousTimerIndex {
            rewindToolbarItem?.image = UIImage(systemName: "\(previousTimerIndex + 1).circle.fill")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large))
            rewindToolbarItem?.isEnabled = true
            rewindToolbarItem?.accessibilityLabel = String(format: "SLUG-ACC-TOOLBAR-FF-CASCADE-FORMAT".accessibilityLocalizedVariant, previousTimerIndex + 1)
        } else {
            rewindToolbarItem?.image = UIImage(systemName: "backward.end.alt.fill")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large))
            rewindToolbarItem?.isEnabled = _isAlarming || !_isAtStart
            rewindToolbarItem?.accessibilityLabel = "SLUG-ACC-TOOLBAR-REWIND-ALARM".accessibilityLocalizedVariant
        }
        
        playPauseToolbarItem?.isEnabled = !_isAlarming
        playPauseToolbarItem?.accessibilityLabel = _isAlarming ? nil : (_isTimerRunning ? "SLUG-ACC-TOOLBAR-PAUSE".accessibilityLocalizedVariant : "SLUG-ACC-TOOLBAR-PLAY".accessibilityLocalizedVariant)

        stopToolbarItem?.accessibilityLabel = "SLUG-ACC-TOOLBAR-STOP".accessibilityLocalizedVariant
        
        if nil != _nextTimerIndex {
            timerIndicatorToolbarItem?.image = UIImage(systemName: "\(RVS_AmbiaMara_Settings().currentTimerIndex + 1).circle")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large))
            timerIndicatorToolbarItem?.accessibilityLabel = String(format: "SLUG-ACC-TOOLBAR-TIMER-FORMAT".accessibilityLocalizedVariant, RVS_AmbiaMara_Settings().currentTimerIndex + 1)
        } else {
            timerIndicatorToolbarItem?.image = nil
        }

        if _isTimerRunning {
            playPauseToolbarItem?.image = UIImage(systemName: "pause.fill")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large))
        } else {
            playPauseToolbarItem?.image = UIImage(systemName: "play.fill")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large))
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
        setDigitalTimeAs(hours: hours, minutes: minutes, seconds: seconds)
        determineStoplightColor(RVS_AmbiaMara_Settings().currentTimer.startTime)
        _selectionFeedbackGenerator?.prepare()
        _feedbackGenerator?.prepare()
        if RVS_AmbiaMara_Settings().startTimerImmediately {
            if !RVS_AmbiaMara_Settings().stoplightMode {
                flashGreen()
            }
            startTimer()
        } else {
            if !RVS_AmbiaMara_Settings().stoplightMode {
                flashCyan()
            }
            pauseTimer()
        }
        
        setAutoHide()
    }

    /* ############################################################## */
    /**
     Fast forward will either sto the alarm, or cascade to the next timer.
     */
    func fastForwardHit() {
        if _isAlarming {
            stopAlarm()
            cascadeTimer()
        } else if _isTimerRunning || !(_isAtStart || _isAtEnd) {
            _isAlarming = true
        } else if !cascadeTimer(),
                  !RVS_AmbiaMara_Settings().stoplightMode {
            flashCyan()
        }
    }

    /* ############################################################## */
    /**
     Rewind will either reset the alarm, or cascade to the previous timer.
     */
    func rewindHit() {
        if !_isAlarming,
           !_isTimerRunning,
           _isAtStart || _isAtEnd {
            if !cascadeTimer(backwards: true),
               !RVS_AmbiaMara_Settings().stoplightMode {
                flashCyan()
            }
        } else {
            stopAlarm()
            if !RVS_AmbiaMara_Settings().stoplightMode {
                flashCyan()
            }
            resetTimer()
        }
        
        setUpToolbar()
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
            _tickTimeInSeconds = 0
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
        _alarmTimer?.isRunning = false
        _timer?.isRunning = false
        _startingTime = nil
        _tickTimeInSeconds = 0
        stopSounds()
        setTimerDisplay()
        setUpToolbar()
    }

    /* ############################################################## */
    /**
     This sets the timer to scratch, but does not start it.
     */
    func finishTimer() {
        _startingTime = nil
        _tickTimeInSeconds = RVS_AmbiaMara_Settings().currentTimer.startTime
        _isAlarming = true
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
     */
    func continueTimer() {
        setTimerDisplay()
        _startingTime = Date().addingTimeInterval(-TimeInterval(_tickTimeInSeconds))
        _tickTimeInSeconds = 0 // Doing this, ensures that the next tick will update.
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
        DispatchQueue.main.async { [weak self] in
            self?._isAlarming = false
            self?._isSoundPlaying = false
            self?._timer?.invalidate()
            self?._timer = nil
            self?._alarmTimer?.invalidate()
            self?._alarmTimer = nil
            self?._autoHideTimer?.invalidate()
            self?._autoHideTimer = nil
            self?.navigationController?.popViewController(animated: true)
        }
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
     This sets up the timer display, according to the time and the settings.
     */
    func setTimerDisplay() {
        setDigitDisplayTime()
        determineDigitLEDColor(remainingTime)
        determineStoplightColor(remainingTime)
    }
    
    /* ############################################################## */
    /**
     This determines the proper color for the digit "LEDs."
     - parameter inCurrentTime: Optional. Default is 0. This is the elapsed time, in seconds.
     */
    func determineStoplightColor(_ inCurrentTime: Int = 0) {
        guard _isTimerRunning else {
            startTrafficLightImageView?.alpha = Self._pausedStoplightAlpha
            warnTrafficLightImageView?.alpha = Self._pausedStoplightAlpha
            finalTrafficLightImageView?.alpha = Self._pausedStoplightAlpha
            return
        }
        
        if inCurrentTime <= RVS_AmbiaMara_Settings().currentTimer.finalTime {
            startTrafficLightImageView?.alpha = Self._inactiveStoplightAlpha
            warnTrafficLightImageView?.alpha = Self._inactiveStoplightAlpha
            finalTrafficLightImageView?.alpha = Self._activeStoplightAlpha
        } else if inCurrentTime <= RVS_AmbiaMara_Settings().currentTimer.warnTime {
            startTrafficLightImageView?.alpha = Self._inactiveStoplightAlpha
            warnTrafficLightImageView?.alpha = Self._activeStoplightAlpha
            finalTrafficLightImageView?.alpha = Self._inactiveStoplightAlpha
        } else {
            startTrafficLightImageView?.alpha = Self._activeStoplightAlpha
            warnTrafficLightImageView?.alpha = Self._inactiveStoplightAlpha
            finalTrafficLightImageView?.alpha = Self._inactiveStoplightAlpha
        }
    }
    
    /* ############################################################## */
    /**
     This determines the proper color for the digit "LEDs."
     - parameter inCurrentTime: Optional. Default is 0. This is the elapsed time, in seconds.
     */
    func determineDigitLEDColor(_ inCurrentTime: Int = 0) {
        if !_isTimerRunning,
           !_isAlarming,
           _isAtEnd || _isAtStart {
            digitalDisplayViewHours?.onGradientStartColor = Self._pausedLEDColor
            digitalDisplayViewMinutes?.onGradientStartColor = Self._pausedLEDColor
            digitalDisplayViewSeconds?.onGradientStartColor = Self._pausedLEDColor
        } else if _isAlarming || inCurrentTime <= RVS_AmbiaMara_Settings().currentTimer.finalTime {
            digitalDisplayViewHours?.onGradientStartColor = Self._finalLEDColor
            digitalDisplayViewMinutes?.onGradientStartColor = Self._finalLEDColor
            digitalDisplayViewSeconds?.onGradientStartColor = Self._finalLEDColor
        } else if inCurrentTime <= RVS_AmbiaMara_Settings().currentTimer.warnTime {
            digitalDisplayViewHours?.onGradientStartColor = Self._warnLEDColor
            digitalDisplayViewMinutes?.onGradientStartColor = Self._warnLEDColor
            digitalDisplayViewSeconds?.onGradientStartColor = Self._warnLEDColor
        } else {
            digitalDisplayViewHours?.onGradientStartColor = Self._startLEDColor
            digitalDisplayViewMinutes?.onGradientStartColor = Self._startLEDColor
            digitalDisplayViewSeconds?.onGradientStartColor = Self._startLEDColor
        }
        
        digitalDisplayViewHours?.onGradientEndColor = !_isAlarming && !_isTimerRunning && !_isAtEnd && !_isAtStart ? .white : nil
        digitalDisplayViewMinutes?.onGradientEndColor = !_isAlarming && !_isTimerRunning && !_isAtEnd && !_isAtStart ? .white : nil
        digitalDisplayViewSeconds?.onGradientEndColor = !_isAlarming && !_isTimerRunning && !_isAtEnd && !_isAtStart ? .white : nil
    }
    
    /* ############################################################## */
    /**
     This will flash the screen, for transitions between timer states.
     It will also set the colors for the digits and/or traffic lights.
     - parameter previousTickTime: The previous ticktime.
     */
    func flashIfNecessary(previousTickTime inTickTime: Int) {
        // Look for a threshold crossing.
        let previousTime = RVS_AmbiaMara_Settings().currentTimer.startTime - inTickTime
        determineDigitLEDColor(remainingTime)
        determineStoplightColor(remainingTime)
        
        guard !RVS_AmbiaMara_Settings().stoplightMode else { return }   // No flashes for stoplight mode.
        
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
     This flashes the screen briefly cyan (pause)
     */
    func flashCyan() {
        flasherView?.backgroundColor = UIColor(named: "Paused-Color")
        if areHapticsAvailable {
            _feedbackGenerator?.impactOccurred(intensity: CGFloat(UIImpactFeedbackGenerator.FeedbackStyle.rigid.rawValue))
        }
        UIView.animate(withDuration: Self._flashDurationInSeconds,
                       animations: { [weak self] in
                                        self?.flasherView?.backgroundColor = .clear
                                    },
                       completion: { [weak self] _ in
                                        self?._feedbackGenerator?.prepare()
                                    }
        )
    }
    
    /* ############################################################## */
    /**
     This flashes the screen briefly green
     */
    func flashGreen() {
        flasherView?.backgroundColor = UIColor(named: "Start-Color")
        if areHapticsAvailable {
            _feedbackGenerator?.impactOccurred(intensity: CGFloat(UIImpactFeedbackGenerator.FeedbackStyle.light.rawValue))
        }
        UIView.animate(withDuration: Self._flashDurationInSeconds,
                       animations: { [weak self] in
                                        self?.flasherView?.backgroundColor = .clear
                                    },
                       completion: { [weak self] _ in
                                        self?._feedbackGenerator?.prepare()
                                    }
        )
    }

    /* ############################################################## */
    /**
     This flashes the screen briefly yellow
     */
    func flashYellow() {
        flasherView?.backgroundColor = UIColor(named: "Warn-Color")
        if areHapticsAvailable {
            _feedbackGenerator?.impactOccurred(intensity: CGFloat(UIImpactFeedbackGenerator.FeedbackStyle.medium.rawValue))
        }
        UIView.animate(withDuration: Self._flashDurationInSeconds,
                       animations: { [weak self] in
                                        self?.flasherView?.backgroundColor = .clear
                                    },
                       completion: { [weak self] _ in
                                        self?._feedbackGenerator?.prepare()
                                    }
        )
    }

    /* ############################################################## */
    /**
     This flashes the screen briefly red
     */
    func flashRed() {
        if areHapticsAvailable {
            if _isAlarming {
                _feedbackGenerator?.impactOccurred(intensity: CGFloat(UIImpactFeedbackGenerator.FeedbackStyle.soft.rawValue))
            } else {
                _feedbackGenerator?.impactOccurred(intensity: CGFloat(UIImpactFeedbackGenerator.FeedbackStyle.heavy.rawValue))
            }
            
        }
        flasherView?.backgroundColor = UIColor(named: "Final-Color")
        UIView.animate(withDuration: Self._flashDurationInSeconds,
                       animations: { [weak self] in
                                        self?.flasherView?.backgroundColor = .clear
                                    },
                       completion: { [weak self] _ in
                                        self?._feedbackGenerator?.prepare()
                                    }
        )
    }

    /* ############################################################## */
    /**
     This flashes the current timer number, in an expanding and fading image.
     */
    func flashTimerNumber(_ inNumber: Int) {
        guard let view = view else { return }
        
        let timerLabel = UILabel()
        view.addSubview(timerLabel)
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        timerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        timerLabel.text = isHighContrastMode ? "" : String(inNumber)    // No flash for high contrast.
        timerLabel.textAlignment = .center
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.font = .monospacedDigitSystemFont(ofSize: view.bounds.size.height * 3, weight: .bold)
        timerLabel.transform = timerLabel.transform.scaledBy(x: 0.1, y: 0.1)
        timerLabel.textColor = UIColor(named: "Paused-Color")
        
        if areHapticsAvailable {
            _feedbackGenerator?.impactOccurred(intensity: CGFloat(UIImpactFeedbackGenerator.FeedbackStyle.rigid.rawValue))
        }

        flasherView?.backgroundColor = UIColor(named: "Paused-Color")
        UIView.animate(withDuration: Self._flashDurationInSeconds,
                       animations: { [weak self] in
                                        timerLabel.transform = CGAffineTransform.identity
                                        timerLabel.alpha = 0.0
                                        self?.flasherView?.backgroundColor = .clear
                                    },
                       completion: { [weak self] _ in
                                        timerLabel.removeFromSuperview()
                                        self?._feedbackGenerator?.prepare()
                                    }
        )
    }
    
    /* ############################################################## */
    /**
     This sets the digits, directly.
     - parameter hours: The hour number
     - parameter minutes: The minute number
     - parameter seconds: The second number.
     */
    func setDigitalTimeAs(hours inHours: Int, minutes inMinutes: Int, seconds inSeconds: Int) {
        digitalDisplayViewMinutes?.hasLeadingZeroes = 0 < inHours
        digitalDisplayViewSeconds?.hasLeadingZeroes = 0 < inHours || 0 < inMinutes
        
        digitalDisplayViewHours?.value = inHours
        digitalDisplayViewMinutes?.value = inMinutes
        digitalDisplayViewSeconds?.value = inSeconds
    }
    
    /* ############################################################## */
    /**
     This calculates the current time, and sets the digital display to that time.
     */
    func setDigitDisplayTime() {
        var differenceInSeconds = _isTimerRunning || 0 < remainingTime ? remainingTime : RVS_AmbiaMara_Settings().currentTimer.startTime
        
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
// MARK: Callbacks
/* ###################################################################################################################################### */
extension RVS_RunningTimerAmbiaMara_ViewController {
    /* ############################################################## */
    /**
     Called if the background was tapped. This is how we start/pause/continue the timer. This only works for toolbar hidden.
     - parameter: ignored.
     */
    @IBAction func backgroundTapped(_: UITapGestureRecognizer) {
        setAutoHide()

        guard !RVS_AmbiaMara_Settings().displayToolbar else { return }
        
        if areHapticsAvailable {
            _selectionFeedbackGenerator?.selectionChanged()
            _selectionFeedbackGenerator?.prepare()
        }
        if _isAlarming {
            stopAlarm()
        } else if _isTimerRunning {
            if !RVS_AmbiaMara_Settings().stoplightMode {
                flashCyan()
            }
            pauseTimer()
        } else if _isAtStart {
            if !RVS_AmbiaMara_Settings().stoplightMode {
                flashGreen()
            }
            startTimer()
        } else {
            if !_isWarning,
               !_isFinal,
               !RVS_AmbiaMara_Settings().stoplightMode {
                flashGreen()
            }
            continueTimer()
        }
    }
    
    /* ############################################################## */
    /**
     The user right-swiped the timer. This only works for toolbar hidden.
     - parameter: ignored.
     */
    @IBAction func rightSwipeGestureReceived(_: UISwipeGestureRecognizer) {
        setAutoHide()

        guard !RVS_AmbiaMara_Settings().displayToolbar else { return }
        
        if areHapticsAvailable {
            _selectionFeedbackGenerator?.selectionChanged()
            _selectionFeedbackGenerator?.prepare()
        }
        
        fastForwardHit()
    }
    
    /* ############################################################## */
    /**
     The user left-swiped the timer. This only works for toolbar hidden.
     - parameter: ignored.
     */
    @IBAction func leftSwipeGestureReceived(_ inGestureRecognizer: UISwipeGestureRecognizer) {
        setAutoHide()

        guard !RVS_AmbiaMara_Settings().displayToolbar else { return }
        
        if areHapticsAvailable {
            _selectionFeedbackGenerator?.selectionChanged()
            _selectionFeedbackGenerator?.prepare()
        }
        
        rewindHit()
    }

    /* ############################################################## */
    /**
     The user up- or down-swiped the timer. This only works for toolbar hidden.
     - parameter: ignored.
     */
    @IBAction func upDownwipeGestureReceived(_: UISwipeGestureRecognizer) {
        setAutoHide()

        guard !RVS_AmbiaMara_Settings().displayToolbar else { return }
        
        if areHapticsAvailable {
            _feedbackGenerator?.impactOccurred(intensity: CGFloat(UIImpactFeedbackGenerator.FeedbackStyle.rigid.rawValue))
            _feedbackGenerator?.prepare()
        }
        
        flashRed()
        stopTimer()
    }

    /* ############################################################## */
    /**
     One of the toolbar controls was hit.
     
     - parameter inSender: The item that was activated.
     */
    @IBAction func toolbarItemHit(_ inSender: UIBarButtonItem) {
        if areHapticsAvailable {
            _selectionFeedbackGenerator?.selectionChanged()
            _selectionFeedbackGenerator?.prepare()
        }
        if stopToolbarItem == inSender {
            stopTimer()
        } else if rewindToolbarItem == inSender {
            rewindHit()
        } else if fastForwardBarButtonItem == inSender {
            fastForwardHit()
        } else if playPauseToolbarItem == inSender {
            if _isTimerRunning {
                if !RVS_AmbiaMara_Settings().stoplightMode {
                    flashCyan()
                }
                pauseTimer()
            } else {
                if 0 == _tickTimeInSeconds {
                    if !RVS_AmbiaMara_Settings().stoplightMode {
                        flashGreen()
                    }
                    startTimer()
                } else {
                    if !_isWarning,
                       !_isFinal,
                       !RVS_AmbiaMara_Settings().stoplightMode {
                        flashGreen()
                    }
                    continueTimer()
                }
            }
            
            setUpToolbar()
        }
        
        setAutoHide()
    }
}

/* ###################################################################################################################################### */
// MARK: RVS_BasicGCDTimerDelegate Conformance
/* ###################################################################################################################################### */
extension RVS_RunningTimerAmbiaMara_ViewController: RVS_BasicGCDTimerDelegate {
    /* ############################################################## */
    /**
     Called when the timer fires.
     
     - parameter inTimer: The timer
     */
    func basicGCDTimerCallback(_ inTimer: RVS_BasicGCDTimer) {
        guard _autoHideTimer != inTimer else {
            #if DEBUG
                print("Triggering the auto-hide timer")
            #endif
            hideToolbar()

            return
        }
        
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
        guard differenceInSeconds != _tickTimeInSeconds else { return }
        let previousTickTime = _tickTimeInSeconds
        _tickTimeInSeconds = differenceInSeconds
        flashIfNecessary(previousTickTime: previousTickTime)
        setDigitDisplayTime()
        if areHapticsAvailable {
            _selectionFeedbackGenerator?.selectionChanged()
            _selectionFeedbackGenerator?.prepare()
        }

        if 0 >= (RVS_AmbiaMara_Settings().currentTimer.startTime - differenceInSeconds) {
            _isAlarming = true
        }
    }
}
