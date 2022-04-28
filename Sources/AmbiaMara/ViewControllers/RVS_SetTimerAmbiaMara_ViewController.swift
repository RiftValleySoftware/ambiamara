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
    // MARK: - Time Sections Enum -
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
    // MARK: - App State Enum -
    /* ################################################################################################################################## */
    /**
     */
    enum States: Int {
        /* ############################################################## */
        /**
         The timer is alarming.
        */
        case alarm = -1

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
            case .alarm:
                return "Alarm"
                
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
     The size of the picker font
    */
    private static let _pickerFont = UIFont.boldSystemFont(ofSize: 60) // UIFont(name: "Let's Go Digital", size: 60)

    /* ################################################################## */
    /**
     The size of the picker selection corner radius.
    */
    private static let _pickerCornerRadius = CGFloat(8)

    /* ################################################################## */
    /**
     The period that we use for the "fade in" animation.
    */
    private static let _fadeAnimationPeriod = CGFloat(1.0)

    /* ################################################################## */
    /**
     The period that we use for the "fade in" animation.
    */
    private static let _pickerViewData: [Range<Int>] = [0..<100, 0..<60, 0..<60]

    /* ################################################################## */
    /**
     The current screen state.
    */
    private var _state: States = .start

    /* ################################################################## */
    /**
     This holds the set times (0 is start, 1, is warning, and 2 is final).
     These are seconds.
    */
    private var _setTimesInSeconds: [Int] = [0, 0, 0]

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
    */
    @IBOutlet weak var hoursLabel: UILabel?

    /* ################################################################## */
    /**
    */
    @IBOutlet weak var minutesLabel: UILabel?

    /* ################################################################## */
    /**
    */
    @IBOutlet weak var secondsLabel: UILabel?
    
    /* ################################################################## */
    /**
     The timer set picker control.
    */
    @IBOutlet weak var setPickerControl: UIPickerView?
    
    /* ################################################################## */
    /**
     The horizontal stack view that contains the three state buttons.
    */
    @IBOutlet weak var buttonContainerStackView: UIStackView?

    /* ################################################################## */
    /**
     The button to select the start time set state.
    */
    @IBOutlet weak var startSetButton: RVS_MaskButton?

    /* ################################################################## */
    /**
     The button to select the warning time set state.
    */
    @IBOutlet weak var warnSetButton: RVS_MaskButton?

    /* ################################################################## */
    /**
     The button to select the final time set state.
    */
    @IBOutlet weak var finalSetButton: RVS_MaskButton?
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension RVS_SetTimerAmbiaMara_ViewController {
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
            var currentValue = newValue
            let hours = min(99, currentValue / (60 * 60))
            currentValue -= (hours * 60 * 60)
            let minutes = min(59, currentValue / 60)
            currentValue -= (minutes * 60)
            let seconds = min(59, currentValue)
            DispatchQueue.main.async { [weak self] in
                guard let setPickerControl = self?.setPickerControl else { return }
                setPickerControl.reloadAllComponents()
                setPickerControl.selectRow(hours, inComponent: PickerComponents.hour.rawValue, animated: false)
                setPickerControl.selectRow(minutes, inComponent: PickerComponents.minute.rawValue, animated: false)
                setPickerControl.selectRow(seconds, inComponent: PickerComponents.second.rawValue, animated: false)
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RVS_SetTimerAmbiaMara_ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        hoursLabel?.text = (hoursLabel?.text ?? "ERROR").localizedVariant
        minutesLabel?.text = (minutesLabel?.text ?? "ERROR").localizedVariant
        secondsLabel?.text = (secondsLabel?.text ?? "ERROR").localizedVariant
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
    @IBAction func setButtonHit(_ inButton: RVS_MaskButton) {
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
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RVS_SetTimerAmbiaMara_ViewController {
    /* ################################################################## */
    /**
     This handles the "fade in" animation. This only happens, the first time.
     */
    func fadeInAnimation() {
        view.layoutIfNeeded()
        if let startupLogo = startupLogo {
            startupLogo.alpha = 1.0
            setPickerControl?.alpha = 0.0
            buttonContainerStackView?.alpha = 0.0
            labelContainerStackView?.alpha = 0.0
            view.layoutIfNeeded()
            UIView.animate(withDuration: Self._fadeAnimationPeriod,
                           animations: { [weak self] in
                                            startupLogo.alpha = 0.0
                                            self?.setPickerControl?.alpha = 1.0
                                            self?.buttonContainerStackView?.alpha = 1.0
                                            self?.labelContainerStackView?.alpha = 1.0
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
        pickerTime = 0
        stateLabel?.text = "SLUG-STATE-\(_state.stringValue)".localizedVariant
        setPickerControl?.reloadAllComponents()
        labelContainerStackView?.backgroundColor = UIColor(named: "\(_state.stringValue)-GradientTopColor")
        stateLabel?.textColor = .final == _state ? .white : .black
        hoursLabel?.textColor = .final == _state ? .white : .black
        minutesLabel?.textColor = .final == _state ? .white : .black
        secondsLabel?.textColor = .final == _state ? .white : .black
        startSetButton?.reversed = .start == _state
        warnSetButton?.reversed = .warn == _state
        finalSetButton?.reversed = .final == _state
        pickerTime = _setTimesInSeconds[_state.rawValue]
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
    func numberOfComponents(in: UIPickerView) -> Int { Self._pickerViewData.count }
    
    /* ################################################################## */
    /**
     - parameter: The picker view (ignored)
     - parameter numberOfRowsInComponent: The 0-based index of the component we are querying.
    */
    func pickerView(_: UIPickerView, numberOfRowsInComponent inComponent: Int) -> Int { (Self._pickerViewData[inComponent].max() ?? -1) + 1 }
}

/* ###################################################################################################################################### */
// MARK: UIPickerViewDelegate Conformance
/* ###################################################################################################################################### */
extension RVS_SetTimerAmbiaMara_ViewController: UIPickerViewDelegate {
    /* ################################################################## */
    /**
     All picker rows are the same height, based on the point size of the font.
    */
    func pickerView(_: UIPickerView, rowHeightForComponent: Int) -> CGFloat { max(0, Self._pickerFont.pointSize - 10) }
    
    /* ################################################################## */
    /**
    */
    func pickerView(_ inPickerView: UIPickerView, didSelectRow inRow: Int, inComponent: Int) {
        _setTimesInSeconds[_state.rawValue] = pickerTime
        inPickerView.reloadAllComponents()
    }
    
    /* ################################################################## */
    /**
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
        
        let value = Self._pickerViewData[inComponent][inRow]
        let ret = RVS_MaskButton()
        ret.setTitle(String(value), for: .normal)
        ret.cornerRadius = Self._pickerCornerRadius
        ret.buttonFont = Self._pickerFont
        ret.gradientStartColor = UIColor(named: "\(_state.stringValue)-GradientTopColor")
        ret.gradientEndColor = UIColor(named: "\(_state.stringValue)-GradientBottomColor")
        ret.isEnabled = false
        ret.reversed = (inRow == inPickerView.selectedRow(inComponent: inComponent))
        return ret
    }
}
