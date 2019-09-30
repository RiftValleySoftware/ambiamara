/**
© Copyright 2019, The Great Rift Valley Software Company. All rights reserved.

This code is proprietary and confidential code,
It is NOT to be reused or combined into any application,
unless done so, specifically under written license from The Great Rift Valley Software Company.

The Great Rift Valley Software Company: https://riftvalleysoftware.com
*/

import WatchKit
import Foundation
import UserNotifications

/* ###################################################################################################################################### */
/**
 */
class NotificationController: WKUserNotificationInterfaceController {
    /* ################################################################## */
    /**
     */
    override init() {
        super.init()
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

    /* ################################################################## */
    /**
     This method is called when a notification needs to be presented.
     */
    override func didReceive(_ notification: UNNotification) {
    }
}
