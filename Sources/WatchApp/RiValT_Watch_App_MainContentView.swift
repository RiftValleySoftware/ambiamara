/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import SwiftUI

/* ###################################################################################################################################### */
// MARK: - Main Watch Content View -
/* ###################################################################################################################################### */
/**
 This displays a navigation list of timers (may only be one, in which case it automatically opens to that timer).
 */
struct RiValT_Watch_App_MainContentView: View {
    /* ################################################################## */
    /**
     */
    static let digitalFontMid = Font.custom("Let\'s Go Digital", size: 30)
    
    /* ################################################################## */
    /**
     This handles the session delegate.
     */
    @State private var _wcSessionDelegateHandler: RiValT_WatchDelegate?

    /* ################################################################## */
    /**
     */
    @State private var _selectedTimerDisplay: String = "ERROR"
    
    /* ################################################################## */
    /**
     Tracks scene activity.
     */
    @Environment(\.scenePhase) private var _scenePhase

    /* ################################################################## */
    /**
     The main display body.
    */
    var body: some View {
        Text(self._selectedTimerDisplay)
            .font(Self.digitalFontMid)
            .onAppear {
                self._wcSessionDelegateHandler = RiValT_WatchDelegate()
//                self._selectedTimerDisplay = self._wcSessionDelegateHandler?.timerModel.selectedTimer?.timerDisplay ?? "No Timer"
            }
    }
}
