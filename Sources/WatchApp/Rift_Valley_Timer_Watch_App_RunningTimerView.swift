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
struct Rift_Valley_Timer_Watch_App_RunningTimerView: View {
    /* ################################################################## */
    /**
     This contains the state for the app.
    */
    @Binding var timerStatus: Rift_Valley_Timer_Watch_App.TimerStatus

    /* ################################################################## */
    /**
    */
    var body: some View {
        VStack {
            if .alarming == timerStatus.timerState {
                Image(systemName: "bell.and.waves.left.and.right.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color("Final-Color"))
                    .frame(width: 100, height: 100)
            } else {
                let textColor = (timerStatus.timerState == .paused)
                        ? "Paused-Color" : ((timerStatus.timerState == .final)
                                        ? "Final-Color" : ((timerStatus.timerState == .warning)
                                                           ? "Warn-Color" : "Start-Color"))
                Text(timerStatus.runningTimerDisplay)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .font(Font.custom("Let's go Digital Regular", size: 60))
                    .foregroundColor(Color(textColor))
            }
        }
        .gesture(
            TapGesture()
                .onEnded {
                    let newStatus = Rift_Valley_Timer_Watch_App.TimerStatus(timers: RVS_AmbiaMara_Settings().timers,
                                                                            selectedTimerIndex: RVS_AmbiaMara_Settings().currentTimerIndex,
                                                                            runningSync: timerStatus.runningSync,
                                                                            timerState: timerStatus.timerState == .paused ? .started : .paused,
                                                                            screen: .runningTimer,
                                                                            watchDelegate: timerStatus.watchDelegate
                    )
                    
                    if newStatus.timerState == .started {
                        newStatus.watchDelegate?.sendTimerControl(operation: .resume)
                    } else {
                        newStatus.watchDelegate?.sendTimerControl(operation: .pause)
                    }
                    timerStatus = newStatus
                }
                .simultaneously(with: TapGesture(count: 2).onEnded {
                    let newStatus = Rift_Valley_Timer_Watch_App.TimerStatus(timers: RVS_AmbiaMara_Settings().timers,
                                                                            selectedTimerIndex: RVS_AmbiaMara_Settings().currentTimerIndex,
                                                                            runningSync: timerStatus.runningSync,
                                                                            timerState: .stopped,
                                                                            screen: .timerDetails,
                                                                            watchDelegate: timerStatus.watchDelegate
                    )
                    newStatus.watchDelegate?.sendTimerControl(operation: .stop)
                    timerStatus = newStatus
                })
        )
        
    }
}
