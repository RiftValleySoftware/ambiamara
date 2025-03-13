/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import SwiftUI
import RVS_BasicGCDTimer

/* ###################################################################################################################################### */
// MARK: - Main Watch Content View -
/* ###################################################################################################################################### */
/**
 This displays a navigation list of timers (may only be one, in which case it automatically opens to that timer).
 */
struct Rift_Valley_Timer_Watch_App_MainContentView: View {
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
     This will be the actual ticker for the running timer.
     */
    @Binding var runningTimerInstance: RVS_BasicGCDTimer?

    /* ################################################################## */
    /**
     If the timer is running, this displays the current countdown time.
    */
    @Binding var runningTimerDisplay: String
    
    /* ################################################################## */
    /**
     If the timer is running, this contains the latest sync.
    */
    @Binding var runningSync: [TimeInterval]

    /* ################################################################## */
    /**
     This displays a navstack, if there are more than one timer, or it directly opens the timer screen, if just one.
     
     If the timer is running, it goes straight to that screen.
    */
    var body: some View {
        if (0..<timers.count).contains(selectedTimerIndex) {
            if nil != runningTimerInstance {
                Rift_Valley_Timer_Watch_App_RunningTimerContentView(timer: timers[selectedTimerIndex],
                                                                    runningTimerInstance: $runningTimerInstance,
                                                                    runningTimerDisplay: $runningTimerDisplay,
                                                                    runningSync: $runningSync
                )
            } else if 1 < timers.count {
                NavigationStack {
                    List(timers, id: \.id) { inTimer in
                        let startTimeString = inTimer.startTimeAsString
                        NavigationLink {
                            Rift_Valley_Timer_Watch_App_TimerContentView(timer: inTimer, selectedTimerIndex: $selectedTimerIndex, runningTimerInstance: $runningTimerInstance)
                        } label: {
                            Text(startTimeString)
                                .foregroundColor(Color(inTimer.index == selectedTimerIndex ? "Start-Color" : "Paused-Color"))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                                .font(Font.custom("Let's go Digital Regular", size: 60))
                                .padding(0.1)
                        }
                        .padding(0.1)
                    }
                    .navigationTitle("SLUG-TIMER-LIST-TITLE")
                }
            } else if 1 == timers.count {
                Rift_Valley_Timer_Watch_App_TimerContentView(timer: timers[0], selectedTimerIndex: $selectedTimerIndex, runningTimerInstance: $runningTimerInstance)
            } else {
                ProgressView()
            }
        }
    }
}
