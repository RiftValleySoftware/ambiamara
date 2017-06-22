//
//  LGV_Timer_Watch_MainInterfaceController.swift
//  X-Timer Companion Extension
//
//  Created by Chris Marshall on 6/19/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_Watch_MainInterfaceTableRowController: NSObject {
    @IBOutlet var timerNameLabel: WKInterfaceLabel!
    @IBOutlet var timeDisplayLabel: WKInterfaceLabel!
    @IBOutlet var displayFormatImage: WKInterfaceImage!
}

/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_Watch_NoAppInterfaceController: WKInterfaceController {
    @IBOutlet var timerDismissTextButtonLabel: WKInterfaceLabel!
    @IBOutlet var timerDismissTextButtonBottomLabel: WKInterfaceLabel!
    
    var myController: LGV_Timer_Watch_MainInterfaceController! = nil
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.timerDismissTextButtonLabel.setText("LGV_TIMER-WATCH-NOT-ACTIVE-TOP-MESSAGE".localizedVariant)
        self.timerDismissTextButtonBottomLabel.setText("LGV_TIMER-WATCH-NOT-ACTIVE-BOTTOM-MESSAGE".localizedVariant)
        if let contextInfo = context as? [String:Any] {
            if let controller = contextInfo[LGV_Timer_Watch_MainInterfaceController.s_ControllerContextKey] as? LGV_Timer_Watch_MainInterfaceController {
                self.myController = controller
                self.myController.offTheChainInterfaceController = self
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func willDisappear() {
        self.myController.offTheChainInterfaceController = nil
    }
}

/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_Watch_MainInterfaceController: WKInterfaceController, WCSessionDelegate {
    static let s_TableRowID = "TimerRow"
    static let s_ModalTimerID = "IndividualTimer"
    static let s_NoAppID = "NoApp"
    static let s_ControllerContextKey = "Controller"
    static let s_TimerContextKey = "Timer"
    static let s_CurrentTimeContextKey = "CurrentTime"
    
    private var _mySession = WCSession.default()
    private var _timers: [[String: Any]] = []
    private var _offTheChain:Bool = false
    
    var offTheChainInterfaceController: LGV_Timer_Watch_NoAppInterfaceController! = nil
    var myCurrentTimer: LGV_Timer_Watch_MainTimerHandlerInterfaceController! = nil
    var youreOnYourOwn: Bool = false
    
    @IBOutlet var timerDisplayTable: WKInterfaceTable!
    
    /* ################################################################################################################################## */
    var session: WCSession {
        get {
            return self._mySession
        }
    }
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    private func _activateSession() {
        self._offTheChain = false
        if WCSession.isSupported() && (self.session.activationState != .activated) {
            self.session.delegate = self
            self.session.activate()
        }
    }
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func updateUI() {
        DispatchQueue.main.async {
            for rowIndex in 0..<self._timers.count {
                if let tableRow = self.timerDisplayTable.rowController(at: rowIndex) as? LGV_Timer_Watch_MainInterfaceTableRowController {
                    let timer = self._timers[rowIndex]
                    if let color = timer[LGV_Timer_Data_Keys.s_timerDataColorKey] as? UIColor {
                        tableRow.timerNameLabel.setTextColor(color)
                        tableRow.timeDisplayLabel.setTextColor(color)
                        if let timerName = timer[LGV_Timer_Data_Keys.s_timerDataTimerNameKey] as? String {
                            tableRow.timerNameLabel.setText(timerName)
                        }
                    }
                    
                    if let time = timer[LGV_Timer_Data_Keys.s_timerDataTimeSetKey] as? NSNumber {
                        let timeTotal = time.intValue
                        let timeInHours: Int = timeTotal / 3600
                        let timeInMinutes = (timeTotal - (timeInHours * 3600)) / 60
                        let timeInSeconds = timeTotal - ((timeInHours * 3600) + (timeInMinutes * 60))
                        let displayString = String(format: "%02d:%02d:%02d", timeInHours, timeInMinutes, timeInSeconds)
                        tableRow.timeDisplayLabel.setText(displayString)
                    }
                    
                    if let displayModeNum = timer[LGV_Timer_Data_Keys.s_timerDataDisplayModeKey] as? NSNumber {
                        let displayMode = TimerDisplayMode(rawValue: displayModeNum.intValue)
                        tableRow.displayFormatImage.setHidden(.Podium != displayMode)
                    }
                }
            }
            
            if self._offTheChain {
                self.showOffTheChainScreen()
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func showOffTheChainScreen() {
        if nil == self.offTheChainInterfaceController {
            self.dismissTimers()
            let contextInfo:[String:Any] = [type(of: self).s_ControllerContextKey:self]
            self.presentController(withName: type(of:self).s_NoAppID, context: contextInfo)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sendSelectMessage(timerUID: String = "") {
        if !self.youreOnYourOwn {
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
        
        for index in 0..<self._timers.count {
            if let uid = self._timers[index][LGV_Timer_Data_Keys.s_timerDataUIDKey] as? String {
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
        
        if let uid = self._timers[inIndex][LGV_Timer_Data_Keys.s_timerDataUIDKey] as? String {
            ret = uid
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     */
    func pushTimer(_ timerIndex: Int) {
        DispatchQueue.main.async {
            if nil == self.myCurrentTimer {
                if let uid = self._timers[timerIndex][LGV_Timer_Data_Keys.s_timerDataUIDKey] as? String {
                    self.sendSelectMessage(timerUID: uid)
                }
                
                let contextInfo:[String:Any] = [type(of: self).s_ControllerContextKey:self, type(of: self).s_TimerContextKey: self._timers[timerIndex]]
                
                self.presentController(withName: type(of: self).s_ModalTimerID, context: contextInfo)
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func dismissTimers() {
        DispatchQueue.main.async {
            if nil != self.myCurrentTimer {
                if nil != self.myCurrentTimer.modalTimerScreen {
                    self.myCurrentTimer.modalTimerScreen.dismiss()
                }
                self.myCurrentTimer.dismiss()
                self.myCurrentTimer = nil
            }
        }
    }
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.sendSelectMessage()
        self.myCurrentTimer = nil
        self._activateSession()
        self.updateUI()
    }
    
    /* ################################################################## */
    /**
     */
    override func willActivate() {
        super.willActivate()
        self.updateUI()
    }
    
    /* ################################################################## */
    /**
     */
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    /* ################################################################## */
    /**
     */
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        self.sendSelectMessage(timerUID: self.getTimerUIDForIndex(rowIndex))
        self.pushTimer(rowIndex)
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
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            for key in message.keys {
                switch key {
                case    LGV_Timer_Messages.s_timerListHowdyMessageValue:
                    if let messagePayload = message[key] as? Data {
                        if let payload = NSKeyedUnarchiver.unarchiveObject(with: messagePayload) as? [[String:Any]] {
                            self._timers = payload
                            self.timerDisplayTable.setNumberOfRows(payload.count, withRowType: type(of: self).s_TableRowID)
                            self.sendStatusRequestMessage()
                        }
                    }
                
                case LGV_Timer_Messages.s_timerListUpdateTimerMessageKey:
                    if !self._offTheChain {
                        if nil != self.myCurrentTimer {
                            if let seconds = message[key] as? Int {
                                self.myCurrentTimer.updateUI(inSeconds: seconds)
                            }
                        }
                    } else {
                        self.showOffTheChainScreen()
                        self.sendStatusRequestMessage()
                    }
                    
                case    LGV_Timer_Messages.s_timerListSelectTimerMessageKey:
                    if !self._offTheChain {
                        if let uid = message[key] as? String {
                            let timerIndex = self.getTimerIndexForUID(uid)
                            if 0 <= timerIndex {
                                var currentUID = ""
                                
                                if nil != self.myCurrentTimer {
                                    currentUID = self.myCurrentTimer.timerUID
                                }
                                
                                if currentUID.isEmpty || uid.isEmpty || (uid != currentUID) {
                                    self.dismissTimers()
                                    self.pushTimer(timerIndex)
                                }
                            } else {
                                self.dismissTimers()
                                self.updateUI()
                            }
                        } else {
                            print("Bad UID!")
                        }
                    } else {
                        self.showOffTheChainScreen()
                        self.sendStatusRequestMessage()
                    }
                    
                case    LGV_Timer_Messages.s_timerListStopTimerMessageKey:
                    if !self._offTheChain {
                        if let uid = message[key] as? String {
                            if (nil != self.myCurrentTimer) && (uid == self.myCurrentTimer.timerUID) {
                                self.myCurrentTimer.stopTimer()
                            }
                        }
                    } else {
                        self.showOffTheChainScreen()
                        self.sendStatusRequestMessage()
                    }
                    
                case    LGV_Timer_Messages.s_timerListStartTimerMessageKey:
                    if !self._offTheChain {
                        if let uid = message[key] as? String {
                            let timerIndex = self.getTimerIndexForUID(uid)
                            if 0 <= timerIndex {
                                if (nil == self.myCurrentTimer) || (uid != self.myCurrentTimer.timerUID) {
                                    self.dismissTimers()
                                    self.pushTimer(timerIndex)
                                }
                                
                                if nil != self.myCurrentTimer {
                                    self.myCurrentTimer.startTimer()
                                }
                            }
                        }
                    } else {
                        self.showOffTheChainScreen()
                    }
                    
                case    LGV_Timer_Messages.s_timerListAlarmMessageKey:
                    if !self._offTheChain {
                        if let uid = message[key] as? String {
                            if (nil == self.myCurrentTimer) || (uid != self.myCurrentTimer.timerUID) {
                                self.dismissTimers()
                            }
                            
                            if (nil != self.myCurrentTimer) && (nil != self.myCurrentTimer.modalTimerScreen) {
                                self.myCurrentTimer.modalTimerScreen.alarm()
                            }
                        }
                    } else {
                        self.showOffTheChainScreen()
                        self.sendStatusRequestMessage()
                    }
                    
                case    LGV_Timer_Messages.s_timerRequestActiveTimerUIDMessageKey:
                    if let uid = message[key] as? String {
                        if uid.isEmpty {
                            self.dismissTimers()
                        } else {
                            if (nil == self.myCurrentTimer) || (uid != self.myCurrentTimer.timerUID) {
                                self.pushTimer(self.getTimerIndexForUID(uid))
                            }
                        }
                    } else {
                        self.dismissTimers()
                    }
                    
                case    LGV_Timer_Messages.s_timerAppInForegroundMessageKey:
                    self._offTheChain = false
                    if nil != self.offTheChainInterfaceController {
                        self.offTheChainInterfaceController.dismiss()
                        self.sendActiveTimerRequestMessage()
                    }
                    self.updateUI()
                
                case    LGV_Timer_Messages.s_timerAppInBackgroundMessageKey:
                    self._offTheChain = true
                    self.showOffTheChainScreen()
                    
                default:
                    self._offTheChain = true
                    self.showOffTheChainScreen()
                    self.sendStatusRequestMessage()
                }
            }
        }
    }
}
