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
     This contains the iOS app instance of the Watch Delegate class.

     "There can only be one."
         - Connor MacLeod
     */
    var watchDelegate: RiValT_WatchDelegate = RiValT_WatchDelegate()
    
    /* ################################################################## */
    /**
     This is the shared timer model instance. We get it from the Watch Delegate instance.
     */
    var timerModel: TimerModel { self.watchDelegate.timerModel }
    
    /* ################################################################## */
    /**
     Easy access to the root-level nav controller (the multi-timer Group Editor Screen).
     */
    weak var groupEditorController: RiValT_GroupEditor_ViewController?
    
    /* ################################################################## */
    /**
     Called when the application has set up, and is preparing to "go live."
     
     - parameter inApplication: The application instance that this is delegated to (ignored).
     - parameter didFinishLaunchingWithOptions: The launch options (ignored)
     
     - returns: True (all the time).
     */
    func application(_ inApplication: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Self.appDelegateInstance = self
        return true
    }
    
    /* ################################################################## */
    /**
     This updates the stored timer model.
     */
    func updateSettings() {
        self.watchDelegate.updateSettings()
    }

    // MARK: UISceneSession Lifecycle

    /* ################################################################## */
    /**
     Returns a new scene configuration.
     
     - parameter inApplication: The application instance that this is delegated to (ignored).
     - parameter inConnectingSceneSession: The session we're generating a scene for.
     - parameter inOptions: The connection options (ignored).
     
     - returns: A new scene configuration for the session.
     */
    func application(_ inApplication: UIApplication, configurationForConnecting inConnectingSceneSession: UISceneSession, options inOptions: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: inConnectingSceneSession.role)
    }
}
