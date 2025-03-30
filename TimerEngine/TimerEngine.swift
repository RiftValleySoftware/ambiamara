/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import Foundation
import RVS_Generic_Swift_Toolbox
import RVS_BasicGCDTimer

/* ###################################################################################################################################### */
// MARK: - Main Timer Engine -
/* ###################################################################################################################################### */
/**
 This struct implements the "executable heart" of the timer app.
 
 # BASIC OVERVIEW
 
 This is a countdown timer, in seconds. It starts from a "starting" time, and counts down to 0, at which time it starts an alarm.
 
 The "granularity" of the timer is seconds. It does not deal with fractions of a second. Anything over a fraction of a second is rounded down, when pausing. Callbacks only happen on the second transitions.
 
 It has six "modes" of operation:
 
 ## STOPPED MODE
 
 The timer is "stopped." It is set to the starting time, and the timer is not running.

 ## COUNTDOWN MODE
 
 This is the basic countdown mode, starting from the "starting time" threshold.
 
 ## WARNING MODE

 This is a threshold, in seconds. Once the coundown reaches this, the timer goes into "warning" mode. This cannot be less than the final threshold (or 0), and cannot be higher than the starting threshold.
 
 ## FINAL MODE
 
 This is a threshold, in seconds. Once the coundown reaches this, the timer goes into "final" mode. The timer is running. This cannot be less than 0, and cannot be higher than the warning threshold.
 
 ## ALARM MODE
 
 Once it hits 0, it goes into "alarm" mode. The timer stops running, once this threshold is encountered.
 
 ## PAUSED MODE
 
 The timer countdown is in one of the above ranges, but has been "paused." It is not running.
 */
struct TimerEngine {
    /* ################################################################################################################################## */
    // MARK: Timer Completion Handler
    /* ################################################################################################################################## */
    /**
     This is the structure of the callback for each "tick," handed to the instance. It is called once a second. It may be called in any thread.
     
     - parameter: The timer engine instance calling it.
     */
    typealias TimerTickHandler = (_: TimerEngine) -> Void
    
    /* ################################################################################################################################## */
    // MARK: Timer Transition Handler
    /* ################################################################################################################################## */
    /**
     This is the structure of the callback for mode transitions, handed to the instance. It is called, once only, when the timer mode changes. It may be called in any thread.
     
     - parameter: The timer engine instance calling it.
     - parameter: The mode we have transitioned into.
     */
    typealias TimerTransitionHandler = (_: TimerEngine, _: Mode) -> Void
    
    /* ################################################################################################################################## */
    // MARK: Timer Mode State Enum
    /* ################################################################################################################################## */
    /**
     This defines the six timer states
     */
    indirect enum Mode {
        /* ############################################################## */
        /**
         The timer is "stopped." It is set to the starting time, and the timer is not running.
         */
        case stopped
        
        /* ############################################################## */
        /**
         The timer is in the time between the "starting" threshold, and the next threshold (warning, final, or alarm).
         */
        case countdown
        
        /* ############################################################## */
        /**
         The timer is in the time between the "warning" threshold, and the next threshold (final or alarm).
         */
        case warning
        
        /* ############################################################## */
        /**
         The timer is in the time between the "warning" threshold, and 0 (alarm).
         */
        case final
        
        /* ############################################################## */
        /**
         The timer is at 0.
         */
        case alarm
        
        /* ############################################################## */
        /**
         The timer is between 0 and the "starting time," but is not running.
         
         - parameter: The mode (countdown, warning, or final) that the timer is in.
         */
        case paused(Mode)
    }
    
    /* ################################################################## */
    /**
     We will ask for a callback, every tenth-second. Since our granularity is a second, this should be fine.
     */
    private static let _timerInterval = TimeInterval(0.1)
    
    /* ################################################################## */
    /**
     This is the actual timer instance that runs the clock.
     */
    private var _timer: RVS_BasicGCDTimer?
    
    /* ################################################################## */
    /**
     The callback for the tick handler. This can be called in any thread.
     */
    private let _tickHandler: TimerTickHandler
    
    /* ################################################################## */
    /**
     The callback for the transition handler. This can be called in any thread. It may also be nil.
     */
    private let _transitionHandler: TimerTransitionHandler?

    /* ################################################################## */
    /**
     This is the beginning (total) countdown time.
     */
    let startingTimeInSeconds: TimeInterval
    
    /* ################################################################## */
    /**
     This is the threshold, at which the clock switches into "warning" mode.
     */
    let warningTimeInSeconds: TimeInterval
    
    /* ################################################################## */
    /**
     This is the threshold, at which the clock switches into "final" mode.
     */
    let finalTimeInSeconds: TimeInterval
    
    /* ################################################################## */
    /**
     This is the current time.
     */
    var currentTime: TimeInterval
    
    /* ################################################################## */
    /**
     Default initializer
     
     We specify all three thresholds. The starting threshold is required. The other two are optional, and will be ignored, if not specified.
     We also require at least a tick handler callback. A threshold handler callback is optional.
     
     - parameters:
        - startingTimeInSeconds: This is the beginning (total) countdown time.
        - warningTimeInSeconds: This is the threshold, at which the clock switches into "warning" mode.
        - finalTimeInSeconds: This is the threshold, at which the clock switches into "final" mode.
        - transitionHandler: The callback for each transition. This is optional.
        - tickHandler: The callback for each tick. This is required, and can be a tail completion.
     */
    init(startingTimeInSeconds inStartingTimeInSeconds: TimeInterval,
         warningTimeInSeconds inWarningTimeInSeconds: TimeInterval = 0,
         finalTimeInSeconds inFinalTimeInSeconds: TimeInterval = 0,
         transitionHandler inTransitionHandler: TimerTransitionHandler? = nil,
         tickHandler inTickHandler: @escaping TimerTickHandler
    ) {
        // NOTE: Starting from now, I am ignoring previous convention, and always specifying "self."
        self.startingTimeInSeconds = inStartingTimeInSeconds
        self.warningTimeInSeconds = inWarningTimeInSeconds
        self.finalTimeInSeconds = inFinalTimeInSeconds
        self.currentTime = inStartingTimeInSeconds
        self._transitionHandler = inTransitionHandler
        self._tickHandler = inTickHandler

        self._timer = RVS_BasicGCDTimer(timeIntervalInSeconds: Self._timerInterval,
                                        onlyFireOnce: false,
                                        queue: .global(),
                                        isWallTime: true,
                                        completion: self.timerCallback
        )
    }
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension TimerEngine {
    /* ################################################################## */
    /**
     This is the timer mode (computed from the timer state).
     */
    var mode: Mode {
        .stopped
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension TimerEngine {
    /* ################################################################## */
    /**
     */
    func timerCallback(_ inTimer: RVS_BasicGCDTimer, _ inSuccess: Bool) {
        
    }
}
