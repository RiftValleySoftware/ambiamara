/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_Generic_Swift_Toolbox
import RVS_UIKit_Toolbox

/* ###################################################################################################################################### */
// MARK: - Wrapper Struct for Timers -
/* ###################################################################################################################################### */
/**
 This struct is used as a wrapper for each individual timer, and provides accessors.
 
 We make it a class, so it can be easily mutated and referenced.
 */
class RiValT_TimerContainer: Hashable, Equatable {
    /* ############################################################## */
    /**
     Equatable Conformance
     
     - parameter lhs: The left-hand side of the comparison.
     - parameter rhs: The right-hand side of the comparison.
     
     - returns: True, if they are equal (same ID).
     */
    static func == (lhs: RiValT_TimerContainer, rhs: RiValT_TimerContainer) -> Bool { lhs.id == rhs.id }
    
    /* ############################################################## */
    /**
     The actual timer engine.
     */
    let timer = TimerEngine()

    /* ############################################################## */
    /**
     The timer's unique ID.
     */
    var id: UUID { self.timer.id }

    /* ############################################################## */
    /**
     The timer's index (temporary)
     */
    var index: Int = -1

    /* ############################################################## */
    /**
     This is the 00:00:00 format of the time, as a string.
     */
    var timerDisplay: String { self.timer.timerDisplay }
    
    /* ############################################################## */
    /**
     This is a direct accessor for the timer's tick handler callback.
     */
    var tickHandler: TimerEngine.TimerTickHandler? {
        get { self.timer.tickHandler }
        set { self.timer.tickHandler = newValue }
    }
    
    /* ############################################################## */
    /**
     This is a direct accessor for the timer's transition handler callback.
     */
    var transitionHandler: TimerEngine.TimerTransitionHandler? {
        get { self.timer.transitionHandler }
        set { self.timer.transitionHandler = newValue }
    }

    /* ############################################################## */
    /**
     This is the saved state of the timer. It may be extracted, or supplied.
     */
    var timerState: [String: any Hashable] {
        get { self.timer.asDictionary }
        set { self.timer.asDictionary = newValue }
    }
    
    /* ############################################################## */
    /**
     This is a direct accessor for the timer's starting time.
     */
    var startingTimeInSeconds: Int {
        get { self.timer.startingTimeInSeconds }
        set { self.timer.startingTimeInSeconds = newValue }
    }
    
    /* ############################################################## */
    /**
     This is a direct accessor for the timer's warning time.
     */
    var warningTimeInSeconds: Int {
        get { self.timer.warningTimeInSeconds }
        set { self.timer.warningTimeInSeconds = newValue }
    }
    
    /* ############################################################## */
    /**
     This is a direct accessor for the timer's final time.
     */
    var finalTimeInSeconds: Int {
        get { self.timer.finalTimeInSeconds }
        set { self.timer.finalTimeInSeconds = newValue }
    }
    
    /* ############################################################## */
    /**
     This is a direct accessor for the timer's current countdown time (integer).
     */
    var currentTime: Int {
        get { self.timer.currentTime }
        set { self.timer.currentTime = newValue }
    }
    
    /* ############################################################## */
    /**
     This is a direct accessor for the timer's current countdown time (precise).
     */
    var currentPreciseTime: TimeInterval? {
        get { self.timer.currentPreciseTime }
        set { self.timer.currentPreciseTime = newValue }
    }
    
