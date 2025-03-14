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
    /* ################################################################## */
    /**
     Tracks scene activity.
     */
    @Environment(\.scenePhase) private var _scenePhase
    
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
    @State private var _runningSync: TimeInterval?

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
                    _timerIsRunning = false
                    print("Sync: \(_runningSync?.debugDescription ?? "nil")")
                    if let runningSync = _runningSync {
                        let totalTime = Int(TimeInterval(RVS_AmbiaMara_Settings().timers[_selectedTimerIndex].startTime) - runningSync)
                        let hour = totalTime / 3600
                        let minute = totalTime / 60 - (hour * 60)
                        let second = totalTime - ((hour * 3600) + (minute * 60))
                        _runningTimerDisplay = RVS_AmbiaMara_Settings.optimizedTimeString(hours: hour, minutes: minute, seconds: second)
                    } else {
                        _runningTimerDisplay = ""
                    }
                }
                .onChange(of: _timerIsRunning) {
                    if _timerIsRunning {
                        _watchDelegate?.sendTimerControl(operation: .start)
                    }
                }
        }
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
     - parameter inApplicationContext: The application context from the Watch.
     */
    func watchUpdateHandler(_ inWatchDelegate: RVS_WatchDelegate?, _ inApplicationContext: [String: Any]) {
        #if DEBUG
            print("Received WatchData: \(inApplicationContext.debugDescription)")
        #endif
        
        var operation = RVS_WatchDelegate.TimerOperation.stop
        
        defer {
            (_timers, _selectedTimerIndex) = (RVS_AmbiaMara_Settings().timers, RVS_AmbiaMara_Settings().currentTimerIndex)
            _timerIsRunning = (.start == operation) || (.resume == operation)
        }

        if let sync = inApplicationContext["sync"] as? TimeInterval {
            #if DEBUG
                print("Received Sync: \(sync)")
            #endif
            _runningSync = sync
        } else if let operationTemp = inApplicationContext["timerControl"] as? RVS_WatchDelegate.TimerOperation {
            #if DEBUG
                print("Received Operation: \(operation.rawValue)")
            #endif
            operation = operationTemp
        }
    }
}
