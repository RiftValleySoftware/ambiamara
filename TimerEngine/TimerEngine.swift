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
 This class implements the "executable heart" of the timer app.
 
 # BASIC OVERVIEW
 
 This is a countdown timer, in seconds. It starts from a "starting" time, and counts down to 0, at which time it starts an alarm.
 
 It is a class, as opposed to a struct, so it can be referenced, and so that it can be easily mutated.
 
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
class TimerEngine {
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
     - parameter: The mode we have transitioned from.
     - parameter: The mode we have transitioned into.
     */
    typealias TimerTransitionHandler = (_: TimerEngine, _: Mode, _: Mode) -> Void
    
    /* ################################################################################################################################## */
    // MARK: Timer Mode State Enum
    /* ################################################################################################################################## */
    /**
     This defines the six timer states
     */
    indirect enum Mode: Equatable, CustomStringConvertible {
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
        
        /* ############################################################## */
        /**
         Debug description (CustomStringConvertible conformance)
         */
        var description: String {
            switch self {
            case .stopped:
                return "stopped"
                
            case .countdown:
                return "countdown"
                
            case .warning:
                return "warning"
                
            case .final:
                return "final"
                
            case .alarm:
                return "alarm"
                
            case let .paused(mode):
                return "paused(\(mode.description))"
            }
        }
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
     This is the date of the last tick. Nil, to start.
     */
    private var _lastTick: Date?
    
    /* ################################################################## */
    /**
     This is the previous timer mode (to track transitions).
     */
    private var _lastMode: Mode = .stopped

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
     This is the current time. It can be set to change the time in the timer. The new value is clamped to the timer range.
     */
    var currentTime: TimeInterval { didSet { self.currentTime = min(max(currentTime, 0), startingTimeInSeconds) } }
    
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
        // NOTE: Starting from now, I am ignoring previous convention, and always specifying "self.", when referencing properties and methods.
        self.startingTimeInSeconds = inStartingTimeInSeconds
        self.warningTimeInSeconds = inWarningTimeInSeconds
        self.finalTimeInSeconds = inFinalTimeInSeconds
        self.currentTime = inStartingTimeInSeconds
        self._transitionHandler = inTransitionHandler
        self._tickHandler = inTickHandler
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
        let timeMode: Mode = (self.currentTime <= self.finalTimeInSeconds) ? .final
                                : (self.currentTime <= self.warningTimeInSeconds) ? .warning
                                    : (0 == self.currentTime) ? .alarm
                                        : (self.startingTimeInSeconds >= self.currentTime && self._timer?.isRunning ?? false) ? .countdown
                                            : .stopped
        
        return (self._timer?.isRunning ?? false) ? timeMode
                    : (.alarm != timeMode && .stopped != timeMode) ? .countdown
                        : .paused(self._lastMode)
    }
    
    /* ################################################################## */
    /**
     This is the entire timer range, expressed as a closed seconds range.
     */
    var range: ClosedRange<TimeInterval> { return 0...self.finalTimeInSeconds }
    
    /* ################################################################## */
    /**
     Returns true, if the timer is currently "ticking."
     */
    var isTicking: Bool { return self._timer?.isRunning ?? false }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension TimerEngine {
    /* ################################################################## */
    /**
     This is the "first-level" callback from the timer. It can be called in any thread.
     
     - parameter inTimer: The timer object.
     - parameter inSuccess: True, if the timer completed its term.
     */
    func timerCallback(_ inTimer: RVS_BasicGCDTimer, _ inSuccess: Bool) {
        let currentMode = self.mode
        
        #if DEBUG
            print("TimerEngine: timerCallback(\(inSuccess))")
            print("TimerEngine: previous tick: \(self._lastTick ?? .now), current: \(Date.now), difference: \(self._lastTick?.timeIntervalSinceNow ?? 0)")
        #endif
        
        if 1.0 <= -(self._lastTick?.timeIntervalSinceNow ?? 0) {
            self.currentTime -= 1.0
            self._tickHandler(self)
            
            if currentMode != self._lastMode,
               let transitionHandler = self._transitionHandler {
                #if DEBUG
                    print("TimerEngine: transitionHandler(\(self._lastMode), \(currentMode))")
                #endif
                transitionHandler(self, self._lastMode, currentMode)
            }
            
            self._lastTick = .now
            self._lastMode = currentMode
        } else if nil == self._lastTick {
            self._lastTick = .now
            self.currentTime = self.startingTimeInSeconds
            self._tickHandler(self)
        }
        
        if .alarm == currentMode || .stopped == currentMode {
            self._timer?.isRunning = false
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension TimerEngine {
    /* ################################################################## */
    /**
     Starts the timer from the beginning.
     
     This will interrupt any previous timer.
     */
    func start() {
        self._timer = RVS_BasicGCDTimer(timeIntervalInSeconds: Self._timerInterval,
                                        onlyFireOnce: false,
                                        queue: .global(),
                                        isWallTime: true,
                                        completion: self.timerCallback
        )
        
        self._lastMode = .stopped
        self.currentTime = self.startingTimeInSeconds
        self._timer?.isRunning = true
        self._transitionHandler?(self, .stopped, .countdown)
    }

    /* ################################################################## */
    /**
     This stops the timer, and resets it to the starting point, with no alarm.
     */
    func stop() {
        self._timer?.isRunning = false
        self._timer?.invalidate()
        self._timer = nil
        self.currentTime = self.startingTimeInSeconds
        self._transitionHandler?(self, self._lastMode, .stopped)
    }

    /* ################################################################## */
    /**
     This forces the timer into alarm mode.
     */
    func end() {
        self._timer?.isRunning = false
        self._timer?.invalidate()
        self._timer = nil
        self.currentTime = 0
        self._transitionHandler?(self, self._lastMode, .alarm)
    }

    /* ################################################################## */
    /**
     This pauses a running timer.
     */
    func pause() {
        if case .countdown = self.mode {
            self._timer?.isRunning = false
        }
    }
    
    /* ################################################################## */
    /**
     This resumes a paused timer.
     */
    func resume() {
        if case .paused = self.mode {
            self._timer?.isRunning = true
        }
    }
}
