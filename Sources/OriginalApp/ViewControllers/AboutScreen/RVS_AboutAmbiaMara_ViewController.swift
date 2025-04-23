/*
 © Copyright 2018-2022, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_Generic_Swift_Toolbox
import RVS_UIKit_Toolbox

/* ###################################################################################################################################### */
// MARK: - About AmbiaMara Screen View Controller -
/* ###################################################################################################################################### */
/**
 This is the view controller for the about screen.
 */
class RVS_AboutAmbiaMara_ViewController: RVS_AmbiaMara_BaseViewController {
    /* ################################################################## */
    /**
     The app icon is displayed here.
    */
    @IBOutlet weak var appIconImageView: UIImageView?
    
    /* ################################################################## */
    /**
     The version is displayed here.
    */
    @IBOutlet weak var versionLabel: UILabel?
    
    /* ################################################################## */
    /**
     This is the main about text.
    */
    @IBOutlet weak var aboutText: UITextView?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RVS_AboutAmbiaMara_ViewController {
    /* ################################################################## */
    /**
     Called when the hierarchy has loaded. We set up the text and localization.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = navigationItem.title?.localizedVariant
        if let image = Bundle.main.appIcon {
            appIconImageView?.image = image
        } else {
            appIconImageView?.isHidden = true
        }
        versionLabel?.text =  String(format: "%@ (%@)", Bundle.main.appVersionString, Bundle.main.appVersionBuildString)
        guard let file = Bundle.main.url(forResource: "Instructions", withExtension: "txt"),
              let contents = try? String(contentsOf: file, encoding: String.Encoding.utf8 )
        else { return }
      
        aboutText?.text = contents
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillAppear(_ inAnimated: Bool) {
        super.viewWillAppear(inAnimated)
        navigationController?.isNavigationBarHidden = false
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillDisappear(_ inAnimated: Bool) {
        super.viewWillDisappear(inAnimated)
        navigationController?.isNavigationBarHidden = true
    }
}
