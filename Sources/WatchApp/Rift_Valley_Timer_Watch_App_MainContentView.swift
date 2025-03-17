/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import SwiftUI

/* ###################################################################################################################################### */
// MARK: - Main Watch Content View -
/* ###################################################################################################################################### */
/**
 This displays a navigation list of timers (may only be one, in which case it automatically opens to that timer).
 */
struct Rift_Valley_Timer_Watch_App_MainContentView: View {
    /* ################################################################## */
    /**
    */
    @State private var _selectedTimer: String?
    
    /* ################################################################## */
    /**
     These are the timers the phone sent us.
    */
    @Binding var timers: [RVS_AmbiaMara_Settings.TimerSettings]

    /* ################################################################## */
    /**
     The 0-based index of the selected timer.
    */
    @Binding var selectedTimerIndex: Int

    /* ################################################################## */
    /**
     This is set to true, if the timer has started.
    */
    @Binding var timerIsRunning: Bool

    /* ############################################################## */
    /**
     The current state of the timer.
     */
    @Binding var timerState: Rift_Valley_Timer_Watch_App.TimerState
    
    /* ################################################################## */
    /**
     If the timer is running, this displays the current countdown time.
    */
    @Binding var runningTimerDisplay: String

    /* ################################################################## */
    /**
     The main display body.
    */
    var body: some View {
        if !runningTimerDisplay.isEmpty {
            Rift_Valley_Timer_Watch_App_RunningTimerContentView(timer: timers[selectedTimerIndex],
                                                                timerState: $timerState,
                                                                runningTimerDisplay: $runningTimerDisplay
            )
        } else if runningTimerDisplay.isEmpty,
                  .stopped == timerState {
            Rift_Valley_Timer_Watch_App_TimerList(timers: $timers, selectedTimerIndex: $selectedTimerIndex, timerIsRunning: $timerIsRunning, runningTimerDisplay: $runningTimerDisplay)
        } else {
            ProgressView()
        }
    }
}
