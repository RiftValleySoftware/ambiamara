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
    private var _mySession = WCSession.default
    private var _timerObject: Timer! = nil
    private var _offTheChain:Bool = true
    
    /* ################################################################################################################################## */
    var timers: [[String: Any]] = []
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
        if self.session.isReachable {
            let selectMsg = [LGV_Timer_Messages.s_timerListSelectTimerMessageKey:timerUID]
            self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendAskForListMessage() {
        let selectMsg = [LGV_Timer_Messages.s_timerSendListAgainMessageKey:""]
        self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
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
    
    /* ################################################################## */
    /**
     */
    func updateTimerGivenUID(_ inUID: String, selectTimer: Bool = false) {
        let index = self.getTimerIndexForUID(inUID)
        
        if 0..<self.timerObjects.count ~= index {
            DispatchQueue.main.async {
                let controller = self.timerObjects[index]
                if selectTimer && (controller != self.currentTimer) {
                    controller.dontBotherThePhone = true
                    controller.becomeCurrentPage()
                }
                
                if let currentTime = self.timers[index][LGV_Timer_Data_Keys.s_timerDataCurrentTimeKey] as? Int {
                    controller.timer = self.timers[index]
                    controller.updateUI(inSeconds: currentTime)
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func process(userInfo: [String : Any] = [:]) {
        if let messagePayload = userInfo[LGV_Timer_Messages.s_timerStatusUserInfoValue] as? Data {
            let uid = self.setTimerObject(messagePayload)
            
            if !uid.isEmpty {
                let index = self.getTimerIndexForUID(uid)
                self.timerObjects[index].timer = self.timers[index]
                self.timerObjects[index].updateUI()
            }
        } else {
            if let uid = userInfo[LGV_Timer_Messages.s_timerAlarmUserInfoValue] as? String {
                let index = self.getTimerIndexForUID(uid)
                if 0 <= index {
                    self.timerObjects[index].timer = self.timers[index]
                    self.updateTimerGivenUID(uid, selectTimer: true)
                    self.timerObjects[index].alarm()
                }
            }
            
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
                backgroundTask.setTaskCompletedWithSnapshot(true)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                self.process(userInfo: connectivityTask.userInfo as! [String : Any])
                connectivityTask.setTaskCompletedWithSnapshot(true)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(true)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(true)
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
        }
    }
    
    /* ################################################################## */
    /**
     */
    func populateScreens(noTimers: Bool) {
        var namesAndContexts: [(name: String, context: AnyObject)] = []
        
        if !noTimers {
            for timer in self.timers {
                let nameAndContext: (name: String, context: AnyObject) = (name: LGV_Timer_Watch_MainTimerHandlerInterfaceController.screenID,
                                                                          context: [LGV_Timer_Watch_MainAppInterfaceController.s_ControllerContextKey:self,LGV_Timer_Watch_MainAppInterfaceController.s_TimerContextKey:timer] as AnyObject)
                namesAndContexts.append(nameAndContext)
            }
        }
        
        WKInterfaceController.reloadRootControllers(withNamesAndContexts: namesAndContexts)
    }
    
    /* ################################################################## */
    /**
     */
    func addTimerControllerIfNotAlreadyThere(controller: LGV_Timer_Watch_MainTimerHandlerInterfaceController) {
        var found: Bool = false
        for timerObject in self.timerObjects {
            if timerObject == controller {
                found = true
                break
            }
        }
        
        if !found {
            self.timerObjects.append(controller)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func setTimerObject(_ inData: Data) -> String {
        if let payload = NSKeyedUnarchiver.unarchiveObject(with: inData) as? [String:Any] {
            if let uid = payload[LGV_Timer_Data_Keys.s_timerDataUIDKey] as? String {
                let index = self.getTimerIndexForUID(uid)
                if 0..<self.timers.count ~= index {
                    self.timers[index] = payload
                    self.timerObjects[index].timer = payload
                    self.updateTimerGivenUID(uid)
                    
                    return uid
               }
            }
        }
        
        return ""
    }
    
    /* ################################################################## */
    /**
     */
    func updateAllTimerObjects(inTimerList: [[String:Any]]) {
        var index: Int = 0
        var deleteList: [Int] = []
        var updateList: [LGV_Timer_Watch_BaseInterfaceController] = []
        
        for timerObject in self.timerObjects {
            let uid = timerObject.timerUID
            var found: Bool = false
            for timerData in inTimerList {
                if let timerUID = timerData[LGV_Timer_Data_Keys.s_timerDataUIDKey] as? String {
                    if timerUID == uid {
                        if self.timers.count == index {
                            self.timers.append(timerData)
                        } else {
                            self.timers[index] = timerData
                        }
                        timerObject.timer = self.timers[index]
                        updateList.append(timerObject)
                        found = true
                        break
                    }
                }
            }
            
            if !found {
                deleteList.append(index)
            }
            
            index += 1
        }
        
        while let delIndex = deleteList.popLast() {
            self.timers.remove(at: delIndex)
            self.timerObjects.remove(at: delIndex)
        }
        
        for updateObject in updateList {
            updateObject.updateUI()
        }
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
                case    LGV_Timer_Messages.s_timerListHowdyMessageValue:
                    if let messagePayload = message[key] as? Data {
                        if let payload = NSKeyedUnarchiver.unarchiveObject(with: messagePayload) as? [[String:Any]] {
                            self.timers = payload
                            if 0 < payload.count {
                                self.populateScreens(noTimers: false)
                                self.sendActiveTimerRequestMessage()
                            } else {
                                self.sendAskForListMessage()
                            }
                        }
                    }
                    
                case    LGV_Timer_Messages.s_timerSendListAgainMessageKey:
                    if let messagePayload = message[key] as? Data {
                        if let payload = NSKeyedUnarchiver.unarchiveObject(with: messagePayload) as? [[String:Any]] {
                            self.timers = payload
                            if 0 < payload.count {
                                self.populateScreens(noTimers: false)
                                self.sendActiveTimerRequestMessage()
                            } else {
                                self.sendAskForListMessage()
                            }
                        }
                    }
                    
                case    LGV_Timer_Messages.s_timerRecaclulateTimersMessageKey:
                    if let messagePayload = message[key] as? Data {
                        if let payload = NSKeyedUnarchiver.unarchiveObject(with: messagePayload) as? [[String:Any]] {
                            let oldController = self.currentTimer
                            self.updateAllTimerObjects(inTimerList: payload)
                            if (nil != oldController) && self.timerObjects.contains(oldController!) {
                                oldController!.becomeCurrentPage()
                            } else {
                                self.timerListController.becomeCurrentPage()
                            }
                            self._offTheChain = true
                            self.sendStatusRequestMessage()
                        }
                    }
                    
                case    LGV_Timer_Messages.s_timerListSelectTimerMessageKey:
                    if !self.appDisconnected {
                        if let uid = message[key] as? String {
                            let index = self.getTimerIndexForUID(uid)
                            if let timerObject = self.currentTimer {
                                timerObject.dontBotherThePhone = true
                                if index != timerObject.timerIndex {
                                    self.updateTimerGivenUID(timerObject.timerUID)
                                    timerObject.stopTimer()
                                }
                            }
                            if 0 <= index {
                                self.updateTimerGivenUID(uid, selectTimer: true)
                            } else {
                                self.timerListController.becomeCurrentPage()
                            }
                        }
                    } else {
                        self.sendStatusRequestMessage()
                    }
                    
                case    LGV_Timer_Messages.s_timerRequestActiveTimerUIDMessageKey:
                    if !self.appDisconnected {
                        if let uid = message[key] as? String {
                            let index = self.getTimerIndexForUID(uid)
                            if 0 <= index {
                                self.timerObjects[index].dontBotherThePhone = true
                                self.timerObjects[index].becomeCurrentPage()
                            }
                        } else {
                            self.timerListController.becomeCurrentPage()
                        }

                    } else {
                        self.sendStatusRequestMessage()
                    }
                
                case    LGV_Timer_Messages.s_timerAppInForegroundMessageKey:
                    if self.appDisconnected {
                        self._offTheChain = false
                        self.timerObjects = []
                        self.sendAskForListMessage()
                    }
                    
                case    LGV_Timer_Messages.s_timerAppInBackgroundMessageKey:
                    self._offTheChain = true
                    self.timerObjects = []
                    self.populateScreens(noTimers: true)
                    
                case LGV_Timer_Messages.s_timerListUpdateFullTimerMessageKey:
                    if let messagePayload = message[key] as? Data {
                        let uid = self.setTimerObject(messagePayload)
                        
                        if !uid.isEmpty {
                            let index = self.getTimerIndexForUID(uid)
                            self.timerObjects[index].timer = self.timers[index]
                            self.timerObjects[index].updateUI()
                        }

                    }
                    
                case    LGV_Timer_Messages.s_timerListStopTimerMessageKey:
                    if !self.appDisconnected {
                        if let messagePayload = message[key] as? Data {
                            let uid = self.setTimerObject(messagePayload)
                            
                            if !uid.isEmpty {
                                let index = self.getTimerIndexForUID(uid)
                                self.timerObjects[index].timer = self.timers[index]
                                self.timerObjects[index].stopTimer()
                            }
    
                        }
                    } else {
                        self.sendStatusRequestMessage()
                    }
                    
                case    LGV_Timer_Messages.s_timerListResetTimerMessageKey:
                    if !self.appDisconnected {
                        if let messagePayload = message[key] as? Data {
                            let uid = self.setTimerObject(messagePayload)
                            
                            if !uid.isEmpty {
                                let index = self.getTimerIndexForUID(uid)
                                self.timerObjects[index].timer = self.timers[index]
                                self.timerObjects[index].updateUI()
                            }
    
                        }
                    } else {
                        self.sendStatusRequestMessage()
                    }
                    
                case    LGV_Timer_Messages.s_timerListStartTimerMessageKey:
                    if !self.appDisconnected {
                        if let messagePayload = message[key] as? Data {
                            let uid = self.setTimerObject(messagePayload)
                            
                            if !uid.isEmpty {
                                let index = self.getTimerIndexForUID(uid)
                                self.timerObjects[index].timer = self.timers[index]
                                self.timerObjects[index].startTimer()
                            }
    
                        }
                    } else {
                        self.sendStatusRequestMessage()
                    }
                    
                case    LGV_Timer_Messages.s_timerListEndTimerMessageKey:
                    if !self.appDisconnected {
                        if let messagePayload = message[key] as? Data {
                            let uid = self.setTimerObject(messagePayload)
                            
                            if !uid.isEmpty {
                                let index = self.getTimerIndexForUID(uid)
                                self.timerObjects[index].timer = self.timers[index]
                                self.timerObjects[index].updateUI()
                            }
    
                        }
                    } else {
                        self.sendStatusRequestMessage()
                    }

                case    LGV_Timer_Messages.s_timerListAlarmMessageKey:
                    if !self.appDisconnected {
                        if let uid = message[key] as? String {
                            let index = self.getTimerIndexForUID(uid)
                            if 0 <= index {
                                self.timerObjects[index].timer = self.timers[index]
                                self.updateTimerGivenUID(uid, selectTimer: true)
                                self.timerObjects[index].alarm()
                            }
    
                        }
                    } else {
                        self.sendStatusRequestMessage()
                    }
                    
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

