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
    private var _mySession = WCSession.default()
    
    // MARK: - Internal Instance Calculated Properties
    /* ################################################################################################################################## */
    var session: WCSession {
        get {
            return self._mySession
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
    func applicationWillEnterForeground(_ application: UIApplication) {
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
        self.activateSession()
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
    
    // MARK: - WCSessionDelegate Protocol Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
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
        if let value = message[LGV_Timer_Messages.s_timerListHowdyMessageKey] as? String {
            if LGV_Timer_Messages.s_timerListHowdyMessageValue == value {
                var timerArray:[[String:Any]] = []
                for timer in s_g_LGV_Timer_AppDelegatePrefs.timers {
                    var timerDictionary:[String:Any] = [:]
                    timerDictionary[LGV_Timer_Data_Keys.s_timerDataTimeSetKey] = timer.timeSet
                    timerDictionary[LGV_Timer_Data_Keys.s_timerDataDisplayModeKey] = timer.displayMode.rawValue
                    timerDictionary[LGV_Timer_Data_Keys.s_timerDataUIDKey] = timer.uid
                    let colorIndex = timer.colorTheme
                    let pickerPepper = LGV_Timer_StaticPrefs.prefs.pickerPepperArray[colorIndex]
                    // This awful hack is because colors read from IB don't seem to transmit well to Watch. Pretty sure it's an Apple bug.
                    if let color = pickerPepper.textColor {
                        if let destColorSpace: CGColorSpace = CGColorSpace(name: CGColorSpace.sRGB) {
                            if let newColor = color.cgColor.converted(to: destColorSpace, intent: CGColorRenderingIntent.perceptual, options: nil) {
                                timerDictionary[LGV_Timer_Data_Keys.s_timerDataColorKey] = UIColor(cgColor: newColor)
                            }
                        }
                    }
                    timerArray.append(timerDictionary)
                }
                
                let timerData = NSKeyedArchiver.archivedData(withRootObject: timerArray)
                let responseMessage = [LGV_Timer_Messages.s_timerListHowdyMessageValue:timerData]

                session.sendMessage(responseMessage, replyHandler: nil, errorHandler: nil)
            }
        } else {
            if let value = message[LGV_Timer_Messages.s_timerListGimmeMoreInfoMessageKey] as? String {
                if LGV_Timer_Messages.s_timerListGimmeMoreInfoMessageValue == value {
//                    let timerData = NSKeyedArchiver.archivedData(withRootObject: s_g_LGV_Timer_AppDelegatePrefs.timers)
//                    let responseMessage = [LGV_Timer_Messages.s_timerListGimmeMoreInfoMessageValue:timerData]
//                    
//                    session.sendMessage(responseMessage, replyHandler: nil, errorHandler: nil)
                }
            } else {
                type(of:self).displayAlert("iOS App: LGV_Timer_AppDelegate.session(_:,didReceiveMessage:)", inMessage: "\(message)")
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        type(of:self).displayAlert("iOS App: LGV_Timer_AppDelegate.session(_:,didReceiveMessage:)", inMessage: "\(message)")
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        type(of:self).displayAlert("iOS App: LGV_Timer_AppDelegate.session(_:,didReceiveMessageData:)", inMessage: "\(messageData)")
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        type(of:self).displayAlert("iOS App: LGV_Timer_AppDelegate.session(_:,didReceiveMessageData:)", inMessage: "\(messageData)")
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        type(of:self).displayAlert("iOS App: LGV_Timer_AppDelegate.session(_:,didReceiveUserInfo:)", inMessage: "\(userInfo)")
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        print("iOS App: LGV_Timer_AppDelegate.session(_:,didFinish:,error:)\n\(userInfoTransfer)\n\(String(describing: error))")
        type(of:self).displayAlert("iOS App: LGV_Timer_AppDelegate.session(_:,didFinish:)", inMessage: "\(userInfoTransfer)\n\(String(describing: error))")
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        type(of:self).displayAlert("iOS App: LGV_Timer_AppDelegate.session(_:,didReceive:)", inMessage: "\(file)")
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        type(of:self).displayAlert("iOS App: LGV_Timer_AppDelegate.session(_:,didFinish:)", inMessage: "\(fileTransfer)\n\(String(describing: error))")
    }
}

