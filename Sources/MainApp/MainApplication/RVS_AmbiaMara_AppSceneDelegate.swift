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
 The main app/scene delegate (I combine them).
 */
@UIApplicationMain
class RVS_AmbiaMara_AppSceneDelegate: UIResponder {
    /* ############################################################## */
    /**
     Quick accessor for the delegate instance.
     */
    class var appDelegateInstance: RVS_AmbiaMara_AppSceneDelegate? { UIApplication.shared.delegate as? RVS_AmbiaMara_AppSceneDelegate }
    
    /* ############################################################## */
    /**
     The required window property.
     */
    var window: UIWindow?
    
    /* ############################################################## */
    /**
     This handles communications with the Watch app.
     */
    private var _watchDelegate: RVS_WatchDelegate?
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
     This closes any open popovers, and also stops any alarms.
     */
    func cleanPopoverAndStopAlarm() {
        DispatchQueue.main.async { [weak self] in
           (self?.navigationController?.viewControllers.first as? RVS_SetTimerWrapper)?.currentDisplayedPopover?.dismiss(animated: false)
           (self?.navigationController?.topViewController as? RVS_RunningTimerAmbiaMara_ViewController)?.stopAlarm()
        }
    }

    /* ################################################################## */
    /**
     This sends a sync pulse to the phone.
     
     - parameter: timerStartTime: The date at which the timer began its countdown.
     - parameter: timerTotalTime: The number of seconds that the timer started with.
     - parameter: timerWarnTime: The number of seconds that the timer considers into the "warning" state. Optional. If left out, the warning time is ignored.
     - parameter: timerFinalTime: The number of seconds that the timer considers into the "final" state. Optional. If left out, the final time is ignored.
    */
    func sendSync(timerStartTime inTimerStartTime: TimeInterval,
                  timerTotalTime inTimerTotalTime: TimeInterval,
                  timerWarnTime inTimerWarnTime: TimeInterval = 0.0,
                  timerFinalTime inTimerFinalTime: TimeInterval = 0.0) {
        _watchDelegate?.sendSync(timerStartTime: inTimerStartTime, timerTotalTime: inTimerTotalTime, timerWarnTime: inTimerWarnTime, timerFinalTime: inTimerFinalTime)
    }
    
    /* ################################################################## */
    /**
     This is called to send the current state of the prefs to the Watch.
     */
    func updateApplicationContext() {
        _watchDelegate?.sendApplicationContext()
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension RVS_AmbiaMara_AppSceneDelegate {
    /* ################################################################## */
    /**
     This responds to updates from the Watch delegate.
     
     - parameter inWatchDelegate: The delegate handler calling this.
     - parameter inApplicationContext: The application context from the Watch.
     */
    func watchUpdateHandler(_ inWatchDelegate: RVS_WatchDelegate?, _ inApplicationContext: [String: Any]) {
        
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
    func application(_: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        _watchDelegate = RVS_WatchDelegate(updateHandler: watchUpdateHandler)
        return true
    }

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
        _watchDelegate = nil
        cleanPopoverAndStopAlarm()
    }
    
    /* ################################################################## */
    /**
     Called when the app goes into the background.
     - parameter: The scene instance (ignored).
     */
    func sceneDidEnterBackground(_: UIScene) {
        cleanPopoverAndStopAlarm()
    }
    
    /* ################################################################## */
    /**
     Called when the app is about to become active.
     I use this to make sure the buttons and toolbar react promply to changes in things like increased contrast.
     - parameter: The scene instance (ignored).
     */
    func sceneDidBecomeActive(_: UIScene) {
        _watchDelegate = RVS_WatchDelegate(updateHandler: watchUpdateHandler)
        DispatchQueue.main.async { [weak self] in
            if let viewControllers = self?.navigationController?.viewControllers {
                if let setupScreen = viewControllers.first as? RVS_SetTimerAmbiaMara_ViewController {
                    setupScreen.setUpButtons()
               }
            }
        }
    }
}
