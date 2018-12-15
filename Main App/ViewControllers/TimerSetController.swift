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
class TimerSetController: TimerSetPickerController {
    static let switchToSettingsSegueID = "timer-segue-to-settings"
    static let startTimerSegueID = "timer-segue-to-start-timer"
    
    @IBOutlet weak var setupButton: UIBarButtonItem!
    @IBOutlet weak var setTimePickerView: UIPickerView!
    @IBOutlet weak var nextTimerButton: UIButton!
    @IBOutlet weak var bigStartButton: UIButton!
    @IBOutlet weak var timeDisplayLabel: UILabel!
    @IBOutlet weak var nextTimerSelectionContainer: UIView!
    @IBOutlet weak var nextTimerPickerView: UIPickerView!
    @IBOutlet weak var trafficLightsImageView: UIImageView!
    
    var runningTimer: TimerRuntimeViewController! = nil
    
    /* ################################################################################################################################## */
    // MARK: - Private Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    private func _setUpDisplay() {
        self.bigStartButton.isHidden = 0 >= self.timerObject.timeSet
        
        let timerNumber = self.timerNumber
        let tabBarImage = self.tabBarImage
        
        if nil != self.navigationController as? TimerNavController {
            if (self.tabBarController?.viewControllers?.count)! > timerNumber + 1 {
                self.tabBarController?.viewControllers?[timerNumber + 1].tabBarItem.image = tabBarImage
                self.tabBarController?.viewControllers?[timerNumber + 1].tabBarItem.selectedImage = tabBarImage
            }
        }
        
        if 1 < Timer_AppDelegate.appDelegateObject.timerEngine.timers.count {
            self.nextTimerButton.isHidden = false
            let nextID = self.timerObject.succeedingTimerID
            
            if 0 <= nextID {
                self.nextTimerButton.setTitle(String(format: "NEXT-TIMER-TIMER-FORMAT".localizedVariant, nextID + 1), for: .normal)
                self.nextTimerPickerView.selectRow(nextID + 1, inComponent: 0, animated: false)
            } else {
                self.nextTimerButton.setTitle("NO-TIMER".localizedVariant, for: .normal)
                self.nextTimerPickerView.selectRow(0, inComponent: 0, animated: false)
            }
            self.nextTimerButton.titleLabel?.text = self.nextTimerButton.title(for: .normal)
        } else {
            self.nextTimerButton.isHidden = true
        }

        self.nextTimerPickerView.reloadComponent(0)
        self.updateTimeDisplayLabel()
        
        var nextTimer: String = ""
        let row = self.timerObject.succeedingTimerID + 1
        if 0 == row {
            nextTimer = "NO-TIMER".localizedVariant
        } else {
            if row - 1 == Timer_AppDelegate.appDelegateObject.timerEngine.selectedTimerIndex {
                nextTimer = "CANT-SELECT".localizedVariant
            } else {
                nextTimer = String(format: "LGV_TIMER-TIMER-TITLE-FORMAT".localizedVariant, row)
            }
        }
        
