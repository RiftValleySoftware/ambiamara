//
//  LGV_Timer_Watch_MainTimerHandlerInterfaceController.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 6/19/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//

import WatchKit

/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_Watch_MainTimerHandlerInterfaceController: LGV_Timer_Watch_BaseInterfaceController {
    static var screenID: String { get { return "TimerScreen"} }

    var myController: LGV_Timer_Watch_MainAppInterfaceController! = nil
    var modalTimerScreen: LGV_Timer_Watch_RunningTimerInterfaceController! = nil
    var currentTimeInSeconds: Int = 0
    var leaveMeAlone: Bool = false
    
    @IBOutlet var trafficLightIcon: WKInterfaceImage!
    @IBOutlet var timeDisplayGroup: WKInterfaceGroup!
    @IBOutlet var timeDisplayLabel: WKInterfaceLabel!
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBAction func startButtonHit() {
        LGV_Timer_Watch_ExtensionDelegate.delegateObject.sendStartMessage(timerUID: self.timerUID)
        self.pushTimer()
    }
    
    /* ################################################################## */
    /**
     */
    override func updateUI() {
        self.updateUI(inSeconds: nil)
    }

    /* ################################################################## */
    /**
     */
    func updateUI(inSeconds: Int!) {
        DispatchQueue.main.async {
            if nil != inSeconds {
                self.currentTimeInSeconds = inSeconds
            } else {
                if let timeSetNum = self.timer[LGV_Timer_Data_Keys.s_timerDataTimeSetKey] as? NSNumber {
                    self.currentTimeInSeconds = timeSetNum.intValue
                }
            }
            
            let timeTotal = max(0, self.currentTimeInSeconds)
            let timeInHours: Int = timeTotal / 3600
            let timeInMinutes = (timeTotal - (timeInHours * 3600)) / 60
            let timeInSeconds = timeTotal - ((timeInHours * 3600) + (timeInMinutes * 60))
            let displayString = String(format: "%02d:%02d:%02d", timeInHours, timeInMinutes, timeInSeconds)
            self.timeDisplayLabel.setText(displayString)
            if nil != self.modalTimerScreen {
                self.modalTimerScreen.updateUI(inSeconds: self.currentTimeInSeconds)
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func alarm() {
        if nil != self.modalTimerScreen {
            self.modalTimerScreen.alarm()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func stopTimer() {
        if nil != self.modalTimerScreen {
            self.leaveMeAlone = true
            self.modalTimerScreen.dismiss()
        }
        
        if let timeSetNum = self.timer[LGV_Timer_Data_Keys.s_timerDataTimeSetKey] as? NSNumber {
            self.currentTimeInSeconds = timeSetNum.intValue
            self.updateUI()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func startTimer() {
        if let time = (self.timer[LGV_Timer_Data_Keys.s_timerDataTimeSetKey] as? NSNumber)?.intValue {
            if !(1..<time ~= self.currentTimeInSeconds) {
                self.currentTimeInSeconds = time
            }
        }
        
        self.pushTimer()
    }
    
    /* ################################################################## */
    /**
     */
    func pauseTimer() {
        if nil != self.modalTimerScreen {
            self.leaveMeAlone = true
            self.modalTimerScreen.dismiss()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func pushTimer() {
        DispatchQueue.main.async {
            if nil == self.modalTimerScreen {
                self.leaveMeAlone = true
                let contextInfo:[String:Any] = [LGV_Timer_Watch_MainAppInterfaceController.s_ControllerContextKey:self, LGV_Timer_Watch_MainAppInterfaceController.s_TimerContextKey: self.timer, LGV_Timer_Watch_MainAppInterfaceController.s_CurrentTimeContextKey: self.currentTimeInSeconds]
                
                self.presentController(withName: LGV_Timer_Watch_RunningTimerInterfaceController.screenID, context: contextInfo)
            }
        }
    }

    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override init() {
        super.init()
        LGV_Timer_Watch_ExtensionDelegate.delegateObject.timerObjects.append(self)
        
    }
    
    /* ################################################################## */
    /**
     */
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.modalTimerScreen = nil
        self.leaveMeAlone = false
        if let contextInfo = context as? [String:Any] {
            if let controller = contextInfo[LGV_Timer_Watch_MainAppInterfaceController.s_ControllerContextKey] as? LGV_Timer_Watch_MainAppInterfaceController {
                self.myController = controller
            }

            if let timer = contextInfo[LGV_Timer_Watch_MainAppInterfaceController.s_TimerContextKey] as? [String:Any] {
                self.timer = timer
                if let time = (self.timer[LGV_Timer_Data_Keys.s_timerDataTimeSetKey] as? NSNumber)?.intValue {
                    self.currentTimeInSeconds = time
                }

                if let color = self.timer[LGV_Timer_Data_Keys.s_timerDataColorKey] as? UIColor {
                    self.timeDisplayLabel.setTextColor(color)
                }
                
                if let name = self.timer[LGV_Timer_Data_Keys.s_timerDataTimerNameKey] as? String {
                    self.setTitle(name)
                }
                
                if let displayModeNum = self.timer[LGV_Timer_Data_Keys.s_timerDataDisplayModeKey] as? NSNumber {
                    let displayMode = TimerDisplayMode(rawValue: displayModeNum.intValue)
                    self.trafficLightIcon.setHidden(.Podium != displayMode)
                }
            }
            
            self.updateUI()
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func didAppear() {
        super.didAppear()
        LGV_Timer_Watch_ExtensionDelegate.delegateObject.currentTimer = self
        if !self.leaveMeAlone {
            LGV_Timer_Watch_ExtensionDelegate.delegateObject.sendSelectMessage(timerUID: self.timerUID)
        }
        self.leaveMeAlone = false
    }
    
    /* ################################################################## */
    /**
     */
    override func willDisappear() {
        if !self.leaveMeAlone && (nil != self.modalTimerScreen) {
            self.modalTimerScreen.dismiss()
        }
        
        if let timeSetNum = self.timer[LGV_Timer_Data_Keys.s_timerDataTimeSetKey] as? NSNumber {
            self.currentTimeInSeconds = timeSetNum.intValue
        }
        
        super.willDisappear()
        self.leaveMeAlone = false
    }
}
