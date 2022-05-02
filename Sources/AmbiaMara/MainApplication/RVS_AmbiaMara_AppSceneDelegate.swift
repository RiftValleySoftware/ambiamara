/*
 © Copyright 2018-2022, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit

/* ###################################################################################################################################### */
// MARK: - Main App and Scene Delegate Class -
/* ###################################################################################################################################### */
/**
 */
@UIApplicationMain
class RVS_AmbiaMara_AppSceneDelegate: UIResponder {
    /* ############################################################## */
    /**
     The required window property.
     */
    var window: UIWindow?
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension RVS_AmbiaMara_AppSceneDelegate {
    /* ################################################################## */
    /**
     Easy access to our navigation controller.
     */
    var navigationController: UINavigationController? {
        var ret: UINavigationController?
        
        if let temp = window?.rootViewController as? UINavigationController {
            ret = temp
        } else {
            for scene in UIApplication.shared.connectedScenes where .unattached != scene.activationState && .background != scene.activationState {
                if let temp = ((scene as? UIWindowScene)?.delegate as? UIWindowSceneDelegate)?.window??.rootViewController as? UINavigationController {
                    ret = temp
                    break
                }
            }
        }
        
        return ret
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RVS_AmbiaMara_AppSceneDelegate {
    /* ################################################################## */
    /**
     This closes any open popovers.
     */
    func cleanPopover() {
        DispatchQueue.main.async { [weak self] in
            if let viewControllers = self?.navigationController?.viewControllers,
               let setupScreen = viewControllers.first as? RVS_SetTimerAmbiaMara_ViewController,
               let popover = setupScreen.currentPopover {
                setupScreen.currentPopover = nil
                popover.dismiss(animated: false)
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: UIApplicationDelegate Conformance
/* ###################################################################################################################################### */
extension RVS_AmbiaMara_AppSceneDelegate: UIApplicationDelegate {
    /* ############################################################## */
    /**
     - parameter: The application instance (ignored).
     - parameter didFinishLaunchingWithOptions: The launch options (ignored).
     */
    func application(_: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool { true }

    /* ############################################################## */
    /**
     - parameter: The application instance (ignored).
     - parameter configurationForConnecting: The connection configuration.
     - parameter options: Connection options (ignored).
     */
    func application(_: UIApplication, configurationForConnecting inConnectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: inConnectingSceneSession.role)
    }
}

/* ###################################################################################################################################### */
// MARK: UIWindowSceneDelegate Conformance
/* ###################################################################################################################################### */
extension RVS_AmbiaMara_AppSceneDelegate: UIWindowSceneDelegate {
    /* ################################################################## */
    /**
     Called when the app is resigning active
     - parameter: The scene instance (ignored).
     */
    func sceneWillResignActive(_: UIScene) {
        cleanPopover()
    }
    
    /* ################################################################## */
    /**
     Called when the app goes into the background.
     - parameter: The scene instance (ignored).
     */
    func sceneDidEnterBackground(_: UIScene) {
        cleanPopover()
    }
}
