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
     The period that we use for the "fade in" animation.
    */
    private static let _alarmPopoverSize = CGSize(width: 400, height: 228)

    /* ################################################################## */
    /**
     The period that we use for the "fade in" animation.
    */
    private static let _fadeInAnimationPeriod = CGFloat(1.0)

    /* ################################################################## */
    /**
     The period that we use for the selection fade animation.
    */
    private static let _selectionFadeAnimationPeriod = CGFloat(0.5)

    /* ################################################################## */
    /**
     The size of the picker font
    */
    private static let _pickerFont = UIFont.monospacedDigitSystemFont(ofSize: 40, weight: .bold)

    /* ################################################################## */
    /**
     The size of the picker selection corner radius.
    */
    private static let _pickerCornerRadius = CGFloat(4)

    /* ################################################################## */
    /**
     The ranges that we use to populate the picker (default).
    */
    private static let _defaultPickerViewData: [Range<Int>] = [0..<100, 0..<60, 0..<60]

    /* ################################################################## */
    /**
     The maximum number of timers we can have.
    */
    private static let _maxTimerCount = 7

    /* ################################################################## */
    /**
     The current screen state.
    */
    private var _state: States = .start { didSet { setUpButtons() } }

    /* ################################################################## */
    /**
     The current timer, cached.
    */
    private var _currentTimer: RVS_AmbiaMara_Settings.TimerSettings?

    /* ################################################################## */
    /**
     The current timer, cached.
    */
    var currentTimer: RVS_AmbiaMara_Settings.TimerSettings {
        get {
            guard nil == _currentTimer else { return _currentTimer ?? RVS_AmbiaMara_Settings.TimerSettings() }
            _currentTimer = RVS_AmbiaMara_Settings().currentTimer
            
            return _currentTimer ?? RVS_AmbiaMara_Settings.TimerSettings()
        }
        
        set {
            RVS_AmbiaMara_Settings().currentTimer = newValue
            _currentTimer = nil
        }
    }
    
    /* ################################################################## */
    /**
     If a popover is being displayed, we reference it here (so we put it away, when we ned to).
    */
    weak var currentPopover: UIViewController?

    /* ################################################################## */
    /**
     The set alarm bar button item.
    */
    @IBOutlet weak var alarmSetBarButtonItem: UIBarButtonItem?
    
    /* ################################################################## */
    /**
     The button that sets the timer back to zero.
    */
    @IBOutlet weak var clearButton: UIButton?
    
    /* ################################################################## */
    /**
     The about screen bar button item.
    */
    @IBOutlet weak var infoBarButtonItem: UIBarButtonItem?
    
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
    
    /* ################################################################## */
    /**
     The state label.
    */
    @IBOutlet weak var stateLabel: UILabel?
    
    /* ################################################################## */
    /**
     The button to select the start time set state.
    */
    @IBOutlet weak var topLabelContainerView: UIView?

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
    
    /* ################################################################## */
    /**
     The timer set picker control.
    */
    @IBOutlet weak var setPickerControl: UIPickerView?
    
    /* ################################################################## */
    /**
     This contains the whole timer settings area. It has a background color that changes for the state.
    */
    @IBOutlet weak var setupContainerView: UIView?
    
    /* ################################################################## */
    /**
     The horizontal stack view that contains the three state buttons.
    */
    @IBOutlet weak var buttonContainerStackView: UIStackView?

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
    
    /* ################################################################## */
    /**
     This starts the timer.
    */
    @IBOutlet weak var startButton: UIButton?
    
    /* ################################################################## */
    /**
     The popover gesture recognizer for the state.
    */
    @IBOutlet var stateTapGestureRecognizer: UITapGestureRecognizer?
    
    /* ################################################################## */
    /**
     The popover gesture recognizer for the hours component.
    */
    @IBOutlet var hoursTapGestureRecognizer: UITapGestureRecognizer?
    
    /* ################################################################## */
    /**
     The popover gesture recognizer for the minutes component.
    */
    @IBOutlet var minutesTapGestureRecognizer: UITapGestureRecognizer?
    
    /* ################################################################## */
    /**
     The popover gesture recognizer for the seconds component.
    */
    @IBOutlet var secondsTapGestureRecognizer: UITapGestureRecognizer?
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension RVS_SetTimerAmbiaMara_ViewController {
    /* ################################################################## */
    /**
     This will list out timer toolbar items.
    */
    var timerBarItems: [UIBarButtonItem] {
        var ret = [UIBarButtonItem]()
        
        guard let items = bottomToolbar?.items else { return [] }
        
        for item in items.enumerated() where (2..<(items.count - 2)).contains(item.offset) {
            ret.append(item.element)
        }
        
        return ret
    }

    /* ################################################################## */
    /**
     Returns the currently limited value (warn can't be higher than start, and final can't be higher than either warn or start).
     - parameter from: The time being checked (in seconds).
     - returns: The normalized time (clipped, if necessary).
    */
    private func _stateTime(from inTime: Int) -> Int {
        var currentValue = inTime
        
        let startTimeInSeconds = currentTimer.startTime
        let warnTimeInSeconds = currentTimer.warnTime
        
        let startTimeThreshold = startTimeInSeconds - 1
        let warnTimeThreshold = startTimeInSeconds > warnTimeInSeconds && 0 < warnTimeInSeconds
                                    ? warnTimeInSeconds - 1
                                    : startTimeThreshold
        
        switch _state {
        case .start:
            break

        case .warn:
            currentValue = min(inTime, startTimeThreshold)
            
        case .final:
            currentValue = min(inTime, warnTimeThreshold)
        }
        
        return currentValue
    }

    /* ################################################################## */
    /**
     The ranges that we use to populate the picker.
     The picker will display Integers between the range endpoints.
    */
    private var _pickerViewData: [Range<Int>] { Self._defaultPickerViewData }

    /* ################################################################## */
    /**
     This is the number of seconds currently represented by the picker.
     Setting it, sets the picker.
    */
    var pickerTime: Int {
        get {
            guard let setPickerControl = setPickerControl else { return 0 }
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
                guard let setPickerControl = self?.setPickerControl else { return }
                setPickerControl.selectRow(hours, inComponent: PickerComponents.hour.rawValue, animated: false)
                setPickerControl.selectRow(minutes, inComponent: PickerComponents.minute.rawValue, animated: false)
                setPickerControl.selectRow(seconds, inComponent: PickerComponents.second.rawValue, animated: false)
                setPickerControl.reloadAllComponents()
                self?.setUpToolbar()
            }
        }
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
        
        infoBarButtonItem?.accessibilityLabel = "SLUG-ACC-ABOUT-BUTTON".localizedVariant
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

        // Makes the toolbar background transparent.
        bottomToolbar?.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        bottomToolbar?.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        // This allows us to set a help popover to the navigation bar.
        navigationController?.navigationBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(displayHelpPopover)))

        setUpButtons()
    }
    
    /* ############################################################## */
    /**
     Called when the view is about to appear.
     We use this to start the "fade in" animation.
     
     - parameter inIsAnimated: True, if the transition is to be animated (ignored, but sent to the superclass).
     */
    override func viewWillAppear(_ inIsAnimated: Bool) {
        super.viewWillAppear(inIsAnimated)
        navigationController?.isNavigationBarHidden = false
        
        stateLabel?.isUserInteractionEnabled = RVS_AmbiaMara_Settings().useGuidancePopovers
        hoursLabel?.isUserInteractionEnabled = RVS_AmbiaMara_Settings().useGuidancePopovers
        minutesLabel?.isUserInteractionEnabled = RVS_AmbiaMara_Settings().useGuidancePopovers
        secondsLabel?.isUserInteractionEnabled = RVS_AmbiaMara_Settings().useGuidancePopovers
        
        setAlarmIcon()
        
        // First time through, we do a "fade in" animation.
        if let startupLogo = startupLogo {
            alarmSetBarButtonItem?.isEnabled = false
            infoBarButtonItem?.isEnabled = false
            setPickerControl?.isUserInteractionEnabled = false
            startupLogo.alpha = 1.0
            containerView?.alpha = 0.0
            view.layoutIfNeeded()
            UIView.animate(withDuration: Self._fadeInAnimationPeriod,
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
                                                self?.infoBarButtonItem?.isEnabled = true
                                                self?.setPickerControl?.isUserInteractionEnabled = true
                                            }
                                        }
            )
        }
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
        currentTimer.finalTime = 0
        currentTimer.warnTime = 0
        currentTimer.startTime = 0
        
        _state = .start
        setUpButtons()
        setUpToolbar()
    }

    /* ################################################################## */
    /**
     Called when one of the state buttons is hit. It sets the screen state.
     
     - parameter inButton: The button that was hit.
    */
    @IBAction func setButtonHit(_ inButton: UIButton) {
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
        setUpButtons()
    }
    
    /* ################################################################## */
    /**
     Called when the trash bar button item has been hit.
     This puts up a confirmation screen, asking if the user is sure they want to delete the timer.
     - parameter: ignored.
    */
    @IBAction func trashHit(_: Any) {
        if 1 < timerBarItems.count {
            let timerTag = currentTimer.index + 1
            let startTimeAsComponents = currentTimer.startTimeAsComponents
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
                if let currentTimer = self?.currentTimer {
                    self?._currentTimer = nil
                    RVS_AmbiaMara_Settings().remove(timer: currentTimer)
                }
                self?.setUpToolbar()
                self?._state = .start
                self?.setUpButtons()
            })
            
            alertController.addAction(okAction)
            
            alertController.addAction(UIAlertAction(title: "SLUG-CANCEL-BUTTON-TEXT".localizedVariant, style: .cancel, handler: nil))

            present(alertController, animated: true, completion: nil)
        }
    }
    
    /* ################################################################## */
    /**
     Called when the add bar button item has been hit.
     - parameter: ignored.
    */
    @IBAction func addHit(_: Any) {
        if Self._maxTimerCount > timerBarItems.count {
            _currentTimer = nil
            RVS_AmbiaMara_Settings().add(andSelect: true)
            setUpToolbar()
            _state = .start
            setUpButtons()
        }
    }
    
    /* ################################################################## */
    /**
     The timer start button was hit.
     
     - parameter: ignored.
    */
    @IBAction func startButtonHit(_: Any) {
        _state = .start
    }
    
    /* ################################################################## */
    /**
     This is called, when someone selects one of the help items.
     It displays a popover, with help text.
     - parameter: ignored.
     */
    @IBAction func displayHelpPopover(_ inTapGestureRecognizer: UITapGestureRecognizer) {
        if RVS_AmbiaMara_Settings().useGuidancePopovers,
           let popoverController = storyboard?.instantiateViewController(identifier: RVS_HelpAmbiaMara_PopoverViewController.storyboardID) as? RVS_HelpAmbiaMara_PopoverViewController {
            var displayString = "ERROR"
            var viewHook: UIView?

            guard let setPickerControl = setPickerControl else { return }

            switch inTapGestureRecognizer {
            case hoursTapGestureRecognizer:
                displayString = pickerView(setPickerControl, accessibilityLabelForComponent: 0) ?? "ERROR"
                viewHook = hoursLabel
            case minutesTapGestureRecognizer:
                displayString = pickerView(setPickerControl, accessibilityLabelForComponent: 1) ?? "ERROR"
                viewHook = minutesLabel
            case secondsTapGestureRecognizer:
                displayString = pickerView(setPickerControl, accessibilityLabelForComponent: 2) ?? "ERROR"
                viewHook = secondsLabel
            case stateTapGestureRecognizer:
                displayString = "SLUG-ACC-STATE-\(_state.stringValue)".localizedVariant
                viewHook = stateLabel
            default:
                var timeAsComponents: [Int]
                switch _state {
                case .start:
                    pickerTime = currentTimer.startTime
                    timeAsComponents = currentTimer.startTimeAsComponents
                case .warn:
                    pickerTime = currentTimer.warnTime
                    timeAsComponents = currentTimer.warnTimeAsComponents
                case .final:
                    pickerTime = currentTimer.finalTime
                    timeAsComponents = currentTimer.finalTimeAsComponents
                }
                
                displayString = (1 < RVS_AmbiaMara_Settings().numberOfTimers ? String(format: "SLUG-CURRENT-TIMER-SELECTED-FORMAT".localizedVariant + "\n", currentTimer.index + 1) : "")
                                + "SLUG-ACC-STATE-PREFIX-\(_state.stringValue)".localizedVariant + "\n"
                                + String(format: "SLUG-CURRENT-TIMER-TIME-FORMAT".localizedVariant, timeAsComponents[0], timeAsComponents[1], timeAsComponents[2])
                viewHook = navigationController?.navigationBar
            }
           
            popoverController.descriptionString = displayString
            popoverController.modalPresentationStyle = .popover
            popoverController.popoverPresentationController?.sourceView = viewHook
            popoverController.popoverPresentationController?.delegate = self
            currentPopover = popoverController
            present(popoverController, animated: true)
       }
    }
    
    /* ################################################################## */
    /**
     This is called, when someone selects the Alarm Set Bar Button.
     It displays a popover, with tools to select the audible (or vibratory) alarm.
     - parameter inButtonItem: the bar button item.
     */
    @IBAction func displayAlarmSetupPopover(_ inButtonItem: UIBarButtonItem) {
        if let popoverController = storyboard?.instantiateViewController(identifier: RVS_SetAlarmAmbiaMara_PopoverViewController.storyboardID) as? RVS_SetAlarmAmbiaMara_PopoverViewController {
            popoverController.modalPresentationStyle = .popover
            popoverController.myController = self
            popoverController.popoverPresentationController?.barButtonItem = inButtonItem
            popoverController.popoverPresentationController?.delegate = self
            popoverController.preferredContentSize = Self._alarmPopoverSize
            currentPopover = popoverController
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
            popoverController.modalPresentationStyle = .popover
            popoverController.myController = self
            popoverController.popoverPresentationController?.barButtonItem = inButtonItem
            popoverController.popoverPresentationController?.delegate = self
            popoverController.preferredContentSize = Self._alarmPopoverSize
            currentPopover = popoverController
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
        _currentTimer = nil
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
            let currentTag = currentTimer.index + 1
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
            
            bottomToolbar?.setItems(newItems, animated: false)
            
            trashBarButtonItem?.accessibilityLabel = String(format: "SLUG-ACC-DELETE-TIMER-BUTTON-FORMAT".localizedVariant, currentTag)
            trashBarButtonItem?.isEnabled = 1 < timerBarItems.count
            addBarButtonItem?.isEnabled = Self._maxTimerCount > timerBarItems.count
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
                                    && 1 < currentTimer.startTime
        finalSetButton?.isEnabled = .final != _state
                                    && 1 < currentTimer.startTime
                                    && (1 < currentTimer.warnTime
                                        || 0 == currentTimer.warnTime)
        startButton?.isEnabled = 0 < currentTimer.startTime && (RVS_AmbiaMara_Settings().showDigits || RVS_AmbiaMara_Settings().showStoplights)
        clearButton?.isHidden = 0 >= currentTimer.startTime
        
        stateLabel?.accessibilityLabel = "SLUG-ACC-STATE".localizedVariant + " " + "SLUG-ACC-STATE-PREFIX-\(_state.stringValue)".localizedVariant
        stateLabel?.accessibilityHint = "SLUG-ACC-STATE-\(_state.stringValue)".localizedVariant

        var timeAsComponents: [Int]
        switch _state {
        case .start:
            pickerTime = currentTimer.startTime
            timeAsComponents = currentTimer.startTimeAsComponents
        case .warn:
            pickerTime = currentTimer.warnTime
            timeAsComponents = currentTimer.warnTimeAsComponents
        case .final:
            pickerTime = currentTimer.finalTime
            timeAsComponents = currentTimer.finalTimeAsComponents
        }
        
        setPickerControl?.accessibilityHint = String(format: "SLUG-CURRENT-TIMER-TIME-FORMAT".localizedVariant, timeAsComponents[0], timeAsComponents[1], timeAsComponents[2])
        navigationController?.navigationBar.accessibilityHint = String(format: "SLUG-CURRENT-TIMER-SELECTED-FORMAT".localizedVariant, currentTimer.index + 1)
            + " " + "SLUG-ACC-STATE-PREFIX-\(_state.stringValue)".localizedVariant
            + " " + String(format: "SLUG-CURRENT-TIMER-TIME-FORMAT".localizedVariant, timeAsComponents[0], timeAsComponents[1], timeAsComponents[2])

        view.layoutIfNeeded()
        UIView.animate(withDuration: Self._selectionFadeAnimationPeriod,
                       animations: { [weak self] in
                                        self?.topLabelContainerView?.backgroundColor = UIColor(named: "\(self?._state.stringValue ?? "ERROR")-Color")
                                        self?.stateLabel?.textColor = .final == self?._state ? .white : .black
                                        self?.hoursLabel?.textColor = .final == self?._state ? .white : .black
                                        self?.minutesLabel?.textColor = .final == self?._state ? .white : .black
                                        self?.secondsLabel?.textColor = .final == self?._state ? .white : .black
                                        self?.view.layoutIfNeeded()
                                    },
                       completion: nil
        )

        setPickerControl?.reloadAllComponents()
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
        switch _state {
        case .start:
            currentTimer.startTime = originalPickerTime
        case .warn:
            currentTimer.warnTime = originalPickerTime
        case .final:
            currentTimer.finalTime = originalPickerTime
        }
        
        var currentValue = originalPickerTime
        
        let hours = min(99, currentValue / (60 * 60))
        currentValue -= (hours * 60 * 60)
        let minutes = min(59, currentValue / 60)
        currentValue -= (minutes * 60)
        let seconds = min(59, currentValue)
        
        inPickerView.selectRow(hours, inComponent: PickerComponents.hour.rawValue, animated: false)
        inPickerView.selectRow(minutes, inComponent: PickerComponents.minute.rawValue, animated: false)
        inPickerView.selectRow(seconds, inComponent: PickerComponents.second.rawValue, animated: false)

        inPickerView.reloadAllComponents()
        setUpToolbar()
        setUpButtons()
    }
    
    /* ################################################################## */
    /**
     This returns the view to display for the picker row.
     
     - parameter inPickerView: The picker instance.
     - parameter viewForRow: The 0-based row index to be displayed.
     - parameter forComponent: The 0-based component index for the row.
     - parameter reusing: If a view will be reused, we'll use that, instead.
     - returns: A new view, containing the row. If it is selected, it is displayed as reversed.
    */
    func pickerView(_ inPickerView: UIPickerView, viewForRow inRow: Int, forComponent inComponent: Int, reusing inView: UIView?) -> UIView {
        let hasValue: [Bool] = [0 < inPickerView.selectedRow(inComponent: PickerComponents.hour.rawValue),
                                0 < inPickerView.selectedRow(inComponent: PickerComponents.minute.rawValue)
                                ]
        guard 0 < inRow || (hasValue[PickerComponents.hour.rawValue]
                            && PickerComponents.minute.rawValue == inComponent)
                        || ((hasValue[PickerComponents.hour.rawValue] || hasValue[PickerComponents.minute.rawValue])
                            && PickerComponents.second.rawValue == inComponent)
        else { return UIView() }
        
        guard let reusedView = inView else {
            let value = _pickerViewData[inComponent][inRow]
            let ret = RVS_MaskButton()
            ret.setTitle(String(value), for: .normal)
            ret.cornerRadius = Self._pickerCornerRadius
            ret.buttonFont = Self._pickerFont
            ret.gradientStartColor = UIColor(named: "\(_state.stringValue)-Color")
            ret.isEnabled = false
            ret.reversed = (inRow == inPickerView.selectedRow(inComponent: inComponent))
            return ret
        }
        
        return reusedView
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
        String(format: "SLUG-ACC-\(inComponent)-FORMAT".localizedVariant, _pickerViewData[inComponent].upperBound - 1, inPickerView.selectedRow(inComponent: inComponent))
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
