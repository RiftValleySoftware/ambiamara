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
 This implements an observable object wrapper, aggregating the basic model.
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

    /* ###################################################################### */
    /**
     This is only relevant to the Watch app. This becomes true, if we can reach the iPhone app.
     */
    var canReachIPhoneApp = false

    /* ################################################################## */
    /**
     Default initializer.
     
     It creates the communication instance, and sets up the various local callbacks.
     */
    init() {
        self.canReachIPhoneApp = false
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
            self.canReachIPhoneApp = self._wcSessionDelegateHandler?.canReachIPhoneApp ?? false
            if self.canReachIPhoneApp,
               self.isCurrentlyRunning,
               !(self.timerModel?.selectedTimer?.isTimerRunning ?? false) {
                if case .paused = self.timerModel?.selectedTimer?.timerMode {
                    self.timerModel?.selectedTimer?.resume()
                } else {
                    self.timerModel?.selectedTimer?.start()
                }
            }
            self.objectWillChange.send()
        }
    }

    /* ################################################################## */
    /**
     Called upon getting an update from the phone.
     
     - parameter inWatchDelegate: The Watch communication instance.
    */
    private func _delegateUpdateHandler(_ inWatchDelegate: RiValT_WatchDelegate?, update inForceUpdate: Bool = false) {
        self._showBusy = !inForceUpdate
        self.currentTimer?.tickHandler = self._tickHandler
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
     Callede when there's an error.
     
     - parameter: The watch delkegate (ignored).
     - parameter: The error (also ignored).
    */
    private func _errorHandler(_: RiValT_WatchDelegate?, _: Error?) {
        self.canReachIPhoneApp = false
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
    
    /* ###################################################################### */
    /**
     If the phone is in the running timer screen, this is true.
     */
    var isCurrentlyRunning: Bool { self._wcSessionDelegateHandler?.isCurrentlyRunning ?? false }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RiValT_ObservableModel {
    #if os(watchOS)    // Only necessary for Watch
        /* ############################################################## */
        /**
         This asks the phone to send us its current state.
         */
        func requestApplicationContextFromPhone() {
            self._wcSessionDelegateHandler?.sendContextRequest()
        }
    #endif
    
    /* ################################################################## */
    /**
     This sends a timer operation command to the peer
     
     - parameter inCommand: The operation to send.
     - parameter inExtraData: A String, with any value we wish associated with the command. Default is the command, itself.
     */
    func sendCommand(command inCommand: RiValT_WatchDelegate.TimerOperation, extraData inExtraData: String = "") {
        guard let currentTimer = self.currentTimer else { return }

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
            self._showBusy = true
            currentTimer.start()

        case .reset:
            self.currentTimer?.tickHandler = nil
            currentTimer.start()
            currentTimer.pause()
            currentTimer.currentTime = currentTimer.startingTimeInSeconds
            currentTimer.resetLastPausedTime()
            
        case .stop:
            self._showBusy = true
            self.currentTimer?.tickHandler = nil
            currentTimer.stop()

        case .pause:
            self.currentTimer?.tickHandler = nil
            currentTimer.pause()

        case .resume:
            self.currentTimer?.tickHandler = nil
            currentTimer.resume()
            
        case .fastForward:
            currentTimer.end()
        }
    }

    /* ################################################################## */
    /**
     This tries to open the app
     */
    func openCompanionApp() {
        self._wcSessionDelegateHandler?.openCompanionApp()
    }
}
