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
struct Rift_Valley_Timer_Watch_App_TimerContentView: View {
    /* ################################################################## */
    /**
    */
    @State var timer: RVS_AmbiaMara_Settings.TimerSettings

    /* ################################################################## */
    /**
    */
    @Binding var selectedTimerIndex: Int

    /* ################################################################## */
    /**
    */
    var body: some View {
        Text("HOWDY!")
            .onAppear {
                selectedTimerIndex = timer.index
            }
    }
}
