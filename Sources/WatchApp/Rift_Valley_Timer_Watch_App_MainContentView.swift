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
    @Binding var timers: [RVS_AmbiaMara_Settings.TimerSettings]

    /* ################################################################## */
    /**
    */
    @Binding var selectedTimerIndex: Int

    /* ################################################################## */
    /**
    */
    var body: some View {
        if 1 < timers.count {
            NavigationStack {
                List(timers, id: \.id) { inTimer in
                    let startTimeString = inTimer.startTimeAsString
                        NavigationLink {
                            Rift_Valley_Timer_Watch_App_TimerContentView(timer: inTimer, selectedTimerIndex: $selectedTimerIndex)
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
            Rift_Valley_Timer_Watch_App_TimerContentView(timer: timers[0], selectedTimerIndex: $selectedTimerIndex)
        } else {
            ProgressView()
        }
    }
}
