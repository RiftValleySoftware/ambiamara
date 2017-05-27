//
//  LGV_Timer_SettingsViewController.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 5/24/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//
/* ###################################################################################################################################### */

import UIKit

/* ###################################################################################################################################### */
/**
 This is the main controller class for the "global" settings tab screen.
 */
class LGV_Timer_SettingsViewController: LGV_Timer_TimerBaseViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - IB Properties
    /* ################################################################################################################################## */
    @IBOutlet weak var clockOptionsHeaderLabel: UILabel!
    @IBOutlet weak var keepPhoneAwakeLabel: UILabel!
    @IBOutlet weak var keepPhoneAwakeSwitch: UISwitch!
    @IBOutlet weak var stopwatchOptionsHeaderLabel: UILabel!
    @IBOutlet weak var stopwatchKeepPhoneAwakeSwitch: UISwitch!
    @IBOutlet weak var stopwatchKeepPhoneAwakeLabel: UILabel!
    @IBOutlet weak var stopwatchCountLapsSwitch: UISwitch!
    @IBOutlet weak var stopwatchCountLapsLabel: UILabel!
    @IBOutlet weak var timerSettingsHeaderLabel: UILabel!
    @IBOutlet weak var timerTableView: UITableView!
    @IBOutlet weak var addTimerButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view has finished loading.
     
     We use this method to establish all the localized strings, and restore the controls to reflect the stored state.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clockOptionsHeaderLabel.text = self.clockOptionsHeaderLabel.text?.localizedVariant
        self.keepPhoneAwakeLabel.text = self.keepPhoneAwakeLabel.text?.localizedVariant
        self.stopwatchOptionsHeaderLabel.text = self.stopwatchOptionsHeaderLabel.text?.localizedVariant
        self.stopwatchKeepPhoneAwakeLabel.text = self.stopwatchKeepPhoneAwakeLabel.text?.localizedVariant
        self.stopwatchCountLapsLabel.text = self.stopwatchCountLapsLabel.text?.localizedVariant
        self.timerSettingsHeaderLabel.text = self.timerSettingsHeaderLabel.text?.localizedVariant
        self.addTimerButton.setTitle(self.addTimerButton.title(for: UIControlState.normal)?.localizedVariant, for: UIControlState.normal)

        self.keepPhoneAwakeSwitch.isOn = s_g_LGV_Timer_AppDelegatePrefs.clockKeepsDeviceAwake
        self.stopwatchKeepPhoneAwakeSwitch.isOn = s_g_LGV_Timer_AppDelegatePrefs.stopwatchKeepsDeviceAwake
        self.stopwatchCountLapsSwitch.isOn = s_g_LGV_Timer_AppDelegatePrefs.stopwatchTracksLaps
    }
    
    // MARK: - IBAction Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is called when the the switch specifying whether or not the clock keeps the device awake while selected is hit.
     
     :param: sender The switch object.
     */
    @IBAction func clockKeepsAwakeSwitchHit(_ sender: UISwitch) {
        s_g_LGV_Timer_AppDelegatePrefs.clockKeepsDeviceAwake = sender.isOn
    }
    
    /* ################################################################## */
    /**
     This is called when the the switch specifying whether or not the stopwatch keeps the device awake while running is hit.
     
     :param: sender The switch object.
     */
    @IBAction func stopwatchKeepsAwakeSwitchHit(_ sender: UISwitch) {
        s_g_LGV_Timer_AppDelegatePrefs.stopwatchKeepsDeviceAwake = sender.isOn
    }
    
    /* ################################################################## */
    /**
     This is called when the the switch specifying whether or not the stopwatch counts laps is hit.
     
     :param: sender The switch object.
     */
    @IBAction func stopwatchCountsLapSwitchHit(_ sender: UISwitch) {
        s_g_LGV_Timer_AppDelegatePrefs.stopwatchTracksLaps = sender.isOn
    }
    
    /* ################################################################## */
    /**
     This is called when the "Add Timer" button is hit, requesting a new timer be created.
     
     :param: sender The button object.
     */
    @IBAction func addTimerButtonHit(_ sender: UIButton) {
    }
    
    /* ################################################################## */
    /**
     This is called when the info button is hit, requesting that we bring in the information screen.
     
     :param: sender The button object.
     */
    @IBAction func infoButtonHit(_ sender: UIButton) {
    }
    
    // MARK: - UITableViewDataSource Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     - parameter tableView: The UITableView object requesting the view
     - parameter numberOfRowsInSection: The section index (0-based).
     
     - returns the number of rows to display.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    /* ################################################################## */
    /**
     This is the routine that creates a new table row for the Meeting indicated by the index.
     
     - parameter tableView: The UITableView object requesting the view
     - parameter cellForRowAt: The IndexPath of the requested cell.
     
     - returns a nice, shiny cell (or sets the state of a reused one).
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let ret = tableView.dequeueReusableCell(withIdentifier: "REUSE-ID") {
            return ret
        } else {
            return UITableViewCell()
        }
    }
    
    // MARK: - UITableViewDelegate Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called before a row is selected.
     
     - parameter tableView: The table view being checked
     - parameter willSelectRowAt: The indexpath of the row being selected.
     
     - returns: nil (don't let selection happen).
     */
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    /* ################################################################## */
    /**
     Indicate that a row can be edited (for left-swipe delete).
     
     - parameter tableView: The table view being checked
     - parameter canEditRowAt: The indexpath of the row to be checked.
     
     - returns: true, always.
     */
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /* ################################################################## */
    /**
     Called to do a delete action.
     
     - parameter tableView: The table view being checked
     - parameter commit: The action to perform.
     - parameter forRowAt: The indexpath of the row to be deleted.
     */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let alertController = UIAlertController(title: NSLocalizedString("DELETE-HEADER", comment: ""), message: NSLocalizedString("DELETE-MESSAGE-FORMAT", comment: ""), preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: NSLocalizedString("DELETE-OK-BUTTON", comment: ""), style: UIAlertActionStyle.destructive, handler: {(_: UIAlertAction) in self.doADirtyDeedCheap(tableView, forRowAt: indexPath)})
            
            alertController.addAction(deleteAction)
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("DELETE-CANCEL-BUTTON", comment: ""), style: UIAlertActionStyle.default, handler: {(_: UIAlertAction) in self.dontDoADirtyDeedCheap(tableView)})
            
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    /* ################################################################## */
    /**
     Called to do a delete action.
     
     - parameter tableView: The table view being checked
     - parameter forRowAt: The indexpath of the row to be deleted.
     */
    func doADirtyDeedCheap(_ tableView: UITableView, forRowAt indexPath: IndexPath) {
    }
    
    /* ################################################################## */
    /**
     Called to cancel a delete action.
     
     - parameter tableView: The table view being checked
     */
    func dontDoADirtyDeedCheap(_ tableView: UITableView) {
        tableView.isEditing = false
    }
}