        self.nextTimerButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-NEXT-TIMER-PICKER-LABEL".localizedVariant + " " + nextTimer
    }

    /* ################################################################################################################################## */
    // MARK: - Internal @IBAction Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Bring in the setup screen button hit.
     */
    @IBAction func setupButtonHit(_ sender: Any) {
        self.bringInSettingsScreen()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func startButtonHit(_ sender: Any) {
        Timer_AppDelegate.appDelegateObject.timerEngine.startTimer()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func nextTimerButtonHit(_ sender: UIButton) {
        self.nextTimerSelectionContainer.isHidden = false
        self.setTimePickerView.isHidden = true
        
        self.updateTimer()
        self.nextTimerButton.addTarget(self, action: #selector(type(of: self).setSelectedNextTimer(_:)), for: .touchUpInside)
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func setSelectedNextTimer(_ : Any! = nil) {
        self.nextTimerSelectionContainer.isHidden = true
        self.setTimePickerView.isHidden = false
        self.nextTimerButton.addTarget(self, action: #selector(type(of: self).nextTimerButtonHit(_:)), for: .touchUpInside)
    }
    
    /* ################################################################################################################################## */
    // MARK: - Internal Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Bring in the setup screen.
     */
    func bringInSettingsScreen() {
        self.performSegue(withIdentifier: type(of: self).switchToSettingsSegueID, sender: nil)
    }
    
    /* ################################################################## */
    /**
     Update the time set label.
     */
    func updateTimeDisplayLabel() {
        self.timeDisplayLabel.text = TimeTuple(self.timerObject.timeSet).description
        if let backgroundColor = Timer_AppDelegate.appDelegateObject.timerEngine.colorLabelArray[self.timerObject.colorTheme].backgroundColor {
            self.timeDisplayLabel.textColor = (.Podium == self.timerObject.displayMode ? UIColor.white : backgroundColor)
        }
        
        if .Podium == self.timerObject.displayMode {
            self.timeDisplayLabel.font = UIFont.boldSystemFont(ofSize: 42)
        } else {
            if let titleFont = UIFont(name: "Let's Go Digital", size: 50) {
                self.timeDisplayLabel.font = titleFont
            }
        }
        self.timeDisplayLabel.setNeedsDisplay()
    }
    /* ################################################################## */
    /**
     Start the Timer.
     */
    func startTimer() {
        self.performSegue(withIdentifier: type(of: self).startTimerSegueID, sender: nil)
    }
    
    /* ################################################################## */
    /**
     */
    func updateTimer() {
        let timeSet = TimeTuple(self.timerObject.timeSet)
        
        if nil != self.setTimePickerView {
            self.setTimePickerView.selectRow(timeSet.hours, inComponent: Components.Hours.rawValue, animated: true)
            self.setTimePickerView.selectRow(timeSet.minutes, inComponent: Components.Minutes.rawValue, animated: true)
            self.setTimePickerView.selectRow(timeSet.seconds, inComponent: Components.Seconds.rawValue, animated: true)
        }
        
        self._setUpDisplay()
        
        if nil != self.runningTimer {
            if .Stopped == self.timerObject.timerStatus {
                self.navigationController?.dismiss(animated: true, completion: nil)
            } else {
                self.runningTimer.updateTimer()
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func tick(times inTimes: Int = 1) {
        self.runningTimer?.tick(times: inTimes)
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
        
        if let tabber = self.tabBarController as? Timer_MainTabController {
            tabber.addTimerToList(self)
        }
        
        self.setTimePickerView.setValue(self.view.tintColor, forKey: "textColor")
    }
    
    /* ################################################################## */
    /**
     Called when the view will display.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateTimer()
        if nil != self.timerObject {
            Timer_AppDelegate.appDelegateObject.sendSelectMessage(timerUID: self.timerObject.uid)
        }
        
        self.nextTimerSelectionContainer.isHidden = true
        self.setTimePickerView.isHidden = false
        self.nextTimerButton.addTarget(self, action: #selector(type(of: self).nextTimerButtonHit(_:)), for: .touchUpInside)
        self.trafficLightsImageView.isHidden = .Digital == self.timerObject.displayMode
        self.titleLabel.text = self.navigationItem.title ?? ""
    }
        
    /* ################################################################## */
    /**
     Called when the view will go away.
     */
    override func viewWillDisappear(_ animated: Bool) {
        if let navBar = self.navigationController?.navigationBar {
            navBar.titleTextAttributes?[NSAttributedString.Key.foregroundColor] = UIColor.white
        }
    }
    
    /* ################################################################## */
    /**
     Called when the view has finished displaying.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateTimer()
    }
    
    /* ################################################################## */
    /**
     Called when we are about to bring in the setup controller.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationController = segue.destination as? TimerRuntimeViewController {
            destinationController.myHandler = self
            self.runningTimer = destinationController
        }
        
        if let destinationController = segue.destination as? TimerNavBaseController {
            destinationController.timerObject = self.timerObject
        }
    }
    
    /* ################################################################################################################################## */
    /// MARK: - UIPickerViewDelegate Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.nextTimerPickerView {
            let pickerIndex = pickerView.selectedRow(inComponent: 0) - 1
            
            if pickerIndex != Timer_AppDelegate.appDelegateObject.timerEngine.selectedTimerIndex {  // We do nothing if this is the selected timer.
                self.timerObject.succeedingTimerID = pickerIndex
                
                self.updateTimer()
            }
        } else {
            let hours = pickerView.selectedRow(inComponent: Components.Hours.rawValue)
            let minutes = pickerView.selectedRow(inComponent: Components.Minutes.rawValue)
            let seconds = pickerView.selectedRow(inComponent: Components.Seconds.rawValue)
            self.timerObject.timeSet = Int(TimeTuple(hours: hours, minutes: minutes, seconds: seconds))
            
            self.updateTimer()
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == self.nextTimerPickerView {
            return 1
        }
        return super.numberOfComponents(in: pickerView)
    }
    
    /* ################################################################## */
    /**
     */
    override func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if pickerView == self.nextTimerPickerView {
            return pickerView.bounds.size.width
        }
        
        return super.pickerView(pickerView, widthForComponent: component)
    }
    
    /* ################################################################## */
    /**
     */
    override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.nextTimerPickerView {
            return Timer_AppDelegate.appDelegateObject.timerEngine.timers.count + 1
        }
        
        return super.pickerView(pickerView, numberOfRowsInComponent: component)
    }

    /* ################################################################## */
    /**
     */
    override func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if pickerView == self.nextTimerPickerView {
            let ret = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.pickerView(pickerView, widthForComponent: component), height: self.pickerView(pickerView, rowHeightForComponent: component))))
            
            ret.adjustsFontSizeToFitWidth = true
            ret.backgroundColor = UIColor.clear
            ret.textColor = self.view.tintColor

            if 0 == row {
                ret.font = UIFont.systemFont(ofSize: self.pickerView(pickerView, rowHeightForComponent: component))
                ret.text = "NO-TIMER".localizedVariant
            } else {
                if row - 1 == Timer_AppDelegate.appDelegateObject.timerEngine.selectedTimerIndex {
                    ret.font = UIFont.italicSystemFont(ofSize: self.pickerView(pickerView, rowHeightForComponent: component))
                    ret.textColor = self.view.tintColor.withAlphaComponent(0.5)
                    ret.text = "CANT-SELECT".localizedVariant
                } else {
                    ret.font = UIFont.systemFont(ofSize: self.pickerView(pickerView, rowHeightForComponent: component))
                    ret.text = String(format: "LGV_TIMER-TIMER-TITLE-FORMAT".localizedVariant, row)
                }
            }
            
            return ret
        }
        
        return super.pickerView(pickerView, viewForRow: row, forComponent: component, reusing: view)
    }
    
    /* ################################################################################################################################## */
    /**
     This method adds all the accessibility stuff.
     */
    override func addAccessibilityStuff() {
        super.addAccessibilityStuff()
        let title = self.navigationItem.title ?? ""
        
        self.setupButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-SETTINGS-BUTTON-LABEL".localizedVariant
        self.setupButton.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-SETTINGS-BUTTON-HINT".localizedVariant
        
        self.setTimePickerView.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-SET-TIME-PICKER-LABEL".localizedVariant
        self.setTimePickerView.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-SET-TIME-PICKER-HINT".localizedVariant
        self.nextTimerButton.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-NEXT-TIMER-PICKER-HINT".localizedVariant

        self.nextTimerPickerView.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-NEXT-TIMER-PICKER-LABEL".localizedVariant
        self.nextTimerPickerView.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-NEXT-TIMER-PICKER-HINT".localizedVariant
        
        self.bigStartButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-TIMER-START-BUTTON-LABEL".localizedVariant
        self.bigStartButton.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-TIMER-START-BUTTON-HINT".localizedVariant

        switch self.timerObject.displayMode {
        case .Podium:
            self.timeDisplayLabel.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-PODIUM-LABEL".localizedVariant + " (" + self.timerObject.setSpeakableTime + ")"
            self.timeDisplayLabel.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-PODIUM-HINT".localizedVariant
            self.trafficLightsImageView.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-PODIUM-LABEL".localizedVariant + " (" + self.timerObject.setSpeakableTime + ")"
            self.trafficLightsImageView.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-PODIUM-HINT".localizedVariant
            self.titleLabel.accessibilityLabel = title + " " + "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-PODIUM-LABEL".localizedVariant + " (" + self.timerObject.setSpeakableTime + ")"
        case .Digital:
            self.timeDisplayLabel.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-DIGITAL-LABEL".localizedVariant + " (" + self.timerObject.setSpeakableTime + ")"
            self.timeDisplayLabel.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-DIGITAL-HINT".localizedVariant
            self.trafficLightsImageView.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-DIGITAL-LABEL".localizedVariant + " (" + self.timerObject.setSpeakableTime + ")"
            self.trafficLightsImageView.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-DIGITAL-HINT".localizedVariant
            self.titleLabel.accessibilityLabel = title + " " + "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-DIGITAL-LABEL".localizedVariant + " (" + self.timerObject.setSpeakableTime + ")"
        case .Dual:
            self.timeDisplayLabel.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-DUAL-LABEL".localizedVariant + " (" + self.timerObject.setSpeakableTime + ")"
            self.timeDisplayLabel.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-DUAL-HINT".localizedVariant
            self.trafficLightsImageView.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-DUAL-LABEL".localizedVariant + " (" + self.timerObject.setSpeakableTime + ")"
            self.trafficLightsImageView.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-DUAL-HINT".localizedVariant
            self.titleLabel.accessibilityLabel = title + " " + "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-DUAL-LABEL".localizedVariant + " (" + self.timerObject.setSpeakableTime + ")"
        }
        
        UIAccessibility.post(notification: .layoutChanged, argument: self.timeDisplayLabel)
    }
}
