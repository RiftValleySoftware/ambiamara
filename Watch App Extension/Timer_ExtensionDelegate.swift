/**
© Copyright 2019, The Great Rift Valley Software Company. All rights reserved.

This code is proprietary and confidential code,
It is NOT to be reused or combined into any application,
unless done so, specifically under written license from The Great Rift Valley Software Company.

The Great Rift Valley Software Company: https://riftvalleysoftware.com
*/

import WatchKit

/* ###################################################################################################################################### */
/**
 The main extension delegate class for the Watch app.
 */
class Timer_ExtensionDelegate: NSObject, WKExtensionDelegate {
    /* ################################################################## */
    /**
     Called just after the app has finished its launch setup.
     */
    func applicationDidFinishLaunching() {
    }

    /* ################################################################## */
    /**
     Called just before the app is to become active.
     */
    func applicationDidBecomeActive() {
    }

    /* ################################################################## */
    /**
     Called just before the app is to resign its active status.
     */
    func applicationWillResignActive() {
    }

    /* ################################################################## */
    /**
     Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
     
     - parameter inBackgroundTasks: The various background task orders sent in.
     */
    func handle(_ inBackgroundTasks: Set<WKRefreshBackgroundTask>) {
        inBackgroundTasks.forEach {
            // Use a switch statement to check the task type
            switch $0 {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                $0.setTaskCompletedWithSnapshot(false)
            }
        }
    }

}
