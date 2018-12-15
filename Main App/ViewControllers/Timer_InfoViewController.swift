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
class Timer_InfoViewController: TimerBaseViewController {
    /// This is the URI for the corporation. It is not localized.
    let corporateURI =   "https://riftvalleysoftware.com"
    /// This is the name of the corporation. It is not localized.
    let corporateName =   "The Great Rift Valley Software Company"
    
    @IBOutlet weak var corporateBlurb: UILabel!
    @IBOutlet weak var labelForTitle: UILabel!
    @IBOutlet weak var lgvText: UITextView!
    
    /* ################################################################## */
    /**
     */
    @IBAction func doneButtonHit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func lgvButtonHit(_ sender: Any) {
        let openLink = NSURL(string: self.corporateURI)
        UIApplication.shared.open(openLink! as URL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
    
    /* ################################################################## */
    /**
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
                if let versionTemp = plistDictionary["CFBundleDisplayName"] as? NSString {
                    appName = versionTemp as String
                }
            }
        }

        self.corporateBlurb.text = self.corporateName
        self.titleLabel.text = appName + " " + appVersion
        self.lgvText.text = self.lgvText.text.localizedVariant
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
