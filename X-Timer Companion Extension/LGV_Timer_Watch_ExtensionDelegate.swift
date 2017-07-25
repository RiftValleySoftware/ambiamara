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
class LGV_Timer_Watch_ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate, LGV_Timer_StateDelegate {
    /* ################################################################################################################################## */
    static let timerInterval: TimeInterval = 0.25
    
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
    var timerControllers:[LGV_Timer_Watch_MainTimerHandlerInterfaceController] = []
    var currentTimer:LGV_Timer_Watch_MainTimerHandlerInterfaceController! = nil
    var ignoreSelectMessageFromPhone: Bool = false
    
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
        if .activated == self.session.activationState {
            #if DEBUG
                print("LGV_Timer_Watch_ExtensionDelegate.sendSelectMessage(\"\(timerUID)\"): Turning On Ignore Select From Phone.")
            #endif
            self.ignoreSelectMessageFromPhone = true
            let selectMsg = [LGV_Timer_Messages.s_timerListSelectTimerMessageKey:timerUID]
            #if DEBUG
                print("Watch Sending Message: " + String(describing: selectMsg))
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
            print("Watch Sending Message: " + String(describing: selectMsg))
        #endif
        self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
    }
    
    /* ################################################################## */
    /**
     */
    func sendForegroundMessage() {
        let selectMsg = [LGV_Timer_Messages.s_timerAppInForegroundMessageKey:""]
        #if DEBUG
            print("Watch Sending Message: " + String(describing: selectMsg))
        #endif
        self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
    }
    
