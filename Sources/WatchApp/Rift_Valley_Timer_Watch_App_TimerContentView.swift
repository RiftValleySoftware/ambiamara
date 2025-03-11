/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import SwiftUI
import RVS_Generic_Swift_Toolbox

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
        let hour = (Int(timer.startTime) / 60) / 60
        let minute = (Int(timer.startTime) / 60) - (hour * 60)
        let second = Int(timer.startTime) - ((hour * 60) * 60) - ((minute * 60))
        let startTimeString = String(format: "%02d:%02d:%02d", hour, minute, second)
        VStack {
            Text(startTimeString)
                .frame(maxWidth: .infinity, alignment: .center)
                .font(Font.custom("Let's go Digital Regular", size: 50))
                .onAppear { selectedTimerIndex = timer.index }
        }
        .navigationTitle(Text(String(format: "SLUG-TIMER-FORMAT".localizedVariant, timer.index + 1)))
    }
}
