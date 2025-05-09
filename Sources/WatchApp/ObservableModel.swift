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
     This is the basic model for the whole app. It handles communication with the phone, as well as the local timer instance.
     */
    @Published var wcSessionDelegateHandler: RiValT_WatchDelegate
        
    /* ################################################################## */
    /**
     Default initializer.
     
     It creates the communication instance, and sets up the various local callbacks.
     */
    init() {
        self.wcSessionDelegateHandler = RiValT_WatchDelegate()
        self.wcSessionDelegateHandler.updateHandler = self._delegateUpdateHandler
        self.wcSessionDelegateHandler.timerModel.selectedTimer?.tickHandler = self._tickHandler
        self.wcSessionDelegateHandler.timerModel.selectedTimer?.transitionHandler = self._transitionHandler
    }
}

/* ###################################################################################################################################### */
// MARK: Private Instance Methods
/* ###################################################################################################################################### */
extension ObservableModel {
    /* ################################################################## */
    /**
     This simply calls the update handler, in the main thread.
    */
    private func _updateSubscribers() {
        DispatchQueue.main.async { self.objectWillChange.send() }
    }

    /* ################################################################## */
    /**
     Called upon getting an update from the phone.
     
     - parameter inWatchDelegate: The Watch communication instance.
    */
    private func _delegateUpdateHandler(_ inWatchDelegate: RiValT_WatchDelegate?) {
        self._updateSubscribers()
    }
    
    /* ################################################################## */
    /**
     Called for each "tick."
     
     - parameter inTimer: The timer instance that's "ticking."
    */
    private func _tickHandler(_ inTimer: Timer) {
        self._updateSubscribers()
    }
    
    /* ################################################################## */
    /**
     Called when the timer transitions from one state, ti another.
     
     - parameter inTimer: The timer instance that's transitioning.
     - parameter inFromState: The state that it's transitioning from.
     - parameter inToState: The state that it's transitioning to.
    */
    private func _transitionHandler(_ inTimer: Timer, _ inFromState: TimerEngine.Mode, _ inToState: TimerEngine.Mode) {
        self._updateSubscribers()
    }
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension ObservableModel {
    /* ################################################################## */
    /**
     This is an accessor for the local timer model object.
     */
    var timerModel: TimerModel? { self.wcSessionDelegateHandler.timerModel }
    
    /* ################################################################## */
    /**
     This is a direct accessor for the local selected timer.
     */
    var currentTimer: Timer? { self.timerModel?.selectedTimer }
    
    /* ################################################################## */
    /**
     This is a direct accessor for the group, to which the local selected timer belongs.
     */
    var currentGroup: TimerGroup? { self.currentTimer?.group }
}
