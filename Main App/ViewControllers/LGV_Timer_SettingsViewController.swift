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
    @IBOutlet weak var clockDisplay: UILabel!
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
    @IBOutlet weak var showControlsSwitch: UISwitch!
    @IBOutlet weak var showControlsButton: UIButton!
    
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
        LGV_Timer_AppDelegate.appDelegateObject.timerListController = self
        super.viewDidLoad()
        self.gussyUpTheMoreNavigation()
        
        self.showControlsSwitch.isOn = LGV_Timer_AppDelegate.appDelegateObject.timerEngine.appState.showControlsInRunningTimer
    }
    
    /* ################################################################## */
    /**
     Called when the view has changed its layout.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let titleString = "LGV_TIMER-ABOUT-SHOWCONTROLS-BUTTON".localizedVariant
        
        let viewBounds = self.view.bounds
        
        if 480 > viewBounds.size.width {
            let font = UIFont.systemFont(ofSize: 14)
            let attributedTitle = NSAttributedString(string: titleString, attributes:[NSAttributedStringKey.font: font])
            self.showControlsButton.setAttributedTitle(attributedTitle, for: UIControlState.normal)
        } else {
            let font = UIFont.systemFont(ofSize: 20)
            let attributedTitle = NSAttributedString(string: titleString, attributes:[NSAttributedStringKey.font: font])
            self.showControlsButton.setAttributedTitle(attributedTitle, for: UIControlState.normal)
        }
    }
    
    /* ################################################################## */
    /**
     Called when the view is about to appear.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mainTabController.timerEngine.selectedTimerIndex = -1
        self.timerTableView.reloadData()
        LGV_Timer_AppDelegate.appDelegateObject.sendSelectMessage()
    }
        
    // MARK: - Internal Instance Methods

    // MARK: - IBAction Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the swictch is changed to display the timer controls in a running timer.
     
     :param: sender The switch object.
     */
    @IBAction func changedShowControlsSwitch(_ sender: UISwitch) {
        LGV_Timer_AppDelegate.appDelegateObject.timerEngine.appState.showControlsInRunningTimer = sender.isOn
        LGV_Timer_AppDelegate.appDelegateObject.timerEngine.savePrefs()
    }
    
    /* ################################################################## */
    /**
     Called when the button that acts as a label for the switch is hit. This toggles the switch.
     
     :param: sender The button object.
     */
    @IBAction func showControlsButtonHit(_ sender: Any) {
        self.showControlsSwitch.setOn(!self.showControlsSwitch.isOn, animated: true)
        LGV_Timer_AppDelegate.appDelegateObject.timerEngine.appState.showControlsInRunningTimer = self.showControlsSwitch.isOn
        LGV_Timer_AppDelegate.appDelegateObject.timerEngine.savePrefs()
    }
    
    /* ################################################################## */
    /**
     This is called when the "Add Timer" button is hit, requesting a new timer be created.
     
     :param: sender The button object.
     */
    @IBAction func addTimerButtonHit(_ sender: Any) {
        self.mainTabController.addNewTimer()
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
        return self.mainTabController.timerEngine.timers.count
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
                let timerPrefs = self.mainTabController.timerEngine[indexPath.row]
                clockView.text = TimeTuple(timerPrefs.timeSet).description
                clockView.textColor = (.Podium == timerPrefs.displayMode ? UIColor.white : self.mainTabController.timerEngine.colorLabelArray[timerPrefs.colorTheme].textColor!)
                if .Podium == timerPrefs.displayMode {
                    clockView.font = UIFont.boldSystemFont(ofSize: 24)
                } else {
                    if let titleFont = UIFont(name: "Let's Go Digital", size: 30) {
                        clockView.font = titleFont
                    }
                }
                clockView.setNeedsDisplay()
            }
            
            if let timerNameLabel = ret.timerNameLabel {
                let timerPrefs = self.mainTabController.timerEngine[indexPath.row]
                timerNameLabel.textColor = (.Podium == timerPrefs.displayMode ? UIColor.white : self.mainTabController.timerEngine.colorLabelArray[timerPrefs.colorTheme].textColor!)
                timerNameLabel.text = String(format: "LGV_TIMER-TIMER-TITLE-FORMAT".localizedVariant, indexPath.row + 1)
            }
            
            if let trafficLights = ret.trafficLights {
                let timerPrefs = self.mainTabController.timerEngine[indexPath.row]
                trafficLights.isHidden = (.Digital == timerPrefs.displayMode)
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
        let timerIndex = max(0, min(indexPath.row, self.mainTabController.timerEngine.timers.count - 1))
        self.mainTabController.timerEngine.selectedTimerIndex = timerIndex
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
        return 1 < self.mainTabController.timerEngine.timers.count
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
        tableView.isEditing = false
        self.mainTabController.deleteTimer(indexPath.row)
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
