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
 This displays a navigation list of timers (may only be one, in which case it automatically opens to that timer).
 */
struct Rift_Valley_Timer_Watch_App_MainContentView: View {
    /* ################################################################## */
    /**
     This contains the state for the app.
    */
    @Binding var timerStatus: Rift_Valley_Timer_Watch_App.TimerStatus

    /* ################################################################## */
    /**
     The main display body.
    */
    var body: some View {
        ViewThatFits {
            switch timerStatus.screen {
            case .timerList:
                Rift_Valley_Timer_Watch_App_TimerList(timerStatus: $timerStatus)
            case .timerDetails:
                Rift_Valley_Timer_Watch_App_IndividualTimerView(timerStatus: $timerStatus)
            case .runningTimer:
                Rift_Valley_Timer_Watch_App_RunningTimerView(timerStatus: $timerStatus)
            case .busy:
                ProgressView()
            case .appNotReachable:
                Text("SLUG-CANT-REACH-PHONE-APP".localizedVariant)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
