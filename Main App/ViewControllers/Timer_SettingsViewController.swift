/**
 © Copyright 2018, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

/* ###################################################################################################################################### */

import UIKit

/* ###################################################################################################################################### */
/**
 This is a controller that genericizes the labels
 */
class SettingsTimerTableCell: UITableViewCell {
    /// The label that displays the clock time
    @IBOutlet weak var clockDisplay: UILabel!
    /// The label that displays the name of the timer
    @IBOutlet weak var timerNameLabel: UILabel!
    /// The little traffic lights image that may be displayed
    @IBOutlet weak var trafficLights: UIImageView!
}

/* ###################################################################################################################################### */
/**
 Really just a placeholder
 */
class TimerSettingsNavController: UINavigationController {
}

/* ###################################################################################################################################### */
/**
 This is the main controller class for the "global" settings tab screen.
 */
class Timer_SettingsViewController: A_TimerBaseViewController, UITableViewDelegate, UITableViewDataSource {
    /* ################################################################################################################################## */
    // MARK: - IB Properties
    /* ################################################################################################################################## */
    /// The timer list is shown here
    @IBOutlet weak var timerTableView: UITableView!
    /// The title item for our navitem
    @IBOutlet weak var navItemTitle: UINavigationItem!
    /// The info bar button item
    @IBOutlet weak var navInfo: UIBarButtonItem!
    /// The plus button
    @IBOutlet weak var navAdd: UIBarButtonItem!
    /// The switch for showing the controls
    @IBOutlet weak var showControlsSwitch: UISwitch!
    /// The button label for that switch
    @IBOutlet weak var showControlsButton: UIButton!
    /// The ID of the info segue
    private let _info_segue_id = "segue-id-info"
    
    /* ################################################################################################################################## */
    // MARK: - Internal Instance Properties
    /* ################################################################################################################################## */
    /// The main tab controller
    var mainTabController: Timer_MainTabController! = nil
    
    /* ################################################################################################################################## */
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view has finished loading.
     
     We use this method to establish all the localized strings, and restore the controls to reflect the stored state.
     */
    override func viewDidLoad() {
        navItemTitle.title = navItemTitle.title?.localizedVariant
        mainTabController = tabBarController as? Timer_MainTabController
        Timer_AppDelegate.appDelegateObject.timerListController = self
        super.viewDidLoad()
        gussyUpTheMoreNavigation()
        
        showControlsSwitch.isOn = Timer_AppDelegate.appDelegateObject.timerEngine.appState.showControlsInRunningTimer
    }
    
    /* ################################################################## */
    /**
     Called when the view has changed its layout.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let titleString = "LGV_TIMER-ABOUT-SHOWCONTROLS-BUTTON".localizedVariant
        
        let viewBounds = view.bounds
        
        if 480 > viewBounds.size.width {
            let font = UIFont.systemFont(ofSize: 14)
            let attributedTitle = NSAttributedString(string: titleString, attributes: [NSAttributedString.Key.font: font])
            showControlsButton.setAttributedTitle(attributedTitle, for: UIControl.State.normal)
        } else {
            let font = UIFont.systemFont(ofSize: 20)
            let attributedTitle = NSAttributedString(string: titleString, attributes: [NSAttributedString.Key.font: font])
            showControlsButton.setAttributedTitle(attributedTitle, for: UIControl.State.normal)
        }
    }
    
    /* ################################################################## */
    /**
     Called when the view is about to appear.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainTabController.timerEngine.selectedTimerIndex = -1
        timerTableView.reloadData()
        Timer_AppDelegate.appDelegateObject.sendSelectMessage()
    }

    /* ################################################################################################################################## */
    // MARK: - IBAction Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the swictch is changed to display the timer controls in a running timer.
     
     - parameter sender: The switch object.
     */
    @IBAction func changedShowControlsSwitch(_ sender: UISwitch) {
        Timer_AppDelegate.appDelegateObject.timerEngine.appState.showControlsInRunningTimer = sender.isOn
        Timer_AppDelegate.appDelegateObject.timerEngine.savePrefs()
    }
    
    /* ################################################################## */
    /**
     Called when the button that acts as a label for the switch is hit. This toggles the switch.
     
     - parameter sender: The button object.
     */
    @IBAction func showControlsButtonHit(_ sender: Any) {
        showControlsSwitch.setOn(!showControlsSwitch.isOn, animated: true)
        Timer_AppDelegate.appDelegateObject.timerEngine.appState.showControlsInRunningTimer = showControlsSwitch.isOn
        Timer_AppDelegate.appDelegateObject.timerEngine.savePrefs()
    }
    
    /* ################################################################## */
    /**
     This is called when the "Add Timer" button is hit, requesting a new timer be created.
     
     - parameter sender: The button object.
     */
    @IBAction func addTimerButtonHit(_ sender: Any) {
        mainTabController.addNewTimer()
        timerTableView.reloadData()
        gussyUpTheMoreNavigation()
    }
    
    /* ################################################################## */
    /**
     This is called when the info button is hit, requesting that we bring in the information screen.
     
     - parameter sender: The button object.
     */
    @IBAction func infoButtonHit(_ sender: Any) {
        performSegue(withIdentifier: _info_segue_id, sender: nil)
    }
    
    /* ################################################################################################################################## */
    // MARK: - UITableViewDataSource Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     - parameter tableView: The UITableView object requesting the view
     - parameter numberOfRowsInSection: The section index (0-based).
     
