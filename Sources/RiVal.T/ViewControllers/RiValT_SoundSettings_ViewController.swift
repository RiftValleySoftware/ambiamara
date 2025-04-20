/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_Generic_Swift_Toolbox
import RVS_UIKit_Toolbox

/* ###################################################################################################################################### */
// MARK: - Extension for Integrating Persistent Settings -
/* ###################################################################################################################################### */
extension TimerGroup {
    /* ################################################################## */
    /**
     Accessor for the group settings.
     */
    private var _storedSettings: [String: any Hashable] {
        get { RiValT_Settings().groupSettings[self.id.uuidString] ?? [:] }
        set { RiValT_Settings().groupSettings[self.id.uuidString] = newValue }
    }
    
    /* ################################################################## */
    /**
     The sound file for the alarm that is played after the last timer in the group finishes.
     */
    var endAlarmFileName: String? {
        get { _storedSettings["endAlarmFileName"] as? String }
        set { _storedSettings["endAlarmFileName"] = newValue }
    }
    
    /* ################################################################## */
    /**
     The sound file for the alarm that is played when one of the earlier timers finishes, and cascades to the next.
     */
    var transitionAlarmFileName: String? {
        get { _storedSettings["transitionAlarmFileName"] as? String }
        set { _storedSettings["transitionAlarmFileName"] = newValue }
    }
}

/* ###################################################################################################################################### */
// MARK: - The Main View Controller for the Group Sound Settings Editor -
/* ###################################################################################################################################### */
/**
 */
class RiValT_SoundSettings_ViewController: RiValT_Base_ViewController {
    /* ############################################################## */
    /**
     The storyboard ID for instantiating the class.
     */
    static let storyboardID = "RiValT_SoundSettings_ViewController"
    
    /* ############################################################## */
    /**
     The timer group associated with these settings.
     */
    weak var group: TimerGroup?
    
    /* ############################################################## */
    /**
     Called when the view has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let groupIndex = self.group?.index else { return }
        
        if 1 < timerModel.count {
            self.navigationItem.title = String(format: "SLUG-SETTINGS-FORMAT".localizedVariant, groupIndex + 1)
        } else {
            self.navigationItem.title = "SLUG-GROUP-SETTINGS".localizedVariant
        }
    }
}
