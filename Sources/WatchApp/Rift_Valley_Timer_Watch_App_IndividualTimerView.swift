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
     This contains the state for the app.
    */
    @Binding var timerStatus: Rift_Valley_Timer_Watch_App.TimerStatus

    /* ################################################################## */
    /**
     It's a fairly basic VStack, with the timer start
    */
    var body: some View {
        if let timer = timerStatus.selectedTimer {
            let timeString = timer.startTimeAsString
            NavigationStack {
                VStack {
                    Text(timeString)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .font(Rift_Valley_Timer_Watch_App.mainDetailsDisplayFont)
                        .foregroundColor(Color("Start-Color"))
                    
                    if ((0 < timer.warnTime) && (timer.startTime > timer.warnTime)) || ((0 < timer.finalTime) && (timer.startTime > timer.finalTime)) {
                        HStack {
                            if 0 < timer.warnTime,
                               timer.startTime > timer.warnTime {
                                let timeString = timer.warnTimeAsString
                                Text(timeString)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                                    .font(Rift_Valley_Timer_Watch_App.subDetailsDisplayFont)
                                    .foregroundColor(Color("Warn-Color"))
                            }
                            
                            if 0 < timer.finalTime,
                               timer.startTime > timer.finalTime {
                                let timeString = timer.finalTimeAsString
                                Text(timeString)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                                    .font(Rift_Valley_Timer_Watch_App.subDetailsDisplayFont)
                                    .foregroundColor(Color("Final-Color"))
                            }
                        }
                    }
                    
                    Button {
                        var newStatus = Rift_Valley_Timer_Watch_App.TimerStatus(timerStatus)
                        newStatus.timerState = .started
                        newStatus.screen = .runningTimer
                        timerStatus = newStatus
                        newStatus.watchDelegate?.sendTimerControl(operation: .start)
                    } label: {
                        Image(systemName: "play.fill")
                            .resizable()
                            .scaledToFit()
                    }
                }
                .toolbar {
                    if 1 < _timerStatus.timers.count {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                timerStatus.screen = .timerList
                            } label: {
                                Image(systemName: "list.bullet")
                            }
                            .frame(width: 24)
                        }
                    }
                }
            }
            .onAppear {
                timerStatus.watchDelegate?.sendApplicationContext()
            }
        } else {
            Text("ERROR")
        }
    }
}
