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
    @IBAction func startButtonHit(_ sender: Any) {
        self.startTimer()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func modeSegmentedControlChanged(_ sender: UISegmentedControl) {
        let timers = s_g_LGV_Timer_AppDelegatePrefs.timers
        timers[self.timerNumber].displayMode = TimerDisplayMode(rawValue: sender.selectedSegmentIndex)!
        s_g_LGV_Timer_AppDelegatePrefs.timers = timers
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
        self.startButton.isEnabled = 0 < s_g_LGV_Timer_AppDelegatePrefs.timers[self.timerNumber].timeSet
        self.tabBarController?.viewControllers?[self.timerNumber + 1].tabBarItem.image = self.tabBarImage
        self.tabBarController?.viewControllers?[self.timerNumber + 1].tabBarItem.selectedImage = self.tabBarImage
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
        self.timerNumber = (self.tabBarController?.selectedIndex)! - 1
    }
    
    /* ################################################################## */
    /**
     Called when the view has finished displaying.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.timerModeSegmentedSwitch.selectedSegmentIndex = s_g_LGV_Timer_AppDelegatePrefs.timers[self.timerNumber].displayMode.rawValue
        
        let timers = s_g_LGV_Timer_AppDelegatePrefs.timers
        let timeSet = TimeTuple(timers[self.timerNumber].timeSet)
        self.setTimePickerView.reloadAllComponents()
        self.setTimePickerView.selectRow(timeSet.hours, inComponent: Components.Hours.rawValue, animated: true)
        self.setTimePickerView.selectRow(timeSet.minutes, inComponent: Components.Minutes.rawValue, animated: true)
        self.setTimePickerView.selectRow(timeSet.seconds, inComponent: Components.Seconds.rawValue, animated: true)
        self.setUpDisplay()
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
    
    /* ################################################################## */
    /**
     This supplies a dynamically-created image for the Tab Bar.
     */
    var tabBarImage: UIImage! {
        get {
            var displayedString = "";
            let prefs = s_g_LGV_Timer_AppDelegatePrefs.timers[self.timerNumber]
            let timeTuple = TimeTuple(prefs.timeSet)
            
            if 0 < timeTuple.hours {
                displayedString = String(format: "%02d:%02d:%02d", timeTuple.hours, timeTuple.minutes, timeTuple.seconds)
            } else {
                if 0 < timeTuple.minutes {
                    displayedString = String(format: "%02d:%02d", timeTuple.minutes, timeTuple.seconds)
                } else {
                    displayedString = String(format: "%02d", timeTuple.seconds)
                }
            }
            
            return LGV_Timer_TimerNavController.textAsImage(drawText: displayedString as NSString)
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
        self.setUpDisplay()
    }
}

