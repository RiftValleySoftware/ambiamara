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
    var wcSessionDelegateHandler: RiValT_WatchDelegate
    
    /* ################################################################## */
    /**
     This is the external update handler that we'll call, when it's time to refresh. It is always called in the main thread.
    */
    var updateHandler: ((_: ObservableModel) -> Void)
    
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

    /* ################################################################## */
    /**
     Default initializer.
     
     It creates the communication instance, and sets up the various local callbacks.
    */
    init(updateHandler inUpdateHandler: @escaping (_: ObservableModel) -> Void) {
        self.updateHandler = inUpdateHandler
        self.wcSessionDelegateHandler = RiValT_WatchDelegate()
        self.wcSessionDelegateHandler.updateHandler = self.delegateUpdateHandler
        self.wcSessionDelegateHandler.timerModel.selectedTimer?.tickHandler = self.tickHandler
        self.wcSessionDelegateHandler.timerModel.selectedTimer?.transitionHandler = self.transitionHandler
    }
    
    /* ################################################################## */
    /**
     Called upon getting an update from the phone. Always called in the main thread.
     
     - parameter inWatchDelegate: The Watch communication instance.
    */
    func delegateUpdateHandler(_ inWatchDelegate: RiValT_WatchDelegate?) {
        self.updateHandler(self)
    }
    
    /* ################################################################## */
    /**
     Called for each "tick."
     
     - parameter inTimer: The timer instance that's "ticking."
    */
    func tickHandler(_ inTimer: Timer) {
        DispatchQueue.main.async { self.updateHandler(self) }
    }
    
    /* ################################################################## */
    /**
    */
    func transitionHandler(_ inTimer: Timer, _ inFromState: TimerEngine.Mode, _ inToState: TimerEngine.Mode) {
        DispatchQueue.main.async { self.updateHandler(self) }
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
     */
    private var _model: ObservableModel

    /* ################################################################## */
    /**
     This is basically just a wrapper for the screens.
     */
    var body: some Scene {
        WindowGroup {
            Text("HAI")
//            RiValT_Watch_App_MainContentView(wcSessionDelegateHandler: self._model.wcSessionDelegateHandler)
        }
    }
    
    /* ################################################################## */
    /**
     Default initializer
     */
    init() {
        self._model = ObservableModel { inModel in
            print("Hello!")
        }
    }
}
