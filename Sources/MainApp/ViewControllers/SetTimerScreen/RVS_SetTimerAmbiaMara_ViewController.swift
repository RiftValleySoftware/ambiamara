/*
 © Copyright 2018-2022, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_Generic_Swift_Toolbox

/* ###################################################################################################################################### */
// MARK: - Initial View Controller -
/* ###################################################################################################################################### */
/**
 This is the view controller for the setup screen, where the timer is set, and started.
 */
class RVS_SetTimerAmbiaMara_ViewController: UIViewController {
    /* ################################################################################################################################## */
    // MARK: Time Sections Enum
    /* ################################################################################################################################## */
    /**
     The timer setup is accomplished via a picker control, with three sections: Hours (left), Minutes (center), and Seconds (right).
     You can have up to 99 hours, and/or 59 minutes, and/or 59 seconds.
     */
    enum PickerComponents: Int {
        /* ############################################################## */
        /**
         This is the hour component of the picker (0)
        */
        case hour
        
        /* ############################################################## */
        /**
         This is the minute component of the picker (1)
       */
        case minute
        
        /* ############################################################## */
        /**
         This is the second component of the picker (2)
        */
        case second
    }

    /* ################################################################################################################################## */
    // MARK: Screen State Enum
    /* ################################################################################################################################## */
    /**
     These enums determine the state of this screen
     */
    enum States: Int {
        /* ############################################################## */
        /**
         The timer is setting the start time.
        */
        case start
        
        /* ############################################################## */
        /**
         The timer is setting the warning threshold.
        */
        case warn
        
        /* ############################################################## */
        /**
         The timer is setting the final countdown threshold.
        */
        case final
        
        /* ############################################################## */
        /**
         This returns strings, corresponding to the selected integers.
        */
        var stringValue: String {
            switch self {
            case .start:
                return "Start"
                
            case .warn:
                return "Warn"
                
            case .final:
                return "Final"
            }
        }
    }

    /* ################################################################## */
    /**
     The ID for the segue, to show the about screen.
    */
    private static let _aboutViewSegueID = "ShowAboutView"
    
    /* ################################################################## */
    /**
     The ID for the segue, to start the timer.
    */
    private static let _startTimerSegueID = "start-timer"

    /* ################################################################## */
    /**
     The size of the two settings popovers.
    */
    private static let _settingsPopoverWidthInDisplayUnits = CGFloat(400)

    /* ################################################################## */
    /**
     The period that we use for the "fade in" animation.
    */
    private static let _fadeInAnimationPeriodInSeconds = CGFloat(1.0)

    /* ################################################################## */
    /**
     The period that we use for the selection fade animation.
    */
    private static let _selectionFadeAnimationPeriodInSeconds = CGFloat(0.25)
    
    /* ################################################################## */
    /**
     The period that we use for the add timer animation.
    */
    private static let _addTimerAnimationPeriodInSeconds = CGFloat(0.5)
    
    /* ################################################################## */
    /**
     The starting alpha for our settings items, in the initial animation.
    */
    private static let _initialSettingsItemAlpha = CGFloat(0.25)

    /* ################################################################## */
    /**
     The size of the picker font
    */
    private static let _pickerFont = UIFont.monospacedDigitSystemFont(ofSize: 40, weight: .bold)

    /* ################################################################## */
    /**
     The size of the picker selection corner radius.
    */
    private static let _pickerCornerRadiusInDisplayUnits = CGFloat(4)

    /* ################################################################## */
    /**
     The ranges that we use to populate the picker (default).
    */
    private static let _defaultPickerViewDataRanges: [Range<Int>] = [0..<100, 0..<60, 0..<60]

    /* ################################################################## */
    /**
     The current screen state.
    */
    private var _state: States = .start { didSet { setUpButtons() } }

    /* ################################################################## */
    /**
     This will provide haptic/audio feedback for subtle events.
     */
    private var _selectionFeedbackGenerator: UISelectionFeedbackGenerator?

    /* ################################################################## */
    /**
     This will provide haptic/audio feedback for more significant events.
     */
    private var _impactFeedbackGenerator: UIImpactFeedbackGenerator?
    
    /* ################################################################## */
    /**
     The storyboard ID, for instantiating the class.
     */
    static let storyboardID = "RVS_SetTimerAmbiaMara_ViewController"

    /* ################################################################## */
    /**
     If a popover is being displayed, we reference it here (so we put it away, when we ned to).
    */
    weak var currentDisplayedPopover: UIViewController?

