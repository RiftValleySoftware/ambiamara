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
    static var delegateObject:LGV_Timer_Watch_ExtensionDelegate {
        get {
            return WKExtension.shared().delegate as! LGV_Timer_Watch_ExtensionDelegate
        }
    }
    
    /* ################################################################################################################################## */
    private var _mySession = WCSession.default()
    private var _timerObject: Timer! = nil
    private var _offTheChain:Bool = true
    
    /* ################################################################################################################################## */
    var timers: [[String: Any]] = []
    var dontCallMeBack: Bool = false
    var youreOnYourOwn: Bool = false
    var timerListController: LGV_Timer_Watch_MainAppInterfaceController! = nil
    var timerObjects:[LGV_Timer_Watch_MainTimerHandlerInterfaceController] = []
    var currentTimer: LGV_Timer_Watch_MainTimerHandlerInterfaceController! = nil
    
    /* ################################################################################################################################## */
    var session: WCSession {get { return self._mySession }}
    var appDisconnected: Bool {get { return self._offTheChain }}
    
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
        if !self.youreOnYourOwn && !self.dontCallMeBack {
            let selectMsg = [LGV_Timer_Messages.s_timerListSelectTimerMessageKey:timerUID]
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
        
        self.dontCallMeBack = false
    }
    
    /* ################################################################## */
    /**
     */
    func sendStartMessage(timerUID: String) {
        if !self.youreOnYourOwn {
            let selectMsg = [LGV_Timer_Messages.s_timerListStartTimerMessageKey:timerUID]
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendStopMessage(timerUID: String) {
        if !self.youreOnYourOwn {
            let selectMsg = [LGV_Timer_Messages.s_timerListStopTimerMessageKey:timerUID]
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendPauseMessage(timerUID: String) {
        if !self.youreOnYourOwn {
            let selectMsg = [LGV_Timer_Messages.s_timerListPauseTimerMessageKey:timerUID]
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendEndMessage(timerUID: String) {
        if !self.youreOnYourOwn {
            let selectMsg = [LGV_Timer_Messages.s_timerListEndTimerMessageKey:timerUID]
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendResetMessage(timerUID: String) {
        if !self.youreOnYourOwn {
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
    func sendActiveTimerRequestMessage() {
        if .activated == self.session.activationState {
            let selectMsg = [LGV_Timer_Messages.s_timerRequestActiveTimerUIDMessageKey:""]
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func getTimerIndexForUID(_ inUID: String) -> Int {
        var ret: Int = -1
        
        for index in 0..<self.timers.count {
            if let uid = self.timers[index][LGV_Timer_Data_Keys.s_timerDataUIDKey] as? String {
                if uid == inUID {
                    ret = index
                    break
                }
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     */
    func getTimerUIDForIndex(_ inIndex: Int) -> String {
        var ret: String = ""
        
        if let uid = self.timers[inIndex][LGV_Timer_Data_Keys.s_timerDataUIDKey] as? String {
            ret = uid
        }
        
        return ret
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
    func applicationDidBecomeActive() {
    }

    /* ################################################################## */
    /**
     */
    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
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
                backgroundTask.setTaskCompleted()
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompleted()
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompleted()
            default:
                // make sure to complete unhandled task types
                task.setTaskCompleted()
            }
        }
    }
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            let heloMsg = [LGV_Timer_Messages.s_timerListHowdyMessageKey:LGV_Timer_Messages.s_timerListHowdyMessageValue]
            session.sendMessage(heloMsg, replyHandler: nil, errorHandler: nil)
        } else {
            self.youreOnYourOwn = true
        }
    }
    
    /* ################################################################## */
    /**
     */
    func populateScreens(noTimers: Bool) {
        var screenIDs:[String] = [LGV_Timer_Watch_MainAppInterfaceController.screenID]
        var contexts:[[String:Any]] = [[:]]
        
        if !noTimers {
            for timer in self.timers {
                screenIDs.append(LGV_Timer_Watch_MainTimerHandlerInterfaceController.screenID)
                let contextObject = [LGV_Timer_Watch_MainAppInterfaceController.s_ControllerContextKey:self,LGV_Timer_Watch_MainAppInterfaceController.s_TimerContextKey:timer] as [String : Any]
                contexts.append(contextObject)
            }
        }
        
        WKInterfaceController.reloadRootControllers(withNames: screenIDs, contexts: contexts)
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            for key in message.keys {
                switch key {
                case    LGV_Timer_Messages.s_timerListHowdyMessageValue:
                    if let messagePayload = message[key] as? Data {
                        if let payload = NSKeyedUnarchiver.unarchiveObject(with: messagePayload) as? [[String:Any]] {
                            self.timers = payload
                            self.sendStatusRequestMessage()
                        }
                    }
                    
                case LGV_Timer_Messages.s_timerListUpdateTimerMessageKey:
                    if !self.appDisconnected {
                        if let seconds = message[key] as? Int {
                            if let timerObject = self.currentTimer {
                                timerObject.updateUI(inSeconds: seconds)
                            }
                        }
                    } else {
                        self.sendStatusRequestMessage()
                    }
                    
                case    LGV_Timer_Messages.s_timerListSelectTimerMessageKey:
                    if !self.appDisconnected {
                        if let uid = message[key] as? String {
                            self.dontCallMeBack = true
                            let index = self.getTimerIndexForUID(uid)
                            if 0 <= index {
                                self.timerListController.pushTimer(index)
                            } else {
                                DispatchQueue.main.async {
                                    self.timerListController.becomeCurrentPage()
                                }
                            }
                        } else {
                            print("Bad UID!")
                        }
                    } else {
                        self.sendStatusRequestMessage()
                    }
                    
                case    LGV_Timer_Messages.s_timerListStopTimerMessageKey:
                    if !self.appDisconnected {
                        if let uid = message[key] as? String {
                            self.dontCallMeBack = true
                            let index = self.getTimerIndexForUID(uid)
                            if 0 <= index {
                                self.timerObjects[index].stopTimer()
                            }
                        } else {
                            print("Bad UID!")
                        }
                    } else {
                        self.sendStatusRequestMessage()
                    }
                    
                case    LGV_Timer_Messages.s_timerListPauseTimerMessageKey:
                    if !self.appDisconnected {
                        if let uid = message[key] as? String {
                            self.dontCallMeBack = true
                            let index = self.getTimerIndexForUID(uid)
                            if 0 <= index {
                                self.timerObjects[index].pauseTimer()
                            }
                        } else {
                            print("Bad UID!")
                        }
                    } else {
                        self.sendStatusRequestMessage()
                    }
                
                case    LGV_Timer_Messages.s_timerListStartTimerMessageKey:
                    if !self.appDisconnected {
                        if let uid = message[key] as? String {
                            self.dontCallMeBack = true
                            let index = self.getTimerIndexForUID(uid)
                            if 0 <= index {
                                self.timerObjects[index].pushTimer()
                            }
                        } else {
                            print("Bad UID!")
                        }
                    } else {
                        self.sendStatusRequestMessage()
                    }
                    
                case    LGV_Timer_Messages.s_timerListResetTimerMessageKey:
                    if !self.appDisconnected {
                        if let uid = message[key] as? String {
                            self.dontCallMeBack = true
                            let index = self.getTimerIndexForUID(uid)
                            if 0 <= index {
                                self.timerObjects[index].stopTimer()
                            }
                        } else {
                            print("Bad UID!")
                        }
                    } else {
                        self.sendStatusRequestMessage()
                    }

                case    LGV_Timer_Messages.s_timerListEndTimerMessageKey:
                    break
                    
                case    LGV_Timer_Messages.s_timerListAlarmMessageKey:
                    if !self.appDisconnected {
                        if let uid = message[key] as? String {
                            let index = self.getTimerIndexForUID(uid)
                            if 0 <= index {
                                self.timerObjects[index].alarm()
                            }
                        } else {
                            print("Bad UID!")
                        }
                    } else {
                        self.sendStatusRequestMessage()
                    }
                    
                case    LGV_Timer_Messages.s_timerAppInForegroundMessageKey:
                    if self.appDisconnected {
                        self.populateScreens(noTimers: false)
                    }
                    
                    self._offTheChain = false
                
                case    LGV_Timer_Messages.s_timerAppInBackgroundMessageKey:
                    self._offTheChain = true
                    self.populateScreens(noTimers: true)
                    
                default:
                    self.sendStatusRequestMessage()
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

