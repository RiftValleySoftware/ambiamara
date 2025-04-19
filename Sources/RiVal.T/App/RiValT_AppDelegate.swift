/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit

/* ###################################################################################################################################### */
// MARK: - Main App Delegate Class -
/* ###################################################################################################################################### */
/**
 This is the app delegate for the main app.
 */
@main
class RiValT_AppDelegate: UIResponder, UIApplicationDelegate {
    /* ################################################################## */
    /**
     Accessor for this instance
     */
    static var appDelegateInstance: RiValT_AppDelegate?
    
    /* ################################################################## */
    /**
     "There can only be one."
         - Connor MacLeod
     */
    var timerModel = TimerModel()
    
    /* ################################################################## */
    /**
     Called when the application has set up, and is preparing to "go live."
     
     - parameter: The application instance that this is delegated to (ignored).
     - parameter didFinishLaunchingWithOptions: The launch options (ignored)
     
     - returns: True (all the time).
     */
    func application(_: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Self.appDelegateInstance = self
        setUpTimerModel()
        return true
    }
    
    /* ################################################################## */
    /**
     This initializes the timer model.
     */
    func setUpTimerModel() {
        self.timerModel.asArray = RiValT_Settings().timerModel
        if timerModel.allTimers.isEmpty {
            let timer = timerModel.createNewTimer(at: IndexPath(item: 0, section: 0))
            timer.isSelected = true
        }
        RiValT_Settings().cleanGroupSettings()
    }
    
    /* ################################################################## */
    /**
     This updates the stored timer model.
     */
    func updateSettings() {
        RiValT_Settings().timerModel = self.timerModel.asArray
    }

    // MARK: UISceneSession Lifecycle

    /* ################################################################## */
    /**
     Returns a new scene configuration.
     
     - parameter: The application instance that this is delegated to (ignored).
     - parameter inConnectingSceneSession: The session we're generating a scene for.
     
     - returns: A new scene configuration for the session.
     */
    func application(_: UIApplication, configurationForConnecting inConnectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: inConnectingSceneSession.role)
    }
}
