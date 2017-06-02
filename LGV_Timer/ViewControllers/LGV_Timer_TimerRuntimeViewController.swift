//
//  LGV_Timer_TimerRuntimeViewController.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 6/1/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//
/* ###################################################################################################################################### */

import UIKit

/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_TimerRuntimeStoplightContainer: UIView {
    
}
/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_TimerRuntimeViewController: LGV_Timer_TimerBaseViewController {
    private var _timer: Timer! = nil

    var timerNumber: Int = 0
    var clockPaused: Bool = false
    var currentTimeInSeconds: Int = 0
    var lastTimerDate: Date! = nil
    
    let pauseButtonImageName = "Pause"
    let startButtonImageName = "Start"
    
    // MARK: - IB Properties
    /* ################################################################################################################################## */
    @IBOutlet weak var pauseButton: UIBarButtonItem!
    @IBOutlet weak var stopButton: UIBarButtonItem!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var timeDisplay: LGV_Lib_LEDDisplayHoursMinutesSecondsDigitalClock!
    @IBOutlet weak var stoplightContainerView: LGV_Timer_TimerRuntimeStoplightContainer!
    
    @IBOutlet weak var redLight: UIImageView!
    @IBOutlet weak var yellowLight: UIImageView!
    @IBOutlet weak var greenLight: UIImageView!
    // MARK: - Private Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Bring in the setup screen.
     */
    private func _setUpDisplay() {
        if .Digital == s_g_LGV_Timer_AppDelegatePrefs.timers[self.timerNumber].displayMode {
            self.stoplightContainerView.isHidden = true
        } else {
            if .Podium == s_g_LGV_Timer_AppDelegatePrefs.timers[self.timerNumber].displayMode {
                self.timeDisplay.isHidden = true
            } else {
            }
        }
        
        if .Podium != s_g_LGV_Timer_AppDelegatePrefs.timers[self.timerNumber].displayMode {
            self.timeDisplay.hours = TimeTuple(self.currentTimeInSeconds).hours
            self.timeDisplay.minutes = TimeTuple(self.currentTimeInSeconds).minutes
            self.timeDisplay.seconds = TimeTuple(self.currentTimeInSeconds).seconds
            self.timeDisplay.setNeedsDisplay()
        }
        
        if .Digital != s_g_LGV_Timer_AppDelegatePrefs.timers[self.timerNumber].displayMode {
            let yellowThreshold = s_g_LGV_Timer_AppDelegatePrefs.timers[self.timerNumber].timeSetPodiumWarn
            let redThreshold = s_g_LGV_Timer_AppDelegatePrefs.timers[self.timerNumber].timeSetPodiumFinal
            
            if (0 == self.currentTimeInSeconds) || self.clockPaused {
                self.greenLight.isHighlighted = false
                self.yellowLight.isHighlighted = false
                self.redLight.isHighlighted = false
            } else {
                if redThreshold >= self.currentTimeInSeconds {
                    self.greenLight.isHighlighted = false
                    self.yellowLight.isHighlighted = false
                    self.redLight.isHighlighted = true
                } else {
                    if yellowThreshold >= self.currentTimeInSeconds {
                        self.greenLight.isHighlighted = false
                        self.yellowLight.isHighlighted = true
                        self.redLight.isHighlighted = false
                    } else {
                        self.greenLight.isHighlighted = true
                        self.yellowLight.isHighlighted = false
                        self.redLight.isHighlighted = false
                    }
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    private func _startTimer() {
        if 0 == self.currentTimeInSeconds {
            self.currentTimeInSeconds = s_g_LGV_Timer_AppDelegatePrefs.timers[self.timerNumber].timeSet
        }
        self.clockPaused = false
        self.pauseButton.image = UIImage(named: self.pauseButtonImageName)
        self.lastTimerDate = Date()
        self._timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(self.timerCallback(_:)), userInfo: nil, repeats: true)
        self._setUpDisplay()
    }
    
    /* ################################################################## */
    /**
     */
    private func _alarm() {
        if nil != self._timer {
            self._timer.invalidate()
            self._timer = nil
        }
        self.pauseButton.image = UIImage(named: self.startButtonImageName)
        self._setUpDisplay()
    }
    
    // MARK: - Internal Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func pauseTimer() {
        if nil != self._timer {
            self._timer.invalidate()
            self._timer = nil
        }
        self.clockPaused = true
        self.pauseButton.image = UIImage(named: self.startButtonImageName)
    }
    
    /* ################################################################## */
    /**
     */
    func timerCallback(_ inTimer: Timer) {
        if nil != self.lastTimerDate {
            let seconds = floor(Date().timeIntervalSince(self.lastTimerDate))
            if 0 < seconds {
                self.currentTimeInSeconds = max(0, self.currentTimeInSeconds - Int(seconds))
                
                if 0 == self.currentTimeInSeconds {
                    inTimer.invalidate()
                    self._timer = nil
                    self._alarm()
                } else {
                    self.lastTimerDate = Date()
                    self._setUpDisplay()
                }
            }
        }
    }
    
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.timeDisplay.activeSegmentColor = LGV_Timer_StaticPrefs.prefs.pickerPepperArray[s_g_LGV_Timer_AppDelegatePrefs.timers[self.timerNumber].colorTheme].textColor!
        self.pauseButton.image = UIImage(named: self.pauseButtonImageName)
        LGV_Timer_AppDelegate.appDelegateObject.currentTimer = self
        self._startTimer()
    }
    
    /* ################################################################## */
    /**
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LGV_Timer_AppDelegate.appDelegateObject.currentTimer = nil
    }
    
    // MARK: - IB Action Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBAction func stopButtonHit(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func pauseButtonHit(_ sender: Any) {
        if self.clockPaused || (0 == self.currentTimeInSeconds) {
            self._startTimer()
        } else {
            self.pauseTimer()
        }
    }
}
