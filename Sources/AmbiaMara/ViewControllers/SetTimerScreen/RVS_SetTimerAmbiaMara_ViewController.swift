/*
 © Copyright 2018-2022, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_Generic_Swift_Toolbox
import RVS_MaskButton

/* ###################################################################################################################################### */
// MARK: - Initial View Controller -
/* ###################################################################################################################################### */
/**
 This is the view controller for the setup screen, where the timer is set, and started.
 */
class RVS_SetTimerAmbiaMara_ViewController: RVS_AmbiaMara_BaseViewController {
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
     The maximum number of timers we can have.
    */
    private static let _maximumNumberOfTimers = 7

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

    // MARK: Toolbar
    
    /* ################################################################## */
    /**
     This is the toolbar on the bottom, with the timers.
    */
    @IBOutlet weak var bottomToolbar: UIToolbar?
    
    /* ################################################################## */
    /**
     This is the leftmost button, the trash icon.
    */
    @IBOutlet weak var trashBarButtonItem: UIBarButtonItem?
    
    /* ################################################################## */
    /**
     This is the rightmost button, the add button.
    */
    @IBOutlet weak var addBarButtonItem: UIBarButtonItem?
    
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
     The current timer, cached.
    */
    private var _currentTimer: RVS_AmbiaMara_Settings.TimerSettings {
        get { RVS_AmbiaMara_Settings().currentTimer }
        set { RVS_AmbiaMara_Settings().currentTimer = newValue  }
    }

    /* ################################################################## */
    /**
     This will list our timer toolbar items.
    */
    private var _timerBarItems: [UIBarButtonItem] {
        var ret = [UIBarButtonItem]()
        
        guard let items = bottomToolbar?.items else { return [] }
        
        for item in items.enumerated() where (2..<(items.count - 2)).contains(item.offset) {
            ret.append(item.element)
        }
        
        return ret
    }
    
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
                setPickerControl.selectRow(hours, inComponent: PickerComponents.hour.rawValue, animated: false)
                setPickerControl.selectRow(minutes, inComponent: PickerComponents.minute.rawValue, animated: false)
                setPickerControl.selectRow(seconds, inComponent: PickerComponents.second.rawValue, animated: false)
                setPickerControl.reloadAllComponents()
                self?.setUpToolbar()
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
        hoursLabel?.text = (hoursLabel?.text ?? "ERROR").localizedVariant
        minutesLabel?.text = (minutesLabel?.text ?? "ERROR").localizedVariant
        secondsLabel?.text = (secondsLabel?.text ?? "ERROR").localizedVariant
        
        // We should not rely on gestures for Catalyst. Also, voiceover mode does not work well with gestures.
        // [ProcessInfo().isMacCatalystApp](https://developer.apple.com/documentation/foundation/nsprocessinfo/3362531-maccatalystapp)
        // is a general-purpose Mac detector, and works better than the precompiler targetEnvironment test.
        if ProcessInfo().isMacCatalystApp || UIAccessibility.isVoiceOverRunning {
            RVS_AmbiaMara_Settings().displayToolbar = true
        }

        settingsBarButtonItem?.accessibilityLabel = "SLUG-ACC-SETTINGS-BUTTON".localizedVariant
        alarmSetBarButtonItem?.accessibilityLabel = "SLUG-ACC-ALARM-BUTTON".localizedVariant
        startSetButton?.accessibilityLabel = "SLUG-ACC-STATE-BUTTON-LABEL-Start".localizedVariant
        startSetButton?.accessibilityHint = "SLUG-ACC-STATE-BUTTON-HINT".localizedVariant
        warnSetButton?.accessibilityLabel = "SLUG-ACC-STATE-BUTTON-LABEL-Warn".localizedVariant
        warnSetButton?.accessibilityHint = "SLUG-ACC-STATE-BUTTON-HINT".localizedVariant
        finalSetButton?.accessibilityLabel = "SLUG-ACC-STATE-BUTTON-LABEL-Final".localizedVariant
        finalSetButton?.accessibilityHint = "SLUG-ACC-STATE-BUTTON-HINT".localizedVariant
        startButton?.accessibilityLabel = "SLUG-ACC-PLAY-BUTTON".localizedVariant
        startButton?.accessibilityHint = "SLUG-ACC-PLAY-BUTTON-HINT".localizedVariant
        addBarButtonItem?.accessibilityLabel = "SLUG-ACC-ADD-TIMER-BUTTON".localizedVariant
        clearButton?.accessibilityLabel = "SLUG-ACC-CLEAR-BUTTON".localizedVariant
        
