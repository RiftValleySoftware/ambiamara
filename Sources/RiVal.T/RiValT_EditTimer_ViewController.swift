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
            return 24
        case .minutes, .seconds:
            return 60
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
     */
    func pickerView(_ inPickerView: UIPickerView, viewForRow inRow: Int, reusing inReusingView: UIView?) -> UIView {
        return UIView()
    }
}
