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
     This handles the session delegate.
     */
    @State private var _wcSessionDelegateHandler: RiValT_WatchDelegate

    /* ################################################################## */
    /**
     Toggling this, forces a refresh of the UI.
     */
    @State private var _refresh: Bool = false

    /* ################################################################## */
    /**
     This is basically just a wrapper for the screens.
     */
    var body: some Scene {
        WindowGroup {
            RiValT_Watch_App_MainContentView(wcSessionDelegateHandler: self.$_wcSessionDelegateHandler,
                                             refresh: self.$_refresh
            )
        }
    }
    
    /* ################################################################## */
    /**
     Default initializer
     */
    init() {
        self._wcSessionDelegateHandler = RiValT_WatchDelegate()
        self._wcSessionDelegateHandler.updateHandler = self.updateHandler
    }
    
    /* ################################################################## */
    /**
     Called upon getting an update from the phone. Always called in the main thread.
     
     - parameter inWatchDelegate: The Watch communication instance.
    */
    func updateHandler(_ inWatchDelegate: RiValT_WatchDelegate?) {
        self._wcSessionDelegateHandler.timerModel.selectedTimer?.tickHandler = self.tickHandler
        self._wcSessionDelegateHandler.timerModel.selectedTimer?.transitionHandler = self.transitionHandler
        self._refresh.toggle()
    }
    
    /* ################################################################## */
    /**
     Called for each "tick."
     
     - parameter inTimer: The timer instance that's "ticking."
    */
    func tickHandler(_ inTimer: Timer) {
        self._refresh.toggle()
    }
    
    /* ################################################################## */
    /**
    */
    func transitionHandler(_ inTimer: Timer, _ inFromState: TimerEngine.Mode, _ inToState: TimerEngine.Mode) {
        self._refresh.toggle()
    }
}
