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
class LGV_Timer_TimerSetController: LGV_Timer_TimerBaseViewController {
    private static let _switchToSettingsSegueID = "timer-segue-to-settings"
    
    @IBOutlet weak var startButton: UIBarButtonItem!
    @IBOutlet weak var setupButton: UIBarButtonItem!

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
    }
    
    /* ################################################################## */
    /**
     Called when the view is about to appear.
     */
    override func viewWillAppear(_ animated: Bool) {
        if let navController = self.navigationController as? LGV_Timer_TimerNavController {
            var timerNumber = navController.timerNumber
            timerNumber = max(0, timerNumber - 1)
            let prefs = s_g_LGV_Timer_AppDelegatePrefs.timers[timerNumber]
            if !prefs.hasBeenSet {
                self.performSegue(withIdentifier: type(of: self)._switchToSettingsSegueID, sender: nil)
            }
        }
        
        super.viewWillAppear(animated)
    }
    
    /* ################################################################## */
    /**
     Called before we shift in something else.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }
}

