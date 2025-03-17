/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import SwiftUI

/* ###################################################################################################################################### */
// MARK: - List of Timers View -
/* ###################################################################################################################################### */
/**
 This displays a navigation list of timers (may only be one, in which case it automatically opens to that timer).
 */
struct Rift_Valley_Timer_Watch_App_TimerList: View {
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
    
    /* ################################################################## */
    /**
     If the timer is running, this displays the current countdown time.
    */
    @Binding var runningTimerDisplay: String

    /* ################################################################## */
    /**
     This displays a navstack, if there are more than one timer, or it directly opens the timer screen, if just one.
     
     If the timer is running, it goes straight to that screen.
    */
    var body: some View {
        NavigationStack {
            List(timers, id: \.id) { inTimer in
                let startTimeString = inTimer.startTimeAsString
                NavigationLink {
                    Rift_Valley_Timer_Watch_App_TimerContentView(timer: inTimer, selectedTimerIndex: $selectedTimerIndex, timerIsRunning: $timerIsRunning)
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
    }
}
