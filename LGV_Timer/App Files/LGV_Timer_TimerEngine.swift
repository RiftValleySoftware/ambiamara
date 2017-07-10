//
//  LGV_Timer_TimerEngine.swift
//  X-Timer
//
//  Created by Chris Marshall on 7/9/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//

import UIKit

// MARK: - LGV_Timer_TimerEngineDelegate Protocol -
/* ###################################################################################################################################### */
/**
 This protocol allows observers of the engine.
 */
protocol LGV_Timer_TimerEngineDelegate {
    func timerSetting(timerSetting: TimerSettingTuple, changedTimeSet: Int)
    func timerSetting(timerSetting: TimerSettingTuple, changedTimeSetPodiumWarn: Int)
    func timerSetting(timerSetting: TimerSettingTuple, changedTimeSetPodiumFinal: Int)
    func timerSetting(timerSetting: TimerSettingTuple, changedDisplayMode: TimerDisplayMode)
    func timerSetting(timerSetting: TimerSettingTuple, changedColorTheme: Int)
    func timerSetting(timerSetting: TimerSettingTuple, changedDisplayMode: AlertMode)
    
    func timerSetting(timerSetting: TimerSettingTuple, alarm: Int)
    func timerSetting(timerSetting: TimerSettingTuple, changedCurrentTimeFrom: Int)
    func timerSetting(timerSetting: TimerSettingTuple, changedTimerStatusFrom: TimerStatus)
}

