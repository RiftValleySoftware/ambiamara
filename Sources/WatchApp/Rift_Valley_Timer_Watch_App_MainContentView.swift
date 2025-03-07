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
 
 */
struct Rift_Valley_Timer_Watch_App_MainContentView: View {
    /* ################################################################## */
    /**
    */
    @Binding var timers: [RVS_AmbiaMara_Settings.TimerSettings]

    /* ################################################################## */
    /**
    */
    @Binding var selectedTimerID: String
    
    /* ################################################################## */
    /**
    */
    var body: some View {
        ScrollView {
            VStack {
                ForEach(timers, id: \.id) { inTimer in
                    if inTimer.id == selectedTimerID {
                        Text("Selected Timer: \(inTimer.startTime)")
                            .foregroundColor(.red)
                    } else {
                        Text("Unselected Timer: \(inTimer.startTime)")
                    }
                }
            }
        }
        .onAppear {
            timers = RVS_AmbiaMara_Settings().timers
            selectedTimerID = RVS_AmbiaMara_Settings().currentTimerID
        }
    }
}
