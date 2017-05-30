//
//  LGV_Timer_AppDelegate.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 5/24/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//
/* ###################################################################################################################################### */
/**
 */

import UIKit

/* ###################################################################################################################################### */
/**
 These are String class extensions that we'll use throughout the app.
 */
extension String {
    /* ################################################################## */
    /**
     */
    var localizedVariant: String {
        return NSLocalizedString(self, comment: "")
    }
}

var s_g_LGV_Timer_AppDelegatePrefs = LGV_Timer_StaticPrefs.prefs

@UIApplicationMain
/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: - Instance Properties
    /* ################################################################################################################################## */
    var orientationLock = UIInterfaceOrientationMask.all
    var window: UIWindow?

    // MARK: - Static Class Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    class func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? LGV_Timer_AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    /* ################################################################## */
    /**
     */
    class func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        self.lockOrientation(orientation)
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    
    /* ################################################################## */
    /**
     */
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }

    /* ################################################################## */
    /**
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    /* ################################################################## */
    /**
     */
    func applicationWillResignActive(_ application: UIApplication) {
        s_g_LGV_Timer_AppDelegatePrefs.savePrefs()
    }

    /* ################################################################## */
    /**
     */
    func applicationDidEnterBackground(_ application: UIApplication) {
        s_g_LGV_Timer_AppDelegatePrefs.savePrefs()
    }
    
    /* ################################################################## */
    /**
     */
    func applicationWillTerminate(_ application: UIApplication) {
        s_g_LGV_Timer_AppDelegatePrefs.savePrefs()
    }

    /* ################################################################## */
    /**
     */
    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    /* ################################################################## */
    /**
     */
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
}

