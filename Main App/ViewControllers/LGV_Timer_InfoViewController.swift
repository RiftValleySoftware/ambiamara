//
//  LGV_Timer_InfoViewController.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 6/4/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//
/* ###################################################################################################################################### */

import UIKit

/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_InfoViewController: LGV_Timer_TimerBaseViewController {
    @IBOutlet weak var longBlurb: UITextView!
    @IBOutlet weak var lgvBlurb1Label: UILabel!
    @IBOutlet weak var lgvBlurb: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var instructionsLinkButton: UIButton!
    
    /* ################################################################## */
    /**
     */
    @IBAction func instructionsLinkHit(_ sender: UIButton) {
        let openLink = NSURL(string: (sender.title(for: UIControlState.normal)?.localizedVariant)!)
        UIApplication.shared.open(openLink! as URL, options: [:], completionHandler: nil)
    }
    
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
        let openLink = NSURL(string : "LGV_TIMER-ABOUT-LGV-INSTRUCTIONS-URI".localizedVariant)
        UIApplication.shared.open(openLink! as URL, options: [:], completionHandler: nil)
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
        
        self.titleLabel.text = String(format: (self.titleLabel?.text?.localizedVariant)!, appVersion)
        self.longBlurb.text = self.longBlurb.text.localizedVariant
        self.doneButton.setTitle(self.doneButton.title(for: .normal)?.localizedVariant, for: .normal)
        self.instructionsLinkButton.setTitle(self.instructionsLinkButton.title(for: .normal)?.localizedVariant, for: .normal)

        self.lgvBlurb1Label.text = self.lgvBlurb1Label.text?.localizedVariant
        self.lgvBlurb.setTitle(self.lgvBlurb.title(for: UIControlState.normal)?.localizedVariant, for: UIControlState.normal)
    }
}
