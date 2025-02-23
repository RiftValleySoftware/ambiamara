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
     The maximum number of timers we can have.
    */
    private static let _maximumNumberOfTimers = 7

    /* ################################################################## */
    /**
     The current screen state.
    */
    private var _state: States {
        get { container?.state ?? .start }
        set {
            container?.state = newValue
            setUpButtons()
        }
    }

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
     The 0-based timer index for this screen. -1, if no timer assigned.
    */
    var timerIndex: Int = -1
    
    /* ################################################################## */
    /**
     The actual timer instance for this screen.
    */
    var timer: RVS_AmbiaMara_Settings.TimerSettings? {
        didSet {
            if let timer {
                RVS_AmbiaMara_Settings().currentTimer = timer
            }
        }
    }
    
    /* ################################################################## */
    /**
     Shortcut to the overall container for this instance.
    */
    weak var container: RVS_SetTimerWrapper?

    // MARK: Overall Items
    
    /* ################################################################## */
    /**
     The "startup" logo that we fade out.
    */
    @IBOutlet weak var startupLogo: UIImageView?
    
    // MARK: Bar Button Items
    
    /* ################################################################## */
    /**
     The set alarm popover bar button item.
    */
    @IBOutlet weak var alarmSetButton: UIBarButtonItem?
    
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
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension RVS_SetTimerAmbiaMara_ViewController {
    /* ############################################################## */
    /**
     - returns: The index of the following timer. Nil, if no following timer.
                This "circles around," so the last timer points to the first timer.
     */
    private var _nextTimerIndex: Int? {
        guard 1 < RVS_AmbiaMara_Settings().numberOfTimers else { return nil }
        
        let nextIndex = RVS_AmbiaMara_Settings().currentTimerIndex + 1
        
        guard nextIndex < RVS_AmbiaMara_Settings().numberOfTimers else { return nil }
        
        return nextIndex
    }
    
    /* ############################################################## */
    /**
     - returns: The index of the previous timer. Nil, if no previous timer.
                This "circles around," so the first timer points to the last timer.
     */
    private var _previousTimerIndex: Int? {
        guard 1 < RVS_AmbiaMara_Settings().numberOfTimers else { return nil }
        
        let previousIndex = RVS_AmbiaMara_Settings().currentTimerIndex - 1
        
        guard 0 <= previousIndex else { return nil }
        
        return previousIndex
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
        guard let timer else { return 0 }
        
        var currentValue = -1 == inTime ? pickerTime : inTime
        
        let startTimeInSeconds = timer.startTime
        let warnTimeInSeconds = timer.warnTime
        
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
        alarmSetButton?.accessibilityLabel = "SLUG-ACC-ALARM-BUTTON-LABEL".accessibilityLocalizedVariant
        alarmSetButton?.accessibilityHint = "SLUG-ACC-ALARM-BUTTON".accessibilityLocalizedVariant
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
        
        guard (0..<RVS_AmbiaMara_Settings().timers.count).contains(timerIndex) else { return }
        
        timer = RVS_AmbiaMara_Settings().timers[timerIndex]
        
        RVS_AmbiaMara_Settings().currentTimerIndex = timerIndex
        
        #if DEBUG
            print("Timer Setup Loaded for Timer \(timerIndex).")
            print("Timer: \(timer.debugDescription).")
        #endif

        UIApplication.shared.isIdleTimerDisabled = false    // Just in case...
        
        container?.setUpToolbar()
        container?.setAlarmIcon()
        container?.setTimerLabel()
        setUpButtons()
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
        guard let timer else { return }
        
        stateLabel?.text = "SLUG-STATE-\(_state.stringValue)".localizedVariant
        
        startSetButton?.isEnabled = .start != _state
        warnSetButton?.isEnabled = .warn != _state
        && 1 < timer.startTime
        finalSetButton?.isEnabled = .final != _state
        && 1 < timer.startTime
        && (1 < timer.warnTime
            || 0 == timer.warnTime)
        startButton?.isEnabled = 0 < timer.startTime
        clearButton?.isHidden = 0 >= _stateTime()
        
        stateLabel?.accessibilityHint = "SLUG-ACC-STATE-\(_state.stringValue)".accessibilityLocalizedVariant
        stateLabel?.accessibilityHint = "SLUG-ACC-STATE".accessibilityLocalizedVariant + " " + "SLUG-ACC-STATE-PREFIX-\(_state.stringValue)".accessibilityLocalizedVariant
        
        if 0 < timer.startTime,
           .start != _state {
            let timeAsComponents = timer.startTimeAsComponents
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
        
        if 0 < timer.warnTime,
           .warn != _state {
            let timeAsComponents = timer.warnTimeAsComponents
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
        
        if 0 < timer.finalTime,
           .final != _state {
            let timeAsComponents = timer.finalTimeAsComponents
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
        
        animateIntro()
    }
    
    /* ################################################################## */
    /**
     This animates the intro of the screen.
    */
    func animateIntro() {
        guard let timer else { return }
        
        view.layoutIfNeeded()

        var timeAsComponents: [Int]
        switch _state {
        case .start:
            pickerTime = timer.startTime
            timeAsComponents = timer.startTimeAsComponents
        case .warn:
            pickerTime = timer.warnTime
            timeAsComponents = timer.warnTimeAsComponents
        case .final:
            pickerTime = timer.finalTime
            timeAsComponents = timer.finalTimeAsComponents
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
    /* ################################################################## */
    /**
     The clear button was hit.
     - parameter inClearButton: the clear button instance.
    */
    @IBAction func clearButtonHit(_ inClearButton: UIButton) {
        guard let setPickerControl = setTimePickerView else { return }

        switch _state {
        case .start:
            timer?.startTime = 0

        case .warn:
            timer?.warnTime = 0

        case .final:
            timer?.finalTime = 0
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
        _state = .start
        container?.startTimer()
        
        if hapticsAreAvailable {
            _impactFeedbackGenerator?.impactOccurred(intensity: CGFloat(UIImpactFeedbackGenerator.FeedbackStyle.heavy.rawValue))
            _impactFeedbackGenerator?.prepare()
        }
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
            timer?.startTime = originalPickerTime
        } else if .warn == _state {
            timer?.warnTime = originalPickerTime
        } else {
            timer?.finalTime = originalPickerTime
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
     - parameter reusing: If a row has been previously created, it is sent in here (ignored).
     - returns: A new view, containing the row. If it is selected, it is displayed as reversed.
    */
    func pickerView(_ inPickerView: UIPickerView, viewForRow inRow: Int, forComponent inComponent: Int, reusing: UIView?) -> UIView {
        let selectedRow = inPickerView.selectedRow(inComponent: inComponent)
        
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
