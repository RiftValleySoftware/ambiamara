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
        super.willDisappear()
        self.myController.myCurrentTimer = nil
    }
}