     - returns the number of rows to display.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainTabController.timerEngine.timers.count
    }
    
    /* ################################################################## */
    /**
     This is the routine that creates a new table row for the Timer indicated by the index.
     
     - parameter tableView: The UITableView object requesting the view
     - parameter cellForRowAt: The IndexPath of the requested cell.
     
     - returns a nice, shiny cell (or sets the state of a reused one).
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        assert(mainTabController.timerEngine.count > indexPath.row && 0 <= indexPath.row)
        if let ret = tableView.dequeueReusableCell(withIdentifier: "SingleTimerCell") as? SettingsTimerTableCell {
            if let clockView = ret.clockDisplay, let timerNameLabel = ret.timerNameLabel {
                let timerName = String(format: "LGV_TIMER-TIMER-TITLE-FORMAT".localizedVariant, indexPath.row + 1)
                
                let timerPrefs = mainTabController.timerEngine[indexPath.row]
                clockView.text = TimeInstance(timerPrefs.timeSet).description
                if .Podium == timerPrefs.displayMode {
                    clockView.textColor = UIColor.white
                    timerNameLabel.textColor = UIColor.white
                    clockView.font = UIFont.boldSystemFont(ofSize: 24)
                } else {
                    if let backgroundColor = mainTabController.timerEngine.colorLabelArray[timerPrefs.colorTheme].backgroundColor {
                        clockView.textColor = backgroundColor
                        timerNameLabel.textColor = backgroundColor
                    }
                    if let titleFont = UIFont(name: "Let's Go Digital", size: 30) {
                        clockView.font = titleFont
                    }
                }
                
                timerNameLabel.text = timerName
                ret.accessibilityLabel = timerName + " (" + timerPrefs.setSpeakableTime + ")"
                clockView.setNeedsDisplay()
            }
            
            if let trafficLights = ret.trafficLights {
                let timerPrefs = mainTabController.timerEngine[indexPath.row]
                trafficLights.isHidden = (.Digital == timerPrefs.displayMode)
            }
            
            // Add accessibility strings.
            switch mainTabController.timerEngine[indexPath.row].displayMode {
            case .Podium:
                ret.accessibilityLabel = (ret.accessibilityLabel ?? "") + " " + "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-PODIUM-LABEL".localizedVariant
                ret.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-PODIUM-HINT".localizedVariant
            case .Digital:
                ret.accessibilityLabel = (ret.accessibilityLabel ?? "") + " " + "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-DIGITAL-LABEL".localizedVariant
                ret.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-DIGITAL-HINT".localizedVariant
            case .Dual:
                ret.accessibilityLabel = (ret.accessibilityLabel ?? "") + " " + "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-DUAL-LABEL".localizedVariant
                ret.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-TABLE-ROW-DUAL-HINT".localizedVariant
            }

            return ret
        } else {
            return UITableViewCell()
        }
    }
    
    /* ################################################################################################################################## */
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
        let timerIndex = max(0, min(indexPath.row, mainTabController.timerEngine.timers.count - 1))
        mainTabController.timerEngine.selectedTimerIndex = timerIndex
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
        return 1 < mainTabController.timerEngine.timers.count
    }
    
    /* ################################################################## */
    /**
     Called to do a delete action.
     
     - parameter tableView: The table view being checked
     - parameter commit: The action to perform.
     - parameter forRowAt: The indexpath of the row to be deleted.
     */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let alertController = UIAlertController(title: "DELETE-HEADER".localizedVariant, message: String(format: "DELETE-MESSAGE-FORMAT".localizedVariant, indexPath.row + 1), preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "DELETE-OK-BUTTON".localizedVariant, style: UIAlertAction.Style.destructive, handler: {(_: UIAlertAction) in self.doADirtyDeedCheap(tableView, forRowAt: indexPath)})
            
            alertController.addAction(deleteAction)
            
            let cancelAction = UIAlertAction(title: "DELETE-CANCEL-BUTTON".localizedVariant, style: UIAlertAction.Style.default, handler: {(_: UIAlertAction) in self.dontDoADirtyDeedCheap(tableView)})
            
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
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
        mainTabController.deleteTimer(indexPath.row)
    }
    
    /* ################################################################## */
    /**
     Called to cancel a delete action.
     
     - parameter tableView: The table view being checked
     */
    func dontDoADirtyDeedCheap(_ tableView: UITableView) {
        tableView.isEditing = false
    }
    
    /* ################################################################################################################################## */
    /**
     This method adds all the accessibility stuff.
     */
    override func addAccessibilityStuff() {
        super.addAccessibilityStuff()
        
        navInfo.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-INFO-LABEL".localizedVariant
        navInfo.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-INFO-HINT".localizedVariant
        navAdd.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-ADD-LABEL".localizedVariant
        navAdd.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-ADD-HINT".localizedVariant
        
        timerTableView.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-TABLE-LABEL".localizedVariant
        timerTableView.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-TABLE-HINT".localizedVariant

        showControlsSwitch.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-SWITCH-LABEL".localizedVariant
        showControlsSwitch.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-SWITCH-HINT".localizedVariant
        
        showControlsButton.accessibilityLabel = "LGV_TIMER-ACCESSIBILITY-SWITCH-LABEL".localizedVariant
        showControlsButton.accessibilityHint = "LGV_TIMER-ACCESSIBILITY-SWITCH-HINT".localizedVariant
        
        UIAccessibility.post(notification: .layoutChanged, argument: timerTableView)
    }
}
