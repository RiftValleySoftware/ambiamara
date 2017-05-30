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
    
    @IBOutlet weak var startButton: UIBarButtonItem!
    @IBOutlet weak var setupButton: UIBarButtonItem!
    @IBOutlet weak var timeSetLabel: UILabel!
    @IBOutlet weak var setTimePickerView: UIPickerView!

    // MARK: - Internal @IBAction Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Bring in the setup screen button hit.
     */
    @IBAction func setupButtonHit(_ sender: Any) {
        self.bringInSettingsScreen()
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
    
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view has finished loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startButton.title = self.startButton.title?.localizedVariant
        self.setupButton.title = self.setupButton.title?.localizedVariant
        self.timeSetLabel.text = self.timeSetLabel.text?.localizedVariant
    }
    
    /* ################################################################## */
    /**
     Called when the view has finished displaying.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navController = self.navigationController as? LGV_Timer_TimerNavController {
            self.setTimePickerView.reloadAllComponents()
            let timerNumber = max(0, navController.timerNumber - 1)
            let timers = s_g_LGV_Timer_AppDelegatePrefs.timers
            let timeSet = TimeTuple(timers[timerNumber].timeSet)
            self.setTimePickerView.selectRow(timeSet.hours, inComponent: Components.Hours.rawValue, animated: true)
            self.setTimePickerView.selectRow(timeSet.minutes, inComponent: Components.Minutes.rawValue, animated: true)
            self.setTimePickerView.selectRow(timeSet.seconds, inComponent: Components.Seconds.rawValue, animated: true)
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
     */
    @IBAction func modeSegmentedControlChanged(_ sender: UISegmentedControl) {
        let timerNumber = max(0, ((self.navigationController as? LGV_Timer_TimerNavController)?.timerNumber)! - 1)
        let timers = s_g_LGV_Timer_AppDelegatePrefs.timers
        timers[timerNumber].displayMode = TimerDisplayMode(rawValue: sender.selectedSegmentIndex)!
        s_g_LGV_Timer_AppDelegatePrefs.timers = timers
    }
    
    /// MARK: - UIPickerViewDelegate Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let timerNumber = max(0, ((self.navigationController as? LGV_Timer_TimerNavController)?.timerNumber)! - 1)
        let timers = s_g_LGV_Timer_AppDelegatePrefs.timers
        let hours = pickerView.selectedRow(inComponent: Components.Hours.rawValue)
        let minutes = pickerView.selectedRow(inComponent: Components.Minutes.rawValue)
        let seconds = pickerView.selectedRow(inComponent: Components.Seconds.rawValue)
        timers[timerNumber].timeSet = Int(TimeTuple(hours: hours, minutes: minutes, seconds: seconds))
        s_g_LGV_Timer_AppDelegatePrefs.timers = timers
        if let navController = self.navigationController as? LGV_Timer_TimerNavController {
            navController.tabBarItem.image = navController.tabBarImage
            navController.tabBarItem.selectedImage = navController.tabBarImage
        }
    }
}

