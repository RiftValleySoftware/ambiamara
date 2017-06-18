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
    private var _timerModal: Bool = false
    private var _timer: Timer! = nil
    
    var currentTimeInSeconds: Int = 0
    var lastTimerDate: Date! = nil
    
    var timer:[String:Any] = [:]
    var mainController: LGV_Timer_TimerListInterfaceController! = nil
    
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
    /* ################################################################## */
    /**
     */
    func setProperStartPauseButton() {
        let buttonImageName = self.timerRunning && self._timerModal ? type(of:self).s_PauseButtonImageName : type(of:self).s_StartButtonImageName
        self.pauseStartImage.setImageNamed(buttonImageName)
        self.endButton.setHidden(!self._timerModal || (0 == self.currentTimeInSeconds))
        self.stopButton.setHidden(!self._timerModal)
        if let timeSetInSecondsNumber = self.timer[LGV_Timer_Data_Keys.s_timerDataTimeSetKey] as? NSNumber {
            self.resetButton.setHidden(!self._timerModal || (self.currentTimeInSeconds == timeSetInSecondsNumber.intValue))
        }
    }
    
    /* ################################################################## */
    /**
     */
    func setTimeFromSeconds() {
        DispatchQueue.main.async {
            let currentSeconds = self.currentTimeInSeconds
            let hours = currentSeconds / 3600
            let minutes = (currentSeconds - (hours * 3600)) / 60
            let seconds = currentSeconds - ((hours * 3600) + (minutes * 60))
            let displayString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            if let color = self.timer[LGV_Timer_Data_Keys.s_timerDataColorKey] as? UIColor {
                self.timeDisplay.setTextColor(color)
                self.timeDisplay.setText(displayString)
            }
            self.setProperStartPauseButton()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func timerCallback(_ inTimer: Timer) {
        if nil != self.lastTimerDate {
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
        if self.timerRunning {
            if nil != self._timer {
                self._timer.invalidate()
                self._timer = nil
            }
            
            self.mainController.sendPauseMessage(self, timer: self.timer)
        } else {
            self.mainController.sendStartMessage(self, timer: self.timer)
            self.lastTimerDate = Date()
            self._timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(self.timerCallback(_:)), userInfo: nil, repeats: true)
            self._timerModal = true
        }
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func endButtonHit() {
        self.mainController.sendEndMessage(self, timer: self.timer)
        self.currentTimeInSeconds = 0
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func resetButtonHit() {
        self.mainController.sendResetMessage(self, timer: self.timer)
        if let timeSetInSecondsNumber = self.timer[LGV_Timer_Data_Keys.s_timerDataTimeSetKey] as? NSNumber {
            self.currentTimeInSeconds = timeSetInSecondsNumber.intValue
        }
    }
    
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.currentTimeInSeconds = 0
        if let theContext = context as? [String:Any] {
            if let theController = theContext[LGV_Timer_TimerListInterfaceController.s_timerListContextControllerElementKey] as? LGV_Timer_TimerListInterfaceController {
                self.mainController = theController
                if let theTimer = theContext[LGV_Timer_TimerListInterfaceController.s_timerListContextTimerElementKey] as? [String:Any] {
                    self.timer = theTimer
                    if let timeSetInSecondsNumber = self.timer[LGV_Timer_Data_Keys.s_timerDataTimeSetKey] as? NSNumber {
                        self.currentTimeInSeconds = timeSetInSecondsNumber.intValue
                    }
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func willActivate() {
        super.willActivate()
        self.setTimeFromSeconds()
    }
    
    /* ################################################################## */
    /**
     */
    override func willDisappear() {
        super.willDisappear()
        if nil != self._timer {
            self._timer.invalidate()
            self._timer = nil
        }
        self.mainController.sendSelectMessage()
    }
}
