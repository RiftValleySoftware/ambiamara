//
//  LGV_Timer_SettingsViewController.swift
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
class LGV_Timer_SettingsViewController: LGV_Timer_TimerBaseViewController {
    @IBOutlet weak var militaryTimeSwitchLabel: UILabel!
    @IBOutlet weak var militaryTimeSwitch: UISwitch!
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view has finished loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.militaryTimeSwitchLabel.text = self.militaryTimeSwitchLabel.text?.localizedVariant
    }
}

