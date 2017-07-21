//
//  LGV_Timer_Watch_    ExtensionDelegate.swift
//  X-Timer Companion Extension
//
//  Created by Chris Marshall on 6/19/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//

import WatchKit
import WatchConnectivity

/* ###################################################################################################################################### */
class LGV_Timer_Watch_ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    /* ################################################################################################################################## */
    static var delegateObject:LGV_Timer_Watch_ExtensionDelegate! {
        get {
            let sharedExt = WKExtension.shared()
            if let delegate = sharedExt.delegate as? LGV_Timer_Watch_ExtensionDelegate {
                return delegate
            }
            
            return nil
        }
    }
    
    /* ################################################################################################################################## */
    private var _mySession = WCSession.default
    
    /* ################################################################################################################################## */
    var appStatus: LGV_Timer_State! = nil
    var timerListController: LGV_Timer_Watch_MainAppInterfaceController! = nil
    
    /* ################################################################################################################################## */
    var session: WCSession {get { return self._mySession }}
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    private func _activateSession() {
        if WCSession.isSupported() && (self.session.activationState != .activated) {
            self.session.delegate = self
            self.session.activate()
        }
    }
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func sendSelectMessage(timerUID: String = "") {
        if self.session.isReachable {
            let selectMsg = [LGV_Timer_Messages.s_timerListSelectTimerMessageKey:timerUID]
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendBackgroundMessage() {
        let selectMsg = [LGV_Timer_Messages.s_timerAppInBackgroundMessageKey:""]
        self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
    }
    
    /* ################################################################## */
    /**
     */
    func sendForegroundMessage() {
        let selectMsg = [LGV_Timer_Messages.s_timerAppInForegroundMessageKey:""]
        self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
    }
    
    /* ################################################################## */
    /**
     */
    func sendStartMessage(timerUID: String) {
        if self.session.isReachable {
            let selectMsg = [LGV_Timer_Messages.s_timerListStartTimerMessageKey:timerUID]
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendStopMessage(timerUID: String) {
        if self.session.isReachable {
            let selectMsg = [LGV_Timer_Messages.s_timerListStopTimerMessageKey:timerUID]
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendPauseMessage(timerUID: String) {
        if self.session.isReachable {
            let selectMsg = [LGV_Timer_Messages.s_timerListPauseTimerMessageKey:timerUID]
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendEndMessage(timerUID: String) {
        if self.session.isReachable {
            let selectMsg = [LGV_Timer_Messages.s_timerListEndTimerMessageKey:timerUID]
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendResetMessage(timerUID: String) {
        if self.session.isReachable {
            let selectMsg = [LGV_Timer_Messages.s_timerListResetTimerMessageKey:timerUID]
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendStatusRequestMessage() {
        if .activated == self.session.activationState {
            let selectMsg = [LGV_Timer_Messages.s_timerRequestAppStatusMessageKey:""]
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func getTimerIndexForUID(_ inUID: String) -> Int {
        let ret: Int = -1
        return ret
    }
    
    /* ################################################################## */
    /**
     */
    func getTimerUIDForIndex(_ inIndex: Int) -> String {
        let ret: String = ""
        return ret
    }
    
    /* ################################################################## */
    /**
     */
    func updateTimerGivenUID(_ inUID: String, selectTimer: Bool = false) {
    }
    
    /* ################################################################## */
    /**
     */
    func process(userInfo: [String : Any] = [:]) {
    }
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func applicationDidFinishLaunching() {
        self._activateSession()
    }

    /* ################################################################## */
    /**
     */
    func applicationDidEnterBackground() {
        self.sendBackgroundMessage()
    }
    
    /* ################################################################## */
    /**
     */
    func applicationWillEnterForeground() {
        self.sendForegroundMessage()
    }
    
    /* ################################################################## */
    /**
     */
    func applicationDidBecomeActive() {
        self.sendForegroundMessage()
    }

    /* ################################################################## */
    /**
     */
    func applicationWillResignActive() {
        self.sendBackgroundMessage()
    }

    /* ################################################################## */
    /**
     */
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                if #available(watchOSApplicationExtension 4.0, *) {
                    backgroundTask.setTaskCompletedWithSnapshot(true)
                } else {
                    // Fallback on earlier versions
                }
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                self.process(userInfo: connectivityTask.userInfo as! [String : Any])
                if #available(watchOSApplicationExtension 4.0, *) {
                    connectivityTask.setTaskCompletedWithSnapshot(true)
                } else {
                    // Fallback on earlier versions
                }
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                if #available(watchOSApplicationExtension 4.0, *) {
                    urlSessionTask.setTaskCompletedWithSnapshot(true)
                } else {
                    // Fallback on earlier versions
                }
            default:
                // make sure to complete unhandled task types
                if #available(watchOSApplicationExtension 4.0, *) {
                    task.setTaskCompletedWithSnapshot(true)
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            self.sendStatusRequestMessage()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func populateScreens(noTimers: Bool) {
    }
    
    /* ################################################################## */
    /**
     */
    func addTimerControllerIfNotAlreadyThere(controller: LGV_Timer_Watch_MainTimerHandlerInterfaceController) {
    }
    
    /* ################################################################## */
    /**
     */
    func setTimerObject(_ inData: Data) -> String {
        return ""
    }
    
    /* ################################################################## */
    /**
     */
    func updateAllTimerObjects(inTimerList: [[String:Any]]) {
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        self.process(userInfo: userInfo)
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            #if DEBUG
                print(String(describing: message))
            #endif
            
            for key in message.keys {
                switch key {
                case    LGV_Timer_Messages.s_timerStatusUserInfoValue:
                    break
                    
                default:
                    break
                }
            }
        }
    }
}

/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_Watch_BaseInterfaceController: WKInterfaceController {
    var timerUID: String = ""
    var timerIndex: Int = -1
    var timer:[String:Any]! = nil {
        didSet {
            if let uid = self.timer[LGV_Timer_Data_Keys.s_timerDataUIDKey] as? String {
                self.timerUID = uid
                self.timerIndex = LGV_Timer_Watch_ExtensionDelegate.delegateObject.getTimerIndexForUID(uid)
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func updateUI() { }
}

