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
    private var _offTheChain:Bool = true
    private var _timerObject: Timer! = nil
    
    /* ################################################################################################################################## */
    var timers: [[String: Any]] = []
    var youreOnYourOwn: Bool = false
    var firstInterfaceController: LGV_Timer_Watch_MainAppInterfaceController! = nil
    var disgustingHackSemaphore: Bool = false
    
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
        if !self.youreOnYourOwn && !self.disgustingHackSemaphore {
            let selectMsg = [LGV_Timer_Messages.s_timerListSelectTimerMessageKey:timerUID]
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
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
        self.disgustingHackSemaphore = false
        self._activateSession()
    }

    /* ################################################################## */
    /**
     */
    func applicationDidBecomeActive() {
        self.disgustingHackSemaphore = false
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
    func closingTimer(timerIndex: Int) {
        self.sendSelectMessage()
    }
    
    /* ################################################################## */
    /**
     */
    func timerCallback(_ timer: Timer) {
        if let timerIndex = timer.userInfo as? Int {
            if 0 <= timerIndex {
                DispatchQueue.main.async {self.firstInterfaceController.pushTimer(timerIndex)}
            }
        }
        
        self._timerObject = nil
        self.disgustingHackSemaphore = false
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
                    if !self._offTheChain {
                        if let seconds = message[key] as? Int {
                            if nil != self.firstInterfaceController {
                                if nil != self.firstInterfaceController.myCurrentTimer {
                                    self.firstInterfaceController.myCurrentTimer.updateUI(inSeconds: seconds)
                                }
                            }
                        }
                    } else {
                        self.sendStatusRequestMessage()
                    }
                    
                case    LGV_Timer_Messages.s_timerListSelectTimerMessageKey:
                    if !self._offTheChain {
                        if let uid = message[key] as? String {
                            let timerIndex = self.getTimerIndexForUID(uid)
                            if 0 <= timerIndex {
                                var currentIndex = -2
                                if let interfaceController = self.firstInterfaceController.myCurrentTimer {
                                    currentIndex = interfaceController.timerIndex
                                    // OK. THis is sad.
                                    // You have to wait until the screens have actually closed before you push the new one.
                                    // The disgusting hack semaphore is to prevent the watch from telling the phone app
                                    // to reset to the Timer List, when we actually have a new timer about to be selected.
                                    // This is gross, I know, but them's the breaks.
                                    if nil != self.firstInterfaceController.myCurrentTimer {
                                        self.disgustingHackSemaphore = true
                                        self.firstInterfaceController.myCurrentTimer.closeMe()
                                    }
                                    self._timerObject = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(self.timerCallback(_:)), userInfo: timerIndex, repeats: false)
                                } else {
                                    if currentIndex != timerIndex {
                                        if nil != self.firstInterfaceController.myCurrentTimer {
                                            self.firstInterfaceController.myCurrentTimer.closeMe()
                                        }
                                        
                                        if 0 <= timerIndex {
                                            self.firstInterfaceController.pushTimer(timerIndex)
                                        }
                                    }
                                }
                            } else {
                                self.firstInterfaceController.popToRootController()
                            }
                        } else {
                            print("Bad UID!")
                        }
                    } else {
                        self.sendStatusRequestMessage()
                    }
                    
                case    LGV_Timer_Messages.s_timerListStopTimerMessageKey:
                    if !self._offTheChain {
                        if nil != self.firstInterfaceController.myCurrentTimer {
                            if nil != self.firstInterfaceController.myCurrentTimer.modalTimerScreen {
                                self.firstInterfaceController.myCurrentTimer.modalTimerScreen.closeMe()
                            }
                            
                            if let timeSet = (self.firstInterfaceController.myCurrentTimer.timer[LGV_Timer_Data_Keys.s_timerDataTimeSetKey] as? NSNumber)?.intValue {
                                self.firstInterfaceController.myCurrentTimer.currentTimeInSeconds = timeSet
                            }
                            
                            self.firstInterfaceController.myCurrentTimer.updateUI(inSeconds: self.firstInterfaceController.myCurrentTimer.currentTimeInSeconds)
                        }
                    } else {
                        self.sendStatusRequestMessage()
                    }
                    
                case    LGV_Timer_Messages.s_timerListStartTimerMessageKey:
                    if !self._offTheChain {
                        if let uid = message[key] as? String {
                            let timerIndex = self.getTimerIndexForUID(uid)
                            if 0 <= timerIndex {
                                var currentIndex = -2
                                if let interfaceController = self.firstInterfaceController.myCurrentTimer {
                                    currentIndex = interfaceController.timerIndex
                                    if currentIndex != timerIndex {
                                        if nil != self.firstInterfaceController.myCurrentTimer {
                                            self.disgustingHackSemaphore = true
                                            self.firstInterfaceController.myCurrentTimer.closeMe()
                                        }
                                        self.firstInterfaceController.pushTimer(timerIndex)
                                        self.disgustingHackSemaphore = false
                                    }
                                    
                                    self.firstInterfaceController.myCurrentTimer.startTimer()
                                } else {
                                    self.firstInterfaceController.pushTimer(timerIndex)
                                    self.firstInterfaceController.myCurrentTimer.startTimer()
                                }
                            }
                        }
                    }
                    
                case    LGV_Timer_Messages.s_timerListAlarmMessageKey:
                    if !self._offTheChain {
                        if let interfaceController = self.firstInterfaceController.myCurrentTimer {
                            if nil != interfaceController.modalTimerScreen {
                                interfaceController.modalTimerScreen.alarm()
                            }
                        }
                    } else {
                        self.sendStatusRequestMessage()
                    }
                    
                case    LGV_Timer_Messages.s_timerAppInForegroundMessageKey:
                    if self._offTheChain {
                        if nil != self.firstInterfaceController.myCurrentTimer {
                            self.disgustingHackSemaphore = true
                            if nil != self.firstInterfaceController.myCurrentTimer.modalTimerScreen {
                                self.firstInterfaceController.myCurrentTimer.modalTimerScreen.closeMe()
                                self.firstInterfaceController.myCurrentTimer.closeMe()
                            } else {
                                self.firstInterfaceController.myCurrentTimer.closeMe()
                            }
                            self.disgustingHackSemaphore = false
                        }
                    }
                    
                    self._offTheChain = false
                    self.firstInterfaceController.updateUI()
                
                case    LGV_Timer_Messages.s_timerAppInBackgroundMessageKey:
                    self._offTheChain = true
                    self.firstInterfaceController.updateUI()
                    
                default:
                    self._offTheChain = true
                    self.sendStatusRequestMessage()
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
    
    /* ################################################################## */
    /**
     */
    func closeMe() {
        super.pop()
    }
}

