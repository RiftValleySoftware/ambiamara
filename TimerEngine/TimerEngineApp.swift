/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import SwiftUI

/* ###################################################################################################################################### */
// MARK: - Main App Frame -
/* ###################################################################################################################################### */
/**
 
 */
@main
struct TimerEngineApp: App {
    /* ################################################################## */
    /**
     */
    var body: some Scene {
        WindowGroup {
            TimerEngineContentView(seconds: 0)
        }
    }
}
