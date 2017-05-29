//
//  LGV_Timer_TimerSetupController.swift
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
class LGV_Timer_TimeSetPickerView: UIPickerView {
    
}

/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_TimerSetupController: LGV_Timer_TimerBaseViewController {
    @IBOutlet weak var keepDeviceAwakeLabel: UILabel!
    @IBOutlet weak var keepDeviceAwakeSwitch: UISwitch!
    @IBOutlet weak var timeSetLabel: UILabel!
    @IBOutlet weak var timeSetPickerView: LGV_Timer_TimeSetPickerView!
    
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view will appear.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.keepDeviceAwakeLabel.text = self.keepDeviceAwakeLabel.text?.localizedVariant
        self.timeSetLabel.text = self.timeSetLabel.text?.localizedVariant
        let timerNumber = max(0, ((self.navigationController as? LGV_Timer_TimerNavController)?.timerNumber)! - 1)
        let timers = s_g_LGV_Timer_AppDelegatePrefs.timers
        self.keepDeviceAwakeSwitch.isOn = timers[timerNumber].keepsDeviceAwake
        timers[timerNumber].hasBeenSet = true
        s_g_LGV_Timer_AppDelegatePrefs.timers = timers
    }
    
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the keep device awake switch is hit.
     
     :param: sender The switch object.
     */
    @IBAction func keepDeviceAwakeSwitchHit(_ sender: UISwitch) {
        let timerNumber = max(0, ((self.navigationController as? LGV_Timer_TimerNavController)?.timerNumber)! - 1)
        let timers = s_g_LGV_Timer_AppDelegatePrefs.timers
        timers[timerNumber].keepsDeviceAwake = sender.isOn
        s_g_LGV_Timer_AppDelegatePrefs.timers = timers
    }
}
