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
    var body: some Scene {
        WindowGroup {
            Rift_Valley_Timer_Watch_App_MainContentView()
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
     
     - parameter inApplicationContext: The application context from the Watch.
     */
    func watchUpdateHandler(_ inApplicationContext: [String: Any]) {
        #if DEBUG
            print("Received Watch Context Update: \(inApplicationContext.debugDescription)")
        #endif
        
        guard let context = inApplicationContext["timers"] as? [[Int]] else { return }
        
        RVS_AmbiaMara_Settings().asWatchContextData = context
    }
}
