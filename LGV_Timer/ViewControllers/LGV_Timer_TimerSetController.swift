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
    
    @IBOutlet weak var setupButton: UIBarButtonItem!
    @IBOutlet weak var timeSetLabel: UILabel!
    @IBOutlet weak var setTimePickerView: UIPickerView!
    @IBOutlet weak var timerModeSegmentedSwitch: UISegmentedControl!
    @IBOutlet weak var startButtonDisplay: LGV_Lib_LEDDisplayHoursMinutesSecondsDigitalClock!
    
    var timerNumber: Int = 0
    
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
    @IBAction func modeSegmentedControlChanged(_ sender: UISegmentedControl) {
        let timers = s_g_LGV_Timer_AppDelegatePrefs.timers
        timers[self.timerNumber].displayMode = TimerDisplayMode(rawValue: sender.selectedSegmentIndex)!
        s_g_LGV_Timer_AppDelegatePrefs.timers = timers
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func tapOnNumbers(_ sender: Any) {
        self.performSegue(withIdentifier: type(of:self).startTimerSegueID, sender: nil)
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
     Bring in the setup screen.
     */
    func setUpDisplay() {
        self.startButtonDisplay.hours = TimeTuple(s_g_LGV_Timer_AppDelegatePrefs.timers[self.timerNumber].timeSet).hours
        self.startButtonDisplay.minutes = TimeTuple(s_g_LGV_Timer_AppDelegatePrefs.timers[self.timerNumber].timeSet).minutes
        self.startButtonDisplay.seconds = TimeTuple(s_g_LGV_Timer_AppDelegatePrefs.timers[self.timerNumber].timeSet).seconds
        self.startButtonDisplay.activeSegmentColor = LGV_Timer_StaticPrefs.prefs.pickerPepperArray[s_g_LGV_Timer_AppDelegatePrefs.timers[self.timerNumber].colorTheme].textColor!
        self.startButtonDisplay.setNeedsDisplay()
    }
    
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view has finished loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let timers = s_g_LGV_Timer_AppDelegatePrefs.timers

        for segment in 0..<self.timerModeSegmentedSwitch.numberOfSegments {
            self.timerModeSegmentedSwitch.setTitle(self.timerModeSegmentedSwitch.titleForSegment(at: segment)?.localizedVariant, forSegmentAt: segment)
        }
        
        self.timerModeSegmentedSwitch.selectedSegmentIndex = timers[self.timerNumber].displayMode.rawValue
        
        self.setupButton.title = self.setupButton.title?.localizedVariant
        self.timeSetLabel.text = self.timeSetLabel.text?.localizedVariant
        if let navController = self.navigationController as? LGV_Timer_TimerNavController {
            self.timerNumber = max(0, navController.timerNumber - 1)
            let timers = s_g_LGV_Timer_AppDelegatePrefs.timers
            self.tabItemColor = LGV_Timer_StaticPrefs.prefs.pickerPepperArray[timers[self.timerNumber].colorTheme].textColor
        }
    }
    
    /* ################################################################## */
    /**
     Called when the view has finished displaying.
     */
    override func viewWillAppear(_ animated: Bool) {
        self.tabItemColor = LGV_Timer_StaticPrefs.prefs.pickerPepperArray[s_g_LGV_Timer_AppDelegatePrefs.timers[self.timerNumber].colorTheme].textColor
        super.viewWillAppear(animated)
        if let navController = self.navigationController as? LGV_Timer_TimerNavController {
            self.timerNumber = max(0, navController.timerNumber - 1)
            let timers = s_g_LGV_Timer_AppDelegatePrefs.timers
            let timeSet = TimeTuple(timers[self.timerNumber].timeSet)
            self.setTimePickerView.reloadAllComponents()
            self.setTimePickerView.selectRow(timeSet.hours, inComponent: Components.Hours.rawValue, animated: true)
            self.setTimePickerView.selectRow(timeSet.minutes, inComponent: Components.Minutes.rawValue, animated: true)
            self.setTimePickerView.selectRow(timeSet.seconds, inComponent: Components.Seconds.rawValue, animated: true)
            self.setUpDisplay()
        }
    }
    
    /* ################################################################## */
    /**
     Called when the view has finished displaying.
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if LGV_Timer_MainTabController.s_c_pushTimerSettings {
            LGV_Timer_MainTabController.s_c_pushTimerSettings = false
            self.bringInSettingsScreen()
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
        if let destinationController = segue.destination as? LGV_Timer_TimerSetupController {
            destinationController.timerNumber = self.timerNumber
        } else {
            if let destinationController = segue.destination as? LGV_Timer_TimerRuntimeViewController {
                destinationController.timerNumber = self.timerNumber
            }
        }
    }
    
    /// MARK: - UIPickerViewDelegate Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let timers = s_g_LGV_Timer_AppDelegatePrefs.timers
        let hours = pickerView.selectedRow(inComponent: Components.Hours.rawValue)
        let minutes = pickerView.selectedRow(inComponent: Components.Minutes.rawValue)
        let seconds = pickerView.selectedRow(inComponent: Components.Seconds.rawValue)
        timers[self.timerNumber].timeSet = Int(TimeTuple(hours: hours, minutes: minutes, seconds: seconds))
        // We always reset these when we change the main time.
        timers[self.timerNumber].timeSetPodiumWarn = LGV_Timer_StaticPrefs.calcPodiumModeWarningThresholdForTimerValue(timers[self.timerNumber].timeSet)
        timers[self.timerNumber].timeSetPodiumFinal = LGV_Timer_StaticPrefs.calcPodiumModeFinalThresholdForTimerValue(timers[self.timerNumber].timeSet)
        s_g_LGV_Timer_AppDelegatePrefs.timers = timers
        if let navController = self.navigationController as? LGV_Timer_TimerNavController {
            navController.tabBarItem.image = navController.tabBarImage
            navController.tabBarItem.selectedImage = navController.tabBarImage
        }
        self.setUpDisplay()
    }
}

