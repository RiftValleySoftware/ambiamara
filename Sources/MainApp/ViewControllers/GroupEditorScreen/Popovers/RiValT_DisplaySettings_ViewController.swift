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
// MARK: - The Main View Controller for the Group Display Settings Editor -
/* ###################################################################################################################################### */
/**
 This is displayed in a popover, and allows the user to select which display type the group will use.
 
 It presents a segmented switch at the top, with three choices, and a larger preview area, directly below the switch. The preview area shows a "mockup" of the selected display type.
 
 It can be:
 
 - Numerical
 
 - Circular
 
 - Stoplights
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
        guard let numericalImage = TimerGroup.DisplayType.numerical.image?.resized(toMaximumSize: 20),
              let ringImage = TimerGroup.DisplayType.circular.image?.resized(toMaximumSize: 20),
              let dotsImage = TimerGroup.DisplayType.stoplights.image?.resized(toMaximumSize: 20)
        else { return }
        
        numericalImage.isAccessibilityElement = true
        numericalImage.accessibilityLabel = "SLUG-ACC-DISPLAY-SETTINGS-NUMERICAL-LABEL".localizedVariant
        numericalImage.accessibilityHint = "SLUG-ACC-DISPLAY-SETTINGS-NUMERICAL-HINT".localizedVariant
        ringImage.isAccessibilityElement = true
        ringImage.accessibilityLabel = "SLUG-ACC-DISPLAY-SETTINGS-CIRCULAR-LABEL".localizedVariant
        ringImage.accessibilityHint = "SLUG-ACC-DISPLAY-SETTINGS-CIRCULAR-HINT".localizedVariant
        dotsImage.isAccessibilityElement = true
        dotsImage.accessibilityLabel = "SLUG-ACC-DISPLAY-SETTINGS-STOPLIGHTS-LABEL".localizedVariant
        dotsImage.accessibilityHint = "SLUG-ACC-DISPLAY-SETTINGS-STOPLIGHTS-HINT".localizedVariant

        self.displaySelectionSegmentedControl?.setImage(numericalImage, forSegmentAt: 0)
        self.displaySelectionSegmentedControl?.setImage(ringImage, forSegmentAt: 1)
        self.displaySelectionSegmentedControl?.setImage(dotsImage, forSegmentAt: 2)
        
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
        self.updateSettings()
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
        self.selectionHaptic()
        selectDisplayType()
    }
}
