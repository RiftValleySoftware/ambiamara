/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import SwiftUI
import RVS_Generic_Swift_Toolbox
import RVS_BasicGCDTimer

/* ###################################################################################################################################### */
// MARK: - Main Watch Content View -
/* ###################################################################################################################################### */
/**
 
 */
struct Rift_Valley_Timer_Watch_App_RunningTimerContentView: View {
    /* ################################################################## */
    /**
     This is the timer instance, associated with this screen.
    */
    @State var timer: RVS_AmbiaMara_Settings.TimerSettings

    /* ############################################################## */
    /**
     This will be the actual ticker for the running timer.
     */
    @Binding var runningTimerInstance: RVS_BasicGCDTimer?

    /* ################################################################## */
    /**
    */
    var body: some View {
        Text("HAI")
    }
}
