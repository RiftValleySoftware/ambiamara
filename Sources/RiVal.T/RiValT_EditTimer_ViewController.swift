/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_Generic_Swift_Toolbox
import RVS_UIKit_Toolbox

/* ###################################################################################################################################### */
// MARK: - The Main View Controller for the Timer Edit -
/* ###################################################################################################################################### */
/**
 */
class RiValT_EditTimer_ViewController: RiValT_Base_ViewController {
    /* ################################################################################################################################## */
    // MARK: The Various Set Time States
    /* ################################################################################################################################## */
    /**
     These correspond to the selection in the segmented switch.
     */
    enum TimeType: Int {
        /* ########################################################## */
        /**
         This means that we are setting the start time.
         */
        case setTime

        /* ########################################################## */
        /**
         This means that we are setting the warning time threshold.
         */
        case warnTime

        /* ########################################################## */
        /**
         This means that we are setting the final time threshold.
         */
        case finalTime
    }
    
    /* ################################################################################################################################## */
    // MARK: The Various Columns in the Picker
    /* ################################################################################################################################## */
    /**
     These are the indexes for the picker columns.
     */
    enum PickerRow: Int, CaseIterable {
        /* ########################################################## */
        /**
         Set the hours.
         */
        case hours

        /* ########################################################## */
        /**
         Set the minutes.
         */
        case minutes

        /* ########################################################## */
        /**
         Set the seconds.
         */
        case seconds
    }
    
    /* ############################################################## */
    /**
     The large variant of the digital display font.
     */
    private static let _digitalDisplayFont = UIFont(name: "Let\'s go Digital", size: 90)

    /* ############################################################## */
    /**
     The timer instance associated with this screen.
     
     It is implicit optional, because we're in trouble, if it's nil.
     */
    weak var timer: Timer! = nil

    /* ############################################################## */
    /**
     Container for the set time wheels.
     */
    @IBOutlet weak var setTimeContainerView: UIView?

    /* ############################################################## */
    /**
     This selects between set time, warn time, and final time.
     */
    @IBOutlet weak var timeTypeSegmentedControl: UISegmentedControl?

    /* ############################################################## */
    /**
     The time set picker view.
     */
    @IBOutlet weak var timeSetPicker: UIPickerView?

    /* ############################################################## */
    /**
     The Hours label, above the picker.
     */
    @IBOutlet weak var hoursLabel: UILabel?

    /* ############################################################## */
    /**
     The Minutes label, above the picker.
     */
    @IBOutlet weak var minutesLabel: UILabel?

