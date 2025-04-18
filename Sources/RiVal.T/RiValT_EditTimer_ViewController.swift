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
    weak var timer: Timer! = nil { didSet { self.view.setNeedsLayout() } }

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
     The settings button, at the top right.
     */
    @IBOutlet weak var settingsBarButton: UIBarButtonItem!
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
        let appearance = UIToolbarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.backgroundImage = nil
        self.toolbar?.standardAppearance = appearance
        self.toolbar?.scrollEdgeAppearance = appearance
    }
    
    /* ############################################################## */
    /**
     Called when the view is about to appear
     
     - parameter inIsAnimated: True, if the appearance is animated.
     */
    override func viewWillAppear(_ inIsAnimated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        super.viewWillAppear(inIsAnimated)
        self.setUpToolbar()
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
        self.timeSetPicker?.reloadAllComponents()
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RiValT_EditTimer_ViewController {
    /* ############################################################## */
    /**
     This sets up the bottom toolbar.
     */
    func setUpToolbar() {
        guard let timerIndexPath = timer.indexPath,
              let timerGroup = timer.group
        else { return }
        var toolbarItems = [UIBarButtonItem]()
        self.toolbar?.items = []
        if 1 < timerGroup.count {
            let prevButton = UIBarButtonItem()
            prevButton.image = UIImage(systemName: "arrowtriangle.backward.fill")
            prevButton.target = self
            prevButton.action = #selector(toolbarPrevHit)
            prevButton.isEnabled = 0 < timerIndexPath.item

            let nextButton = UIBarButtonItem()
            nextButton.image = UIImage(systemName: "arrowtriangle.right.fill")
            nextButton.target = self
            nextButton.action = #selector(toolbarNextHit)
            nextButton.isEnabled = timerIndexPath.item < (timerGroup.count - 1)
            
            toolbarItems.append(prevButton)
            toolbarItems.append(UIBarButtonItem.flexibleSpace())

            for index in 0..<timerGroup.count {
                let timerButton = UIBarButtonItem()
                timerButton.image = UIImage(systemName: "\(index + 1).square\(index == timerIndexPath.item ? ".fill" : "")")
                timerButton.isEnabled = index != timerIndexPath.item
                timerButton.target = self
                timerButton.tag = index
                timerButton.action = #selector(toolbarTimerHit)
                toolbarItems.append(timerButton)
            }
            
            toolbarItems.append(UIBarButtonItem.flexibleSpace())
            toolbarItems.append(nextButton)
            
            self.toolbar?.setItems(toolbarItems, animated: false)
            self.toolbar?.isHidden = false
        } else {
            self.toolbar?.isHidden = true
        }
    }
    
    /* ############################################################## */
    /**
     This customizes the time set type segmented control.
     */
    func setUpTimeTypeSegmentedControl() {
        guard let count = self.timeTypeSegmentedControl?.numberOfSegments,
              let startColor = UIColor(named: "Start-Color"),
              let warnColor = UIColor(named: "Warn-Color"),
              let finalColor = UIColor(named: "Final-Color")
        else { return }
        
        for index in 0..<count {
            self.timeTypeSegmentedControl?.setTitle(self.timeTypeSegmentedControl?.titleForSegment(at: index)?.localizedVariant, forSegmentAt: index)
        }
        self.timeTypeSegmentedControl?.setImage(UIImage(systemName: "clock.fill")?.withTintColor(startColor), forSegmentAt: TimeType.setTime.rawValue)
        self.timeTypeSegmentedControl?.setImage(UIImage(systemName: "exclamationmark.triangle.fill")?.withTintColor(warnColor), forSegmentAt: TimeType.warnTime.rawValue)
        self.timeTypeSegmentedControl?.setImage(UIImage(systemName: "xmark.circle.fill")?.withTintColor(finalColor), forSegmentAt: TimeType.finalTime.rawValue)
        self.updateTimeTypeSegmentedControl()
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
        
        self.timeTypeSegmentedControl?.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        switch self.currentTimeSetState {
        case .setTime:
            self.navigationItem.title = "SLUG-START-TIME".localizedVariant
            self.timeTypeSegmentedControl?.selectedSegmentTintColor = startColor
        case .warnTime:
            self.navigationItem.title = "SLUG-WARN-TIME".localizedVariant
            self.timeTypeSegmentedControl?.selectedSegmentTintColor = warnColor
        case .finalTime:
            self.navigationItem.title = "SLUG-FINAL-TIME".localizedVariant
            self.timeTypeSegmentedControl?.selectedSegmentTintColor = finalColor
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
    }

    /* ############################################################## */
    /**
     The settings button was hit.
     
     - parameter: ignored.
     */
    @IBAction func settingsBarButtonHit(_: Any) {
    }

    /* ############################################################## */
    /**
     */
    @IBAction func toolbarPrevHit(_: Any) {
        guard self.toolbar?.items?.first?.isEnabled ?? false,
              let groupIndex = self.timer?.indexPath?.section,
              let timerIndex = self.timer?.indexPath?.item
        else { return }
        self.timer = timerModel.getTimer(at: IndexPath(item: max(0, min(TimerGroup.maxTimersInGroup, timerIndex - 1)), section: groupIndex))
        self.setUpToolbar()
        self.setTime(true)
        self.timeTypeSegmentedControl?.selectedSegmentIndex = TimeType.setTime.rawValue
        self.updateTimeTypeSegmentedControl()
    }
    
    /* ############################################################## */
    /**
     */
    @IBAction func toolbarNextHit(_: Any) {
        guard self.toolbar?.items?.last?.isEnabled ?? false,
              let groupIndex = self.timer?.indexPath?.section,
              let timerIndex = self.timer?.indexPath?.item
        else { return }
        self.timer = timerModel.getTimer(at: IndexPath(item: max(0, min(TimerGroup.maxTimersInGroup, timerIndex + 1)), section: groupIndex))
        self.setUpToolbar()
        self.setTime(true)
        self.timeTypeSegmentedControl?.selectedSegmentIndex = TimeType.setTime.rawValue
        self.updateTimeTypeSegmentedControl()
    }

    /* ############################################################## */
    /**
     */
    @objc func toolbarTimerHit(_ inButton: UIBarButtonItem) {
        guard let groupIndex = self.timer?.indexPath?.section else { return }
        self.timer = timerModel.getTimer(at: IndexPath(item: inButton.tag, section: groupIndex))
        self.setUpToolbar()
        self.setTime(true)
        self.timeTypeSegmentedControl?.selectedSegmentIndex = TimeType.setTime.rawValue
        self.updateTimeTypeSegmentedControl()
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
        self.impactHaptic()
        inPickerView.reloadAllComponents()
    }
}
