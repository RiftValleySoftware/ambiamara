/**
 © Copyright 2018, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

/* ###################################################################################################################################### */
/**
 */

import UIKit

/* ###################################################################################################################################### */
/**
 */
class TimerSetController: A_TimerSetPickerController {
    /// Segue ID  to go to settings
    static let switchToSettingsSegueID = "timer-segue-to-settings"
    /// Segue ID to start the timer
    static let startTimerSegueID = "timer-segue-to-start-timer"
    /// Segue ID for immediate timer start (no animation).
    static let startTimerNowSegueID = "timer-segue-to-start-timer-now"
    
    /// The buton to go into settings
    @IBOutlet weak var setupButton: UIBarButtonItem!
    /// The picker view to set the timer time
    @IBOutlet weak var setTimePickerView: UIPickerView!
    /// The button that exposes the "next timer" picker
    @IBOutlet weak var nextTimerButton: UIButton!
    /// The big start button below the picker
    @IBOutlet weak var bigStartButton: UIButton!
    /// The label that displays the current set time
    @IBOutlet weak var timeDisplayLabel: UILabel!
    /// The container for the next timer selection picker
    @IBOutlet weak var nextTimerSelectionContainer: UIView!
    /// The picker view for the next timer selection
    @IBOutlet weak var nextTimerPickerView: UIPickerView!
    /// The little "traffic lights" image in the label, if we are in Poudium or Dual mode
    @IBOutlet weak var trafficLightsImageView: UIImageView!
    
    /// The actual running timer controller
    var runningTimer: TimerRuntimeViewController! = nil
    
    /* ################################################################################################################################## */
    // MARK: - Private Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Sets up the display to its current state
     */
    private func _setUpDisplay() {
        bigStartButton.isHidden = 0 >= timerObject.timeSet
        
        let timerNumber = self.timerNumber
        let tabBarImage = self.tabBarImage
        
        if nil != navigationController as? TimerNavController {
            if (tabBarController?.viewControllers?.count)! > timerNumber + 1 {
                tabBarController?.viewControllers?[timerNumber + 1].tabBarItem.image = tabBarImage
                tabBarController?.viewControllers?[timerNumber + 1].tabBarItem.selectedImage = tabBarImage
            }
        }
        
        if 1 < Timer_AppDelegate.appDelegateObject.timerEngine.timers.count {
            nextTimerButton.isHidden = false
            let nextID = timerObject.succeedingTimerID
            
            if 0 <= nextID {
                nextTimerButton.setTitle(String(format: "NEXT-TIMER-TIMER-FORMAT".localizedVariant, nextID + 1), for: .normal)
                nextTimerPickerView.selectRow(nextID + 1, inComponent: 0, animated: false)
            } else {
                nextTimerButton.setTitle("NO-TIMER".localizedVariant, for: .normal)
                nextTimerPickerView.selectRow(0, inComponent: 0, animated: false)
            }
            nextTimerButton.titleLabel?.text = nextTimerButton.title(for: .normal)
        } else {
            nextTimerButton.isHidden = true
        }

        nextTimerPickerView.reloadComponent(0)
        updateTimeDisplayLabel()
        
        var nextTimer: String = ""
        let row = timerObject.succeedingTimerID + 1
        if 0 == row {
            nextTimer = "NO-TIMER".localizedVariant
        } else {
            if row - 1 == Timer_AppDelegate.appDelegateObject.timerEngine.selectedTimerIndex {
                nextTimer = "CANT-SELECT".localizedVariant
            } else {
                nextTimer = String(format: "LGV_TIMER-TIMER-TITLE-FORMAT".localizedVariant, row)
            }
        }
        
        nextTimerButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-NEXT-TIMER-PICKER-LABEL".localizedVariant + " " + nextTimer
    }

    /* ################################################################################################################################## */
    // MARK: - Internal @IBAction Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Bring in the setup screen button hit.
     */
    @IBAction func setupButtonHit(_ sender: Any) {
        bringInSettingsScreen()
    }
    
    /* ################################################################## */
    /**
     Called when the start button is hit
     
     - parameter sender: ignored
     */
    @IBAction func startButtonHit(_ sender: Any) {
        Timer_AppDelegate.appDelegateObject.timerEngine.startTimer()
    }
    
