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
    func timerSetting(timerSetting: TimerSettingTuple, changedCurrentTime: Int)
    func timerSetting(timerSetting: TimerSettingTuple, changedDisplayMode: TimerDisplayMode)
    func timerSetting(timerSetting: TimerSettingTuple, changedColorTheme: Int)
    func timerSetting(timerSetting: TimerSettingTuple, changedDisplayMode: AlertMode)
    func timerSetting(timerSetting: TimerSettingTuple, changedTimerStatus: TimerStatus)
}

/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_TimerEngine: NSObject, Sequence {
    static let timerInterval: TimeInterval = 0.25
    
    private var _timerTicking: Bool = false
    private var _lastTick: TimeInterval = 0.0
    
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
                self._lastTick = 0.0
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
            if 0 <= self.selectedTimerIndex {
                self._timerTicking = newValue
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
                case (selectedTimer.timeSetPodiumFinal + 1)...selectedTimer.timeSetPodiumWarn:
                    selectedTimer.timerStatus = .WarnRun
                case 0...selectedTimer.timeSetPodiumFinal:
                    selectedTimer.timerStatus = .FinalRun
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
    }
}
