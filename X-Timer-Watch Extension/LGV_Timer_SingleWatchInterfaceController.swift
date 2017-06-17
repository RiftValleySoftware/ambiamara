//
//  LGV_Timer_SingleWatchInterfaceController.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 6/16/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//

import WatchKit
import Foundation

class LGV_Timer_SingleWatchInterfaceController: WKInterfaceController {
    // MARK: - Static Class Properties
    /* ################################################################################################################################## */
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
    // MARK: - Private Instance Properties
    /* ################################################################################################################################## */
    private var _timerRunning: Bool = false
    
    var timer:[String:Any] = [:]
    var mainController: LGV_Timer_TimerListInterfaceController! = nil

    // MARK: - Internal Instance Methods
    /* ################################################################################################################################## */
    func setProperStartPauseButton() {
        let buttonImageName = self._timerRunning ? type(of:self).s_PauseButtonImageName : type(of:self).s_StartButtonImageName
        self.pauseStartImage.setImageNamed(buttonImageName)
    }
    
    // MARK: - IB Handler Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBAction func stopButtonHit() {
        self.mainController.sendStopMessage(self, timer: self.timer)
        self.pop()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func pauseStartButtonHit() {
        if self._timerRunning {
            self.mainController.sendPauseMessage(self, timer: self.timer)
        } else {
            self.mainController.sendStartMessage(self, timer: self.timer)
        }
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func endButtonHit() {
        self.mainController.sendEndMessage(self, timer: self.timer)
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func resetButtonHit() {
        self.mainController.sendResetMessage(self, timer: self.timer)
    }
    
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if let theContext = context as? [String:Any] {
            if let theController = theContext[LGV_Timer_TimerListInterfaceController.s_timerListContextControllerElementKey] as? LGV_Timer_TimerListInterfaceController {
                self.mainController = theController
                if let theTimer = theContext[LGV_Timer_TimerListInterfaceController.s_timerListContextTimerElementKey] as? [String:Any] {
                    self.timer = theTimer
                    self.setProperStartPauseButton()
                    if let color = self.timer[LGV_Timer_Data_Keys.s_timerDataColorKey] as? UIColor {
                        self.timeDisplay.setTextColor(color)
                        if let timeSetInSecondsNumber = self.timer[LGV_Timer_Data_Keys.s_timerDataTimeSetKey] as? NSNumber {
                            let timeSetInSeconds = timeSetInSecondsNumber.intValue
                            let hours = timeSetInSeconds / 3600
                            let minutes = (timeSetInSeconds - (hours * 3600)) / 60
                            let seconds = timeSetInSeconds - ((hours * 3600) + (minutes * 60))
                            let displayString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
                            self.timeDisplay.setText(displayString)
                        }
                    }
                }
            }
        }
    }
}
