//
//  LGV_Timer_TimerRuntimeViewController.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 6/1/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//
/* ###################################################################################################################################### */

import UIKit

/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_TimerRuntimeViewController: LGV_Timer_TimerBaseViewController {
    // MARK: - IB Properties
    /* ################################################################################################################################## */
    @IBOutlet weak var pauseButton: UIBarButtonItem!
    @IBOutlet weak var stopButton: UIBarButtonItem!
    @IBOutlet weak var navItem: UINavigationItem!
    
    // MARK: - IB Action Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBAction func stopButtonHit(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func pauseButtonHit(_ sender: Any) {
    }
}
