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
    @IBOutlet weak var corporateBlurb: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
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
        let openLink = NSURL(string: "LGV_TIMER-ABOUT-LGV-BLURB-URI".localizedVariant)
        UIApplication.shared.open(openLink! as URL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
    
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        var appVersion = ""
        
        if let plistPath = Bundle.main.path(forResource: "Info", ofType: "plist") {
            if let plistDictionary = NSDictionary(contentsOfFile: plistPath) as? [String: Any] {
                if let versionTemp = plistDictionary["CFBundleShortVersionString"] as? NSString {
                    appVersion = versionTemp as String
                }
            }
        }
        
        self.corporateBlurb.text = self.corporateBlurb.text?.localizedVariant
        self.titleLabel.text = String(format: (self.titleLabel?.text?.localizedVariant)!, appVersion)
        self.lgvText.text = self.lgvText.text.localizedVariant
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