        stateLabel?.accessibilityHint = "SLUG-ACC-STATE".localizedVariant
        hoursLabel?.accessibilityLabel = String(format: "SLUG-ACC-0-LABEL-FORMAT".localizedVariant, _pickerViewData[0].upperBound - 1)
        minutesLabel?.accessibilityLabel = String(format: "SLUG-ACC-1-LABEL-FORMAT".localizedVariant, _pickerViewData[1].upperBound - 1)
        secondsLabel?.accessibilityLabel = String(format: "SLUG-ACC-2-LABEL-FORMAT".localizedVariant, _pickerViewData[2].upperBound - 1)

        startSetButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        startSetButton?.titleLabel?.minimumScaleFactor = 0.5
        warnSetButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        warnSetButton?.titleLabel?.minimumScaleFactor = 0.5
        finalSetButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        finalSetButton?.titleLabel?.minimumScaleFactor = 0.5
        
        if isHighContrastMode {
            finalSetButton?.setTitleColor(.black, for: .normal)
        }

        // Makes the toolbar background transparent.
        bottomToolbar?.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        bottomToolbar?.setShadowImage(UIImage(), forToolbarPosition: .any)

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
        if let startupLogo = startupLogo {
            alarmSetBarButtonItem?.isEnabled = false
            settingsBarButtonItem?.isEnabled = false
            setTimePickerView?.isUserInteractionEnabled = false
            startupLogo.alpha = 1.0
            containerView?.alpha = Self._initialSettingsItemAlpha
            view.layoutIfNeeded()
            UIView.animate(withDuration: Self._fadeInAnimationPeriodInSeconds,
                           animations: { [weak self] in
                                            startupLogo.alpha = 0.0
                                            self?.containerView?.alpha = 1.0
                                            self?.view.layoutIfNeeded()
                                        },
                           completion: { [weak self] _ in
                                            DispatchQueue.main.async {
                                                startupLogo.removeFromSuperview()
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
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RVS_SetTimerAmbiaMara_ViewController {
    /* ################################################################## */
    /**
     This sets up the toolbar, by adding all the timers.
    */
    func setUpToolbar() {
        if let items = bottomToolbar?.items {
            var newItems: [UIBarButtonItem] = [items[0], items[1], items[items.count - 2], items[items.count - 1]]
            if 1 < RVS_AmbiaMara_Settings().numberOfTimers {
                let currentTag = _currentTimer.index + 1
                navigationItem.title = String(format: "SLUG-TIMER-TITLE-FORMAT".localizedVariant, currentTag)
                for timer in RVS_AmbiaMara_Settings().timers.enumerated() {
                    let tag = timer.offset + 1
                    let timerButton = UIBarButtonItem()
                    let startTimeAsComponents = timer.element.startTimeAsComponents
                    var timeString: String
                    if 0 < startTimeAsComponents[0] {
                        timeString = "\(String(format: "%d", startTimeAsComponents[0])):\(String(format: "%02d", startTimeAsComponents[1])):\(String(format: "%02d", startTimeAsComponents[2]))"
                    } else if 0 < startTimeAsComponents[1] {
                        timeString = "\(String(format: "%d", startTimeAsComponents[1])):\(String(format: "%02d", startTimeAsComponents[2]))"
                    } else {
                        timeString = String(startTimeAsComponents[2])
                    }
                    
                    timerButton.tag = tag
                    let imageName = "\(tag).circle\(currentTag != tag ? ".fill" : "")"
                    timerButton.image = UIImage(systemName: imageName)?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large))
                    timerButton.accessibilityLabel = String(format: "SLUG-ACC-TIMER-BUTTON-LABEL-FORMAT".localizedVariant, tag)
                    timerButton.accessibilityHint = String(format: "SLUG-ACC-TIMER-BUTTON-HINT-\(currentTag == tag ? "IS" : "NOT")-FORMAT".localizedVariant, timeString)
                    timerButton.isEnabled = currentTag != tag
                    timerButton.target = self
                    timerButton.tintColor = view?.tintColor
                    timerButton.action = #selector(selectToolbarItem(_:))
                    newItems.insert(timerButton, at: 2 + timer.offset)
                }
                trashBarButtonItem?.accessibilityLabel = String(format: "SLUG-ACC-DELETE-TIMER-BUTTON-FORMAT".localizedVariant, currentTag)
            } else {
                navigationItem.title = nil
            }
            
            bottomToolbar?.setItems(newItems, animated: false)
            
            trashBarButtonItem?.isEnabled = 1 < _timerBarItems.count
            addBarButtonItem?.isEnabled = Self._maximumNumberOfTimers > _timerBarItems.count
        }
    }
    
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
        
        stateLabel?.accessibilityLabel = "SLUG-ACC-STATE-\(_state.stringValue)".localizedVariant
        stateLabel?.accessibilityHint = "SLUG-ACC-STATE".localizedVariant + " " + "SLUG-ACC-STATE-PREFIX-\(_state.stringValue)".localizedVariant

        if 0 < _currentTimer.startTime,
           .start != _state {
            let timeAsComponents = _currentTimer.startTimeAsComponents
            var label = ""
            if 0 < timeAsComponents[0] {
                label = String(format: " %02d:%02d:%02d ", timeAsComponents[0], timeAsComponents[1], timeAsComponents[2])
            } else if 0 < timeAsComponents[1] {
                label = String(format: " %02d:%02d ", timeAsComponents[1], timeAsComponents[2])
            } else if 0 < timeAsComponents[2] {
                label = String(format: " %02d ", timeAsComponents[2])
            }
            startSetButton?.setTitle(label, for: .normal)
        } else {
            startSetButton?.setTitle(nil, for: .normal)
        }

        if 0 < _currentTimer.warnTime,
           .warn != _state {
            let timeAsComponents = _currentTimer.warnTimeAsComponents
            var label = ""
            if 0 < timeAsComponents[0] {
                label = String(format: " %02d:%02d:%02d ", timeAsComponents[0], timeAsComponents[1], timeAsComponents[2])
            } else if 0 < timeAsComponents[1] {
                label = String(format: " %02d:%02d ", timeAsComponents[1], timeAsComponents[2])
            } else if 0 < timeAsComponents[2] {
                label = String(format: " %02d ", timeAsComponents[2])
            }
            warnSetButton?.setTitle(label, for: .normal)
        } else {
            warnSetButton?.setTitle(nil, for: .normal)
        }

        if 0 < _currentTimer.finalTime,
           .final != _state {
            let timeAsComponents = _currentTimer.finalTimeAsComponents
            var label = ""
            if 0 < timeAsComponents[0] {
                label = String(format: " %02d:%02d:%02d ", timeAsComponents[0], timeAsComponents[1], timeAsComponents[2])
            } else if 0 < timeAsComponents[1] {
                label = String(format: " %02d:%02d ", timeAsComponents[1], timeAsComponents[2])
            } else if 0 < timeAsComponents[2] {
                label = String(format: " %02d ", timeAsComponents[2])
            }
            finalSetButton?.setTitle(label, for: .normal)
        } else {
            finalSetButton?.setTitle(nil, for: .normal)
        }

        view.layoutIfNeeded()
        UIView.animate(withDuration: Self._selectionFadeAnimationPeriodInSeconds,
                       animations: { [weak self] in
            self?.topLabelContainerView?.backgroundColor = (self?.isHighContrastMode ?? false) ? .white : UIColor(named: "\(self?._state.stringValue ?? "ERROR")-Color")
            self?.startSetButton?.backgroundColor = .start != self?._state ? ((self?.isHighContrastMode ?? false) ? .white : UIColor(named: "Start-Color"))
                                                        : ((self?.isHighContrastMode ?? false) ? .black : UIColor(named: "Start-Color")?.withAlphaComponent(0.4))
            self?.warnSetButton?.backgroundColor = .warn != self?._state && 0 < self?._currentTimer.startTime ?? 0 ? ((self?.isHighContrastMode ?? false) ? .white : UIColor(named: "Warn-Color"))
                                                        :  ((self?.isHighContrastMode ?? false) ? .black : UIColor(named: "Warn-Color")?.withAlphaComponent(0.4))
            self?.finalSetButton?.backgroundColor = .final != self?._state && 0 < self?._currentTimer.startTime ?? 0
                                                    ? ((self?.isHighContrastMode ?? false) ? .white : UIColor(named: "Final-Color"))
                                                    :  ((self?.isHighContrastMode ?? false) ? .black : UIColor(named: "Final-Color")?.withAlphaComponent(0.4))
            self?.startSetButton?.borderColor = .start == self?._state ? ((self?.isHighContrastMode ?? false) ? .white : UIColor(named: "Start-Color")) : nil
            self?.startSetButton?.borderWidth = .start == self?._state ? 4 : 0
            self?.warnSetButton?.borderColor = .warn == self?._state ? ((self?.isHighContrastMode ?? false) ? .white : UIColor(named: "Warn-Color")) : nil
            self?.warnSetButton?.borderWidth = .warn == self?._state ? 4 : 0
            self?.finalSetButton?.borderColor = .final == self?._state ? ((self?.isHighContrastMode ?? false) ? .white : UIColor(named: "Final-Color")) : nil
            self?.finalSetButton?.borderWidth = .final == self?._state ? 4 : 0
            self?.stateLabel?.textColor = (!(self?.isHighContrastMode ?? false) && .final == self?._state) ? .white : .black
                                        self?.hoursLabel?.textColor = (!(self?.isHighContrastMode ?? false) && .final == self?._state) ? .white : .black
                                        self?.minutesLabel?.textColor = (!(self?.isHighContrastMode ?? false) && .final == self?._state) ? .white : .black
                                        self?.secondsLabel?.textColor = (!(self?.isHighContrastMode ?? false) && .final == self?._state) ? .white : .black
                                        self?.view.layoutIfNeeded()
                                    },
                       completion: nil
        )

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
        
        setTimePickerView?.accessibilityHint = String(format: "SLUG-CURRENT-TIMER-TIME-FORMAT".localizedVariant, timeAsComponents[0], timeAsComponents[1], timeAsComponents[2])
        navigationController?.navigationBar.accessibilityHint = String(format: "SLUG-CURRENT-TIMER-SELECTED-FORMAT".localizedVariant, _currentTimer.index + 1)
            + " " + "SLUG-ACC-STATE-PREFIX-\(_state.stringValue)".localizedVariant
            + " " + String(format: "SLUG-CURRENT-TIMER-TIME-FORMAT".localizedVariant, timeAsComponents[0], timeAsComponents[1], timeAsComponents[2])

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
        guard 1 < RVS_AmbiaMara_Settings().numberOfTimers else { return }
        
        var selectTimerIndex = -1
        
        if inGestureRecognizer == backgroundRightSwipeGestureRecognizer,
           let nextTimerIndex = _nextTimerIndex {
            selectTimerIndex = nextTimerIndex
        } else if inGestureRecognizer == backgroundLeftSwipeGestureRecognizer,
                  let previousTimerIndex = _previousTimerIndex {
            selectTimerIndex = previousTimerIndex
        }
        
        guard (0..<RVS_AmbiaMara_Settings().numberOfTimers).contains(selectTimerIndex) else { return }
        
        if areHapticsAvailable {
            if 0 == selectTimerIndex || (RVS_AmbiaMara_Settings().numberOfTimers - 1) == selectTimerIndex {
                _impactFeedbackGenerator?.impactOccurred(intensity: CGFloat(UIImpactFeedbackGenerator.FeedbackStyle.rigid.rawValue))
                _impactFeedbackGenerator?.prepare()
            } else {
                _selectionFeedbackGenerator?.selectionChanged()
                _selectionFeedbackGenerator?.prepare()
            }
        }

        RVS_AmbiaMara_Settings().currentTimerIndex = selectTimerIndex
        setUpToolbar()
        _state = .start
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

        if areHapticsAvailable {
            _impactFeedbackGenerator?.impactOccurred(intensity: CGFloat(UIImpactFeedbackGenerator.FeedbackStyle.rigid.rawValue))
            _impactFeedbackGenerator?.prepare()
        }
        setPickerControl.selectRow(0, inComponent: PickerComponents.hour.rawValue, animated: false)
        pickerView(setPickerControl, didSelectRow: 0, inComponent: PickerComponents.hour.rawValue)
        setPickerControl.selectRow(0, inComponent: PickerComponents.minute.rawValue, animated: false)
        pickerView(setPickerControl, didSelectRow: 0, inComponent: PickerComponents.minute.rawValue)
        setPickerControl.selectRow(0, inComponent: PickerComponents.second.rawValue, animated: false)
        pickerView(setPickerControl, didSelectRow: 0, inComponent: PickerComponents.second.rawValue)
    }

    /* ################################################################## */
    /**
     Called when one of the state buttons is hit. It sets the screen state.
     
     - parameter inButton: The button that was hit.
    */
    @IBAction func setButtonHit(_ inButton: UIButton) {
        if areHapticsAvailable {
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
     Called when the trash bar button item has been hit.
     This puts up a confirmation screen, asking if the user is sure they want to delete the timer.
     - parameter: ignored.
    */
    @IBAction func trashHit(_: Any) {
        if 1 < _timerBarItems.count {
            if areHapticsAvailable {
                _impactFeedbackGenerator?.impactOccurred(intensity: CGFloat(UIImpactFeedbackGenerator.FeedbackStyle.rigid.rawValue))
                _impactFeedbackGenerator?.prepare()
            }

            let timerTag = _currentTimer.index + 1
            let startTimeAsComponents = _currentTimer.startTimeAsComponents
            var timeString: String
            
            if 0 < startTimeAsComponents[0] {
                timeString = "\(String(format: "%d", startTimeAsComponents[0])):\(String(format: "%02d", startTimeAsComponents[1])):\(String(format: "%02d", startTimeAsComponents[2]))"
            } else if 0 < startTimeAsComponents[1] {
                timeString = "\(String(format: "%d", startTimeAsComponents[1])):\(String(format: "%02d", startTimeAsComponents[2]))"
            } else {
                timeString = String(startTimeAsComponents[2])
            }
            
            let message = timeString.isEmpty || "0" == timeString
                ? String(format: "SLUG-DELETE-CONFIRM-MESSAGE-FORMAT-ZERO".localizedVariant, timerTag)
                : String(format: "SLUG-DELETE-CONFIRM-MESSAGE-FORMAT".localizedVariant, timerTag, timeString)
            let alertController = UIAlertController(title: "SLUG-DELETE-CONFIRM-HEADER".localizedVariant, message: message, preferredStyle: .alert
            )

            let okAction = UIAlertAction(title: "SLUG-DELETE-BUTTON-TEXT".localizedVariant, style: .destructive, handler: { [weak self] _ in
                if let currentTimer = self?._currentTimer {
                    if self?.areHapticsAvailable ?? false {
                        self?._impactFeedbackGenerator?.impactOccurred(intensity: CGFloat(UIImpactFeedbackGenerator.FeedbackStyle.rigid.rawValue))
                        self?._impactFeedbackGenerator?.prepare()
                    }
                    RVS_AmbiaMara_Settings().remove(timer: currentTimer)
                }
                self?.setUpToolbar()
                self?._state = .start
                self?.setUpButtons()
            })
            
            alertController.addAction(okAction)

            let cancelAction = UIAlertAction(title: "SLUG-CANCEL-BUTTON-TEXT".localizedVariant, style: .cancel, handler: { [weak self] _ in
                if self?.areHapticsAvailable ?? false {
                    self?._selectionFeedbackGenerator?.selectionChanged()
                    self?._selectionFeedbackGenerator?.prepare()
                }
            })

            alertController.addAction(cancelAction)

            present(alertController, animated: true, completion: nil)
        }
    }
    
    /* ################################################################## */
    /**
     Called when the add bar button item has been hit.
     - parameter: ignored.
    */
    @IBAction func addHit(_: Any) {
        if Self._maximumNumberOfTimers > _timerBarItems.count {
            guard let setupContainerView = setupContainerView,
                  let view = view else { return }
            if areHapticsAvailable {
                _selectionFeedbackGenerator?.selectionChanged()
                _selectionFeedbackGenerator?.prepare()
            }
            
            RVS_AmbiaMara_Settings().add(andSelect: true)
            setupContainerView.transform = CGAffineTransform(translationX: view.bounds.size.width / 2, y: view.bounds.size.height / 2)
            setupContainerView.transform = setupContainerView.transform.scaledBy(x: 0.1, y: 0.1)
            setupContainerView.alpha = 0.0
            _state = .start
            setUpButtons()
            view.layoutIfNeeded()
            UIView.animate(withDuration: Self._addTimerAnimationPeriodInSeconds,
                           animations: { setupContainerView.transform = CGAffineTransform.identity
                                         setupContainerView.alpha = 1.0
                                        },
                           completion: { [weak self] _ in
                                            if self?.areHapticsAvailable ?? false {
                                                self?._impactFeedbackGenerator?.impactOccurred(intensity: CGFloat(UIImpactFeedbackGenerator.FeedbackStyle.soft.rawValue))
                                                self?._impactFeedbackGenerator?.prepare()
                                                self?.setUpToolbar()
                                            }
                                        }
            )
        }
    }
    
    /* ################################################################## */
    /**
     The timer start button was hit.
     
     - parameter: ignored.
    */
    @IBAction func startButtonHit(_: Any) {
        if areHapticsAvailable {
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
            if areHapticsAvailable {
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
            if areHapticsAvailable {
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
     Called when the add bar button item has been hit.
     - parameter: ignored.
    */
    @objc func selectToolbarItem(_ inToolbarButton: UIBarButtonItem) {
        let tag = inToolbarButton.tag
        guard (1...RVS_AmbiaMara_Settings().numberOfTimers).contains(tag) else { return }
        if areHapticsAvailable {
            _selectionFeedbackGenerator?.selectionChanged()
            _selectionFeedbackGenerator?.prepare()
        }
        RVS_AmbiaMara_Settings().currentTimerIndex = tag - 1
        setUpToolbar()
        _state = .start
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
    func pickerView(_: UIPickerView, numberOfRowsInComponent inComponent: Int) -> Int { (_pickerViewData[inComponent].max() ?? -1) + 1 }
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
            inPickerView.selectRow(hours, inComponent: PickerComponents.hour.rawValue, animated: false)
        }
        
        if minutes != inPickerView.selectedRow(inComponent: PickerComponents.minute.rawValue) {
            inPickerView.selectRow(minutes, inComponent: PickerComponents.minute.rawValue, animated: false)
        }
        
        if seconds != inPickerView.selectedRow(inComponent: PickerComponents.second.rawValue) {
            inPickerView.selectRow(seconds, inComponent: PickerComponents.second.rawValue, animated: false)
        }

        if 0 == inComponent {
            inPickerView.reloadComponent(1)
            inPickerView.reloadComponent(2)
        } else if 1 == inComponent {
            inPickerView.reloadComponent(2)
        }
        
        setUpToolbar()
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
        
        let ret = RVS_MaskButton()
        ret.buttonFont = Self._pickerFont
        ret.gradientStartColor = .white
        ret.isEnabled = false

        let hasValue: [Bool] = [0 < inPickerView.selectedRow(inComponent: PickerComponents.hour.rawValue),
                                0 < inPickerView.selectedRow(inComponent: PickerComponents.minute.rawValue)
                                ]

        if 0 < inRow
            || (hasValue[0] && PickerComponents.minute.rawValue == inComponent)
            || ((hasValue[0] || hasValue[1]) && PickerComponents.second.rawValue == inComponent) {
            ret.setTitle(String(_pickerViewData[inComponent][inRow]), for: .normal)
            ret.cornerRadius = Self._pickerCornerRadiusInDisplayUnits
            ret.reversed = (inRow == selectedRow)
        } else {
            ret.setTitle("0", for: .normal)
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
     - parameter accessibilityLabelForComponent: The 0-based component index for the label.
     - returns: An accessibility string for the component.
    */
    func pickerView(_ inPickerView: UIPickerView, accessibilityLabelForComponent inComponent: Int) -> String? {
        String(format: "SLUG-ACC-\(inComponent)-FORMAT".localizedVariant,
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
