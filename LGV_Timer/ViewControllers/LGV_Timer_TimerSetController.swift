//
//  LGV_Timer_TimerSetController.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 5/24/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//
/* ###################################################################################################################################### */
/**
 */

import UIKit

/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_TimerSetController: LGV_Timer_TimerSetPickerController {
    static let switchToSettingsSegueID = "timer-segue-to-settings"
    static let startTimerSegueID = "timer-segue-to-start-timer"
    
    @IBOutlet weak var startButton: UIBarButtonItem!
    @IBOutlet weak var setupButton: UIBarButtonItem!
    @IBOutlet weak var timeSetLabel: UILabel!
    @IBOutlet weak var setTimePickerView: UIPickerView!
    @IBOutlet weak var timerModeSegmentedSwitch: UISegmentedControl!
    
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
        self.startTimer()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func modeSegmentedControlChanged(_ sender: UISegmentedControl) {
        self.timerObject.displayMode = TimerDisplayMode(rawValue: sender.selectedSegmentIndex)!
        s_g_LGV_Timer_AppDelegatePrefs.updateTimer(self.timerObject)
    }
    
    // MARK: - Internal Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Bring in the setup screen.
     */
    func bringInSettingsScreen() {
        self.performSegue(withIdentifier: type(of:self).switchToSettingsSegueID, sender: nil)
    }
    
    /* ################################################################## */
    /**
     Start the Timer.
     */
    func startTimer() {
        self.performSegue(withIdentifier: type(of:self).startTimerSegueID, sender: nil)
    }
    
    /* ################################################################## */
    /**
     */
    func setUpDisplay() {
        self.startButton.isEnabled = 0 < self.timerObject.timeSet
        let timerNumber = self.timerNumber
        let tabBarImage = self.tabBarImage
        if type(of: self.navigationController) == LGV_Timer_TimerNavController.self {
            self.tabBarController?.viewControllers?[timerNumber].tabBarItem.image = tabBarImage
            self.tabBarController?.viewControllers?[timerNumber].tabBarItem.selectedImage = tabBarImage
        }
    }
    
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view has finished loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for segment in 0..<self.timerModeSegmentedSwitch.numberOfSegments {
            self.timerModeSegmentedSwitch.setTitle(self.timerModeSegmentedSwitch.titleForSegment(at: segment)?.localizedVariant, forSegmentAt: segment)
        }
        self.setupButton.title = self.setupButton.title?.localizedVariant
        self.timeSetLabel.text = self.timeSetLabel.text?.localizedVariant
    }
    
    /* ################################################################## */
    /**
     Called when the view will display.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.timerModeSegmentedSwitch.selectedSegmentIndex = self.timerObject.displayMode.rawValue
        let timeSet = TimeTuple(self.timerObject.timeSet)
        self.setTimePickerView.reloadAllComponents()
        self.setTimePickerView.selectRow(timeSet.hours, inComponent: Components.Hours.rawValue, animated: true)
        self.setTimePickerView.selectRow(timeSet.minutes, inComponent: Components.Minutes.rawValue, animated: true)
        self.setTimePickerView.selectRow(timeSet.seconds, inComponent: Components.Seconds.rawValue, animated: true)
        self.setUpDisplay()
    }
    
    /* ################################################################## */
    /**
     Called when the view will go away.
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let tabController = self.tabBarController as? LGV_Timer_MainTabController {
            if let _ = self.navigationController as? LGV_Timer_TimerNavController {
            } else {
                tabController.updateTimers()
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called when the view has finished displaying.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setUpDisplay()
    }
    
    /* ################################################################## */
    /**
     Called when we are about to bring in the setup controller.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationController = segue.destination as? LGV_Timer_TimerNavBaseController {
            destinationController.timerObject = self.timerObject
        }
    }
    
    /// MARK: - UIPickerViewDelegate Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let hours = pickerView.selectedRow(inComponent: Components.Hours.rawValue)
        let minutes = pickerView.selectedRow(inComponent: Components.Minutes.rawValue)
        let seconds = pickerView.selectedRow(inComponent: Components.Seconds.rawValue)
        self.timerObject.timeSet = Int(TimeTuple(hours: hours, minutes: minutes, seconds: seconds))
        // We always reset these when we change the main time.
        self.timerObject.timeSetPodiumWarn = LGV_Timer_StaticPrefs.calcPodiumModeWarningThresholdForTimerValue(self.timerObject.timeSet)
        self.timerObject.timeSetPodiumFinal = LGV_Timer_StaticPrefs.calcPodiumModeFinalThresholdForTimerValue(self.timerObject.timeSet)
        s_g_LGV_Timer_AppDelegatePrefs.updateTimer(self.timerObject)
        self.setUpDisplay()
    }
}