    /* ############################################################## */
    /**
     The Seconds label, above the picker.
     */
    @IBOutlet weak var secondsLabel: UILabel?
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension RiValT_EditTimer_ViewController {
    /* ############################################################## */
    /**
     This is the current time that we are setting.
     */
    var currentTimeSetState: TimeType {
        guard let timeType = self.timeTypeSegmentedControl?.selectedSegmentIndex,
              let ret = TimeType(rawValue: timeType)
        else { return .setTime }
        
        return ret
    }
    
    /* ############################################################## */
    /**
     The time (in seconds) currently represented by the picker.
     */
    var currentPickerTimeInSeconds: Int {
        let hours = self.timeSetPicker?.selectedRow(inComponent: PickerRow.hours.rawValue) ?? 0
        let minutes = self.timeSetPicker?.selectedRow(inComponent: PickerRow.minutes.rawValue) ?? 0
        let seconds = self.timeSetPicker?.selectedRow(inComponent: PickerRow.seconds.rawValue) ?? 0
        
        return (hours * TimerEngine.secondsInHour) + (minutes * TimerEngine.secondsInMinute) + seconds
    }
    
    /* ############################################################## */
    /**
     This is the current time that we are setting.
     */
    var currentTimeInSeconds: Int {
        get {
            switch self.currentTimeSetState {
            case .setTime:
                return timer.startingTimeInSeconds
                
            case .warnTime:
                return timer.warningTimeInSeconds
                
            case .finalTime:
                return timer.finalTimeInSeconds
            }
        }
        set {
            switch self.currentTimeSetState {
            case .setTime:
                timer.startingTimeInSeconds = newValue
                
            case .warnTime:
                timer.warningTimeInSeconds = newValue
                
            case .finalTime:
                timer.finalTimeInSeconds = newValue
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RiValT_EditTimer_ViewController {
    /* ############################################################## */
    /**
     Called when the view has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpTimeTypeSegmentedControl()
        self.hoursLabel?.text = self.hoursLabel?.text?.localizedVariant
        self.minutesLabel?.text = self.minutesLabel?.text?.localizedVariant
        self.secondsLabel?.text = self.secondsLabel?.text?.localizedVariant
    }
    
    /* ############################################################## */
    /**
     Called when the view is about to appear
     
     - parameter inIsAnimated: True, if the appearance is animated.
     */
    override func viewWillAppear(_ inIsAnimated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        super.viewWillAppear(inIsAnimated)
    }
    
    /* ############################################################## */
    /**
     Called when the view has laid itself out.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setTime()
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RiValT_EditTimer_ViewController {
    /* ############################################################## */
    /**
     This customizes the time set type segmented control.
     */
    func setUpTimeTypeSegmentedControl() {
        guard let count = self.timeTypeSegmentedControl?.numberOfSegments else { return }
        
        for index in 0..<count {
            self.timeTypeSegmentedControl?.setTitle(self.timeTypeSegmentedControl?.titleForSegment(at: index)?.localizedVariant, forSegmentAt: index)
        }
    }
    
    /* ############################################################## */
    /**
     Sets the picker to reflect the current time.
     */
    func setTime() {
        let hours = Int(self.currentTimeInSeconds / TimerEngine.secondsInHour)
        let minutes = Int((self.currentTimeInSeconds - (hours * TimerEngine.secondsInHour)) / TimerEngine.secondsInMinute)
        let seconds = Int(self.currentTimeInSeconds - ((hours * TimerEngine.secondsInHour) + (minutes * TimerEngine.secondsInMinute)))
        
        self.timeSetPicker?.selectRow(hours, inComponent: PickerRow.hours.rawValue, animated: true)
        self.timeSetPicker?.selectRow(minutes, inComponent: PickerRow.minutes.rawValue, animated: true)
        self.timeSetPicker?.selectRow(seconds, inComponent: PickerRow.seconds.rawValue, animated: true)
        
        self.timeSetPicker?.reloadAllComponents()
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension RiValT_EditTimer_ViewController {
    /* ############################################################## */
    /**
     Called when the time type segmented control is changed.
     
     - parameter inSegmentedControl: The control that was changed
     */
    @IBAction func timeTypeSegmentedControlChanged(_ inSegmentedControl: UISegmentedControl) {
        self.setTime()
    }
}

/* ###################################################################################################################################### */
// MARK: UIPickerViewDataSource Conformance
/* ###################################################################################################################################### */
extension RiValT_EditTimer_ViewController: UIPickerViewDataSource {
    /* ############################################################## */
    /**
     This always returns the number of columns.
     
     - parameter: The picker view (ignored).
     */
    func numberOfComponents(in: UIPickerView) -> Int { PickerRow.allCases.count }
    
    /* ############################################################## */
    /**
     Returns the number of rows for the designated column.
     */
    func pickerView(_ inPickerView: UIPickerView, numberOfRowsInComponent inComponent: Int) -> Int {
        guard let selectedColumn = PickerRow(rawValue: inComponent) else { return 0 }
        
        switch selectedColumn {
        case .hours:
            return TimerEngine.maxHours
        case .minutes:
            return TimerEngine.maxMinutes
        case .seconds:
            return TimerEngine.maxSeconds
        }
    }
}

/* ###################################################################################################################################### */
// MARK: UIPickerViewDelegate Conformance
/* ###################################################################################################################################### */
extension RiValT_EditTimer_ViewController: UIPickerViewDelegate {
    /* ############################################################## */
    /**
     Returns the displayed row for the selected column and row.
     
     - parameter inPickerView: The picker view
     - parameter inRow: The specified row.
     - parameter inComponent: The selected column.
     - parameter: If the view is being reused, it is set here (ignored).
     */
    func pickerView(_ inPickerView: UIPickerView, viewForRow inRow: Int, forComponent inComponent: Int, reusing: UIView?) -> UIView {
        guard let selectedColumn = PickerRow(rawValue: inComponent) else { return UILabel() }
        
        let selectedRow = inPickerView.selectedRow(inComponent: selectedColumn.rawValue)
        let hours = inPickerView.selectedRow(inComponent: PickerRow.hours.rawValue)
        let minutes = inPickerView.selectedRow(inComponent: PickerRow.minutes.rawValue)

        let ret = UILabel()
        ret.font = Self._digitalDisplayFont
        ret.textAlignment = .center

        var stringFormat = "%d"
        var backgroundColor: UIColor? = .clear
        
        switch selectedColumn {
        case .hours:
            break
            
        case .minutes:
            if 0 < hours,
               inRow == selectedRow {
                stringFormat = "%02d"
            }
            
        case .seconds:
            if 0 < hours || 0 < minutes,
               inRow == selectedRow {
                stringFormat = "%02d"
            }
        }
        
        if inRow == selectedRow {
            ret.textAlignment = .center
            ret.cornerRadius = 12
            switch currentTimeSetState {
            case .setTime:
                ret.textColor = .black
                backgroundColor = UIColor(named: "Start-Color") ?? .label
                
            case .warnTime:
                ret.textColor = .black
                backgroundColor = UIColor(named: "Warn-Color") ?? .label
                
            case .finalTime:
                ret.textColor = .white
                backgroundColor = UIColor(named: "Final-Color") ?? .label
            }
        }
        
        ret.backgroundColor = backgroundColor
        ret.text = String(format: stringFormat, inRow)
        
        return ret
    }
    
    /* ############################################################## */
    /**
     The height of each row.
     
     - parameter: The picker view (ignored)
     - parameter rowHeightForComponent: The selected column (ignored)
     
     - returns: 80 (always)
     */
    func pickerView(_: UIPickerView, rowHeightForComponent: Int) -> CGFloat { 80 }
    
    /* ############################################################## */
    /**
     Called when a column of the picker view has been changed.
     
     - parameter inPickerView: The picker view
     - parameter inRow: The specified row.
     - parameter inComponent: The selected column.
     */
    func pickerView(_ inPickerView: UIPickerView, didSelectRow inRow: Int, inComponent: Int) {
        inPickerView.reloadComponent(inComponent)
        switch currentTimeSetState {
        case .setTime:
            timer.startingTimeInSeconds = currentPickerTimeInSeconds
            timer.warningTimeInSeconds = max(0, min(timer.startingTimeInSeconds - 1, timer.warningTimeInSeconds))
            timer.finalTimeInSeconds = max(0, min(timer.warningTimeInSeconds - 1, timer.finalTimeInSeconds))
        case .warnTime:
            timer.warningTimeInSeconds = currentPickerTimeInSeconds
            timer.finalTimeInSeconds = max(0, min(timer.warningTimeInSeconds - 1, timer.finalTimeInSeconds))
        case .finalTime:
            timer.finalTimeInSeconds = currentPickerTimeInSeconds
        }
    }
}
