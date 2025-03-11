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
        let hour = (Int(timer.startTime) / 60) / 60
        let minute = (Int(timer.startTime) / 60) - (hour * 60)
        let second = Int(timer.startTime) - ((hour * 60) * 60) - ((minute * 60))
        let timeString = String(format: "%02d:%02d:%02d", hour, minute, second)
        VStack {
            Text(timeString)
                .frame(maxWidth: .infinity, alignment: .center)
                .font(Font.custom("Let's go Digital Regular", size: 50))
                .foregroundColor(Color("Start-Color"))
                .onAppear { selectedTimerIndex = timer.index }
            
            if ((0 < timer.warnTime) && (timer.startTime > timer.warnTime)) || ((0 < timer.finalTime) && (timer.startTime > timer.finalTime)) {
                HStack {
                    if 0 < timer.warnTime,
                       timer.startTime > timer.warnTime {
                        let hour = (Int(timer.warnTime) / 60) / 60
                        let minute = (Int(timer.warnTime) / 60) - (hour * 60)
                        let second = Int(timer.warnTime) - ((hour * 60) * 60) - ((minute * 60))
                        let timeString = String(format: "%02d:%02d:%02d", hour, minute, second)
                        Text(timeString)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(Font.custom("Let's go Digital Regular", size: 20))
                            .foregroundColor(Color("Warn-Color"))
                    }
                    
                    if 0 < timer.finalTime,
                       timer.startTime > timer.finalTime {
                        let hour = (Int(timer.finalTime) / 60) / 60
                        let minute = (Int(timer.finalTime) / 60) - (hour * 60)
                        let second = Int(timer.finalTime) - ((hour * 60) * 60) - ((minute * 60))
                        let timeString = String(format: "%02d:%02d:%02d", hour, minute, second)
                        Text(timeString)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(Font.custom("Let's go Digital Regular", size: 20))
                            .foregroundColor(Color("Final-Color"))
                    }
                }
            }
        }
        .navigationTitle(Text(String(format: "SLUG-TIMER-FORMAT".localizedVariant, timer.index + 1)))
    }
}
