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
    enum DisplayType: String, CaseIterable {
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
        get {
            RiValT_Settings().groupSettings[self.id.uuidString] ?? [:]
        }
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
class BaseCustomBarButtonItem: UIBarButtonItem {
}

/* ###################################################################################################################################### */
// MARK: - Special Bar Button for Display Selection -
/* ###################################################################################################################################### */
/**
 */
class DisplayBarButtonItem: BaseCustomBarButtonItem {
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
            super.image = super.image ?? self.group?.displayType.image?.resized(toMaximumSize: 24)
            return super.image
        }
        set { super.image = newValue }
    }
}

/* ###################################################################################################################################### */
// MARK: - The Main View Controller for the Group Display Settings Editor -
/* ###################################################################################################################################### */
/**
 This is displayed in a popover, and allows the user to select which display type the group will use.
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
     The segmented control that allows selection of the display type.
     */
    @IBOutlet weak var displaySelectionSegmentedControl: UISegmentedControl?
    
    /* ############################################################## */
    /**
     The image that is shown, representing the display.
     */
    @IBOutlet weak var previewImageView: UIImageView?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RiValT_DisplaySettings_ViewController {
    /* ############################################################## */
    /**
     The size of the popover.
     */
    override var preferredContentSize: CGSize {
        get { CGSize(width: 270, height: 200) }
        set { super.preferredContentSize = newValue }
    }

    /* ############################################################## */
    /**
     Called when the view has loaded.
     */
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = false
        self.overrideUserInterfaceStyle = isDarkMode ? .light : .dark
        
        super.viewDidLoad()
        
        guard let groupIndex = self.group?.index else { return }
        
        if 1 < timerModel.count {
            self.navigationItem.title = String(format: "SLUG-DISPLAY-FORMAT".localizedVariant, groupIndex + 1)
        } else {
            self.navigationItem.title = "SLUG-DISPLAY-GROUP-SETTINGS".localizedVariant
        }
        
        setUpSelectionControl()
        selectDisplayType()
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RiValT_DisplaySettings_ViewController {
    /* ############################################################## */
    /**
     Sets up the main selection control.
     */
    func setUpSelectionControl() {
        self.displaySelectionSegmentedControl?.setImage(TimerGroup.DisplayType.numerical.image?.resized(toMaximumSize: 20), forSegmentAt: 0)
        self.displaySelectionSegmentedControl?.setImage(TimerGroup.DisplayType.circular.image?.resized(toMaximumSize: 20), forSegmentAt: 1)
        self.displaySelectionSegmentedControl?.setImage(TimerGroup.DisplayType.stoplights.image?.resized(toMaximumSize: 20), forSegmentAt: 2)
        
        self.displaySelectionSegmentedControl?.subviews.flatMap { $0.subviews }.forEach { subview in
            if let imageView = subview as? UIImageView, imageView.frame.width > 5 {
                imageView.contentMode = .scaleAspectFit
            }
        }
        
        switch self.group?.displayType {
        case .circular:
            self.displaySelectionSegmentedControl?.selectedSegmentIndex = 1
        case .stoplights:
            self.displaySelectionSegmentedControl?.selectedSegmentIndex = 2
        default:
            self.displaySelectionSegmentedControl?.selectedSegmentIndex = 0
        }
    }
    
    /* ############################################################## */
    /**
     Selects which image to display in the main area.
     */
    func selectDisplayType() {
        guard let selectedIndex = self.self.displaySelectionSegmentedControl?.selectedSegmentIndex else { return }
        var image: UIImage?
        switch selectedIndex {
        case 1:
            image = UIImage(named: TimerGroup.DisplayType.circular.rawValue)
            self.group?.displayType = TimerGroup.DisplayType.circular
        case 2:
            image = UIImage(named: TimerGroup.DisplayType.stoplights.rawValue)
            self.group?.displayType = TimerGroup.DisplayType.stoplights
        default:
            image = UIImage(named: TimerGroup.DisplayType.numerical.rawValue)
            self.group?.displayType = TimerGroup.DisplayType.numerical
        }
        self.previewImageView?.image = image
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension RiValT_DisplaySettings_ViewController {
    /* ############################################################## */
    /**
     Called when the selection is changed.
     
     - parameter: ignored.
     */
    @IBAction func displaySelectionChanged(_: Any) {
        selectDisplayType()
    }
}
