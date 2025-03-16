/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import SwiftUI

@main
/* ###################################################################################################################################### */
// MARK: - Main Watch App -
/* ###################################################################################################################################### */
/**
 This is the main context for the timer Watch app.
 */
struct Rift_Valley_Timer_Watch_App: App {
    /* ################################################################################################################################## */
    // MARK: These are the states the timer can be in, at any given time.
    /* ################################################################################################################################## */
    /**
     This is the main context for the timer Watch app.
     */
    enum TimerState: Int {
        /* ############################################################## */
        /**
         The timer is in select mode.
         */
        case stopped
        
        /* ############################################################## */
        /**
         The timer is running, but has been paused.
         */
        case paused
        
        /* ############################################################## */
        /**
         The timer has started, and has not reached the warn or final thresholds
         */
        case started
        
        /* ############################################################## */
        /**
         The timer has started, and has reached the warn threshold
         */
        case warning
        
        /* ############################################################## */
        /**
         The timer has started, and has reached the final threshold
         */
        case final
        
        /* ############################################################## */
        /**
         The timer has completed its countdown
         */
        case alarming
    }
    
    /* ################################################################## */
    /**
     Tracks scene activity.
     */
    @Environment(\.scenePhase) private var _scenePhase
    
    /* ############################################################## */
    /**
     The current state of the timer.
     */
    @State private var _timerState: TimerState = .stopped
    
    /* ############################################################## */
    /**
     This handles communications with the Watch app.
     */
    @State private var _watchDelegate: RVS_WatchDelegate?

    /* ################################################################## */
    /**
     These are the timers the phone sent us.
    */
    @State private var _timers: [RVS_AmbiaMara_Settings.TimerSettings] = []

    /* ################################################################## */
    /**
     The 0-based index of the selected timer.
    */
    @State private var _selectedTimerIndex: Int = 0

    /* ################################################################## */
    /**
     This is set to true, if the timer has started.
    */
    @State private var _timerIsRunning: Bool = false
    
    /* ################################################################## */
    /**
     If the timer is running, this contains the latest sync.
    */
    @State private var _runningSync: Int?

    /* ################################################################## */
    /**
     If the timer is running, this displays the current countdown time.
    */
    @State private var _runningTimerDisplay: String = ""

    /* ################################################################## */
    /**
     This is basically just a wrapper for the screens.
     */
    var body: some Scene {
        WindowGroup {
            Rift_Valley_Timer_Watch_App_MainContentView(timers: $_timers,
                                                        selectedTimerIndex: $_selectedTimerIndex,
                                                        timerIsRunning: $_timerIsRunning,
                                                        timerState: $_timerState,
                                                        runningTimerDisplay: $_runningTimerDisplay
            )
                .onAppear {
                    _watchDelegate = RVS_WatchDelegate(updateHandler: watchUpdateHandler)
                }
                .onChange(of: _selectedTimerIndex) {
                    RVS_AmbiaMara_Settings().flush()
                    if _selectedTimerIndex != RVS_AmbiaMara_Settings().currentTimerIndex {
                        RVS_AmbiaMara_Settings().currentTimerIndex = _selectedTimerIndex
                        _watchDelegate?.sendApplicationContext()
                    }
                }
                .onChange(of: _runningSync) {
                    if nil != _runningSync {
                        setDisplayString()
                    } else {
                        _timerState = .stopped
                        _runningTimerDisplay = ""
                    }
                }
                .onChange(of: _timerState) {
                    if .paused == _timerState {
                        _watchDelegate?.sendTimerControl(operation: .pause)
                    }
                    if .stopped == _timerState {
                        _watchDelegate?.sendTimerControl(operation: .stop)
                    }
                    if .started == _timerState {
                        _watchDelegate?.sendTimerControl(operation: .resume)
                    }
                }
                .onChange(of: _timerIsRunning) {
                    if _timerIsRunning,
                       .paused != _timerState {
                        _timerState = .started
                        _watchDelegate?.sendTimerControl(operation: .start)
                        _runningSync = 0
                    } else if _timerIsRunning {
                        _runningSync = 0
                    }
                }
        }
    }
    
    /* ################################################################## */
    /**
     This builds a display string from the current timer state.
     */
    func setDisplayString() {
        let runningSync = TimeInterval(_runningSync ?? 0)
        let totalTime = Int(TimeInterval(RVS_AmbiaMara_Settings().timers[_selectedTimerIndex].startTime) - runningSync)
        let hour = totalTime / 3600
        let minute = totalTime / 60 - (hour * 60)
        let second = totalTime - ((hour * 3600) + (minute * 60))
        _runningTimerDisplay = RVS_AmbiaMara_Settings.optimizedTimeString(hours: hour, minutes: minute, seconds: second)
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension Rift_Valley_Timer_Watch_App {
    /* ################################################################## */
    /**
     This responds to updates from the Watch delegate.
     
     - parameter inWatchDelegate: The delegate handler calling this.
     - parameter inContext: The context from the Watch.
     */
    func watchUpdateHandler(_ inWatchDelegate: RVS_WatchDelegate?, _ inContext: [String: Any]) {
        #if DEBUG
            print("Received WatchData: \(inContext.debugDescription)")
        #endif
        
        defer { (_timers, _selectedTimerIndex) = (RVS_AmbiaMara_Settings().timers, RVS_AmbiaMara_Settings().currentTimerIndex) }

        if let sync = inContext["sync"] as? Int,
           .stopped != _timerState {
            #if DEBUG
                print("Received Sync: \(sync)")
            #endif
            _runningSync = sync
            _timerIsRunning = false
            if _runningSync == RVS_AmbiaMara_Settings().timers[_selectedTimerIndex].startTime {
                _timerState = .alarming
            }
        } else if let operation = inContext["timerControl"] as? RVS_WatchDelegate.TimerOperation {
            #if DEBUG
                print("Received Operation: \(operation.rawValue)")
            #endif
            switch operation {
            case .resume where .alarming != _timerState:
                _timerState = .started
                
            case .pause where .alarming != _timerState:
                if .stopped == _timerState {
                    _timerIsRunning = true
                    _runningSync = 0
                }
                _timerState = .paused

            case .fastForward where .alarming != _timerState:
                _runningSync = RVS_AmbiaMara_Settings().timers[_selectedTimerIndex].startTime
                _timerState = .alarming

            case .start:
                _runningSync = 0
                _timerState = .started

            case .reset:
                _runningSync = 0
                _timerState = .paused

            case .stop:
                _timerState = .stopped
                _runningTimerDisplay = ""
                _runningSync = nil
                
            default:
                break
            }

        } else {
            _timerState = .stopped
            _runningTimerDisplay = ""
            _runningSync = nil
        }
    }
}
