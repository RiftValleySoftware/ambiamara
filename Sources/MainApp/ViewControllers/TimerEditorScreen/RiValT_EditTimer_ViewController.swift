/*
 © Copyright 2018-2026, The Great Rift Valley Software Company. All rights reserved.
 
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
 
 This has a segmented switch, which allows the user to pick which of the thresholds they want to edit. Until a Start Time has been set, the Warning Time and Final time choices are disabled.
 
 Once a Start Time is selected, the Warning Time and Final Time choices become available. They cannot be set equal to, or higher than, the Start Time. The Final Threshold can also not be higher than the Warning Threshold, unless the Warning Threshold is at 00:00:00 (off).
 
 There is also a "Play" triangle, below the time picker. This is disabled, if the Start Time is at 00:00:00, but becomes enabled, once a Start Time has been specified. Selecting this, brings in the Running Timer Screen for the current timer.
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

        /// The asset catalog color for the selected duration or phase threshold.
        fileprivate var colorName: String {
            switch self {
            case .setTime: return "Start-Color"
            case .warnTime: return "Warn-Color"
            case .finalTime: return "Final-Color"
            }
        }
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
    private static let _digitalDisplayFont = UIFont(name: "Let\'s go Digital", size: 50)
    
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

    /// Describes how the edited timer fits into its group.
    @IBOutlet weak var groupSummaryLabel: UILabel?

    /* ############################################################## */
    /**
     Container for the set time wheels.
     */
    @IBOutlet weak var setTimeContainerView: UIStackView?

    /// The storyboard stack containing Play and the associated controls.
    @IBOutlet weak var playControlsStack: UIStackView?

    /// The button that offers the shortcut for the currently selected phase.
    private let phaseShortcutButton = UIButton(type: .system)
    /// The explanatory text shown beside the phase shortcut.
    private let phaseMessageLabel = UILabel()
    /// The play-area stack containing the shortcut and its accompanying text.
    private lazy var phaseGuide = UIStackView(arrangedSubviews: [self.phaseShortcutButton, self.phaseMessageLabel])

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

    /// The start picker previews the phase that the timer will enter at its full duration.
    private var pickerColorState: TimeType {
        let timeType = self.currentTimeSetState
        guard timeType == .setTime, let timer, timer.startingTimeInSeconds > 0 else { return timeType }
        if timer.finalRangeUpperBound >= timer.startingTimeInSeconds { return .finalTime }
        if timer.warningRangeUpperBound >= timer.startingTimeInSeconds { return .warnTime }
        return .setTime
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
        self.configurePhaseGuide()
        self.setUpTimeTypeSegmentedControl()
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
        self.setUpTimeTypeSegmentedControl()
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

    /// Positions the phase guide for the current vertical size class while keeping Play centered.
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let playControlsStack, let playControlsContainer = playControlsStack.superview, let setTimeContainerView else { return }

        let compact = self.traitCollection.verticalSizeClass == .compact
        let axis: NSLayoutConstraint.Axis = compact ? .horizontal : .vertical
        guard self.phaseGuide.superview !== playControlsContainer || self.phaseGuide.axis != axis else { return }

        self.phaseGuide.removeFromSuperview()
        self.phaseGuide.axis = axis
        self.phaseGuide.alignment = compact ? .center : .fill
        self.phaseGuide.spacing = compact ? 8 : 2
        self.phaseGuide.translatesAutoresizingMaskIntoConstraints = false
        playControlsContainer.addSubview(self.phaseGuide)

        // Position the guide independently so the Play button stays centered.
        if compact {
            NSLayoutConstraint.activate([
                self.phaseGuide.centerYAnchor.constraint(equalTo: playControlsStack.centerYAnchor),
                self.phaseGuide.leadingAnchor.constraint(greaterThanOrEqualTo: playControlsContainer.leadingAnchor),
                self.phaseGuide.trailingAnchor.constraint(equalTo: playControlsStack.leadingAnchor, constant: -16),
                self.phaseGuide.topAnchor.constraint(greaterThanOrEqualTo: playControlsContainer.topAnchor),
                self.phaseGuide.bottomAnchor.constraint(lessThanOrEqualTo: playControlsContainer.bottomAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                self.phaseGuide.topAnchor.constraint(equalTo: playControlsContainer.topAnchor, constant: 8),
                self.phaseGuide.leadingAnchor.constraint(equalTo: setTimeContainerView.leadingAnchor),
                self.phaseGuide.trailingAnchor.constraint(equalTo: setTimeContainerView.trailingAnchor),
                self.phaseGuide.bottomAnchor.constraint(lessThanOrEqualTo: playControlsStack.topAnchor, constant: -8)
            ])
        }
    }

    /* ############################################################## */
    /**
     Called when the view has laid itself out.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.timeTypeSegmentedControl?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: self.isDarkMode ? UIColor.black : UIColor.label], for: .selected)
        self.timeSetPicker?.reloadAllComponents()
        self.gradientLayer?.removeFromSuperlayer()
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RiValT_EditTimer_ViewController {
    /// Configures the phase shortcut action and the appearance and accessibility of its text.
    private func configurePhaseGuide() {
        var configuration = UIButton.Configuration.plain()
        configuration.titleLineBreakMode = .byWordWrapping
        configuration.titleAlignment = .center
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var attributes = attributes
            let pointSize = attributes.font?.pointSize ?? UIFont.preferredFont(forTextStyle: .body).pointSize
            attributes.font = .boldSystemFont(ofSize: pointSize)
            return attributes
        }
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        self.phaseShortcutButton.configuration = configuration
        self.phaseShortcutButton.accessibilityIdentifier = "timerPhaseShortcut"
        self.phaseShortcutButton.addTarget(self, action: #selector(self.applyPhaseShortcut), for: .touchUpInside)
        let touchHeight = self.phaseShortcutButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        touchHeight.priority = .defaultHigh
        touchHeight.isActive = true

        self.phaseMessageLabel.font = .preferredFont(forTextStyle: .footnote)
        self.phaseMessageLabel.adjustsFontForContentSizeCategory = true
        self.phaseMessageLabel.textAlignment = .center
        self.phaseMessageLabel.textColor = .label
        self.phaseMessageLabel.numberOfLines = 0
        self.phaseMessageLabel.accessibilityIdentifier = "timerPhaseMessage"
    }

    /// Updates the shortcut and explanation for the selected time field and configured phase thresholds.
    private func updatePhaseGuide() {
        let shortcut: String?
        let message: String?
        let enabled: Bool
        let timeType = self.currentTimeSetState
        let start = self.timer?.startingTimeInSeconds ?? 0
        let warning = self.timer?.warningTimeInSeconds ?? 0
        let final = self.timer?.finalTimeInSeconds ?? 0

        switch timeType {
        case .setTime:
            enabled = 0 < warning || 0 < final
            shortcut = enabled ? "SLUG-CLEAR-WARNING-AND-FINAL-TIMES".localizedVariant : nil
            switch self.pickerColorState {
            case .setTime:
                message = nil
            case .warnTime:
                message = 0 < (self.timer?.finalRangeUpperBound ?? 0)
                    ? "SLUG-TIMER-STARTS-IN-WARNING".localizedVariant
                    : "SLUG-TIMER-ENTIRELY-IN-WARNING".localizedVariant
            case .finalTime:
                message = "SLUG-TIMER-ENTIRELY-IN-FINAL".localizedVariant
            }
        case .warnTime:
            shortcut = 1 < start ? "SLUG-START-IN-WARNING".localizedVariant : nil
            message = nil
            enabled = warning != start - 1
        case .finalTime:
            shortcut = 1 < start ? "SLUG-START-IN-FINAL".localizedVariant : nil
            message = shortcut != nil && 0 < warning ? "SLUG-START-IN-FINAL-TURNS-OFF-WARNING".localizedVariant : nil
            enabled = 0 < warning || final != start - 1
        }

        self.phaseShortcutButton.configuration?.title = shortcut
        self.phaseShortcutButton.isHidden = shortcut == nil
        self.phaseShortcutButton.isEnabled = enabled
        self.phaseShortcutButton.accessibilityHint = timeType == .finalTime ? message : nil
        self.phaseMessageLabel.text = message
        self.phaseMessageLabel.isAccessibilityElement = timeType == .setTime
        self.phaseMessageLabel.isHidden = message == nil
        self.phaseGuide.isHidden = shortcut == nil && message == nil
    }

    /// Shows this preset's position in its group and the total duration when applicable.
    private func updateGroupSummary() {
        guard let timer, let group, let index = timer.indexPath?.item else {
            self.groupSummaryLabel?.text = nil
            return
        }

        if group.count > 1, !RiValT_Settings().combineTimers {
            self.groupSummaryLabel?.text = String.localizedStringWithFormat("SLUG-GROUP-SUMMARY-SEPARATE".localizedVariant, index + 1, group.count)
        } else {
            let total = TimerCountdown(timer, combineTimers: true).totalDuration
            let duration = Duration.seconds(total).formatted(.units(allowed: [.hours, .minutes, .seconds], width: .abbreviated))
            self.groupSummaryLabel?.text = group.count == 1
                ? String.localizedStringWithFormat("SLUG-GROUP-SUMMARY-SINGLE".localizedVariant, duration)
                : String.localizedStringWithFormat("SLUG-GROUP-SUMMARY-COMBINED".localizedVariant, index + 1, group.count, duration)
        }
    }

    /* ############################################################## */
    /**
     This customizes the time set type segmented control.
     */
    func setUpTimeTypeSegmentedControl() {
        guard let startColor = UIColor(named: TimeType.setTime.colorName),
              let warnColor = UIColor(named: TimeType.warnTime.colorName),
              let finalColor = UIColor(named: TimeType.finalTime.colorName),
              let startImage = UIImage(systemName: "\(0 < (self.timer?.startingTimeInSeconds ?? 0) ? "gauge.with.needle.fill" : "timer")")?.withTintColor(startColor),
              let warnImage = UIImage(systemName: "clock.badge.exclamationmark\(0 < (self.timer?.warningTimeInSeconds ?? 0) ? ".fill" : "")")?.withTintColor(warnColor),
              let finalImage = UIImage(systemName: "exclamationmark.circle\(0 < (self.timer?.finalTimeInSeconds ?? 0) ? ".fill" : "")")?.withTintColor(finalColor)
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
        self.timeTypeSegmentedControl?.applySegmentAccessibility()
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
        guard let color = UIColor(named: self.pickerColorState.colorName) else { return }
        
        self.timeTypeSegmentedControl?.setEnabled(true, forSegmentAt: TimeType.setTime.rawValue)
        let start = self.timer?.startingTimeInSeconds ?? 0
        let warning = self.timer?.warningTimeInSeconds ?? 0
        self.timeTypeSegmentedControl?.setEnabled(1 < start, forSegmentAt: TimeType.warnTime.rawValue)
        self.timeTypeSegmentedControl?.setEnabled(1 < start, forSegmentAt: TimeType.finalTime.rawValue)
        // A one-second warning leaves room only for the shortcut, which turns Warning off first.
        self.timeSetPicker?.isUserInteractionEnabled = self.currentTimeSetState != .finalTime || warning != 1
        self.timeTypeSegmentedControl?.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        switch self.currentTimeSetState {
        case .setTime:
            self.statusLabel?.text = "SLUG-START-TIME".localizedVariant
        case .warnTime:
            self.statusLabel?.text = "SLUG-WARN-TIME".localizedVariant
        case .finalTime:
            self.statusLabel?.text = "SLUG-FINAL-TIME".localizedVariant
        }
        self.statusLabel?.textColor = color
        self.timeTypeSegmentedControl?.selectedSegmentTintColor = color
        self.hoursLabel?.textColor = color
        self.minutesLabel?.textColor = color
        self.secondsLabel?.textColor = color
        self.updatePhaseGuide()
    }
    
    /* ############################################################## */
    /**
     Sets the picker to reflect the current time.
     
     - parameter inIsAnimated: True, if the set is animated.
     */
    func setTime(_ inIsAnimated: Bool = false) {
        self.updateGroupSummary()
        let hours = Int(self.currentTimeInSeconds / TimerEngine.secondsInHour)
        let minutes = Int((self.currentTimeInSeconds - (hours * TimerEngine.secondsInHour)) / TimerEngine.secondsInMinute)
        let seconds = Int(self.currentTimeInSeconds - ((hours * TimerEngine.secondsInHour) + (minutes * TimerEngine.secondsInMinute)))

        self.timeSetPicker?.selectRow(hours, inComponent: PickerRow.hours.rawValue, animated: inIsAnimated)
        self.timeSetPicker?.selectRow(minutes, inComponent: PickerRow.minutes.rawValue, animated: inIsAnimated)
        self.timeSetPicker?.selectRow(seconds, inComponent: PickerRow.seconds.rawValue, animated: inIsAnimated)
        self.setUpPlayButton()
        self.timeSetPicker?.reloadAllComponents()
    }

    /// Updates the selected time and clamps the warning and final thresholds to valid values.
    private func updateTime(_ seconds: Int, animated: Bool) {
        self.currentTimeInSeconds = seconds
        timer.warningTimeInSeconds = max(0, min(timer.startingTimeInSeconds - 1, timer.warningTimeInSeconds))
        let finalLimit = 0 < timer.warningTimeInSeconds ? timer.warningTimeInSeconds : timer.startingTimeInSeconds
        timer.finalTimeInSeconds = max(0, min(finalLimit - 1, timer.finalTimeInSeconds))
        self.finishTimeUpdate(animated: animated)
    }

    /// Refreshes the editor controls and persists the new time values.
    private func finishTimeUpdate(animated: Bool = false) {
        self.setTime(animated)
        self.impactHaptic()
        self.updateSettings()
        self.setUpTimeTypeSegmentedControl()
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

    /// Clears the thresholds or moves the chosen threshold just below the timer's starting duration.
    @objc private func applyPhaseShortcut() {
        guard let timer else { return }
        let start = timer.startingTimeInSeconds
        switch self.currentTimeSetState {
        case .setTime:
            timer.warningTimeInSeconds = 0
            timer.finalTimeInSeconds = 0
            self.finishTimeUpdate()
        case .warnTime where 1 < start:
            self.updateTime(start - 1, animated: false)
        case .finalTime where 1 < start:
            timer.warningTimeInSeconds = 0
            self.updateTime(start - 1, animated: false)
        default:
            break
        }
    }

    /* ############################################################## */
    /**
     Called when the "play" button is hit.
     
      - parameter: The button (ignored).
     */
    @IBAction func playButtonHit(_: Any) {
        self.impactHaptic()
        self.myContainer?.performSegue(withIdentifier: RiValT_RunningTimer_ContainerViewController.segueID, sender: self.timer)
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
     - parameter inReusing: If the view is being reused, it is set here (ignored).
     */
    func pickerView(_ inPickerView: UIPickerView, viewForRow inRow: Int, forComponent inComponent: Int, reusing inReusing: UIView?) -> UIView {
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
            let colorState = self.pickerColorState
            ret.textColor = colorState == .finalTime && !self.isDarkMode ? .white : .black
            backgroundColor = UIColor(named: colorState.colorName) ?? (colorState == .finalTime ? .black : .white)
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
     
     - parameter inPickerView: The picker view (ignored)
     - parameter inComponent: The selected column (ignored)
     
     - returns: 70 (always)
     */
    func pickerView(_ inPickerView: UIPickerView, rowHeightForComponent inComponent: Int) -> CGFloat { 40 }
    
    /* ############################################################## */
    /**
     Called when a column of the picker view has been changed.
     
     - parameter inPickerView: The picker view
     - parameter inRow: The specified row.
     - parameter inComponent: The selected column.
     */
    func pickerView(_ inPickerView: UIPickerView, didSelectRow inRow: Int, inComponent: Int) {
        inPickerView.reloadComponent(inComponent)
        self.updateTime(self.currentPickerTimeInSeconds, animated: true)
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
     - parameter inComponentIndex: The 0-based component index for the label.
     - returns: An accessibility string for the component.
    */
    func pickerView(_ inPickerView: UIPickerView, accessibilityLabelForComponent inComponentIndex: Int) -> String? {
        "SLUG-ACC-TIME-PICKER-COMPONENT-\(inComponentIndex)-LABEL".localizedVariant
    }
    
    /* ################################################################## */
    /**
     This returns the accessibility hint for the picker component.
     
     - parameter inPickerView: The picker instance
     - parameter inComponentIndex: The 0-based component index for the Hint (ignored).
     - returns: An accessibility string for the component.
    */
    func pickerView(_ inPickerView: UIPickerView, accessibilityHintForComponent inComponentIndex: Int) -> String? {
        "SLUG-ACC-TIME-PICKER-COMPONENT-\(inComponentIndex)-HINT".localizedVariant
    }
}
