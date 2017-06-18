//
//  LGV_Timer_WatchInterfaceController.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 6/11/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

/* ###################################################################################################################################### */
/**
 This class describes the list of timers that is first presented in the Watch interface.
 */
class LGV_Timer_TimerListInterfaceController: WKInterfaceController, WCSessionDelegate {
    static let s_timerListTableID = "TimerListTable"
    static let s_timerListTableRowControllerID = "TimerListTableRowController"
    static let s_timerListSingleWatchControllerID = "LGV_Timer_SingleWatchInterfaceController"
    static let s_timerListContextTimerElementKey = "Timer"
    static let s_timerListContextControllerElementKey = "Controller"
    
    // MARK: - IB Properties
    /* ################################################################################################################################## */
    @IBOutlet var timerListTable: WKInterfaceTable!
    
    // MARK: - Private Instance Properties
    /* ################################################################################################################################## */
    private var _mySession = WCSession.default()
    private var _timerArray:[[String:Any]] = []
    
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
    
    /* ################################################################## */
    /**
     */
    func sendSelectMessage(timer inTimer: [String:Any]! = nil) {
        var selectMessage = [LGV_Timer_Messages.s_timerListSelectTimerMessageKey:""]
        if nil != inTimer {
            if let uid = inTimer[LGV_Timer_Data_Keys.s_timerDataUIDKey] as? String {
                selectMessage[LGV_Timer_Messages.s_timerListSelectTimerMessageKey] = uid
            }
        }
        session.sendMessage(selectMessage, replyHandler: nil)
    }
    
    /* ################################################################## */
    /**
     */
    func sendStartMessage(_ inController:LGV_Timer_SingleWatchInterfaceController, timer inTimer: [String:Any]) {
        let startMessage = [LGV_Timer_Messages.s_timerListStartTimerMessageKey:inTimer[LGV_Timer_Data_Keys.s_timerDataUIDKey] as Any]
        session.sendMessage(startMessage, replyHandler: nil)
    }
    
    /* ################################################################## */
    /**
     */
    func sendPauseMessage(_ inController:LGV_Timer_SingleWatchInterfaceController, timer inTimer: [String:Any]) {
        let pauseMessage = [LGV_Timer_Messages.s_timerListPauseTimerMessageKey:inTimer[LGV_Timer_Data_Keys.s_timerDataUIDKey] as Any]
        session.sendMessage(pauseMessage, replyHandler: nil)
    }
    
    /* ################################################################## */
    /**
     */
    func sendStopMessage(_ inController:LGV_Timer_SingleWatchInterfaceController, timer inTimer: [String:Any]) {
        let stopMessage = [LGV_Timer_Messages.s_timerListStopTimerMessageKey:inTimer[LGV_Timer_Data_Keys.s_timerDataUIDKey] as Any]
        session.sendMessage(stopMessage, replyHandler: nil)
    }
    
    /* ################################################################## */
    /**
     */
    func sendEndMessage(_ inController:LGV_Timer_SingleWatchInterfaceController, timer inTimer: [String:Any]) {
        let endMessage = [LGV_Timer_Messages.s_timerListEndTimerMessageKey:inTimer[LGV_Timer_Data_Keys.s_timerDataUIDKey] as Any]
        session.sendMessage(endMessage, replyHandler: nil)
    }
    
    /* ################################################################## */
    /**
     */
    func sendResetMessage(_ inController:LGV_Timer_SingleWatchInterfaceController, timer inTimer: [String:Any]) {
        let resetMessage = [LGV_Timer_Messages.s_timerListResetTimerMessageKey:inTimer[LGV_Timer_Data_Keys.s_timerDataUIDKey] as Any]
        session.sendMessage(resetMessage, replyHandler: nil)
    }
    
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.activateSession()
    }

    /* ################################################################## */
    /**
     */
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        self.sendSelectMessage(timer: self._timerArray[rowIndex])
        let context:[String:Any] = [type(of:self).s_timerListContextTimerElementKey:self._timerArray[rowIndex], type(of:self).s_timerListContextControllerElementKey:self]
        pushController(withName: type(of:self).s_timerListSingleWatchControllerID, context:context)
    }
    
    // MARK: - WCSessionDelegate Protocol Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch App: LGV_Timer_TimerListInterfaceController.session(_:,activationDidCompleteWith:,error:)\n\(String(describing: error))")
        let wakeUpMessage = [LGV_Timer_Messages.s_timerListHowdyMessageKey:LGV_Timer_Messages.s_timerListHowdyMessageValue]
        session.sendMessage(wakeUpMessage, replyHandler: nil)
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]){
        print("Watch App: LGV_Timer_TimerListInterfaceController.session(_:,didReceiveApplicationContext:)\n\(applicationContext)")
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let value = message[LGV_Timer_Messages.s_timerListHowdyMessageValue] as? Data {
            let responseArray = NSKeyedUnarchiver.unarchiveObject(with:value)
            if let timerArray = responseArray as? [[String:Any]] {
                self._timerArray = timerArray
                self.timerListTable.setNumberOfRows(self._timerArray.count, withRowType: type(of:self).s_timerListTableRowControllerID)
                for row in 0..<self._timerArray.count {
                    if let controller = self.timerListTable.rowController(at: row) as? LGV_Timer_TimerListTableRowController {
                        let timer = self._timerArray[row]
                        if let color = timer[LGV_Timer_Data_Keys.s_timerDataColorKey] as? UIColor {
                            controller.timerNameLabel.setTextColor(color)
                            controller.timerValueLabel.setTextColor(color)
                            
                            if let timerName = timer[LGV_Timer_Data_Keys.s_timerDataTimerNameKey] as? String {
                                controller.timerNameLabel.setText(timerName)
                            }
                            
                            if let timeSetInSecondsNumber = timer[LGV_Timer_Data_Keys.s_timerDataTimeSetKey] as? NSNumber {
                                let timeSetInSeconds = timeSetInSecondsNumber.intValue
                                let hours = timeSetInSeconds / 3600
                                let minutes = (timeSetInSeconds - (hours * 3600)) / 60
                                let seconds = timeSetInSeconds - ((hours * 3600) + (minutes * 60))
                                let displayString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
                                controller.timerValueLabel.setText(displayString)
                            }
                        }
                        
                        if let displayMode = timer[LGV_Timer_Data_Keys.s_timerDataDisplayModeKey] as? NSNumber {
                            controller.displayModeImage.setHidden(TimerDisplayMode.Podium.rawValue != displayMode.intValue)
                        }
                    }
                }
            }
        } else {
        }
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("Watch App: LGV_Timer_TimerListInterfaceController.session(_:,didReceiveMessage:,replyHandler:)\n\(message)")
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        print("Watch App: LGV_Timer_TimerListInterfaceController.session(_:,didReceiveMessageData:)\n\(messageData)")
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        print("Watch App: LGV_Timer_TimerListInterfaceController.session(_:,didReceiveMessageData:,replyHandler:)\n\(messageData)")
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("Watch App: LGV_Timer_TimerListInterfaceController.session(_:,didReceiveUserInfo:)\n\(userInfo)")
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        print("Watch App: LGV_Timer_TimerListInterfaceController.session(_:,didFinish:,error:)\n\(userInfoTransfer)\n\(String(describing: error))")
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print("Watch App: LGV_Timer_TimerListInterfaceController.session(_:,didReceive:)\n\(file)")
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        print("Watch App: LGV_Timer_TimerListInterfaceController.session(_:,didFinish:)\n\(fileTransfer)\n\(String(describing: error))")
    }
}
