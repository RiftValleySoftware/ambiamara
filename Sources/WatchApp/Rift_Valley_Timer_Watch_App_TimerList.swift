/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import SwiftUI

/* ###################################################################################################################################### */
// MARK: - List of Timers View -
/* ###################################################################################################################################### */
/**
 This displays a navigation list of timers (may only be one, in which case it automatically opens to that timer).
 */
struct Rift_Valley_Timer_Watch_App_TimerList: View {
    /* ################################################################## */
    /**
     This contains the state for the app.
    */
    @Binding var timerStatus: Rift_Valley_Timer_Watch_App.TimerStatus

    /* ################################################################## */
    /**
     This displays a list of all the available timers. Tapping on a timer will open the details screen for that timer.
    */
    var body: some View {
        List(timerStatus.timers, id: \.id) { inTimer in
            let startTimeString = inTimer.startTimeAsString
            Button {
                RVS_AmbiaMara_Settings().currentTimerIndex = inTimer.index
                timerStatus.watchDelegate?.sendApplicationContext()
                timerStatus = Rift_Valley_Timer_Watch_App.TimerStatus(timers: timerStatus.timers,
                                                                      selectedTimerIndex: inTimer.index,
                                                                      runningSync: timerStatus.runningSync,
                                                                      timerState: timerStatus.timerState,
                                                                      screen: .timerDetails,
                                                                      watchDelegate: timerStatus.watchDelegate
                )
            } label: {
                Text(startTimeString)
                    .foregroundColor(Color(inTimer.index == timerStatus.selectedTimerIndex ? "Start-Color" : "Paused-Color"))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .font(Font.custom("Let's go Digital Regular", size: 60))
                    .padding(0.1)
            }
            .padding(0.1)
        }
    }
}
