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
    static let s_RunningTimerInterfaceID = "RunningTimer"
    
    private var _lastTimerDate: Date! = nil
    
    var myController: LGV_Timer_Watch_MainAppInterfaceController! = nil
    var modalTimerScreen: LGV_Timer_Watch_RunningTimerInterfaceController! = nil
    var currentTimeInSeconds: Int = 0
    var disgustingHackSemaphore: Bool = false
    
    @IBOutlet var trafficLightIcon: WKInterfaceImage!
    @IBOutlet var timeDisplayGroup: WKInterfaceGroup!
    @IBOutlet var timeDisplayLabel: WKInterfaceLabel!
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBAction func startButtonHit() {
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
            let oldSeconds = self.currentTimeInSeconds
            
            if nil != inSeconds {
                self.currentTimeInSeconds = inSeconds
            } else {
                if let timeSetNum = self.timer[LGV_Timer_Data_Keys.s_timerDataTimeSetKey] as? NSNumber {
                    self.currentTimeInSeconds = timeSetNum.intValue
                }
            }
            
            if nil != self.modalTimerScreen {
                self.modalTimerScreen.updateUI(inSeconds: self.currentTimeInSeconds, inOldSeconds: oldSeconds)
            }
            
            let timeTotal = max(0, self.currentTimeInSeconds)
            let timeInHours: Int = timeTotal / 3600
            let timeInMinutes = (timeTotal - (timeInHours * 3600)) / 60
            let timeInSeconds = timeTotal - ((timeInHours * 3600) + (timeInMinutes * 60))
            let displayString = String(format: "%02d:%02d:%02d", timeInHours, timeInMinutes, timeInSeconds)
            self.timeDisplayLabel.setText(displayString)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func stopTimer() {
        if nil != self.modalTimerScreen {
            self.modalTimerScreen.pop()
            self.modalTimerScreen = nil
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
        if nil != self.modalTimerScreen {
            self.modalTimerScreen.pop()
            self.modalTimerScreen = nil
        }
        
        if let timeSetNum = self.timer[LGV_Timer_Data_Keys.s_timerDataTimeSetKey] as? NSNumber {
            self.currentTimeInSeconds = timeSetNum.intValue
        }
        
        self.pushTimer()
    }
    
    /* ################################################################## */
    /**
     */
    func pushTimer() {
        self.disgustingHackSemaphore = true
        DispatchQueue.main.async {
            if nil == self.modalTimerScreen {
                if let uid = LGV_Timer_Watch_ExtensionDelegate.delegateObject.timers[self.timerIndex][LGV_Timer_Data_Keys.s_timerDataUIDKey] as? String {
                    LGV_Timer_Watch_ExtensionDelegate.delegateObject.sendSelectMessage(timerUID: uid)
                }
                
                let contextInfo:[String:Any] = [LGV_Timer_Watch_MainAppInterfaceController.s_ControllerContextKey:self, LGV_Timer_Watch_MainAppInterfaceController.s_TimerContextKey: self.timer, LGV_Timer_Watch_MainAppInterfaceController.s_CurrentTimeContextKey: self.currentTimeInSeconds]
                
                self.pushController(withName: type(of: self).s_RunningTimerInterfaceID, context: contextInfo)
            }
        }
    }

    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.modalTimerScreen = nil
        if let contextInfo = context as? [String:Any] {
            if let controller = contextInfo[LGV_Timer_Watch_MainAppInterfaceController.s_ControllerContextKey] as? LGV_Timer_Watch_MainAppInterfaceController {
                self.myController = controller
                self.myController.myCurrentTimer = self
            }

            if let timer = contextInfo[LGV_Timer_Watch_MainAppInterfaceController.s_TimerContextKey] as? [String:Any] {
                self.timer = timer
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
    override func willActivate() {
        super.willActivate()
        self.modalTimerScreen = nil
    }
    
    /* ################################################################## */
    /**
     */
    override func willDisappear() {
        if nil != self.modalTimerScreen {
            self.modalTimerScreen.closeMe()
            self.modalTimerScreen = nil
        }
        
        if !self.disgustingHackSemaphore {
            LGV_Timer_Watch_ExtensionDelegate.delegateObject.closingTimer(timerIndex: self.timerIndex)
        }
        
        self.disgustingHackSemaphore = false
        super.willDisappear()
    }
    
    /* ################################################################## */
    /**
     */
    override func closeMe() {
        if nil != self.modalTimerScreen {
            self.modalTimerScreen.closeMe()
            self.modalTimerScreen = nil
        }
        super.closeMe()
    }
}
