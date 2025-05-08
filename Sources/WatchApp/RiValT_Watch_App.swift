/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import SwiftUI
import WatchConnectivity
import WatchKit

@main
/* ###################################################################################################################################### */
// MARK: - Main Watch App -
/* ###################################################################################################################################### */
/**
 This is the main context for the timer Watch app.
 */
struct RiValT_Watch_App: App {
    /* ################################################################## */
    /**
     Tracks scene activity.
     */
    @Environment(\.scenePhase) private var _scenePhase

    /* ################################################################## */
    /**
     This handles the session delegate.
     */
    @State private var _wcSessionDelegateHandler = RiValT_WatchDelegate()

    /* ################################################################## */
    /**
     */
    @State private var _selectedTimerDisplay: String = "ERROR"

    /* ################################################################## */
    /**
     Making this true, forces a refresh of the UI.
     */
    @State private var _refresh: Bool = false

    /* ################################################################## */
    /**
     This is basically just a wrapper for the screens.
     */
    var body: some Scene {
        WindowGroup {
            RiValT_Watch_App_MainContentView(selectedTimerDisplay: self.$_selectedTimerDisplay,
                                             wcSessionDelegateHandler: self.$_wcSessionDelegateHandler,
                                             refresh: self.$_refresh
            )
        }
        .onChange(of: self._scenePhase) {
            if .active == self._scenePhase {
                self._wcSessionDelegateHandler.updateHandler = self.updateHandler
                self._refresh = true
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called upon getting an update from the phone. Always called in the main thread.
     
     - parameter inWatchDelegate: The Watch communication instance.
    */
    func updateHandler(_ inWatchDelegate: RiValT_WatchDelegate?) {
        inWatchDelegate?.timerModel.selectedTimer?.tickHandler = self.tickHandler
        inWatchDelegate?.timerModel.selectedTimer?.transitionHandler = self.transitionHandler
        self._refresh = true
    }
    
    /* ################################################################## */
    /**
     Called for each "tick."
     
     - parameter inTimer: The timer instance that's "ticking."
    */
    func tickHandler(_ inTimer: Timer) {
        self._selectedTimerDisplay = inTimer.timerDisplay
    }
    
    /* ################################################################## */
    /**
    */
    func transitionHandler(_ inTimer: Timer, _ inFromState: TimerEngine.Mode, _ inToState: TimerEngine.Mode) {
        self._refresh = true
    }
}
