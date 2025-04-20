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
// MARK: - Special Bar Button for Sound Selection -
/* ###################################################################################################################################### */
/**
 */
class SoundBarButtonItem: BaseCustomBarButtonItem {
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
            super.image = super.image ?? self.group?.soundType.image?.resized(toMaximumSize: 24)
            return super.image
        }
        set { super.image = newValue }
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
        self.overrideUserInterfaceStyle = isDarkMode ? .light : .dark
        
        super.viewDidLoad()
        
        guard let groupIndex = self.group?.index else { return }
        
        if 1 < timerModel.count {
            self.navigationItem.title = String(format: "SLUG-SETTINGS-FORMAT".localizedVariant, groupIndex + 1)
        } else {
            self.navigationItem.title = "SLUG-GROUP-SETTINGS".localizedVariant
        }
    }
}
