//
//  LGV_Timer_SettingsViewController.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 5/24/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//
/* ###################################################################################################################################### */

import UIKit

class LGV_Timer_SettingsTimerTableCell: UITableViewCell {
    @IBOutlet weak var clockDisplay: LGV_Lib_LEDDisplayHoursMinutesSecondsDigitalClock!
    @IBOutlet weak var timerNameLabel: UILabel!
    @IBOutlet weak var trafficLights: UIImageView!
}

class LGV_Timer_TimerSettingsNavController: UINavigationController {
}

/* ###################################################################################################################################### */
/**
 This is the main controller class for the "global" settings tab screen.
 */
class LGV_Timer_SettingsViewController: LGV_Timer_TimerBaseViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - IB Properties
    /* ################################################################################################################################## */
    @IBOutlet weak var timerTableView: UITableView!
    @IBOutlet weak var navItemTitle: UINavigationItem!
    @IBOutlet weak var navInfo: UIBarButtonItem!
    @IBOutlet weak var navAdd: UIBarButtonItem!
    
    private let _info_segue_id = "segue-id-info"
    
    // MARK: - Internal Instance Properties
    /* ################################################################################################################################## */
    var mainTabController: LGV_Timer_MainTabController! = nil
    
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view has finished loading.
     
     We use this method to establish all the localized strings, and restore the controls to reflect the stored state.
     */
    override func viewDidLoad() {
        self.navItemTitle.title = self.navItemTitle.title?.localizedVariant
        self.mainTabController = self.tabBarController as! LGV_Timer_MainTabController
        super.viewDidLoad()
        self.gussyUpTheMoreNavigation()
    }
    
    /* ################################################################## */
    /**
     Called when the view has changed its layout.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LGV_Timer_AppDelegate.appDelegateObject.currentTimerSet = nil
        LGV_Timer_AppDelegate.appDelegateObject.sendSelectMessage()
        self.timerTableView.reloadData()
    }
    
    // MARK: - Internal Instance Methods

    // MARK: - IBAction Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is called when the "Add Timer" button is hit, requesting a new timer be created.
     
     :param: sender The button object.
     */
    @IBAction func addTimerButtonHit(_ sender: Any) {
        self.mainTabController.addNewTimer()
        LGV_Timer_AppDelegate.appDelegateObject.sendRecalculateMessage()
        self.timerTableView.reloadData()
        self.gussyUpTheMoreNavigation()
    }
    
    /* ################################################################## */
    /**
     This is called when the info button is hit, requesting that we bring in the information screen.
     
     :param: sender The button object.
     */
    @IBAction func infoButtonHit(_ sender: Any) {
        self.performSegue(withIdentifier: self._info_segue_id, sender: nil)
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
        return LGV_Timer_AppDelegate.appDelegateObject.timerEngine.timers.count
    }
    
    /* ################################################################## */
    /**
     This is the routine that creates a new table row for the Timer indicated by the index.
     
     - parameter tableView: The UITableView object requesting the view
     - parameter cellForRowAt: The IndexPath of the requested cell.
     
     - returns a nice, shiny cell (or sets the state of a reused one).
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let ret = tableView.dequeueReusableCell(withIdentifier: "SingleTimerCell") as? LGV_Timer_SettingsTimerTableCell {
            if let clockView = ret.clockDisplay {
                let timerPrefs = LGV_Timer_AppDelegate.appDelegateObject.timerEngine[indexPath.row]
                let timeTuple = TimeTuple(timerPrefs.timeSet)
                clockView.hours = timeTuple.hours
                clockView.minutes = timeTuple.minutes
                clockView.seconds = timeTuple.seconds
                clockView.activeSegmentColor = LGV_Timer_StaticPrefs.prefs.pickerPepperArray[timerPrefs.colorTheme].textColor!
                clockView.setNeedsDisplay()
            }
            
            if let timerNameLabel = ret.timerNameLabel {
                let timerPrefs = LGV_Timer_AppDelegate.appDelegateObject.timerEngine[indexPath.row]
                timerNameLabel.textColor = LGV_Timer_StaticPrefs.prefs.pickerPepperArray[timerPrefs.colorTheme].textColor!
                timerNameLabel.text = String(format: "LGV_TIMER-TIMER-TITLE-FORMAT".localizedVariant, indexPath.row + 1)
            }
            
            if let trafficLights = ret.trafficLights {
                let timerPrefs = LGV_Timer_AppDelegate.appDelegateObject.timerEngine[indexPath.row]
                trafficLights.isHidden = (.Podium != timerPrefs.displayMode)
            }
            
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
        let timerIndex = max(0, min(indexPath.row, LGV_Timer_AppDelegate.appDelegateObject.timerEngine.timers.count - 1))
        self.mainTabController.selectTimer(timerIndex)
        return nil
    }
    
    /* ################################################################## */
    /**
     Indicate that a row can be edited (for left-swipe delete).
     
     - parameter tableView: The table view being checked
     - parameter canEditRowAt: The indexpath of the row to be checked.
     
     - returns: true, as long as there are more than one timers.
     */
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return 1 < LGV_Timer_AppDelegate.appDelegateObject.timerEngine.timers.count
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
            let alertController = UIAlertController(title: "DELETE-HEADER".localizedVariant, message: String(format: "DELETE-MESSAGE-FORMAT".localizedVariant, indexPath.row + 1), preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "DELETE-OK-BUTTON".localizedVariant, style: UIAlertActionStyle.destructive, handler: {(_: UIAlertAction) in self.doADirtyDeedCheap(tableView, forRowAt: indexPath)})
            
            alertController.addAction(deleteAction)
            
            let cancelAction = UIAlertAction(title: "DELETE-CANCEL-BUTTON".localizedVariant, style: UIAlertActionStyle.default, handler: {(_: UIAlertAction) in self.dontDoADirtyDeedCheap(tableView)})
            
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
        // Just on the off chance we're in a non-traditional thread...
        DispatchQueue.main.async(execute: {
            self.mainTabController.deleteTimer(indexPath.row)
            LGV_Timer_AppDelegate.appDelegateObject.sendRecalculateMessage()
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
            tableView.isEditing = false
            tableView.reloadData()
            self.gussyUpTheMoreNavigation()
        })
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