    /* ################################################################## */
    /**
     */
    func sendStartMessage(timerUID: String) {
        if self.session.isReachable {
            let selectMsg = [LGV_Timer_Messages.s_timerListStartTimerMessageKey:timerUID]
            #if DEBUG
                print("Watch Sending Message: " + String(describing: selectMsg))
            #endif
           self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendStopMessage(timerUID: String) {
        if self.session.isReachable {
            let selectMsg = [LGV_Timer_Messages.s_timerListStopTimerMessageKey:timerUID]
            #if DEBUG
                print("Watch Sending Message: " + String(describing: selectMsg))
            #endif
           self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendPauseMessage(timerUID: String) {
        if self.session.isReachable {
            let selectMsg = [LGV_Timer_Messages.s_timerListPauseTimerMessageKey:timerUID]
            #if DEBUG
                print("Watch Sending Message: " + String(describing: selectMsg))
            #endif
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendEndMessage(timerUID: String) {
        if self.session.isReachable {
            let selectMsg = [LGV_Timer_Messages.s_timerListEndTimerMessageKey:timerUID]
            #if DEBUG
                print("Watch Sending Message: " + String(describing: selectMsg))
            #endif
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendResetMessage(timerUID: String) {
        if self.session.isReachable {
            let selectMsg = [LGV_Timer_Messages.s_timerListResetTimerMessageKey:timerUID]
            #if DEBUG
                print("Watch Sending Message: " + String(describing: selectMsg))
            #endif
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
    func updateAllTimerObjects() {
        if nil != self.appStatus {
            var namesArray:[String] = [LGV_Timer_Watch_MainAppInterfaceController.screenID]
            var contexts:[Any] = [""]
            
            for timer in self.appStatus {
                namesArray.append(LGV_Timer_Watch_MainTimerHandlerInterfaceController.screenID)
                contexts.append(timer)
            }
            
            WKInterfaceController.reloadRootControllers(withNames: namesArray, contexts: contexts)
            
            if nil != self.timerListController {
                self.timerListController.dontSendAnEvent = true
                let pageIndex = self.appStatus.selectedTimerIndex
                if 0 <= pageIndex {
                    self.timerControllers[pageIndex].becomeCurrentPage()
                } else {
                    self.timerListController.becomeCurrentPage()
                }
            }
        } else {
            WKInterfaceController.reloadRootControllers(withNames: [LGV_Timer_Watch_DefaultInterfaceController.screenID], contexts: [])
       }
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
        }
    }
    
    /* ################################################################## */
    /**
     */
    func selectTimer(_ index: Int = -1) {
        if nil != self.timerListController {
            var currentIndex = -1
            if nil != self.currentTimer {
                currentIndex = self.appStatus.indexOf(self.currentTimer.timerObject.uid)
            }
            
            if 0 <= index {
                if currentIndex != index {
                    if nil != self.currentTimer {
                        self.currentTimer.stopTimer()
                    }
                    
                    self.appStatus.selectedTimerIndex = index
                    self.timerControllers[index].dontSendAnEvent = true
                    self.timerListController.pushTimer(index)
                    self.currentTimer = self.timerControllers[index]
                }
            } else {
                if currentIndex != index {
                    if nil != self.currentTimer {
                        self.currentTimer.stopTimer()
                        self.currentTimer = nil
                    }
                    self.timerListController.dontSendAnEvent = true
                    self.timerListController.becomeCurrentPage()
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            #if DEBUG
                print("Watch Received Message: " + String(describing: message))
            #endif
            
            for key in message.keys {
                switch key {
                case LGV_Timer_Messages.s_timerAppInForegroundMessageKey:
                    self.sendForegroundMessage()
                    
                case    LGV_Timer_Messages.s_timerRequestAppStatusMessageKey:
                    if let messageData = message[key] as? [String:Any] {
                        self.ignoreSelectMessageFromPhone = false
                        self.appStatus = LGV_Timer_State(dictionary: messageData)
                        self.updateAllTimerObjects()
                        self.appStatus.delegate = self
                        }
                    
                case    LGV_Timer_Messages.s_timerAppInBackgroundMessageKey:
                    self.appStatus = nil
                    self.updateAllTimerObjects()
                    
                case    LGV_Timer_Messages.s_timerListSelectTimerMessageKey:
                    if !self.ignoreSelectMessageFromPhone {
                        if nil != self.appStatus {
                            if let uid = message[key] as? String {
                                self.appStatus.selectedTimerIndex = self.appStatus.indexOf(uid)
                            }
                        }
                    } else {
                        #if DEBUG
                            print("Select From Phone Ignored. Turning Off Ignore Select From Phone.")
                        #endif
                        self.ignoreSelectMessageFromPhone = false
                    }
                    
                case    LGV_Timer_Messages.s_timerSendTickMessageKey:
                    if (nil != self.appStatus) && (0 <= self.appStatus.selectedTimerIndex) {
                        if let currentTime = message[key] as? Int {
                            let selectedController = self.timerControllers[self.appStatus.selectedTimerIndex]
                            
                            selectedController.updateTimer(currentTime)
                        }
                    }
                    
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - LGV_Timer_StateDelegate Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerStatus: TimerSettingTuple, from: TimerStatus) {
    }
    
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerDisplayMode: TimerSettingTuple, from: TimerDisplayMode) {
        DispatchQueue.main.async {
            self.updateAllTimerObjects()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerCurrentTime: TimerSettingTuple, from: Int) {
    }
    
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerWarnTime: TimerSettingTuple, from: Int) {
    }
    
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerFinalTime: TimerSettingTuple, from: Int) {
    }
    
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerTimeSet: TimerSettingTuple, from: Int) {
        DispatchQueue.main.async {
            self.updateAllTimerObjects()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerSoundID: TimerSettingTuple, from: Int) {
    }
    
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerAlertMode: TimerSettingTuple, from: AlertMode) {
    }
    
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, didUpdateTimerColorTheme: TimerSettingTuple, from: Int) {
        DispatchQueue.main.async {
            self.updateAllTimerObjects()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, didAddTimer: TimerSettingTuple) {
        DispatchQueue.main.async {
            self.updateAllTimerObjects()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, willRemoveTimer: TimerSettingTuple) {
    }
    
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, didRemoveTimerAtIndex: Int) {
        DispatchQueue.main.async {
            self.updateAllTimerObjects()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, didSelectTimer: TimerSettingTuple!) {
        DispatchQueue.main.async {
            if let selectedTimer = didSelectTimer {
                self.selectTimer(appState.indexOf(selectedTimer))
            } else {
                self.selectTimer()
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func appState(_ appState: LGV_Timer_State, didDeselectTimer: TimerSettingTuple) {
    }
}

/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_Watch_BaseInterfaceController: WKInterfaceController {
    var timerObject: TimerSettingTuple! = nil
    
    /* ################################################################## */
    /**
     */
    func updateUI() { }
}

