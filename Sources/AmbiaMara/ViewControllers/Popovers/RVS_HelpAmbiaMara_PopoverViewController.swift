/*
 © Copyright 2018-2022, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_Generic_Swift_Toolbox
import RVS_MaskButton

/* ###################################################################################################################################### */
// MARK: - Help Popover View Controller -
/* ###################################################################################################################################### */
/**
 This controls the popover that is displayed, when touching the mode title button.
 */
class RVS_HelpAmbiaMara_PopoverViewController: UIViewController {
    /* ################################################################## */
    /**
     The storyboard ID for this controller.
     */
    static let storyboardID = "RVS_HelpAmbiaMara_PopoverViewController"
    
    /* ################################################################## */
    /**
     This is how much leeway to give on each side, to account for the popover inset.
     */
    static let sideOffsetInDisplayUnits = CGFloat(40)
    
    /* ################################################################## */
    /**
     The string that will be displayed in the popover.
     */
    var descriptionString: String = "ERROR"
    
    /* ################################################################## */
    /**
     The label that will display the description, in the popover.
     */
    @IBOutlet weak var descriptionLabel: UILabel?
    
    /* ################################################################## */
    /**
     */
    override var preferredContentSize: CGSize {
        get {
            guard let descriptionLabel = descriptionLabel,
                  let text = descriptionLabel.text,
                  let font = descriptionLabel.font
            else { return super.preferredContentSize }
            
            let calcString = NSAttributedString(string: text, attributes: [.font: font])
            let cropRect = calcString.boundingRect(with: CGSize.init(width: super.preferredContentSize.width - (Self.sideOffsetInDisplayUnits * 2),
                                                                     height: CGFloat.greatestFiniteMagnitude),
                                                   options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)

            return CGSize(width: super.preferredContentSize.width, height: cropRect.size.height + (Self.sideOffsetInDisplayUnits * 2))
        }
        set { super.preferredContentSize = newValue }
    }
    
    /* ################################################################## */
    /**
     Called when the view loads.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel?.text = descriptionString
    }
}