    // MARK: Overall Items
    
    /* ################################################################## */
    /**
     The "startup" logo that we fade out.
    */
    @IBOutlet weak var startupLogo: UIImageView?

    /* ################################################################## */
    /**
     This is an "overall container" view. It mainly exists to fix an issue with the toolbar,
     but also makes the fade in more convenient.
    */
    @IBOutlet weak var containerView: UIView?
    
    // MARK: Bar Button Items
    
    /* ################################################################## */
    /**
     The set alarm popover bar button item.
    */
    @IBOutlet weak var alarmSetBarButtonItem: UIBarButtonItem?
    
    /* ################################################################## */
    /**
     The settings popover bar button item.
    */
    @IBOutlet weak var settingsBarButtonItem: UIBarButtonItem?
    
    // MARK: Timer Settings Area
    
    /* ################################################################## */
    /**
     This contains the central timer setting area.
    */
    @IBOutlet weak var setupContainerView: UIView?
    
    /* ################################################################## */
    /**
     The view that contains the four labels at the top of the settings area. It has a background color that changes for the state.
    */
    @IBOutlet weak var topLabelContainerView: UIView?

    // MARK: Top Labels
    
    /* ################################################################## */
    /**
     The state label, at the top of the settings area.
    */
    @IBOutlet weak var stateLabel: UILabel?
    
    /* ################################################################## */
    /**
     The label over the hours wheel
    */
    @IBOutlet weak var hoursLabel: UILabel?

    /* ################################################################## */
    /**
     The label over the minutes wheel
    */
    @IBOutlet weak var minutesLabel: UILabel?

    /* ################################################################## */
    /**
     The label over the seconds wheel
    */
    @IBOutlet weak var secondsLabel: UILabel?

    // MARK: Time Setting
    
    /* ################################################################## */
    /**
     The timer set picker control.
    */
    @IBOutlet weak var setTimePickerView: UIPickerView?
    
    /* ################################################################## */
    /**
     The button that sets the timer back to zero, and appears when there is a value in the picker.
    */
    @IBOutlet weak var clearButton: UIButton?

    // MARK: State/Start Buttons

    /* ################################################################## */
    /**
     The button to select the start time set state.
    */
    @IBOutlet weak var startSetButton: UIButton?

    /* ################################################################## */
    /**
     The button to select the warning time set state.
    */
    @IBOutlet weak var warnSetButton: UIButton?

    /* ################################################################## */
    /**
     The button to select the final time set state.
    */
    @IBOutlet weak var finalSetButton: UIButton?
    
    /* ################################################################## */
    /**
     This is the triangle button that starts the timer.
    */
    @IBOutlet weak var startButton: UIButton?

    // MARK: Gesture Recognizers
    
    /* ############################################################## */
    /**
     This is the left swipe (previous timer) gesture recognizer, applied to the main view.
     */
    @IBOutlet weak var backgroundLeftSwipeGestureRecognizer: UISwipeGestureRecognizer?

