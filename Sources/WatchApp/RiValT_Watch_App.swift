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

/* ###################################################################################################################################### */
// MARK: - Observable State Object -
/* ###################################################################################################################################### */
/**
 */
class ObservableModel: ObservableObject {
    /* ################################################################## */
    /**
    */
    var wcSessionDelegateHandler: RiValT_WatchDelegate
    
    /* ################################################################## */
    /**
    */
    var timerModel: TimerModel? { self.wcSessionDelegateHandler.timerModel }
    
    /* ################################################################## */
    /**
    */
    var currentTimer: Timer? { self.timerModel?.selectedTimer }

    /* ################################################################## */
    /**
    */
    var currentGroup: TimerGroup? { self.currentTimer?.group }

    /* ################################################################## */
    /**
    */
    init() {
        self.wcSessionDelegateHandler = RiValT_WatchDelegate()
        self.wcSessionDelegateHandler.updateHandler = self.updateHandler
        self.wcSessionDelegateHandler.timerModel.selectedTimer?.tickHandler = self.tickHandler
        self.wcSessionDelegateHandler.timerModel.selectedTimer?.transitionHandler = self.transitionHandler
    }
    
    /* ################################################################## */
    /**
     Called upon getting an update from the phone. Always called in the main thread.
     
     - parameter inWatchDelegate: The Watch communication instance.
    */
    func updateHandler(_ inWatchDelegate: RiValT_WatchDelegate?) {
    }
    
    /* ################################################################## */
    /**
     Called for each "tick."
     
     - parameter inTimer: The timer instance that's "ticking."
    */
    func tickHandler(_ inTimer: Timer) {
    }
    
    /* ################################################################## */
    /**
    */
    func transitionHandler(_ inTimer: Timer, _ inFromState: TimerEngine.Mode, _ inToState: TimerEngine.Mode) {
    }
}

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
     This is basically just a wrapper for the screens.
     */
    var body: some Scene {
        WindowGroup {
            RiValT_Watch_App_MainContentView(wcSessionDelegateHandler: self.$_wcSessionDelegateHandler)
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
    }
    
    /* ################################################################## */
    /**
     Called for each "tick."
     
     - parameter inTimer: The timer instance that's "ticking."
    */
    func tickHandler(_ inTimer: Timer) {
    }
    
    /* ################################################################## */
    /**
    */
    func transitionHandler(_ inTimer: Timer, _ inFromState: TimerEngine.Mode, _ inToState: TimerEngine.Mode) {
    }
}
