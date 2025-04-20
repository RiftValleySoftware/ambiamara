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
        
        /* ############################################################## */
        /**
         Returns the image associated with this state.
         */
        var image: UIImage? {
            switch self {
            case .numerical:
                return UIImage(named: "DisplayDigits")
            case .circular:
                return UIImage(named: "DisplayCircle")
            case .stoplights:
                return UIImage(named: "DisplayDots")
            }
        }
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
// MARK: - Special Bar Button for Display Selection -
/* ###################################################################################################################################### */
/**
 */
class DisplayBarButtonItem: UIBarButtonItem {
    /* ############################################################## */
    /**
     Display image cache
     */
    private var _cachedImage: UIImage?
    
    /* ############################################################## */
    /**
     The timer group associated with these settings.
     */
    weak var group: TimerGroup? {
        didSet {
            self.isEnabled = !self.isEnabled
            self.isEnabled = !self.isEnabled
        }
    }

    /* ################################################################## */
    /**
     The image to be displayed in the button.
     */
    override var image: UIImage? {
        get {
            self._cachedImage = self._cachedImage ?? self.group?.displayType.image?.resized(toMaximumSize: 24)
            return self._cachedImage
        }
        set { super.image = newValue }
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
    static let storyboardID = "RiValT_DisplaySettings_ViewController"
    
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