    /* ############################################################## */
    /**
     This is the right swipe (next timer) gesture recognizer, applied to the main view.
     */
    @IBOutlet weak var backgroundRightSwipeGestureRecognizer: UISwipeGestureRecognizer?
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension RVS_SetTimerAmbiaMara_ViewController {
    /* ################################################################## */
    /**
     The current timer, routed from the settings.
    */
    private var _currentTimer: RVS_AmbiaMara_Settings.TimerSettings {
        get { RVS_AmbiaMara_Settings().currentTimer }
        set { RVS_AmbiaMara_Settings().currentTimer = newValue  }
    }

    /* ################################################################## */
    /**
     The ranges that we use to populate the picker.
     The picker will display Integers between the range endpoints.
    */
    private var _pickerViewData: [Range<Int>] { Self._defaultPickerViewDataRanges }

    /* ################################################################## */
    /**
     This is the number of seconds currently represented by the picker.
     Setting it, sets the picker.
    */
    var pickerTime: Int {
        get {
            guard let setPickerControl = setTimePickerView else { return 0 }
            let hours = setPickerControl.selectedRow(inComponent: PickerComponents.hour.rawValue)
            let minutes = setPickerControl.selectedRow(inComponent: PickerComponents.minute.rawValue)
            let seconds = setPickerControl.selectedRow(inComponent: PickerComponents.second.rawValue)
            
            return seconds + (minutes * 60) + (hours * 60 * 60)
        }
        
        set {
            var currentValue = _stateTime(from: newValue)
            
            let hours = min(99, currentValue / (60 * 60))
            currentValue -= (hours * 60 * 60)
            let minutes = min(59, currentValue / 60)
            currentValue -= (minutes * 60)
            let seconds = min(59, currentValue)
            DispatchQueue.main.async { [weak self] in
                guard let setPickerControl = self?.setTimePickerView else { return }
                setPickerControl.selectRow(hours, inComponent: PickerComponents.hour.rawValue, animated: true)
                setPickerControl.selectRow(minutes, inComponent: PickerComponents.minute.rawValue, animated: true)
                setPickerControl.selectRow(seconds, inComponent: PickerComponents.second.rawValue, animated: true)
                setPickerControl.reloadAllComponents()
                self?.clearButton?.isHidden = 0 >= (self?._stateTime() ?? -1)
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Private Instance Methods
/* ###################################################################################################################################### */
extension RVS_SetTimerAmbiaMara_ViewController {
    /* ################################################################## */
    /**
     Returns the currently limited value (warn can't be higher than start, and final can't be higher than either warn or start).
     - parameter from: The time being checked (in seconds). It is optional. leaving it out, fetches the time from the picker.
     - returns: The normalized time (clipped, if necessary).
    */
    private func _stateTime(from inTime: Int = -1) -> Int {
        var currentValue = -1 == inTime ? pickerTime : inTime
        
        let startTimeInSeconds = _currentTimer.startTime
        let warnTimeInSeconds = _currentTimer.warnTime
        
        let startTimeThreshold = startTimeInSeconds - 1
        let warnTimeThreshold = startTimeInSeconds > warnTimeInSeconds && 0 < warnTimeInSeconds
                                    ? warnTimeInSeconds - 1
                                    : startTimeThreshold
        
        switch _state {
        case .start:
            break

        case .warn:
            currentValue = min(currentValue, startTimeThreshold)
            
        case .final:
            currentValue = min(currentValue, warnTimeThreshold)
        }
        
        return currentValue
    }
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RVS_SetTimerAmbiaMara_ViewController {
    /* ################################################################## */
    /**
     Called when the view hierarchy is set up. We use this to set our localizations and accessibility.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        // We do not do auto hide, when in voiceover mode.
        // Voiceover mode does not work well with gestures.
        if isVoiceOverRunning {
            RVS_AmbiaMara_Settings().autoHideToolbar = false
            RVS_AmbiaMara_Settings().displayToolbar = true
        }

        hoursLabel?.text = (hoursLabel?.text ?? "ERROR").localizedVariant
        minutesLabel?.text = (minutesLabel?.text ?? "ERROR").localizedVariant
        secondsLabel?.text = (secondsLabel?.text ?? "ERROR").localizedVariant

        settingsBarButtonItem?.accessibilityLabel = "SLUG-ACC-SETTINGS-BUTTON-LABEL".accessibilityLocalizedVariant
        settingsBarButtonItem?.accessibilityHint = "SLUG-ACC-SETTINGS-BUTTON".accessibilityLocalizedVariant
        alarmSetBarButtonItem?.accessibilityLabel = "SLUG-ACC-ALARM-BUTTON-LABEL".accessibilityLocalizedVariant
        alarmSetBarButtonItem?.accessibilityHint = "SLUG-ACC-ALARM-BUTTON".accessibilityLocalizedVariant
        startSetButton?.accessibilityLabel = "SLUG-ACC-STATE-BUTTON-LABEL-Start".accessibilityLocalizedVariant
        startSetButton?.accessibilityHint = "SLUG-ACC-STATE-BUTTON-HINT".accessibilityLocalizedVariant
        warnSetButton?.accessibilityLabel = "SLUG-ACC-STATE-BUTTON-LABEL-Warn".accessibilityLocalizedVariant
        warnSetButton?.accessibilityHint = "SLUG-ACC-STATE-BUTTON-HINT".accessibilityLocalizedVariant
        finalSetButton?.accessibilityLabel = "SLUG-ACC-STATE-BUTTON-LABEL-Final".accessibilityLocalizedVariant
        finalSetButton?.accessibilityHint = "SLUG-ACC-STATE-BUTTON-HINT".accessibilityLocalizedVariant
        startButton?.accessibilityLabel = "SLUG-ACC-PLAY-BUTTON-LABEL".accessibilityLocalizedVariant
        startButton?.accessibilityHint = "SLUG-ACC-PLAY-BUTTON-HINT".accessibilityLocalizedVariant
        clearButton?.accessibilityHint = "SLUG-ACC-CLEAR-BUTTON".accessibilityLocalizedVariant
        
        guard 2 < _pickerViewData.count else { return }
        
        stateLabel?.accessibilityHint = "SLUG-ACC-STATE".accessibilityLocalizedVariant
        hoursLabel?.accessibilityHint = String(format: "SLUG-ACC-0-LABEL-FORMAT".accessibilityLocalizedVariant, _pickerViewData[0].upperBound - 1)
        minutesLabel?.accessibilityHint = String(format: "SLUG-ACC-1-LABEL-FORMAT".accessibilityLocalizedVariant, _pickerViewData[1].upperBound - 1)
        secondsLabel?.accessibilityHint = String(format: "SLUG-ACC-2-LABEL-FORMAT".accessibilityLocalizedVariant, _pickerViewData[2].upperBound - 1)

        startSetButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        startSetButton?.titleLabel?.minimumScaleFactor = 0.5
        warnSetButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        warnSetButton?.titleLabel?.minimumScaleFactor = 0.5
        finalSetButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        finalSetButton?.titleLabel?.minimumScaleFactor = 0.5
        
        // High contrast, means high contrast.
        if isHighContrastMode {
            finalSetButton?.setTitleColor(.black, for: .normal)
        }

        _selectionFeedbackGenerator = UISelectionFeedbackGenerator()
        _selectionFeedbackGenerator?.prepare()
        
        _impactFeedbackGenerator = UIImpactFeedbackGenerator()
        _impactFeedbackGenerator?.prepare()
        
        navigationItem.backButtonTitle = "SLUG-BACK-BUTTON".localizedVariant
    }
    
    /* ############################################################## */
    /**
     Called when the view is about to appear.
     We use this to start the "fade in" animation.
     
     - parameter inIsAnimated: True, if the transition is to be animated (ignored, but sent to the superclass).
     */
    override func viewWillAppear(_ inIsAnimated: Bool) {
        super.viewWillAppear(inIsAnimated)
        
        #if DEBUG
            print("Timer Setup Loaded for Timer \(RVS_AmbiaMara_Settings().currentTimerIndex).")
            print("Timer: \(_currentTimer).")
        #endif

        navigationController?.isNavigationBarHidden = false
        UIApplication.shared.isIdleTimerDisabled = false    // Just in case...
        
        setAlarmIcon()

        // First time through, we do a "fade in" animation.
        if nil != startupLogo,
           inIsAnimated {
            startupLogo?.alpha = 1.0
            containerView?.alpha = Self._initialSettingsItemAlpha
            alarmSetBarButtonItem?.isEnabled = false
            settingsBarButtonItem?.isEnabled = false
            setTimePickerView?.isUserInteractionEnabled = false // Don't let the user use the picker, until the animation is done.
            UIView.animate(withDuration: Self._fadeInAnimationPeriodInSeconds,
                           animations: { [weak self] in
                                            self?.startupLogo?.alpha = 0.0
                                            self?.containerView?.alpha = 1.0
                                        },
                           completion: { [weak self] _ in
                                            DispatchQueue.main.async {
                                                self?.startupLogo?.removeFromSuperview()
                                                self?.startupLogo = nil
                                                self?.alarmSetBarButtonItem?.isEnabled = true
                                                self?.settingsBarButtonItem?.isEnabled = true
                                                self?.setTimePickerView?.isUserInteractionEnabled = true
                                                self?.view?.setNeedsLayout()
                                            }
                                        }
            )
        } else {
            setUpButtons()
        }
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
                if let leftSwipe = backgroundLeftSwipeGestureRecognizer {
                    swipeGestureReceived(leftSwipe)
                }
                
            case UIKeyCommand.inputRightArrow:
                didHandleEvent = true
                if let rightSwipe = backgroundRightSwipeGestureRecognizer {
                    swipeGestureReceived(rightSwipe)
                }

            case " ", "\r":
                didHandleEvent = true
                startButtonHit()
                performSegue(withIdentifier: Self._startTimerSegueID, sender: nil)
                
            default:
                break
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RVS_SetTimerAmbiaMara_ViewController {    
    /* ################################################################## */
    /**
     This sets up the buttons and the picker to the current state.
    */
    func setUpButtons() {
        stateLabel?.text = "SLUG-STATE-\(_state.stringValue)".localizedVariant
        
        startSetButton?.isEnabled = .start != _state
        warnSetButton?.isEnabled = .warn != _state
        && 1 < _currentTimer.startTime
        finalSetButton?.isEnabled = .final != _state
        && 1 < _currentTimer.startTime
        && (1 < _currentTimer.warnTime
            || 0 == _currentTimer.warnTime)
        startButton?.isEnabled = 0 < _currentTimer.startTime
        clearButton?.isHidden = 0 >= _stateTime()
        
        stateLabel?.accessibilityHint = "SLUG-ACC-STATE-\(_state.stringValue)".accessibilityLocalizedVariant
        stateLabel?.accessibilityHint = "SLUG-ACC-STATE".accessibilityLocalizedVariant + " " + "SLUG-ACC-STATE-PREFIX-\(_state.stringValue)".accessibilityLocalizedVariant
        
        if 0 < _currentTimer.startTime,
           .start != _state {
            let timeAsComponents = _currentTimer.startTimeAsComponents
            var label = ""
            guard 2 < timeAsComponents.count else { return }
            if 0 < timeAsComponents[0] {
                label = String(format: " %d:%02d:%02d ", timeAsComponents[0], timeAsComponents[1], timeAsComponents[2])
            } else if 0 < timeAsComponents[1] {
                label = String(format: " %d:%02d ", timeAsComponents[1], timeAsComponents[2])
            } else if 0 < timeAsComponents[2] {
                label = String(format: " %d ", timeAsComponents[2])
            }
            startSetButton?.setTitle(label, for: .normal)
        } else {
            startSetButton?.setTitle(nil, for: .normal)
        }
        
        if 0 < _currentTimer.warnTime,
           .warn != _state {
            let timeAsComponents = _currentTimer.warnTimeAsComponents
            var label = ""
            guard 2 < timeAsComponents.count else { return }
            if 0 < timeAsComponents[0] {
                label = String(format: " %d:%02d:%02d ", timeAsComponents[0], timeAsComponents[1], timeAsComponents[2])
            } else if 0 < timeAsComponents[1] {
                label = String(format: " %d:%02d ", timeAsComponents[1], timeAsComponents[2])
            } else if 0 < timeAsComponents[2] {
                label = String(format: " %d ", timeAsComponents[2])
            }
            warnSetButton?.setTitle(label, for: .normal)
        } else {
            warnSetButton?.setTitle(nil, for: .normal)
        }
        
        if 0 < _currentTimer.finalTime,
           .final != _state {
            let timeAsComponents = _currentTimer.finalTimeAsComponents
            var label = ""
            guard 2 < timeAsComponents.count else { return }
            if 0 < timeAsComponents[0] {
                label = String(format: " %d:%02d:%02d ", timeAsComponents[0], timeAsComponents[1], timeAsComponents[2])
            } else if 0 < timeAsComponents[1] {
                label = String(format: " %d:%02d ", timeAsComponents[1], timeAsComponents[2])
            } else if 0 < timeAsComponents[2] {
                label = String(format: " %d ", timeAsComponents[2])
            }
            finalSetButton?.setTitle(label, for: .normal)
        } else {
            finalSetButton?.setTitle(nil, for: .normal)
        }
        
        setUpTime()
    }
    
    func setUpTime() {
        var timeAsComponents: [Int]
        switch _state {
        case .start:
            pickerTime = _currentTimer.startTime
            timeAsComponents = _currentTimer.startTimeAsComponents
        case .warn:
            pickerTime = _currentTimer.warnTime
            timeAsComponents = _currentTimer.warnTimeAsComponents
        case .final:
            pickerTime = _currentTimer.finalTime
            timeAsComponents = _currentTimer.finalTimeAsComponents
        }
        
        guard 2 < timeAsComponents.count else { return }

        setTimePickerView?.accessibilityHint = String(format: "SLUG-CURRENT-TIMER-TIME-FORMAT".localizedVariant, timeAsComponents[0], timeAsComponents[1], timeAsComponents[2])

        setTimePickerView?.reloadAllComponents()
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension RVS_SetTimerAmbiaMara_ViewController {
    /* ############################################################## */
    /**
     The user swiped the timer. If there are multiple timers, it selects the next/previous one.
     If there is only one timer, the gesture is ignored.
     
     - parameter inGestureRecognizer: The swipe gesture recognizer.
     */
    @IBAction func swipeGestureReceived(_ inGestureRecognizer: UISwipeGestureRecognizer) {
//        guard 1 < RVS_AmbiaMara_Settings().numberOfTimers else { return }
//        
//        var selectTimerIndex = -1
//        
//        if inGestureRecognizer == backgroundLeftSwipeGestureRecognizer,
//           let nextTimerIndex = _nextTimerIndex {
//            selectTimerIndex = nextTimerIndex
//        } else if inGestureRecognizer == backgroundRightSwipeGestureRecognizer,
//                  let previousTimerIndex = _previousTimerIndex {
//            selectTimerIndex = previousTimerIndex
//        }
//        
//        guard (0..<RVS_AmbiaMara_Settings().numberOfTimers).contains(selectTimerIndex) else { return }
//        
//        if hapticsAreAvailable {
//            if 0 == selectTimerIndex || (RVS_AmbiaMara_Settings().numberOfTimers - 1) == selectTimerIndex {
//                _impactFeedbackGenerator?.impactOccurred(intensity: CGFloat(UIImpactFeedbackGenerator.FeedbackStyle.rigid.rawValue))
//                _impactFeedbackGenerator?.prepare()
//            } else {
//                _selectionFeedbackGenerator?.selectionChanged()
//                _selectionFeedbackGenerator?.prepare()
//            }
//        }
//
//        RVS_AmbiaMara_Settings().currentTimerIndex = selectTimerIndex
//        _state = .start
    }

    /* ################################################################## */
    /**
     The clear button was hit.
     - parameter inClearButton: the clear button instance.
    */
    @IBAction func clearButtonHit(_ inClearButton: UIButton) {
        guard let setPickerControl = setTimePickerView else { return }

        switch _state {
        case .start:
            _currentTimer.startTime = 0

        case .warn:
            _currentTimer.warnTime = 0

        case .final:
            _currentTimer.finalTime = 0
        }

        if hapticsAreAvailable {
            _impactFeedbackGenerator?.impactOccurred(intensity: CGFloat(UIImpactFeedbackGenerator.FeedbackStyle.rigid.rawValue))
            _impactFeedbackGenerator?.prepare()
        }
        setPickerControl.selectRow(0, inComponent: PickerComponents.hour.rawValue, animated: true)
        pickerView(setPickerControl, didSelectRow: 0, inComponent: PickerComponents.hour.rawValue)
        setPickerControl.selectRow(0, inComponent: PickerComponents.minute.rawValue, animated: true)
        pickerView(setPickerControl, didSelectRow: 0, inComponent: PickerComponents.minute.rawValue)
        setPickerControl.selectRow(0, inComponent: PickerComponents.second.rawValue, animated: true)
        pickerView(setPickerControl, didSelectRow: 0, inComponent: PickerComponents.second.rawValue)
    }

    /* ################################################################## */
    /**
     Called when one of the state buttons is hit. It sets the screen state.
     
     - parameter inButton: The button that was hit.
    */
    @IBAction func setButtonHit(_ inButton: UIButton) {
        if hapticsAreAvailable {
            _selectionFeedbackGenerator?.selectionChanged()
            _selectionFeedbackGenerator?.prepare()
        }
        
        switch inButton {
        case startSetButton:
            _state = .start
        case warnSetButton:
            _state = .warn
        case finalSetButton:
            _state = .final
        default:
            _state = .start
        }
    }
    
    /* ################################################################## */
    /**
     The timer start button was hit.
     
     - parameter: ignored (and can be omitted).
    */
    @IBAction func startButtonHit(_: Any! = nil) {
        if hapticsAreAvailable {
            _impactFeedbackGenerator?.impactOccurred(intensity: CGFloat(UIImpactFeedbackGenerator.FeedbackStyle.heavy.rawValue))
            _impactFeedbackGenerator?.prepare()
        }
        _state = .start
    }
    
    /* ################################################################## */
    /**
     This is called, when someone selects the Alarm Set Bar Button.
     It displays a popover, with tools to select the audible (or vibratory) alarm.
     - parameter inButtonItem: the bar button item.
     */
    @IBAction func displayAlarmSetupPopover(_ inButtonItem: UIBarButtonItem) {
        if let popoverController = storyboard?.instantiateViewController(identifier: RVS_SetAlarmAmbiaMara_PopoverViewController.storyboardID) as? RVS_SetAlarmAmbiaMara_PopoverViewController {
            if hapticsAreAvailable {
                _selectionFeedbackGenerator?.selectionChanged()
                _selectionFeedbackGenerator?.prepare()
            }
            popoverController.modalPresentationStyle = .popover
            popoverController.myController = self
            popoverController.popoverPresentationController?.barButtonItem = inButtonItem
            popoverController.popoverPresentationController?.delegate = self
            popoverController.preferredContentSize = CGSize(width: Self._settingsPopoverWidthInDisplayUnits, height: RVS_SetAlarmAmbiaMara_PopoverViewController.settingsPopoverHeightInDisplayUnits)
            currentDisplayedPopover = popoverController
            present(popoverController, animated: true)
       }
    }
    
    /* ################################################################## */
    /**
     This is called, when someone selects the Settings Bar Button.
     It displays a popover, with various app settings.
     - parameter inButtonItem: the bar button item.
     */
    @IBAction func displaySettingsPopover(_ inButtonItem: UIBarButtonItem) {
        if let popoverController = storyboard?.instantiateViewController(identifier: RVS_SettingsAmbiaMara_PopoverViewController.storyboardID) as? RVS_SettingsAmbiaMara_PopoverViewController {
            if hapticsAreAvailable {
                _selectionFeedbackGenerator?.selectionChanged()
                _selectionFeedbackGenerator?.prepare()
            }
            popoverController.modalPresentationStyle = .popover
            popoverController.myController = self
            popoverController.popoverPresentationController?.barButtonItem = inButtonItem
            popoverController.popoverPresentationController?.delegate = self
            popoverController.preferredContentSize = CGSize(width: Self._settingsPopoverWidthInDisplayUnits, height: RVS_SettingsAmbiaMara_PopoverViewController.settingsPopoverHeightInDisplayUnits)
            currentDisplayedPopover = popoverController
            present(popoverController, animated: true)
       }
    }

    /* ################################################################## */
    /**
     This makes sure the alarm icon at the top, is the correct one.
    */
    func setAlarmIcon() {
        alarmSetBarButtonItem?.image = UIImage(systemName: RVS_AmbiaMara_Settings().alarmMode ? "bell.fill" : "bell.slash.fill")
    }

    /* ################################################################## */
    /**
     This shows the about screen.
    */
    func showAboutScreen() {
        performSegue(withIdentifier: Self._aboutViewSegueID, sender: nil)
    }
}

/* ###################################################################################################################################### */
// MARK: UIPickerViewDataSource Conformance
/* ###################################################################################################################################### */
extension RVS_SetTimerAmbiaMara_ViewController: UIPickerViewDataSource {
    /* ################################################################## */
    /**
     - parameter in: The picker view (ignored).
     
     - returns the number of components (always 3)
    */
    func numberOfComponents(in: UIPickerView) -> Int { _pickerViewData.count }
    
    /* ################################################################## */
    /**
     - parameter: The picker view (ignored)
     - parameter numberOfRowsInComponent: The 0-based index of the component we are querying.
    */
    func pickerView(_: UIPickerView, numberOfRowsInComponent inComponent: Int) -> Int {
        guard (0..<_pickerViewData.count).contains(inComponent) else { return 0 }
        return (_pickerViewData[inComponent].max() ?? -1) + 1
    }
}

/* ###################################################################################################################################### */
// MARK: UIPickerViewDelegate Conformance
/* ###################################################################################################################################### */
extension RVS_SetTimerAmbiaMara_ViewController: UIPickerViewDelegate {
    /* ################################################################## */
    /**
     All picker rows are the same height.
     - parameter inPickerView: The picker instance.
     - parameter rowHeightForComponent: ignored (the component we're checking).
    */
    func pickerView(_ inPickerView: UIPickerView, rowHeightForComponent: Int) -> CGFloat { inPickerView.bounds.height / 3 }
    
    /* ################################################################## */
    /**
     This is called when a row is selected.
     It verifies that the value is OK, and may change the selection, if not.
     - parameter inPickerView: The picker instance.
     - parameter didSelectRow: The 0-based row index, in the component.
     - parameter inComponent: The component that contains the selected row (0-based index).
    */
    func pickerView(_ inPickerView: UIPickerView, didSelectRow inRow: Int, inComponent: Int) {
        let originalPickerTime = _stateTime(from: pickerTime)
        
        if .start == _state {
            _currentTimer.startTime = originalPickerTime
        } else if .warn == _state {
            _currentTimer.warnTime = originalPickerTime
        } else {
            _currentTimer.finalTime = originalPickerTime
        }
        
        var currentValue = originalPickerTime
        
        let hours = min(99, currentValue / (60 * 60))
        currentValue -= (hours * 60 * 60)
        let minutes = min(59, currentValue / 60)
        currentValue -= (minutes * 60)
        let seconds = min(59, currentValue)
        
        if hours != inPickerView.selectedRow(inComponent: PickerComponents.hour.rawValue) {
            inPickerView.selectRow(hours, inComponent: PickerComponents.hour.rawValue, animated: true)
        }
        
        if minutes != inPickerView.selectedRow(inComponent: PickerComponents.minute.rawValue) {
            inPickerView.selectRow(minutes, inComponent: PickerComponents.minute.rawValue, animated: true)
        }
        
        if seconds != inPickerView.selectedRow(inComponent: PickerComponents.second.rawValue) {
            inPickerView.selectRow(seconds, inComponent: PickerComponents.second.rawValue, animated: true)
        }

        if 0 == inComponent {
            inPickerView.reloadComponent(1)
            inPickerView.reloadComponent(2)
        } else if 1 == inComponent {
            inPickerView.reloadComponent(2)
        }
        
        setUpButtons()
    }
    
    /* ################################################################## */
    /**
     This returns the view to display for the picker row.
     
     - parameter inPickerView: The picker instance.
     - parameter viewForRow: The 0-based row index to be displayed.
     - parameter forComponent: The 0-based component index for the row.
     - parameter reusing: If a row has been previously created, we use that, instead.
     - returns: A new view, containing the row. If it is selected, it is displayed as reversed.
    */
    func pickerView(_ inPickerView: UIPickerView, viewForRow inRow: Int, forComponent inComponent: Int, reusing inReusingView: UIView?) -> UIView {
        let selectedRow = inPickerView.selectedRow(inComponent: inComponent)
        
        guard nil == inReusingView else { return inReusingView ?? UIView() }
        
        let ret = UILabel()
        ret.font = Self._pickerFont
        ret.textColor = .white
        ret.textAlignment = .center

        let hasValue: [Bool] = [0 < inPickerView.selectedRow(inComponent: PickerComponents.hour.rawValue),
                                0 < inPickerView.selectedRow(inComponent: PickerComponents.minute.rawValue)
                                ]

        if 2 == hasValue.count, // Belt and suspenders...
           (0..<_pickerViewData.count).contains(inComponent),
           0 < inRow
            || (hasValue[0] && PickerComponents.minute.rawValue == inComponent)
            || ((hasValue[0] || hasValue[1]) && PickerComponents.second.rawValue == inComponent) {
            ret.text = String(_pickerViewData[inComponent][inRow])
            if inRow == selectedRow {
                ret.textColor = UIColor(named: "PickerTextColor")
                ret.cornerRadius = Self._pickerCornerRadiusInDisplayUnits
                ret.clipsToBounds = true
                ret.backgroundColor = .white
            }
        } else {
            ret.text = "0"
       }
        
        return ret
    }
}

/* ###################################################################################################################################### */
// MARK: UIPickerViewAccessibilityDelegate Conformance
/* ###################################################################################################################################### */
extension RVS_SetTimerAmbiaMara_ViewController: UIPickerViewAccessibilityDelegate {
    /* ################################################################## */
    /**
     This returns the accessibility label for the picker component.
     
     - parameter inPickerView: The picker instance.
     - parameter accessibilityHintForComponent: The 0-based component index for the label.
     - returns: An accessibility string for the component.
    */
    func pickerView(_ inPickerView: UIPickerView, accessibilityHintForComponent inComponent: Int) -> String? {
        guard (0..<_pickerViewData.count).contains(inComponent) else { return nil }
        
        return String(format: "SLUG-ACC-\(inComponent)-FORMAT".accessibilityLocalizedVariant,
               _pickerViewData[inComponent].upperBound - 1,
               inPickerView.selectedRow(inComponent: inComponent)
        )
    }
}

/* ###################################################################################################################################### */
// MARK: UIPopoverPresentationControllerDelegate Conformance
/* ###################################################################################################################################### */
extension RVS_SetTimerAmbiaMara_ViewController: UIPopoverPresentationControllerDelegate {
    /* ################################################################## */
    /**
     Called to ask if there's any possibility of this being displayed in another way.
     
     - parameter for: The presentation controller we're talking about.
     - returns: No way, Jose.
     */
    func adaptivePresentationStyle(for: UIPresentationController) -> UIModalPresentationStyle { .none }
    
    /* ################################################################## */
    /**
     Called to ask if there's any possibility of this being displayed in another way (when the screen is rotated).
     
     - parameter for: The presentation controller we're talking about.
     - parameter traitCollection: The traits, describing the new orientation.
     - returns: No way, Jose.
     */
    func adaptivePresentationStyle(for: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle { .none }
}