    /* ############################################################## */
    /**
     Default initializer.

     - parameter inStartingTimeInSeconds: This is the beginning (total) countdown time. If not supplied, is set to 0.
     - parameter inWarningTimeInSeconds: This is the threshold, at which the clock switches into "warning" mode. If not supplied, is set to 0.
     - parameter inFinalTimeInSeconds: This is the threshold, at which the clock switches into "final" mode. If not supplied, is set to 0.
     - parameter inTransitionHandler: The callback for each transition. This is optional.
     - parameter inTickHandler: The callback for each tick. This can be a tail completion, and is optional.
     */
    init(startingTimeInSeconds inStartingTimeInSeconds: Int = 0,
         warningTimeInSeconds inWarningTimeInSeconds: Int = 0,
         finalTimeInSeconds inFinalTimeInSeconds: Int = 0,
         transitionHandler inTransitionHandler: TimerEngine.TimerTransitionHandler? = nil,
         tickHandler inTickHandler: TimerEngine.TimerTickHandler? = nil
    ) {
        self.timer.refCon = self
        self.timer.transitionHandler = inTransitionHandler
        self.timer.tickHandler = inTickHandler
        self.timer.startingTimeInSeconds = inStartingTimeInSeconds
        self.timer.warningTimeInSeconds = inWarningTimeInSeconds
        self.timer.finalTimeInSeconds = inFinalTimeInSeconds
    }
    
    /* ############################################################## */
    /**
     Starts the timer from the beginning. It will do so, from any timer state.
     
     This will interrupt any current timer.
     */
    func start() {
        self.timer.start()
    }
    
    /* ############################################################## */
    /**
     This stops the timer, and resets it to the starting point, with no alarm. It will do so, from any timer state.
     
     This will interrupt any current timer.
     */
    func stop() {
        self.timer.stop()
    }

    /* ################################################################## */
    /**
     This forces the timer into alarm mode. It will do so, from any timer state.
     
     This will interrupt any current timer.
     */
    func end() {
        self.timer.end()
    }
    
    /* ################################################################## */
    /**
     This pauses a running timer. The timer must already be in `.countdown`, `.warning`, or `.final` state.
     
     - returns: The state of the instance, just prior to pausing (empty, if failed). Can be ignored.
     */
    @discardableResult
    func pause() -> [String: any Hashable] {
        self.timer.pause()
    }
    
    /* ################################################################## */
    /**
     This resumes a paused timer. The timer must already be in `.paused` state, or a new state should be provided.
     
     You can use this method to set a timer to a saved state, and start it going immediately.
     
     > NOTE: This does not affect the `tickHandler` or `transitionHandler` properties, unless they are provided as method arguments.
            If the `tickHandler` or `transitionHandler` method arguments are supplied, and the resume fails, they will not be applied.

     - parameter inState: The saved state of the timer. If provided, the timer is set to that state, and started immediately, as opposed to a regular resume.
     - parameter inTransitionHandler: The callback for each transition. This is optional.
     - parameter inTickHandler: The callback for each tick. This can be a tail completion, and is optional.
     - returns: True, if the resume was successful.
     */
    @discardableResult
    func resume(_ inState: [String: any Hashable]? = nil,
                transitionHandler inTransitionHandler: TimerEngine.TimerTransitionHandler? = nil,
                tickHandler inTickHandler: TimerEngine.TimerTickHandler? = nil
                ) -> Bool {
        self.timer.resume(inState, transitionHandler: inTransitionHandler, tickHandler: inTickHandler)
    }

    /* ################################################################## */
    /**
     This forces the timer to sync directly to the given seconds. The date is the time that corresponds to the exact second. The timer is started, if it was not already running.
     
     > NOTE: This directly sets the timer to a running state, but the `tickHandler` and `transitionHandler` callbacks may not be immediately executed. The timer must already be in `.countdown`, `.warning`, or `.final` state.
     
     - parameter inSeconds: The actual integer second.
     - parameter inDate: The date that corresponds to the given second. If not supplied, .now is used.
     */
    func sync(to inSeconds: Int, date inDate: Date = .now) {
        self.timer.sync(to: inSeconds, date: inDate)
    }
    
    /* ############################################################## */
    /**
     Hashable Conformance.
     
     - parameter inOutHasher: The hasher we're loading up.
     */
    func hash(into inOutHasher: inout Hasher) {
        inOutHasher.combine(id)
    }
}
