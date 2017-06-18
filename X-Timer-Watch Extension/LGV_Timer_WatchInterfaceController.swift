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
    // MARK: - Static Class Properties
    /* ################################################################################################################################## */
    static let s_timerListTableID = "TimerListTable"
    static let s_timerListTableRowControllerID = "TimerListTableRowController"
    static let s_timerListContextTimerElementKey = "Timer"
    static let s_timerListContextControllerElementKey = "Controller"
    static let s_StartButtonImageName: String = "Watch-Start"
    static let s_PauseButtonImageName: String = "Watch-Pause"
    
    // MARK: - IB Properties
    /* ################################################################################################################################## */
    @IBOutlet var timeDisplay: WKInterfaceLabel!
    @IBOutlet var stopButton: WKInterfaceButton!
    @IBOutlet var pauseStartButton: WKInterfaceButton!
    @IBOutlet var endButton: WKInterfaceButton!
    @IBOutlet var resetButton: WKInterfaceButton!
    @IBOutlet var pauseStartImage: WKInterfaceImage!
    @IBOutlet var timerListTable: WKInterfaceTable!
    @IBOutlet var timerControlsGroup: WKInterfaceGroup!
    
    // MARK: - Private Instance Properties
    /* ################################################################################################################################## */
    private var _timer: Timer! = nil
    private var _mySession = WCSession.default()
    private var _timerArray:[[String:Any]] = []
    private var _displayedString:String = ""
    private var _timerIsModal: Bool = false
    
    // MARK: - Internal Instance Properties
    /* ################################################################################################################################## */
    
    var currentTimeInSeconds: Int = 0
    var lastTimerDate: Date! = nil
    var timer:[String:Any]! = nil
    
    // MARK: - Internal Instance Calculated Properties
    /* ################################################################################################################################## */
    var session: WCSession {
        get {
            return self._mySession
        }
    }
    
    var timerRunning: Bool {
        get {
            return nil != self._timer
        }
    }
    
    // MARK: - Private Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    private func _alarm() {
        if nil != self._timer {
            self._timer.invalidate()
            self._timer = nil
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
    
    /* ################################################################################################################################## */
    func selectTimerByIndex(_ index: Int! = nil) {
        if nil == index {
            self.timer = nil
        } else {
            self._timerIsModal = false
            let myIndex = max(0, min(self._timerArray.count, index))
            self.timer = self._timerArray[myIndex]
        }
        
        self.selectDisplayGroup()
    }
    
    /* ################################################################################################################################## */
    func selectDisplayGroup() {
        self.timerListTable.setHidden(nil != self.timer)
        self.timerControlsGroup.setHidden(nil == self.timer)
        if nil != self.timer {
            if let color = self.timer[LGV_Timer_Data_Keys.s_timerDataColorKey] as? UIColor {
                self.timeDisplay.setTextColor(color)
            }
            
            if let timeSetInSecondsNumber = self.timer[LGV_Timer_Data_Keys.s_timerDataTimeSetKey] as? NSNumber {
                self.currentTimeInSeconds = timeSetInSecondsNumber.intValue
            }
            
            self.setProperStartPauseButton()
            self.setTimeFromSeconds()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func setProperStartPauseButton() {
        let buttonImageName = self.timerRunning ? type(of:self).s_PauseButtonImageName : type(of:self).s_StartButtonImageName
        self.pauseStartImage.setImageNamed(buttonImageName)
        self.endButton.setHidden(self._timerIsModal && (0 == self.currentTimeInSeconds))
        if let timeSetInSecondsNumber = self.timer[LGV_Timer_Data_Keys.s_timerDataTimeSetKey] as? NSNumber {
            self.resetButton.setHidden(self._timerIsModal && (self.currentTimeInSeconds == timeSetInSecondsNumber.intValue))
        }
    }
    
    /* ################################################################## */
    /**
     */
    func setTimeFromSeconds() {
        let currentSeconds = self.currentTimeInSeconds
        let hours = currentSeconds / 3600
        let minutes = (currentSeconds - (hours * 3600)) / 60
        let seconds = currentSeconds - ((hours * 3600) + (minutes * 60))
        self._displayedString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        self.timeDisplay.setText(self._displayedString)
    }
    
    /* ################################################################## */
    /**
     */
    func timerCallback(_ inTimer: Timer) {
        if nil != self.lastTimerDate {
            DispatchQueue.main.async {
                let seconds = floor(Date().timeIntervalSince(self.lastTimerDate))
                self.currentTimeInSeconds = max(0, self.currentTimeInSeconds - Int(seconds))
                
                if 0 < self.currentTimeInSeconds {
                    self.lastTimerDate = Date()
                    self.setTimeFromSeconds()
                } else {
                    self._timer.invalidate()
                    self._timer = nil
                    self._alarm()
                }
            }
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
    func sendStartMessage(timer inTimer: [String:Any]) {
        let startMessage = [LGV_Timer_Messages.s_timerListStartTimerMessageKey:inTimer[LGV_Timer_Data_Keys.s_timerDataUIDKey] as Any]
        session.sendMessage(startMessage, replyHandler: nil)
    }
    
    /* ################################################################## */
    /**
     */
    func sendPauseMessage(timer inTimer: [String:Any]) {
        let pauseMessage = [LGV_Timer_Messages.s_timerListPauseTimerMessageKey:inTimer[LGV_Timer_Data_Keys.s_timerDataUIDKey] as Any]
        session.sendMessage(pauseMessage, replyHandler: nil)
    }
    
    /* ################################################################## */
    /**
     */
    func sendStopMessage(timer inTimer: [String:Any]) {
        let stopMessage = [LGV_Timer_Messages.s_timerListStopTimerMessageKey:inTimer[LGV_Timer_Data_Keys.s_timerDataUIDKey] as Any]
        session.sendMessage(stopMessage, replyHandler: nil)
        self.selectTimerByIndex()
    }
    
    /* ################################################################## */
    /**
     */
    func sendEndMessage(timer inTimer: [String:Any]) {
        let endMessage = [LGV_Timer_Messages.s_timerListEndTimerMessageKey:inTimer[LGV_Timer_Data_Keys.s_timerDataUIDKey] as Any]
        session.sendMessage(endMessage, replyHandler: nil)
    }
    
    /* ################################################################## */
    /**
     */
    func sendResetMessage(timer inTimer: [String:Any]) {
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
        self.selectTimerByIndex(rowIndex)
    }
    
    // MARK: - IB Handler Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBAction func stopButtonHit() {
        self.sendStopMessage(timer: self.timer)
        self.pop()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func pauseStartButtonHit() {
        if self.timerRunning {
            if nil != self._timer {
                self._timer.invalidate()
                self._timer = nil
            }
            
            self.sendPauseMessage(timer: self.timer)
        } else {
            self.sendStartMessage(timer: self.timer)
            self.lastTimerDate = Date()
            self._timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(self.timerCallback(_:)), userInfo: nil, repeats: true)
            self.setTimeFromSeconds()
        }
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func endButtonHit() {
        self.sendEndMessage(timer: self.timer)
        self.currentTimeInSeconds = 0
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func resetButtonHit() {
        self.sendResetMessage(timer: self.timer)
        if let timeSetInSecondsNumber = self.timer[LGV_Timer_Data_Keys.s_timerDataTimeSetKey] as? NSNumber {
            self.currentTimeInSeconds = timeSetInSecondsNumber.intValue
        }
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
