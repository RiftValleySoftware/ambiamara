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
 */
class RVS_SetTimerAmbiaMara_ViewController: RVS_AmbiaMara_BaseViewController {
    /* ################################################################################################################################## */
    // MARK: - Time Sections Enum -
    /* ################################################################################################################################## */
    /**
     */
    enum PickerComponents: Int {
        /* ############################################################## */
        /**
        */
        case hour
        
        /* ############################################################## */
        /**
        */
        case minute
        
        /* ############################################################## */
        /**
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
        */
        case alarm = -1

        /* ############################################################## */
        /**
        */
        case start
        
        /* ############################################################## */
        /**
        */
        case warn
        
        /* ############################################################## */
        /**
        */
        case final
        
        /* ############################################################## */
        /**
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
    private static let _pickerFont = UIFont(name: "Let's Go Digital", size: 60)

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
    */
    private var _state: States = .start

    /* ################################################################## */
    /**
    */
    private var _setTimesInSeconds: [Int] = [0, 0, 0]

    /* ################################################################## */
    /**
     The "startup" logo that we fade out.
    */
    @IBOutlet weak var startupLogo: UIImageView?

    /* ################################################################## */
    /**
    */
    @IBOutlet weak var setPickerControl: UIPickerView?
    
    /* ################################################################## */
    /**
    */
    @IBOutlet weak var buttonContainerStackView: UIStackView?

    /* ################################################################## */
    /**
    */
    @IBOutlet weak var startSetButton: RVS_MaskButton?

    /* ################################################################## */
    /**
    */
    @IBOutlet weak var warnSetButton: RVS_MaskButton?

    /* ################################################################## */
    /**
    */
    @IBOutlet weak var finalSetButton: RVS_MaskButton?
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension RVS_SetTimerAmbiaMara_ViewController {
    /* ################################################################## */
    /**
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
            guard let setPickerControl = setPickerControl else { return }
            var currentValue = newValue
            let hours = min(99, currentValue / (60 * 60))
            currentValue -= (hours * 60 * 60)
            let minutes = min(59, currentValue / 60)
            currentValue -= (minutes * 60)
            let seconds = min(59, currentValue)
            setPickerControl.reloadAllComponents()
            setPickerControl.selectRow(hours, inComponent: PickerComponents.hour.rawValue, animated: false)
            setPickerControl.selectRow(minutes, inComponent: PickerComponents.minute.rawValue, animated: false)
            setPickerControl.selectRow(seconds, inComponent: PickerComponents.second.rawValue, animated: false)
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RVS_SetTimerAmbiaMara_ViewController {
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
            view.layoutIfNeeded()
            UIView.animate(withDuration: Self._fadeAnimationPeriod,
                           animations: { [weak self] in
                                            startupLogo.alpha = 0.0
                                            self?.setPickerControl?.alpha = 1.0
                                            self?.buttonContainerStackView?.alpha = 1.0
                                            self?.view.layoutIfNeeded()
                                        },
                           completion: { [weak self] _ in
                                            DispatchQueue.main.async {
                                                startupLogo.removeFromSuperview()
                                                self?.startupLogo = nil
                                                self?.setButtonsUp()
                                            }
                                        }
            )
        }
    }
    
    /* ################################################################## */
    /**
    */
    func setButtonsUp() {
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
    */
    func numberOfComponents(in pickerView: UIPickerView) -> Int { Self._pickerViewData.count }
    
    /* ################################################################## */
    /**
    */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent inComponent: Int) -> Int { (Self._pickerViewData[inComponent].max() ?? -1) + 1 }
}

/* ###################################################################################################################################### */
// MARK: UIPickerViewDelegate Conformance
/* ###################################################################################################################################### */
extension RVS_SetTimerAmbiaMara_ViewController: UIPickerViewDelegate {
    /* ################################################################## */
    /**
    */
    func pickerView(_: UIPickerView, rowHeightForComponent: Int) -> CGFloat { 50 }
    
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
        ret.buttonFont = Self._pickerFont
        ret.gradientStartColor = UIColor(named: "\(_state.stringValue)-GradientTopColor")
        ret.gradientEndColor = UIColor(named: "\(_state.stringValue)-GradientBottomColor")
        ret.isEnabled = false
        ret.reversed = (inRow == inPickerView.selectedRow(inComponent: inComponent))
        return ret
    }
}
