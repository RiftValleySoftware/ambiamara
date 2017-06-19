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
class LGV_Timer_Watch_MainInterfaceController: WKInterfaceController, WCSessionDelegate {
    static let s_TableRowID = "TimerRow"
    static let s_ModalTimerID = "IndividualTimer"
    static let s_ControllerContextKey = "Controller"
    static let s_TimerContextKey = "Timer"
    
    private var _mySession = WCSession.default()
    private var _timers: [[String: Any]] = []
    
    var myCurrentTimer: LGV_Timer_Watch_MainTimerHandlerInterfaceController! = nil
    
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
        if WCSession.isSupported() && (self.session.activationState != .activated) {
            self.session.delegate = self
            self.session.activate()
        }
    }
    
    /* ################################################################## */
    /**
     */
    private func _updateUI() {
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
        }
    }
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func sendSelectMessage(timerUID: String = "") {
        let selectMsg = [LGV_Timer_Messages.s_timerListSelectTimerMessageKey:timerUID]
        self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
    }
    
    /* ################################################################## */
    /**
     */
    func sendStartMessage(timerUID: String) {
        let selectMsg = [LGV_Timer_Messages.s_timerListStartTimerMessageKey:timerUID]
        self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
    }
    
    /* ################################################################## */
    /**
     */
    func sendStopMessage(timerUID: String) {
        let selectMsg = [LGV_Timer_Messages.s_timerListStopTimerMessageKey:timerUID]
        self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
    }
    
    /* ################################################################## */
    /**
     */
    func sendPauseMessage(timerUID: String) {
        let selectMsg = [LGV_Timer_Messages.s_timerListPauseTimerMessageKey:timerUID]
        self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
    }
    
    /* ################################################################## */
    /**
     */
    func sendEndMessage(timerUID: String) {
        let selectMsg = [LGV_Timer_Messages.s_timerListEndTimerMessageKey:timerUID]
        self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
    }
    
    /* ################################################################## */
    /**
     */
    func sendResetMessage(timerUID: String) {
        let selectMsg = [LGV_Timer_Messages.s_timerListResetTimerMessageKey:timerUID]
        self.session.sendMessage(selectMsg, replyHandler: nil, errorHandler: nil)
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
        if let uid = self._timers[timerIndex][LGV_Timer_Data_Keys.s_timerDataUIDKey] as? String {
            self.sendSelectMessage(timerUID: uid)
        }
        
        let contextInfo:[String:Any] = [type(of: self).s_ControllerContextKey:self, type(of: self).s_TimerContextKey: self._timers[timerIndex]]
        
        presentController(withName: type(of: self).s_ModalTimerID, context: contextInfo)
    }
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self._activateSession()
        self._updateUI()
    }
    
    /* ################################################################## */
    /**
     */
    override func willActivate() {
        super.willActivate()
        self.sendSelectMessage()
        self.myCurrentTimer = nil
        self._updateUI()
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
        let heloMsg = [LGV_Timer_Messages.s_timerListHowdyMessageKey:LGV_Timer_Messages.s_timerListHowdyMessageValue]
        session.sendMessage(heloMsg, replyHandler: nil, errorHandler: nil)
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
                            self._updateUI()
                        }
                    }
                
                case LGV_Timer_Messages.s_timerListUpdateTimerMessageKey:
                    if nil != self.myCurrentTimer {
                        if let seconds = message[key] as? Int {
                            self.myCurrentTimer.updateUI(inSeconds: seconds)
                        }
                    }
                    
                case    LGV_Timer_Messages.s_timerListSelectTimerMessageKey:
                    if let uid = message[key] as? String {
                        let timerIndex = self.getTimerIndexForUID(uid)
                        if 0 <= timerIndex {
                            if (nil != self.myCurrentTimer) && (uid != self.myCurrentTimer.timerUID) {
                                self.myCurrentTimer.dismiss()
                                self.myCurrentTimer = nil
                            }
                            
                            if nil == self.myCurrentTimer {
                                self.pushTimer(timerIndex)
                            }
                        } else {
                            if nil != self.myCurrentTimer {
                                self.myCurrentTimer.dismiss()
                                self.myCurrentTimer = nil
                            }
                        }
                    }
                    
                case    LGV_Timer_Messages.s_timerListStartTimerMessageKey:
                    if let uid = message[key] as? String {
                        if (nil != self.myCurrentTimer) && (uid == self.myCurrentTimer.timerUID) {
                        }
                    }
                    
                default:
                    break
                }
            }
        }
    }
}