    /* ################################################################## */
    /**
     Called when the "next timer setup" button is hit.
     
     - parameter sender: ignored
     */
    @IBAction func nextTimerButtonHit(_ sender: UIButton) {
        nextTimerSelectionContainer.isHidden = false
        setTimePickerView.isHidden = true
        
        updateTimer()
        nextTimerButton.addTarget(self, action: #selector(Self.setSelectedNextTimer(_:)), for: .touchUpInside)
        nextTimerPickerView.isAccessibilityElement = true
        UIAccessibility.post(notification: .layoutChanged, argument: nextTimerPickerView)
    }
    
    /* ################################################################## */
    /**
     Called to select the next timer
     
     - parameter: ignored (optional, so it can be called without parameters)
     */
    @IBAction func setSelectedNextTimer(_ : Any! = nil) {
        nextTimerSelectionContainer.isHidden = true
        setTimePickerView.isHidden = false
        
        nextTimerPickerView.isAccessibilityElement = false
        UIAccessibility.post(notification: .layoutChanged, argument: timeDisplayLabel)
        nextTimerButton.addTarget(self, action: #selector(Self.nextTimerButtonHit(_:)), for: .touchUpInside)
    }
    
    /* ################################################################################################################################## */
    // MARK: - Internal Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Bring in the setup screen.
     */
    func bringInSettingsScreen() {
        performSegue(withIdentifier: Self.switchToSettingsSegueID, sender: nil)
    }
    
    /* ################################################################## */
    /**
     Update the time set label.
     */
    func updateTimeDisplayLabel() {
        timeDisplayLabel.text = TimeInstance(timerObject.timeSet).description
        if let backgroundColor = Timer_AppDelegate.appDelegateObject.timerEngine.colorLabelArray[timerObject.colorTheme].backgroundColor {
            timeDisplayLabel.textColor = (.Podium == timerObject.displayMode ? UIColor.white : backgroundColor)
        }
        
        if .Podium == timerObject.displayMode {
            timeDisplayLabel.font = UIFont.boldSystemFont(ofSize: 42)
        } else {
            if let titleFont = UIFont(name: "Let's Go Digital", size: 50) {
                timeDisplayLabel.font = titleFont
            }
        }

        let title = navigationItem.title ?? ""
        
        switch timerObject.displayMode {
        case .Podium:
            timeDisplayLabel.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-PODIUM-LABEL".localizedVariant + " (" + timerObject.setSpeakableTime + ")"
            timeDisplayLabel.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-PODIUM-HINT".localizedVariant
            trafficLightsImageView.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-PODIUM-LABEL".localizedVariant + " (" + timerObject.setSpeakableTime + ")"
            trafficLightsImageView.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-PODIUM-HINT".localizedVariant
            titleLabel.accessibilityLabel = title + " " + "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-PODIUM-LABEL".localizedVariant + " (" + timerObject.setSpeakableTime + ")"
        case .Digital:
            timeDisplayLabel.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-DIGITAL-LABEL".localizedVariant + " (" + timerObject.setSpeakableTime + ")"
            timeDisplayLabel.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-DIGITAL-HINT".localizedVariant
            trafficLightsImageView.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-DIGITAL-LABEL".localizedVariant + " (" + timerObject.setSpeakableTime + ")"
            trafficLightsImageView.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-DIGITAL-HINT".localizedVariant
            titleLabel.accessibilityLabel = title + " " + "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-DIGITAL-LABEL".localizedVariant + " (" + timerObject.setSpeakableTime + ")"
        case .Dual:
            timeDisplayLabel.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-DUAL-LABEL".localizedVariant + " (" + timerObject.setSpeakableTime + ")"
            timeDisplayLabel.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-DUAL-HINT".localizedVariant
            trafficLightsImageView.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-DUAL-LABEL".localizedVariant + " (" + timerObject.setSpeakableTime + ")"
            trafficLightsImageView.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-DUAL-HINT".localizedVariant
            titleLabel.accessibilityLabel = title + " " + "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-DUAL-LABEL".localizedVariant + " (" + timerObject.setSpeakableTime + ")"
        }

        timeDisplayLabel.setNeedsDisplay()
    }
    /* ################################################################## */
    /**
     Start the Timer.
     */
    func startTimer() {
        performSegue(withIdentifier: Self.startTimerSegueID, sender: nil)
    }
    
    /* ################################################################## */
    /**
     Update the timer to the current state
     */
    func updateTimer() {
        let timeSet = TimeInstance(timerObject.timeSet)
        
        if nil != setTimePickerView {
            setTimePickerView.selectRow(timeSet.hours, inComponent: Components.Hours.rawValue, animated: true)
            setTimePickerView.selectRow(timeSet.minutes, inComponent: Components.Minutes.rawValue, animated: true)
            setTimePickerView.selectRow(timeSet.seconds, inComponent: Components.Seconds.rawValue, animated: true)
        }
        
        _setUpDisplay()
        
        if nil != runningTimer {
            if .Stopped == timerObject.timerStatus {
                navigationController?.dismiss(animated: true, completion: nil)
            } else {
                runningTimer.updateTimer()
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called to "tick" the timer
     */
    func tick(times inTimes: Int = 1) {
        runningTimer?.tick(times: inTimes)
    }
    
    /* ################################################################## */
    /**
     Establishes the entire screen.
     */
    func setUpEntireScreen() {
        if nil != timerObject {
            Timer_AppDelegate.appDelegateObject.sendSelectMessage(timerUID: timerObject.uid)
        }
        
        updateTimer()
        nextTimerSelectionContainer.isHidden = true
        setTimePickerView.isHidden = false
        nextTimerButton.addTarget(self, action: #selector(Self.nextTimerButtonHit(_:)), for: .touchUpInside)
        trafficLightsImageView.isHidden = .Digital == timerObject.displayMode
        titleLabel.text = navigationItem.title ?? ""
        setTimePickerView.reloadAllComponents()
    }

    /* ################################################################################################################################## */
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view has finished loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem?.title = navigationItem.backBarButtonItem?.title?.localizedVariant

        if let tabber = tabBarController as? Timer_MainTabController {
            tabber.addTimerToList(self)
        }
        
        setTimePickerView.setValue(view.tintColor, forKey: "textColor")
    }
    
    /* ################################################################## */
    /**
     Called when the view will display.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpEntireScreen()
    }
        
    /* ################################################################## */
    /**
     Called when the view has displayed.
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Special kludge for cascading timer. We check the navigation controller semaphore (yuck), and select and start the next timer.
        if let navigationController = navigationController as? TimerNavController, let mainTabController = tabBarController as? Timer_MainTabController {
            let nextTimer = navigationController.selectNextTimer
            navigationController.selectNextTimer = -1
            if 0 <= nextTimer {
                mainTabController.selectTimer(nextTimer, andStartTimer: true)
            }
        }
    }

    /* ################################################################## */
    /**
     Called when the view will go away.
     */
    override func viewWillDisappear(_ animated: Bool) {
        if let navBar = navigationController?.navigationBar {
            navBar.titleTextAttributes?[NSAttributedString.Key.foregroundColor] = UIColor.white
        }
    }
    
    /* ################################################################## */
    /**
     Called when the view has finished displaying.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTimer()
    }
    
    /* ################################################################## */
    /**
     Called when we are about to bring in the setup controller.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationController = segue.destination as? TimerRuntimeViewController {
            destinationController.myHandler = self
            runningTimer = destinationController
        }
        
        if let destinationController = segue.destination as? A_TimerNavBaseController {
            destinationController.timerObject = timerObject
        }
    }

    /* ################################################################################################################################## */
    /**
     This method adds all the accessibility stuff.
     */
    override func addAccessibilityStuff() {
        super.addAccessibilityStuff()
        
        setupButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-SETTINGS-BUTTON-LABEL".localizedVariant
        setupButton.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-SETTINGS-BUTTON-HINT".localizedVariant
        
        nextTimerPickerView.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-NEXT-TIMER-PICKER-LABEL".localizedVariant
        nextTimerPickerView.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-NEXT-TIMER-PICKER-HINT".localizedVariant
        
        bigStartButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-TIMER-START-BUTTON-LABEL".localizedVariant
        bigStartButton.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-TIMER-START-BUTTON-HINT".localizedVariant
        
        view.accessibilityElements = [titleLabel as Any, timeDisplayLabel as Any, setTimePickerView as Any, nextTimerButton as Any, nextTimerPickerView as Any, bigStartButton as Any, setupButton as Any]
        
        if let firstElement = view.accessibilityElements?[0] as? UIView {
            UIAccessibility.post(notification: .layoutChanged, argument: firstElement)
        }
    }

    /* ################################################################################################################################## */
    // MARK: - UIPickerViewDelegate Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when  row is selected in the time or next timer picker

     - parameter pickerView: The UIPickerView calling this
     - parameter didSelectRow: The 0-based row index that was selected
     - parameter inComponent: The 0-based component index that was selected
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == nextTimerPickerView {
            let pickerIndex = pickerView.selectedRow(inComponent: 0) - 1
            
            if pickerIndex != Timer_AppDelegate.appDelegateObject.timerEngine.selectedTimerIndex {  // We do nothing if this is the selected timer.
                timerObject.succeedingTimerID = pickerIndex
                
                updateTimer()
            }
        } else {
            let hours = pickerView.selectedRow(inComponent: Components.Hours.rawValue)
            let minutes = pickerView.selectedRow(inComponent: Components.Minutes.rawValue)
            let seconds = pickerView.selectedRow(inComponent: Components.Seconds.rawValue)
            timerObject.timeSet = Int(TimeInstance(hours: hours, minutes: minutes, seconds: seconds))
            
            updateTimer()
        }
    }
    
    /* ################################################################## */
    /**
     - parameter in: The UIPickerView calling this
     
     - returns: 1, if the picker is the next timer picker, or 3, if it is the time set picker
     */
    override func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == nextTimerPickerView {
            return 1
        }
        return super.numberOfComponents(in: pickerView)
    }
    
    /* ################################################################## */
    /**
     - parameter pickerView: The UIPickerView calling this
     - parameter widthForComponent: The 0-based index of the component.
     - returns: the width, in display units, of the referenced picker component
     */
    override func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if pickerView == nextTimerPickerView {
            return pickerView.bounds.size.width
        }
        
        return super.pickerView(pickerView, widthForComponent: component)
    }
    
    /* ################################################################## */
    /**
     - parameter: The UIPickerView calling this (ignored)
     - parameter numberOfRowsInComponent: The 0-based index of the component.
     - returns either 24 (hours) or 60 (minutes and seconds)
     */
    override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == nextTimerPickerView {
            return Timer_AppDelegate.appDelegateObject.timerEngine.timers.count + 1
        }
        
        return super.pickerView(pickerView, numberOfRowsInComponent: component)
    }

    /* ################################################################## */
    /**
     - parameter pickerView: The UIPickerView calling this
     - parameter viewForRow: The 0-based index of the row.
     - parameter forComponent: The 0-based index of the component.
     - parameter reusing: Any view being reused (ignored)
     - returns: a UIView, containing the picker cell.
     */
    override func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if pickerView == nextTimerPickerView {
            let ret = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.pickerView(pickerView, widthForComponent: component), height: self.pickerView(pickerView, rowHeightForComponent: component))))
            
            ret.backgroundColor = UIAccessibility.isDarkerSystemColorsEnabled ? self.view.tintColor : UIColor.clear
            
            if UIAccessibility.isDarkerSystemColorsEnabled {
                let invertedLabel = InvertedMaskLabel(frame: ret.bounds)
                invertedLabel.adjustsFontSizeToFitWidth = true
                invertedLabel.textAlignment = .center
                invertedLabel.baselineAdjustment = .alignCenters
                if 0 == row {
                    invertedLabel.font = UIFont.systemFont(ofSize: self.pickerView(pickerView, rowHeightForComponent: component))
                    invertedLabel.text = "NO-TIMER".localizedVariant
                } else {
                    if row - 1 == Timer_AppDelegate.appDelegateObject.timerEngine.selectedTimerIndex {
                        invertedLabel.font = UIFont.italicSystemFont(ofSize: self.pickerView(pickerView, rowHeightForComponent: component))
                        invertedLabel.text = "CANT-SELECT".localizedVariant
                    } else {
                        invertedLabel.font = UIFont.systemFont(ofSize: self.pickerView(pickerView, rowHeightForComponent: component))
                        invertedLabel.text = String(format: "LGV_TIMER-TIMER-TITLE-FORMAT".localizedVariant, row)
                    }
                }

                ret.mask = invertedLabel
            } else {
                let label = UILabel(frame: ret.bounds)

                label.adjustsFontSizeToFitWidth = true
                label.textColor = self.view.tintColor

                if 0 == row {
                    label.font = UIFont.systemFont(ofSize: self.pickerView(pickerView, rowHeightForComponent: component))
                    label.text = "NO-TIMER".localizedVariant
                } else {
                    if row - 1 == Timer_AppDelegate.appDelegateObject.timerEngine.selectedTimerIndex {
                        label.font = UIFont.italicSystemFont(ofSize: self.pickerView(pickerView, rowHeightForComponent: component))
                        label.textColor = self.view.tintColor.withAlphaComponent(0.5)
                        label.text = "CANT-SELECT".localizedVariant
                    } else {
                        label.font = UIFont.systemFont(ofSize: self.pickerView(pickerView, rowHeightForComponent: component))
                        label.text = String(format: "LGV_TIMER-TIMER-TITLE-FORMAT".localizedVariant, row)
                    }
                }
                
                ret.addSubview(label)
            }
            
            return ret
        }
        
        return super.pickerView(pickerView, viewForRow: row, forComponent: component, reusing: view)
    }
    
    /* ################################################################## */
    /**
     - parameter: The UIPickerView calling this (ignored)
     - parameter accessibilityLabelForComponent: The 0-based index of the component.
     - returns: The accessibility label for the given component.
     */
    override func pickerView(_ inPickerView: UIPickerView, accessibilityLabelForComponent inComponent: Int) -> String? {
        if 1 == inPickerView.numberOfComponents {
            return "LGV_TIMER-ACCESSIBILITY-NEXT-TIMER-PICKER-COLUMN-LABEL".localizedVariant
        } else {
            return super.pickerView(inPickerView, accessibilityLabelForComponent: inComponent)
        }
    }
}
