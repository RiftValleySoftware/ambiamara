/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit

/* ###################################################################################################################################### */
// MARK: - Main Scene Delegate Class -
/* ###################################################################################################################################### */
/**
 This is the scene delegate for the main app.
 */
class RiValT_SceneDelegate: UIResponder, UIWindowSceneDelegate {
    /* ################################################################## */
    /**
     Accessor for this instance
     */
    static var sceneDelegateInstance: RiValT_SceneDelegate?
    
    /* ################################################################## */
    /**
     The required window property.
     */
    var window: UIWindow?

    /* ################################################################## */
    /**
     - parameter inScene: The scene we're connecting.
     - parameter willConnectTo: The session we're connecting to (ignored).
     - parameter options: The connection options (ignored).
     */
    func scene(_ inScene: UIScene, willConnectTo: UISceneSession, options: UIScene.ConnectionOptions) {
        Self.sceneDelegateInstance = self
        guard nil != (inScene as? UIWindowScene) else { return }
    }
    
    /* ################################################################## */
    /**
     Called when the app has been backgrounded.
     
     - parameter inScene: The scene that's entering the background (ignored).
     */
    func sceneDidEnterBackground(_ inScene: UIScene) {
        RiValT_Settings.ephemeralFirstTime = true
    }
    
    /* ################################################################## */
    /**
     Called when the app has been launched from a URL scheme.
     
     - parameter inScene: The scene that's entering the background (ignored).
     - parameter inURLContexts: The URL context.
     */
    func scene(_ inScene: UIScene, openURLContexts inURLContexts: Set<UIOpenURLContext>) {
        guard let url = inURLContexts.first?.url,
              "rivalt" == url.scheme,
              let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              nil != windowScene.delegate as? RiValT_SceneDelegate
        else { return }

        #if DEBUG
            print("Opened from URL: \(url)")
        #endif

        RiValT_AppDelegate.appDelegateInstance?.updateSettings()
    }

    /* ################################################################## */
    /**
     Called when the app is coming to the fore.
     
     - parameter inScene: The scene that's entering the foreground (ignored).
     */
    func sceneWillEnterForeground(_ inScene: UIScene) {
        RiValT_AppDelegate.appDelegateInstance?.updateSettings()
        RiValT_AppDelegate.appDelegateInstance?.groupEditorController?.checkForFastForward()
    }
}
