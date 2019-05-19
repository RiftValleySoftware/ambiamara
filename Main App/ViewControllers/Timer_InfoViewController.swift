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
 */
class Timer_InfoViewController: A_TimerBaseViewController {
    /// This is the URI for the corporation. It is not localized.
    let corporateURI =   "https://riftvalleysoftware.com/work/ios-apps/ambiamara"
    /// This is the name of the corporation. It is not localized.
    let corporateName =   "The Great Rift Valley Software Company"
    
    /// The label with the "corporate blurb" text
    @IBOutlet weak var corporateBlurb: UILabel!
    /// The label for the title text
    @IBOutlet weak var labelForTitle: UILabel!
    /// The label for the corporate ID text
    @IBOutlet weak var rvsText: UITextView!
    
    /* ################################################################## */
    /**
     Called when the done button is hit.
     
     - parameter sender: ignored
     */
    @IBAction func doneButtonHit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /* ################################################################## */
    /**
     Called when the corporate button is hit
     
     - parameter sender: ignored
     */
    @IBAction func rvsButtonHit(_ sender: Any) {
        /// Helper function inserted by Swift 4.2 migrator.
        func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
            return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
        }
        
        let openLink = NSURL(string: self.corporateURI)
        UIApplication.shared.open(openLink! as URL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
    
    /* ################################################################## */
    /**
     Called upon the view load completion
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        var appName = ""
        var appVersion = ""

        if let plistPath = Bundle.main.path(forResource: "Info", ofType: "plist") {
            if let plistDictionary = NSDictionary(contentsOfFile: plistPath) as? [String: Any] {
                if let versionTemp = plistDictionary["CFBundleShortVersionString"] as? NSString {
                    appVersion = versionTemp as String
                }
                if let versionTemp = plistDictionary["CFBundleName"] as? NSString {
                    appName = versionTemp as String
                }
            }
        }

        self.corporateBlurb.text = self.corporateName
        self.labelForTitle.text = appName + " " + appVersion
        self.rvsText.text = self.rvsText.text.localizedVariant
    }
}
