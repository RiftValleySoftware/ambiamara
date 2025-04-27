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
 This view controller allows us to set the timer thresholds for each individual timer.
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
    private static let _digitalDisplayFont = UIFont(name: "Let\'s go Digital", size: 80)
    
    /* ############################################################## */
    /**
     The ID for segue to the settings editor.
     */
    private static let _editGroupSegueID = "edit-group"

    /* ############################################################## */
    /**
     The storyboard ID for instantiating the class.
     */
    static let storyboardID = "RiValT_EditTimer_ViewController"
    
    /* ############################################################## */
    /**
     The timer instance associated with this screen.
     
     It is implicit optional, because we're in trouble, if it's nil.
     */
    weak var timer: Timer! = nil { didSet { self.view.setNeedsLayout() } }
    
    /* ############################################################## */
    /**
     This is the page view container that "owns" this screen.
     */
    weak var myContainer: RiValT_TimerEditor_PageViewContainer?

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
    
    /* ############################################################## */
    /**
     The toolbar at the bottom.
     */
    @IBOutlet weak var toolbar: UIToolbar?

    /* ############################################################## */
    /**
     The label above the time set, indicating the selected time.
     */
    @IBOutlet weak var statusLabel: UILabel?
    
    /* ############################################################## */
    /**
     The "play" triangle, under the pickers.
     */
    @IBOutlet weak var playButton: UIButton?
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
    
    /* ############################################################## */
    /**
     The group for the current timer.
     */
    var group: TimerGroup? { self.timer?.group }
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
        let appearance = UIToolbarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.backgroundImage = nil
        self.toolbar?.standardAppearance = appearance
        self.toolbar?.scrollEdgeAppearance = appearance
        self.backgroundGradientImageView?.removeFromSuperview()
        self.view?.backgroundColor = .clear
    }
    
    /* ############################################################## */
    /**
     Called when the view is about to appear
     
     - parameter inIsAnimated: True, if the appearance is animated.
     */
    override func viewWillAppear(_ inIsAnimated: Bool) {
        super.viewWillAppear(inIsAnimated)
        self.timeTypeSegmentedControl?.selectedSegmentIndex = 0
        self.setTime()
    }
    
    /* ############################################################## */
    /**
     Called when the view has appeared
     
     - parameter inIsAnimated: True, if the appearance is animated.
     */
    override func viewDidAppear(_ inIsAnimated: Bool) {
        super.viewDidAppear(inIsAnimated)
        self.timeSetPicker?.reloadAllComponents()
    }

    /* ############################################################## */
    /**
     Called when the view has laid itself out.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.timeTypeSegmentedControl?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: self.isDarkMode ? UIColor.black : UIColor.label], for: .selected)
        self.timeSetPicker?.reloadAllComponents()
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
        guard let startColor = UIColor(named: "Start-Color"),
              let warnColor = UIColor(named: "Warn-Color"),
              let finalColor = UIColor(named: "Final-Color"),
              let startImage = UIImage(systemName: "clock\(0 < (self.timer?.startingTimeInSeconds ?? 0) ? ".fill" : "")")?.withTintColor(startColor),
              let warnImage = UIImage(systemName: "exclamationmark.triangle\(0 < (self.timer?.warningTimeInSeconds ?? 0) ? ".fill" : "")")?.withTintColor(warnColor),
              let finalImage = UIImage(systemName: "xmark.circle\(0 < (self.timer?.finalTimeInSeconds ?? 0) ? ".fill" : "")")?.withTintColor(finalColor)
        else { return }

        startImage.isAccessibilityElement = true
        startImage.accessibilityLabel = "SLUG-ACC-START-SEGMENT-LABEL".localizedVariant
        startImage.accessibilityHint = "SLUG-ACC-START-SEGMENT-HINT".localizedVariant
        warnImage.isAccessibilityElement = true
        warnImage.accessibilityLabel = "SLUG-ACC-WARN-SEGMENT-LABEL".localizedVariant
        warnImage.accessibilityHint = "SLUG-ACC-WARN-SEGMENT-HINT".localizedVariant
        finalImage.isAccessibilityElement = true
        finalImage.accessibilityLabel = "SLUG-ACC-FINAL-SEGMENT-LABEL".localizedVariant
        finalImage.accessibilityHint = "SLUG-ACC-FINAL-SEGMENT-HINT".localizedVariant
        
        self.timeTypeSegmentedControl?.setImage(startImage, forSegmentAt: TimeType.setTime.rawValue)
        self.timeTypeSegmentedControl?.setImage(warnImage, forSegmentAt: TimeType.warnTime.rawValue)
        self.timeTypeSegmentedControl?.setImage(finalImage, forSegmentAt: TimeType.finalTime.rawValue)
        self.updateTimeTypeSegmentedControl()
    }
    
    /* ############################################################## */
    /**
     This enables or disables the play button.
     */
    func setUpPlayButton() {
        if 0 < (self.timer?.startingTimeInSeconds ?? 0) {
            self.playButton?.isEnabled = true
            self.playButton?.tintColor = self.view?.tintColor
        } else {
            self.playButton?.isEnabled = false
            self.playButton?.tintColor = UIColor.systemGray.withAlphaComponent(0.5)
        }
    }
    
    /* ############################################################## */
    /**
     This customizes the time set type segmented control.
     */
    func updateTimeTypeSegmentedControl() {
        guard let startColor = UIColor(named: "Start-Color"),
              let warnColor = UIColor(named: "Warn-Color"),
              let finalColor = UIColor(named: "Final-Color")
        else { return }
        
        self.timeTypeSegmentedControl?.setEnabled(true, forSegmentAt: TimeType.setTime.rawValue)
        self.timeTypeSegmentedControl?.setEnabled(1 < self.timer?.startingTimeInSeconds ?? 0,
                                                  forSegmentAt: TimeType.warnTime.rawValue)
        self.timeTypeSegmentedControl?.setEnabled((1 < self.timer?.startingTimeInSeconds ?? 0) && (1 != self.timer?.warningTimeInSeconds ?? 0),
                                                  forSegmentAt: TimeType.finalTime.rawValue)
        self.timeTypeSegmentedControl?.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        switch self.currentTimeSetState {
        case .setTime:
            self.statusLabel?.text = "SLUG-START-TIME".localizedVariant
            self.statusLabel?.textColor = startColor
            self.timeTypeSegmentedControl?.selectedSegmentTintColor = startColor
            self.hoursLabel?.textColor = startColor
            self.minutesLabel?.textColor = startColor
            self.secondsLabel?.textColor = startColor
        case .warnTime:
            self.statusLabel?.text = "SLUG-WARN-TIME".localizedVariant
            self.statusLabel?.textColor = warnColor
            self.timeTypeSegmentedControl?.selectedSegmentTintColor = warnColor
            self.hoursLabel?.textColor = warnColor
            self.minutesLabel?.textColor = warnColor
            self.secondsLabel?.textColor = warnColor
        case .finalTime:
            self.statusLabel?.text = "SLUG-FINAL-TIME".localizedVariant
            self.statusLabel?.textColor = finalColor
            self.timeTypeSegmentedControl?.selectedSegmentTintColor = finalColor
            self.hoursLabel?.textColor = finalColor
            self.minutesLabel?.textColor = finalColor
            self.secondsLabel?.textColor = finalColor
        }
    }
    
    /* ############################################################## */
    /**
     Sets the picker to reflect the current time.
     
     - parameter inIsAnimated: True, if the set is animated.
     */
    func setTime(_ inIsAnimated: Bool = false) {
        let hours = Int(self.currentTimeInSeconds / TimerEngine.secondsInHour)
        let minutes = Int((self.currentTimeInSeconds - (hours * TimerEngine.secondsInHour)) / TimerEngine.secondsInMinute)
        let seconds = Int(self.currentTimeInSeconds - ((hours * TimerEngine.secondsInHour) + (minutes * TimerEngine.secondsInMinute)))

        self.timeSetPicker?.selectRow(hours, inComponent: PickerRow.hours.rawValue, animated: inIsAnimated)
        self.timeSetPicker?.selectRow(minutes, inComponent: PickerRow.minutes.rawValue, animated: inIsAnimated)
        self.timeSetPicker?.selectRow(seconds, inComponent: PickerRow.seconds.rawValue, animated: inIsAnimated)
        self.setUpPlayButton()
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
        self.setTime(true)
        self.selectionHaptic()
        self.updateTimeTypeSegmentedControl()
        self.updateSettings()
    }

    /* ############################################################## */
    /**
     Called when the "play" button is hit.
     
      - parameter: The button (ignored).
     */
    @IBAction func playButtonHit(_: Any) {
        self.impactHaptic()
        self.myContainer?.performSegue(withIdentifier: RiValT_RunningTimer_ViewController.segueID, sender: self.timer)
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
        let hours = Int(self.currentTimeInSeconds / TimerEngine.secondsInHour)
        let minutes = Int((self.currentTimeInSeconds - (hours * TimerEngine.secondsInHour)) / TimerEngine.secondsInMinute)

        let ret = UILabel()
        ret.font = Self._digitalDisplayFont
        ret.textAlignment = .center

        var stringFormat = "%d"
        var backgroundColor: UIColor? = .clear
        
        switch selectedColumn {
        case .hours:
            if 0 == hours,
               0 == inRow,
               inRow == selectedRow {
                stringFormat = ""
            }
            
        case .minutes:
            if 0 == hours,
               0 == minutes,
               0 == inRow,
               inRow == selectedRow {
                stringFormat = ""
            } else if 0 < hours,
                      inRow == selectedRow {
                stringFormat = "%02d"
            }

        case .seconds:
            if 0 == hours,
               0 == minutes,
               0 == inRow,
               inRow == selectedRow {
                stringFormat = ""
            } else if 0 < hours || 0 < minutes,
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
                backgroundColor = UIColor(named: "Start-Color") ?? .white
                
            case .warnTime:
                ret.textColor = .black
                backgroundColor = UIColor(named: "Warn-Color") ?? .white
                
            case .finalTime:
                ret.textColor = self.isDarkMode ? .black : .white
                backgroundColor = UIColor(named: "Final-Color") ?? .black
            }
        }
        
        ret.backgroundColor = backgroundColor
        if !stringFormat.isEmpty {
            ret.text = String(format: stringFormat, inRow)
        } else {
            ret.text = ""
        }
        
        return ret
    }
    
    /* ############################################################## */
    /**
     The height of each row.
     
     - parameter: The picker view (ignored)
     - parameter rowHeightForComponent: The selected column (ignored)
     
     - returns: 70 (always)
     */
    func pickerView(_: UIPickerView, rowHeightForComponent: Int) -> CGFloat { 60 }
    
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
            timer.warningTimeInSeconds = max(0, min(timer.startingTimeInSeconds - 1, currentPickerTimeInSeconds))
            timer.finalTimeInSeconds = max(0, min(timer.warningTimeInSeconds - 1, timer.finalTimeInSeconds))
        case .finalTime:
            if 0 < timer.warningTimeInSeconds { // You can have just starting time and final time.
                timer.finalTimeInSeconds = max(0, min(timer.warningTimeInSeconds - 1, currentPickerTimeInSeconds))
            } else {
                timer.finalTimeInSeconds = max(0, min(timer.startingTimeInSeconds - 1, currentPickerTimeInSeconds))
            }
        }
        self.setTime(true)
        self.impactHaptic()
        self.updateSettings()
        self.setUpTimeTypeSegmentedControl()
        inPickerView.reloadAllComponents()
    }
}

/* ###################################################################################################################################### */
// MARK: UIPickerViewAccessibilityDelegate Conformance
/* ###################################################################################################################################### */
extension RiValT_EditTimer_ViewController: UIPickerViewAccessibilityDelegate {
    /* ################################################################## */
    /**
     This returns the accessibility hint for the picker component.
     
     - parameter inPickerView: The picker instance
     - parameter accessibilityLabelForComponent: The 0-based component index for the label.
     - returns: An accessibility string for the component.
    */
    func pickerView(_ inPickerView: UIPickerView, accessibilityLabelForComponent inComponentIndex: Int) -> String? {
        "SLUG-ACC-TIME-PICKER-COMPONENT-\(inComponentIndex)-LABEL".localizedVariant
    }
    
    /* ################################################################## */
    /**
     This returns the accessibility hint for the picker component.
     
     - parameterinPickerView: The picker instance
     - parameter accessibilityHintForComponent: The 0-based component index for the Hint (ignored).
     - returns: An accessibility string for the component.
    */
    func pickerView(_ inPickerView: UIPickerView, accessibilityHintForComponent inComponentIndex: Int) -> String? {
        "SLUG-ACC-TIME-PICKER-COMPONENT-\(inComponentIndex)-HINT".localizedVariant
    }
}
