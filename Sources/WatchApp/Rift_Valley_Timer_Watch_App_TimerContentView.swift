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
     This is the timer instance, associated with this screen.
    */
    @State var timer: RVS_AmbiaMara_Settings.TimerSettings

    /* ################################################################## */
    /**
     This screen is only shown for the selected timer (which is selected upon entering the screen).
    */
    @Binding var selectedTimerIndex: Int

    /* ################################################################## */
    /**
     It's a fairly basic VStack, with the timer start
    */
    var body: some View {
        let timeString = timer.startTimeAsString
        VStack {
            Text(timeString)
                .frame(maxWidth: .infinity, alignment: .center)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .font(Font.custom("Let's go Digital Regular", size: 60))
                .foregroundColor(Color("Start-Color"))
                .onAppear { selectedTimerIndex = timer.index }
            
            if ((0 < timer.warnTime) && (timer.startTime > timer.warnTime)) || ((0 < timer.finalTime) && (timer.startTime > timer.finalTime)) {
                HStack {
                    if 0 < timer.warnTime,
                       timer.startTime > timer.warnTime {
                        let timeString = timer.warnTimeAsString
                        Text(timeString)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .font(Font.custom("Let's go Digital Regular", size: 30))
                            .foregroundColor(Color("Warn-Color"))
                    }
                    
                    if 0 < timer.finalTime,
                       timer.startTime > timer.finalTime {
                        let timeString = timer.finalTimeAsString
                        Text(timeString)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .font(Font.custom("Let's go Digital Regular", size: 30))
                            .foregroundColor(Color("Final-Color"))
                    }
                }
            }
        }
        .navigationTitle(Text(String(format: "SLUG-TIMER-FORMAT".localizedVariant, timer.index + 1)))
    }
}
