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
class LGV_Timer_TimerListInterfaceController: WKInterfaceController, WCSessionDelegate {
    static let s_timerListTableID = "TimerListTable"
    static let s_timerListTableRowControllerID = "TimerListTableRowController"
    
    // MARK: - IB Properties
    /* ################################################################################################################################## */
    @IBOutlet var timerListTable: WKInterfaceTable!
    
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
                self.timerListTable.setNumberOfRows(timerArray.count, withRowType: type(of:self).s_timerListTableRowControllerID)
                for row in 0..<timerArray.count {
                    if let controller = self.timerListTable.rowController(at: row) as? LGV_Timer_TimerListTableRowController {
                        let timer = timerArray[row]
                        controller.timerNameLabel.setText("Timer \(row + 1)")
                        if let color = timer[LGV_Timer_Data_Keys.s_timerDataColorKey] as? UIColor {
                            print("\(color)")
                            controller.timerNameLabel.setTextColor(color)
                            controller.timerValueLabel.setTextColor(color)
                            if let timeSetInSecondsNumber = timer[LGV_Timer_Data_Keys.s_timerDataTimeSetKey] as? NSNumber {
                                let timeSetInSeconds = timeSetInSecondsNumber.intValue
                                let hours = timeSetInSeconds / 3600
                                let minutes = (timeSetInSeconds - (hours * 3600)) / 60
                                let seconds = timeSetInSeconds - ((hours * 3600) + (minutes * 60))
                                let displayString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
                                controller.timerValueLabel.setText(displayString)
                            }
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
