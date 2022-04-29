/*
 © Copyright 2018-2022, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
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
    private static let _maxTimerCount = 3

    /* ################################################################## */
    /**
     The current screen state.
    */
    private var _state: States = .start

    /* ################################################################## */
    /**
     The "startup" logo that we fade out.
    */
    @IBOutlet weak var startupLogo: UIImageView?

    /* ################################################################## */
    /**
     The state label.
    */
    @IBOutlet weak var stateLabel: UILabel!
    
    /* ################################################################## */
    /**
     The button to select the start time set state.
    */
    @IBOutlet weak var labelContainerStackView: UIStackView?

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
    @IBOutlet weak var toolbar: UIToolbar?
    
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
        
        guard let items = toolbar?.items else { return [] }
        
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
        
        let startTimeInSeconds = RVS_AmbiaMara_Settings().currentTimer.startTime
        let warnTimeInSeconds = RVS_AmbiaMara_Settings().currentTimer.warnTime
        
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
                self?.setUpBarButtonItems()
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
        startSetButton?.accessibilityLabel = "SLUG-ACC-STATE-Start".localizedVariant
        warnSetButton?.accessibilityLabel = "SLUG-ACC-STATE-Warn".localizedVariant
        finalSetButton?.accessibilityLabel = "SLUG-ACC-STATE-Final".localizedVariant
        setButtonsUp()
    }
    
    /* ############################################################## */
    /**
     Called when the view is about to appear.
     We use this to start the "fade in" animation.
     
     - parameter inIsAnimated: True, if the transition is to be animated (ignored, but sent to the superclass).
     */
    override func viewWillAppear(_ inIsAnimated: Bool) {
        super.viewWillAppear(inIsAnimated)
        fadeInAnimation()
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension RVS_SetTimerAmbiaMara_ViewController {
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
        setButtonsUp()
    }
    
    /* ################################################################## */
    /**
     Called when the trash bar button item has been hit.
     - parameter: ignored.
    */
    @IBAction func trashHit(_: Any) {
        if 1 < timerBarItems.count {
            RVS_AmbiaMara_Settings().remove(timer: RVS_AmbiaMara_Settings().currentTimer)
            setUpBarButtonItems()
            _state = .start
            setButtonsUp()
        }
    }
    
    /* ################################################################## */
    /**
     Called when the add bar button item has been hit.
     - parameter: ignored.
    */
    @IBAction func addHit(_: Any) {
        if Self._maxTimerCount > timerBarItems.count {
            RVS_AmbiaMara_Settings().add(timer: RVS_AmbiaMara_Settings.TimerSettings(), andSelect: true)
            setUpBarButtonItems()
            _state = .start
            setButtonsUp()
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
        RVS_AmbiaMara_Settings().currentTimerIndex = tag - 1
        setUpBarButtonItems()
        _state = .start
        setButtonsUp()
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RVS_SetTimerAmbiaMara_ViewController {
    /* ################################################################## */
    /**
    */
    func setUpBarButtonItems() {
        if let items = toolbar?.items {
            var newItems: [UIBarButtonItem] = [items[0], items[1], items[items.count - 2], items[items.count - 1]]
            for timer in RVS_AmbiaMara_Settings().timers.enumerated() {
                let tag = timer.offset + 1
                let timerButton = UIBarButtonItem()
                let startTimeAsComponents = timer.element.startTimeAsComponents
                timerButton.tag = tag
                timerButton.title = "\(String(format: "%02d", startTimeAsComponents[0])):\(String(format: "%02d", startTimeAsComponents[1])):\(String(format: "%02d", startTimeAsComponents[2]))"
                timerButton.target = self
                timerButton.action = #selector(selectToolbarItem(_:))
                newItems.insert(timerButton, at: 2 + timer.offset)
            }
            
            toolbar?.setItems(newItems, animated: false)
            
            determineBarButtonStatus()
        }
    }
    
    /* ################################################################## */
    /**
    */
    func determineBarButtonStatus() {
        trashBarButtonItem?.isEnabled = 1 < timerBarItems.count
        for item in timerBarItems.enumerated() {
            item.element.isEnabled = item.offset != RVS_AmbiaMara_Settings().currentTimerIndex
        }
        addBarButtonItem?.isEnabled = Self._maxTimerCount > timerBarItems.count
    }
    
    /* ################################################################## */
    /**
     This handles the "fade in" animation. This only happens, the first time.
     */
    func fadeInAnimation() {
        view.layoutIfNeeded()
        if let startupLogo = startupLogo {
            startupLogo.alpha = 1.0
            setupContainerView?.alpha = 0.0
            view.layoutIfNeeded()
            UIView.animate(withDuration: Self._fadeInAnimationPeriod,
                           animations: { [weak self] in
                                            startupLogo.alpha = 0.0
                                            self?.setupContainerView?.alpha = 1.0
                                            self?.view.layoutIfNeeded()
                                        },
                           completion: { [weak self] _ in
                                            DispatchQueue.main.async {
                                                startupLogo.removeFromSuperview()
                                                self?.startupLogo = nil
                                            }
                                        }
            )
        }
    }
    
    /* ################################################################## */
    /**
     This sets up the buttons and the picker to the current state.
    */
    func setButtonsUp() {
        stateLabel?.text = "SLUG-STATE-\(_state.stringValue)".localizedVariant
        
        startSetButton?.isUserInteractionEnabled = .start != _state
        warnSetButton?.isUserInteractionEnabled = .warn != _state
        finalSetButton?.isUserInteractionEnabled = .final != _state
        
        setupContainerView?.accessibilityLabel = "SLUG-ACC-STATE-\(_state.stringValue)".localizedVariant

        switch _state {
        case .start:
            pickerTime = RVS_AmbiaMara_Settings().currentTimer.startTime
        case .warn:
            pickerTime = RVS_AmbiaMara_Settings().currentTimer.warnTime
        case .final:
            pickerTime = RVS_AmbiaMara_Settings().currentTimer.finalTime
        }
        
        view.layoutIfNeeded()
        UIView.animate(withDuration: Self._selectionFadeAnimationPeriod,
                       animations: { [weak self] in
                                        self?.setupContainerView?.backgroundColor = UIColor(named: "\(self?._state.stringValue ?? "ERROR")-Color")
                                        self?.stateLabel?.textColor = .final == self?._state ? .white : .black
                                        self?.hoursLabel?.textColor = .final == self?._state ? .white : .black
                                        self?.minutesLabel?.textColor = .final == self?._state ? .white : .black
                                        self?.secondsLabel?.textColor = .final == self?._state ? .white : .black
                                        self?.startSetButton?.backgroundColor = .start != self?._state ? .black : self?.setupContainerView?.backgroundColor
                                        self?.warnSetButton?.backgroundColor = .warn != self?._state ? .black : self?.setupContainerView?.backgroundColor
                                        self?.finalSetButton?.backgroundColor = .final != self?._state ? .black : self?.setupContainerView?.backgroundColor
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
            RVS_AmbiaMara_Settings().currentTimer.startTime = originalPickerTime
        case .warn:
            RVS_AmbiaMara_Settings().currentTimer.warnTime = originalPickerTime
        case .final:
            RVS_AmbiaMara_Settings().currentTimer.finalTime = originalPickerTime
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
        setUpBarButtonItems()
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
