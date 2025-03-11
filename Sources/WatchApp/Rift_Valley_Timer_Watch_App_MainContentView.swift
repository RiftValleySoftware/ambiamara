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
                    let hour = (Int(inTimer.startTime) / 60) / 60
                    let minute = (Int(inTimer.startTime) / 60) - (hour * 60)
                    let second = Int(inTimer.startTime) - ((hour * 60) * 60) - ((minute * 60))
                    let startTimeString = String(format: "%02d:%02d:%02d", hour, minute, second)
                        NavigationLink {
                            Rift_Valley_Timer_Watch_App_TimerContentView(timer: inTimer, selectedTimerIndex: $selectedTimerIndex)
                        } label: {
                            Text(startTimeString)
                                .foregroundColor(Color(inTimer.index == selectedTimerIndex ? "SelectedColor" : "AccentColor"))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .font(Font.custom("Let's go Digital Regular", size: 40))
                        }
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
