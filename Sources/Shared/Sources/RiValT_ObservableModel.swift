/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import Foundation

/* ###################################################################################################################################### */
// MARK: - Observable State Object -
/* ###################################################################################################################################### */
/**
 This implements an observable object, from the basic model.
 */
class RiValT_ObservableModel: ObservableObject {
    /* ################################################################## */
    /**
     This is the basic model for the whole app. It handles communication with the phone, as well as the local timer instance.
     */
    private var _wcSessionDelegateHandler: RiValT_WatchDelegate?
    
    /* ################################################################## */
    /**
     Set to true, if the progress view should be shown.
     */
    private var _showBusy: Bool = true { didSet { if self._showBusy { self._updateSubscribers() } } }

    /* ################################################################## */
    /**
     Default initializer.
     
     It creates the communication instance, and sets up the various local callbacks.
     */
    init() {
        self._wcSessionDelegateHandler = self._wcSessionDelegateHandler ?? RiValT_WatchDelegate(activate: false)
        self._wcSessionDelegateHandler?.updateHandler = self._delegateUpdateHandler
        self._wcSessionDelegateHandler?.activate()
    }
}

/* ###################################################################################################################################### */
// MARK: Private Instance Methods
/* ###################################################################################################################################### */
extension RiValT_ObservableModel {
    /* ################################################################## */
    /**
     This simply calls the update handler, in the main thread.
    */
    private func _updateSubscribers() {
        DispatchQueue.main.async {
            self._showBusy = false
            self.objectWillChange.send()
        }
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
extension RiValT_ObservableModel {
    /* ################################################################## */
    /**
     Returns true, if the progress view should be shown.
     */
    var showBusy: Bool { self._showBusy }

    /* ################################################################## */
    /**
     This is an accessor for the local timer model object.
     */
    var timerModel: TimerModel? { self._wcSessionDelegateHandler?.timerModel }
    
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

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RiValT_ObservableModel {
    /* ################################################################## */
    /**
     This sends a timer operation caommand to the peer
     
     - parameter inCommand: The operation to send.
     - parameter inExtraData: A String, with any value we wish associated with the command. Default is the command, itself.
     */
    func sendCommand(command inCommand: RiValT_WatchDelegate.TimerOperation, extraData inExtraData: String = "") {
        guard let currentTimer = self.currentTimer else { return }
        
        self._showBusy = true

        currentTimer.tickHandler = self._tickHandler
        currentTimer.transitionHandler = self._transitionHandler

        self._wcSessionDelegateHandler?.sendCommand(command: inCommand, extraData: inExtraData)

        switch inCommand {
        case .setTime:
            if !inExtraData.isEmpty,
               let toTime = Int(inExtraData),
               (0...currentTimer.startingTimeInSeconds).contains(toTime) {
                currentTimer.currentTime = toTime
                currentTimer.resetLastPausedTime()
            }

        case .start:
            currentTimer.start()

        case .reset:
            currentTimer.start()
            currentTimer.pause()
            currentTimer.currentTime = currentTimer.startingTimeInSeconds
            currentTimer.resetLastPausedTime()
            
        case .stop:
            currentTimer.stop()

        case .pause:
            currentTimer.pause()

        case .resume:
            currentTimer.resume()
            
        case .fastForward:
            currentTimer.end()
        }
    }
}
