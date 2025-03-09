/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import SwiftUI

@main
/* ###################################################################################################################################### */
// MARK: - Main Watch App -
/* ###################################################################################################################################### */
/**
 This is the main context for the timer Watch app.
 */
struct Rift_Valley_Timer_Watch_App: App {
    /* ################################################################## */
    /**
     Tracks scene activity.
     */
    @Environment(\.scenePhase) private var _scenePhase

    /* ############################################################## */
    /**
     This handles communications with the Watch app.
     */
    @State private var _watchDelegate: RVS_WatchDelegate?
    
    /* ################################################################## */
    /**
    */
    @State var timers: [RVS_AmbiaMara_Settings.TimerSettings] = []

    /* ################################################################## */
    /**
    */
    @State var selectedTimerIndex: Int = 0
    
    /* ################################################################## */
    /**
     */
    var body: some Scene {
        WindowGroup {
            Rift_Valley_Timer_Watch_App_MainContentView(timers: $timers, selectedTimerIndex: $selectedTimerIndex)
                .onAppear {
                    _watchDelegate = RVS_WatchDelegate(updateHandler: watchUpdateHandler)
                }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension Rift_Valley_Timer_Watch_App {
    /* ################################################################## */
    /**
     This responds to updates from the Watch delegate.
     
     - parameter inWatchDelegate: The delegate handler calling this.
     - parameter inApplicationContext: The application context from the Watch.
     */
    func watchUpdateHandler(_ inWatchDelegate: RVS_WatchDelegate?, _ inApplicationContext: [String: Any]) {
        #if DEBUG
            print("Received WatchData: \(inApplicationContext.debugDescription)")
        #endif
        
        if let sync = inApplicationContext["sync"] as? [TimeInterval] {
            #if DEBUG
                print("Received Sync: \(sync)")
            #endif
        }
        
        (timers, selectedTimerIndex) = (RVS_AmbiaMara_Settings().timers, RVS_AmbiaMara_Settings().currentTimerIndex)
    }
}
