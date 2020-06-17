/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import WatchKit
import Foundation

/* ###################################################################################################################################### */
/**
 This is the main Watch app interface controller class.
 */
class Timer_InterfaceController: WKInterfaceController {
    /* ################################################################## */
    /**
     Called when the app is first woken up.
     
     - parameter withContext: The data passed into the app as it was rousted out of bed.
     */
    override func awake(withContext inContext: Any?) {
        super.awake(withContext: inContext)
    }
    
    /* ################################################################## */
    /**
     This method is called when watch view controller is about to be visible to user
     */
    override func willActivate() {
        super.willActivate()
    }
    
    /* ################################################################## */
    /**
     This method is called when watch view controller is no longer visible
     */
    override func didDeactivate() {
        super.didDeactivate()
    }
}
