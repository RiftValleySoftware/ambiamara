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
    /* ################################################################################################################################## */
    // MARK: - Extension for Integrating Persistent Settings -
    /* ################################################################################################################################## */
    /**
     This enum defines one of the three different display types for a running timer.
     */
    enum DisplayType: String {
        /* ############################################################## */
        /**
         This displays massive "LED" numbers.
         */
        case numerical

        /* ############################################################## */
        /**
         This displays a circle, winding down.
         */
        case circular
        
        /* ############################################################## */
        /**
         This displays three "stoplights."
         */
        case stoplights
    }
    
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
     This defines the type of display to use for the running timer.
     */
    var displayType: DisplayType {
        get {
            if let dType = _storedSettings["displayType"] as? String,
               let ret = DisplayType(rawValue: dType) {
                return ret
            }
            return .numerical
        }
        set { _storedSettings["displayType"] = newValue.rawValue }
    }
}

/* ###################################################################################################################################### */
// MARK: - The Main View Controller for the Group Display Settings Editor -
/* ###################################################################################################################################### */
/**
 */
class RiValT_DisplaySettings_ViewController: RiValT_Base_ViewController {
    /* ############################################################## */
    /**
     The storyboard ID for instantiating the class.
     */
    static let storyboardID = "RiValT_GroupSettings_ViewController"
    
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
