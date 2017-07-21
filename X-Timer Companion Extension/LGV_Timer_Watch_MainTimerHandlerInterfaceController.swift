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
    var dontBotherThePhone: Bool = false
    
    @IBOutlet var trafficLightIcon: WKInterfaceImage!
    @IBOutlet var timeDisplayGroup: WKInterfaceGroup!
    @IBOutlet var timeDisplayLabel: WKInterfaceLabel!
    @IBOutlet var startButton: WKInterfaceButton!
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBAction func startButtonHit() {
        self.dontBotherThePhone = true
        LGV_Timer_Watch_ExtensionDelegate.delegateObject.sendStartMessage(timerUID: self.timerUID)
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
                
                if let currentTimeInSeconds = self.timer[LGV_Timer_Data_Keys.s_timerDataCurrentTimeKey] as? Int {
                    self.currentTimeInSeconds = currentTimeInSeconds
                }
            }
            
            let timeTotal = max(0, self.currentTimeInSeconds)
            let timeInHours: Int = timeTotal / 3600
            let timeInMinutes = (timeTotal - (timeInHours * 3600)) / 60
            let timeInSeconds = timeTotal - ((timeInHours * 3600) + (timeInMinutes * 60))
            let displayString = String(format: "%02d:%02d:%02d", timeInHours, timeInMinutes, timeInSeconds)
            self.timeDisplayLabel.setText(displayString)
            
            if let timeSet = self.timer[LGV_Timer_Data_Keys.s_timerDataTimeSetKey] as? Int {
                self.startButton.setHidden(0 == timeSet)
            } else {
                self.startButton.setHidden(true)
            }
            
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
        self.updateUI()

        if nil != self.modalTimerScreen {
            self.modalTimerScreen.dismiss()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func startTimer() {
        self.updateUI()
        self.pushTimer()
    }
    
    /* ################################################################## */
    /**
     */
    func pushTimer() {
        DispatchQueue.main.async {
            if nil == self.modalTimerScreen {
                self.dontBotherThePhone = false
                let contextInfo:[String:Any] = [LGV_Timer_Watch_MainAppInterfaceController.s_ControllerContextKey:self, LGV_Timer_Watch_MainAppInterfaceController.s_TimerContextKey: self.timer, LGV_Timer_Watch_MainAppInterfaceController.s_CurrentTimeContextKey: self.currentTimeInSeconds]
                
                self.presentController(withName: LGV_Timer_Watch_RunningTimerInterfaceController.screenID, context: contextInfo)
            }
        }
    }

    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    /* ################################################################## */
    /**
     */
    override func didAppear() {
        super.didAppear()
    }
    
    /* ################################################################## */
    /**
     */
    override func willDisappear() {
        super.willDisappear()
    }
}
