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
struct Rift_Valley_Timer_Watch_App_IndividualTimerView: View {
    /* ################################################################## */
    /**
     This is the timer instance, associated with this screen.
    */
    @State var timer: RVS_AmbiaMara_Settings.TimerSettings

    /* ################################################################## */
    /**
     This is set to true, if we want to show the timer list, as opposed to the selected timer screen.
    */
    @Binding var showTimerList: Bool

    /* ################################################################## */
    /**
     This screen is only shown for the selected timer (which is selected upon entering the screen).
    */
    @Binding var selectedTimerIndex: Int

    /* ################################################################## */
    /**
     This is set to true, if the timer is to be started
    */
    @Binding var timerIsRunning: Bool

    /* ################################################################## */
    /**
     It's a fairly basic VStack, with the timer start
    */
    var body: some View {
        let timeString = timer.startTimeAsString
        VStack {
            HStack {
                Button {
                    showTimerList = true
                } label: {
                    Image(systemName: "list.bullet")
                        .padding(0.1)
                }
                .frame(width: 24)
                .padding(0.1)
                
                Text(timeString)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .font(Font.custom("Let's go Digital Regular", size: 60))
                    .foregroundColor(Color("Start-Color"))
                    .onAppear { selectedTimerIndex = timer.index }
            }
            
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
            
            Button {
                timerIsRunning = true
            } label: {
                Image(systemName: "play.fill")
                    .resizable()
                    .scaledToFit()
            }
            .sensoryFeedback(.impact, trigger: timerIsRunning)
        }
    }
}
