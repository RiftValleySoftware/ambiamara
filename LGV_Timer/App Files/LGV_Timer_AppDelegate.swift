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
import WatchConnectivity

@UIApplicationMain
/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
    // MARK: - Static Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is a quick way to get this object instance (it's a SINGLETON), cast as the correct class.
     */
    static var appDelegateObject: LGV_Timer_AppDelegate {
        get { return UIApplication.shared.delegate as! LGV_Timer_AppDelegate }
    }

    // MARK: - Instance Properties
    /* ################################################################################################################################## */
    var orientationLock = UIInterfaceOrientationMask.all
    var window: UIWindow?
    var currentTimer: LGV_Timer_TimerRuntimeViewController! = nil
    var useUserInfo: Bool = false
    var watchDisconnected: Bool = true
    var timerListController: LGV_Timer_SettingsViewController! = nil
    var ignoreSelectMessageFromWatch: Int = 0
    
    // MARK: - Instance Calculated Properties
    /* ################################################################################################################################## */
    var mainTabController: LGV_Timer_MainTabController! {
        get {
            if let rootController = self.window?.rootViewController as? LGV_Timer_MainTabController {
                return rootController
            }
            return nil
        }
    }
    
    var timerEngine: LGV_Timer_TimerEngine! {
        get {
            if nil != self.mainTabController {
                return self.mainTabController.timerEngine
            }
            return nil
        }
    }
    

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
     Displays the given error in an alert with an "OK" button.
     
     - parameter inTitle: a string to be displayed as the title of the alert. It is localized by this method.
     - parameter inMessage: a string to be displayed as the message of the alert. It is localized by this method.
     - parameter presentedBy: An optional UIViewController object that is acting as the presenter context for the alert. If nil, we use the top controller of the Navigation stack.
     */
    class func displayAlert(_ inTitle: String, inMessage: String, presentedBy inPresentingViewController: UIViewController! = nil ) {
        DispatchQueue.main.async {
            var presentedBy = inPresentingViewController
            
            if nil == presentedBy {
                if let navController = self.appDelegateObject.window?.rootViewController as? UINavigationController {
                    presentedBy = navController.topViewController
                } else {
                    if let tabController = self.appDelegateObject.window?.rootViewController as? UITabBarController {
                        if let navController = tabController.selectedViewController as? UINavigationController {
                            presentedBy = navController.topViewController
                        } else {
                            presentedBy = tabController.selectedViewController
                        }
                    }
                }
            }
            
            if nil != presentedBy {
                let alertController = UIAlertController(title: inTitle.localizedVariant, message: inMessage.localizedVariant, preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "BASIC-OK-BUTTON".localizedVariant, style: UIAlertActionStyle.cancel, handler: nil)
                
                alertController.addAction(okAction)
                
                presentedBy?.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Private Instance Properties
    /* ################################################################################################################################## */
    private var _mySession = WCSession.default
    
    // MARK: - Internal Instance Calculated Properties
    /* ################################################################################################################################## */
    var session: WCSession {
        get {
            return self._mySession
        }
    }
    
    /* ################################################################## */
    /**
     Returns the current app status.
     */
    var appState: LGV_Timer_State! {
        get {
            if nil != self.timerEngine {
                return self.timerEngine.appState
            } else {
                return nil
            }
        }
    }
    
    // MARK: - Internal Instance Methods
    /* ################################################################################################################################## */
    func activateSession() {
        if WCSession.isSupported() && (self._mySession.activationState != .activated) {
            self._mySession.delegate = self
            self.session.activate()
        }
    }

    // MARK: - UIApplicationDelegate Protocol Methods
    /* ################################################################################################################################## */
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
//        self.activateSession()
        return true
    }
    
    /* ################################################################## */
    /**
     */
    func applicationWillEnterForeground(_ application: UIApplication) {
        self.sendForegroundMessage()
    }

    /* ################################################################## */
    /**
     */
    func applicationDidEnterBackground(_ application: UIApplication) {
        if nil != self.timerEngine {
            self.timerEngine.stopTimer()
            self.timerEngine.selectedTimerIndex = -1
            self.sendBackgroundMessage()
            self.timerEngine.savePrefs()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func applicationWillTerminate(_ application: UIApplication) {
        if nil != self.timerEngine {
            self.sendBackgroundMessage()
            self.timerEngine.savePrefs()
        }
    }
    
    // MARK: - WCSessionDelegate Sender Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func sendStartMessage(timerUID: String, currentTime: Int! = nil) {
        if nil != self.timerEngine {
            let selectMsg = [LGV_Timer_Messages.s_timerListStartTimerMessageKey:timerUID]
            #if DEBUG
                print("Phone Sending Message: " + String(describing: selectMsg))
            #endif
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendStopMessage(timerUID: String) {
        if nil != self.timerEngine {
            let selectMsg = [LGV_Timer_Messages.s_timerListStopTimerMessageKey:timerUID]
            #if DEBUG
                print("Phone Sending Message: " + String(describing: selectMsg))
            #endif
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendSelectMessage(timerUID: String = "") {
        #if DEBUG
            print("Incrementing Ignore Select From Watch from \(self.ignoreSelectMessageFromWatch).")
        #endif
        self.ignoreSelectMessageFromWatch += 1
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { (_ inTimer: Timer) in
            #if DEBUG
                if 0 < self.ignoreSelectMessageFromWatch {
                    print("Selection is \(self.ignoreSelectMessageFromWatch). Resetting it to 0.")
                }
            #endif
            self.ignoreSelectMessageFromWatch = 0
        })
        if .activated == self.session.activationState {
            let selectMsg = [LGV_Timer_Messages.s_timerListSelectTimerMessageKey:timerUID]
            #if DEBUG
                print("Phone Sending Message: " + String(describing: selectMsg))
            #endif
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendAlarmMessage(timerUID: String) {
        if .activated == self.session.activationState {
            let selectMsg = [LGV_Timer_Messages.s_timerListAlarmMessageKey:timerUID]
            #if DEBUG
                print("Phone Sending Message: " + String(describing: selectMsg))
            #endif
           self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendTick() {
        if nil != self.timerEngine {
            let selectMsg = [LGV_Timer_Messages.s_timerSendTickMessageKey:self.appState.selectedTimer.currentTime]
            #if DEBUG
                print("Phone Sending Message: " + String(describing: selectMsg))
            #endif
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }

    /* ################################################################## */
    /**
     */
    func sendBackgroundMessage() {
        let selectMsg = [LGV_Timer_Messages.s_timerAppInBackgroundMessageKey:""]
        #if DEBUG
            print("Phone Sending Message: " + String(describing: selectMsg))
        #endif
        self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
    }
    
    /* ################################################################## */
    /**
     */
    func sendForegroundMessage() {
        if nil != self.appState {
            for timer in self.appState {    // Make sure the timer color theme is up to date.
                timer.storedColor = self.timerEngine.getIndexedColorThemeColor(timer.colorTheme)
            }
            
            let selectMsg = [LGV_Timer_Messages.s_timerRequestAppStatusMessageKey:self.appState.dictionary]
            #if DEBUG
                print("Phone Sending Message: " + String(describing: selectMsg))
            #endif
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        } else {
            let selectMsg = [LGV_Timer_Messages.s_timerAppInForegroundMessageKey:""]
            #if DEBUG
                print("Phone Sending Message: " + String(describing: selectMsg))
            #endif
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    // MARK: - WCSessionDelegate Protocol Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if .activated == activationState {
            self.sendForegroundMessage()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sessionDidBecomeInactive(_ session: WCSession) {
        type(of:self).displayAlert("iOS App: LGV_Timer_AppDelegate.sessionDidBecomeInactive", inMessage: "")
    }
    
    /* ################################################################## */
    /**
     */
    func sessionDidDeactivate(_ session: WCSession) {
        type(of:self).displayAlert("iOS App: LGV_Timer_AppDelegate.sessionDidDeactivate", inMessage: "")
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]){
        type(of:self).displayAlert("iOS App: LGV_Timer_AppDelegate.session(_:,didReceiveApplicationContext:)", inMessage: "\(applicationContext)")
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if nil != self.timerEngine {
            DispatchQueue.main.async {
                if .active == UIApplication.shared.applicationState {
                    #if DEBUG
                        print("Phone Received Message: " + String(describing: message))
                    #endif
                    
                    for key in message.keys {
                        switch key {
                        case LGV_Timer_Messages.s_timerListSelectTimerMessageKey:
                            if 0 == self.ignoreSelectMessageFromWatch {
                                if (nil != self.timerEngine) && (nil != self.mainTabController) {
                                    if let uid = message[key] as? String {
                                        let index = self.timerEngine.indexOf(uid)
                                        self.timerEngine.selectedTimerIndex = index
                                    }
                                }
                            } else {
                                #if DEBUG
                                    print("Select From Watch Ignored. Decrementing Ignore Select From Watch from \(self.ignoreSelectMessageFromWatch).")
                                #endif
                                self.ignoreSelectMessageFromWatch -= 1
                            }
                            
                        case LGV_Timer_Messages.s_timerListStopTimerMessageKey:
                            self.timerEngine.stopTimer()
                            
                        case LGV_Timer_Messages.s_timerListStartTimerMessageKey:
                            if (nil != self.timerEngine) && (nil != self.mainTabController) {
                                if let uid = message[key] as? String {
                                    let index = self.timerEngine.indexOf(uid)
                                    self.timerEngine.selectedTimerIndex = index
                                }
                                
                                if let controller = self.mainTabController.getTimerScreen(self.timerEngine.selectedTimer) {
                                    controller.startTimer()
                                }
                            }
                            
                        case LGV_Timer_Messages.s_timerAppInForegroundMessageKey:
                            self.sendForegroundMessage()
                            
                        case LGV_Timer_Messages.s_timerAppInBackgroundMessageKey:
                            #if DEBUG
                                print("Phone app is in background. Resetting ignore from \(self.ignoreSelectMessageFromWatch).")
                            #endif
                            self.ignoreSelectMessageFromWatch = 0

                        default:
                            if let uid = message[key] as? String {
                                print(uid)
                            }
                            type(of:self).displayAlert("iOS App: LGV_Timer_AppDelegate.session(_:,didReceiveMessage:)", inMessage: "\(message)")
                        }
                    }
                }
            }
        }
    }
}