/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_TimerEngine: NSObject, Sequence {
    static let timerInterval: TimeInterval = 0.1
    static let timerTickInterval: TimeInterval = 1.0
    static let timerAlarmInterval: TimeInterval = 0.5
    
    private var _timerTicking: Bool = false
    private var _firstTick: TimeInterval = 0.0
    private var _lastTick: TimeInterval = 0.0
    private var _alarmCount: Int = 0
    
    var prefs = LGV_Timer_StaticPrefs.prefs
    var timer: Timer! = nil
    var delegate: LGV_Timer_TimerEngineDelegate! = nil
    
    // MARK: - Instance Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var timerSelected: Bool {
        get { return self.prefs.appStatus.timerSelected }
    }
    
    /* ################################################################## */
    /**
     */
    var selectedTimer: TimerSettingTuple! {
        get { return self.prefs.appStatus.selectedTimer }
    }
    
    /* ################################################################## */
    /**
     */
    var selectedTimerIndex: Int {
        get { return self.prefs.appStatus.selectedTimerIndex }
        set { self.prefs.appStatus.selectedTimerIndex = newValue }
    }
    
    /* ################################################################## */
    /**
     */
    var selectedTimerUID: String {
        get { return self.prefs.appStatus.selectedTimerUID }
        set { self.prefs.appStatus.selectedTimerUID = newValue }
    }
    
    /* ################################################################## */
    /**
     */
    var isEmpty: Bool {
        get { return self.prefs.appStatus.isEmpty }
    }
    
    /* ################################################################## */
    /**
     */
    var timers:[TimerSettingTuple] {
        get { return self.prefs.appStatus.timers }
        set { self.prefs.appStatus.timers = newValue }
    }
    
    /* ################################################################## */
    /**
     */
    var count: Int {
        get { return self.prefs.appStatus.count }
    }
    
    /* ################################################################## */
    /**
     */
    var timerActive: Bool {
        get { return nil != self.timer }
        
        set {
            if (nil == self.timer) && (0 <= self.selectedTimerIndex) {
                self._lastTick = Date.timeIntervalSinceReferenceDate
                self.timer = Timer.scheduledTimer(timeInterval: type(of: self).timerInterval, target: self, selector: #selector(self.timerCallback(_:)), userInfo: nil, repeats: true)
            } else {
                if nil != self.timer {
                    self.timer.invalidate()
                    self.timer = nil
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    var timerPaused: Bool {
        get { return self._timerTicking }
        set {
            if self.timerSelected {
                if !newValue {
                    if !self._timerTicking {
                        self._lastTick = Date.timeIntervalSinceReferenceDate
                    }
                } else {
                    self._lastTick = 0.0
                }
                self._timerTicking = newValue
            } else {
                self._timerTicking = false
            }
        }
    }
    
    // MARK: - Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func createNewTimer() -> TimerSettingTuple {
        return self.prefs.appStatus.createNewTimer()
    }
    
    /* ################################################################## */
    /**
     */
    func pauseTimer() {
        if let selectedTimer = self.selectedTimer {
            selectedTimer.timerStatus = .Paused
            self.timerPaused = false
        }
    }
    
    /* ################################################################## */
    /**
     */
    func continueTimer() {
        if let selectedTimer = self.selectedTimer {
            if 0 >= selectedTimer.currentTime {
                self.startTimer()
            } else {
                switch selectedTimer.currentTime {
                case 0...selectedTimer.timeSetPodiumFinal:
                    selectedTimer.timerStatus = .FinalRun
                case (selectedTimer.timeSetPodiumFinal + 1)...selectedTimer.timeSetPodiumWarn:
                    selectedTimer.timerStatus = .WarnRun
                default:
                    selectedTimer.timerStatus = .Running
                }
                self.timerPaused = false
            }
       }
    }
    
    /* ################################################################## */
    /**
     */
    func startTimer() {
        if let selectedTimer = self.selectedTimer {
            self._firstTick = Date.timeIntervalSinceReferenceDate
            selectedTimer.currentTime = selectedTimer.timeSet
            self.timerPaused = false
            selectedTimer.timerStatus = .Running
       }
    }
    
    /* ################################################################## */
    /**
     */
    func stopTimer() {
        if let selectedTimer = self.selectedTimer {
            self._firstTick = 0.0
            selectedTimer.currentTime = selectedTimer.timeSet
            self.timerPaused = true
            selectedTimer.timerStatus = .Stopped
        }
    }
    
    /* ################################################################## */
    /**
     */
    func resetTimer() {
        if let selectedTimer = self.selectedTimer {
            self._firstTick = 0.0
            selectedTimer.currentTime = selectedTimer.timeSet
            self.timerPaused = true
            selectedTimer.timerStatus = .Stopped
       }
    }
    
    /* ################################################################## */
    /**
     */
    func endTimer() {
        if let selectedTimer = self.selectedTimer {
            selectedTimer.currentTime = 0
            self.timerPaused = false
            selectedTimer.timerStatus = .Alarm
       }
    }
    
    // MARK: - Sequence Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    subscript(_ index: Int) -> TimerSettingTuple {
        return self.prefs.appStatus[index]
    }
    
    /* ################################################################## */
    /**
     */
    func indexOf(_ inUID: String) -> Int {
        return prefs.appStatus.indexOf(inUID)
    }
    
    /* ################################################################## */
    /**
     */
    func indexOf(_ inObject: TimerSettingTuple) -> Int {
        return prefs.appStatus.indexOf(inObject)
    }
    
    /* ################################################################## */
    /**
     */
    func contains(_ inObject: TimerSettingTuple) -> Bool {
        return prefs.appStatus.contains(inObject)
    }
    
    /* ################################################################## */
    /**
     */
    func contains(_ inUID: String) -> Bool {
        return prefs.appStatus.contains(inUID)
    }
    
    /* ################################################################## */
    /**
     */
    func makeIterator() -> AnyIterator<TimerSettingTuple> {
        var nextIndex = 0
        
        // Return a "bottom-up" iterator for the list.
        return AnyIterator() {
            if nextIndex == self.count {
                return nil
            }
            nextIndex += 1
            return self[nextIndex - 1]
        }
    }
    
    /* ################################################################## */
    /**
     */
    func append(_ inObject: TimerSettingTuple) {
        self.prefs.appStatus.append(inObject)
    }
    
    /* ################################################################## */
    /**
     */
    func remove(at index: Int) {
        self.prefs.appStatus.remove(at: index)
    }
    
    // MARK: - Callback Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @objc func timerCallback(_ inTimer: Timer) {
        if 0.0 < self._lastTick {
            if let selectedTimer = self.selectedTimer {
                if .Alarm == selectedTimer.timerStatus {
                    if type(of: self).timerAlarmInterval <= (Date.timeIntervalSinceReferenceDate - self._lastTick) {
                        self._lastTick = Date.timeIntervalSinceReferenceDate
                        DispatchQueue.main.async {
                            if nil != self.delegate {
                                self.delegate.timerSetting(timerSetting: selectedTimer, alarm: self._alarmCount)
                            }
                        }
                        self._alarmCount += 1
                    }
                } else {
                    if type(of: self).timerTickInterval <= (Date.timeIntervalSinceReferenceDate - self._lastTick) {
                        self._lastTick = Date.timeIntervalSinceReferenceDate
                        let oldTime: Int = selectedTimer.currentTime
                        selectedTimer.currentTime = Swift.max(0, oldTime - 1)
                        DispatchQueue.main.async {
                            if nil != self.delegate {
                                self.delegate.timerSetting(timerSetting: selectedTimer, changedCurrentTimeFrom: oldTime)
                            }
                            
                            let oldStatus = selectedTimer.timerStatus
                            switch selectedTimer.currentTime {
                            case 0:
                                self._alarmCount = 0
                                selectedTimer.timerStatus = .Alarm
                            case 1...selectedTimer.timeSetPodiumFinal:
                                selectedTimer.timerStatus = .FinalRun
                            case (selectedTimer.timeSetPodiumFinal + 1)...selectedTimer.timeSetPodiumWarn:
                                selectedTimer.timerStatus = .WarnRun
                            default:
                                selectedTimer.timerStatus = .Running
                            }
                            
                            if oldStatus != selectedTimer.timerStatus {
                                if nil != self.delegate {
                                    self.delegate.timerSetting(timerSetting: selectedTimer, changedTimerStatusFrom: oldStatus)
                                }
                            }
                       }
                    }
                }
            }
        }
    }
}
