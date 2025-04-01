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
         
         - parameter: The mode (countdown, warning, or final) that the timer was in, before the pause.
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
     We will ask for a callback, every ten milliseconds. Since our granularity is a second, this should be fine.
     */
    private static let _timerInterval = TimeInterval(0.01)
    
    /* ################################################################## */
    /**
     The integer above our maximum number of hours.
     */
    private static let _maxHours = 24
    
    /* ################################################################## */
    /**
     The integer above our maximum number of minutes.
     */
    private static let _maxMinutes = 60
    
    /* ################################################################## */
    /**
     The integer above our maximum number of seconds.
     */
    private static let _maxSeconds = 60

    /* ################################################################## */
    /**
     The number of seconds in a minute.
     */
    private static let _secondsInMinute = 60

    /* ################################################################## */
    /**
     The number of seconds in an hour.
     */
    private static let _secondsInHour = 3600

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
    let startingTimeInSeconds: Int
    
    /* ################################################################## */
    /**
     This is the threshold, at which the clock switches into "warning" mode.
     */
    let warningTimeInSeconds: Int
    
    /* ################################################################## */
    /**
     This is the threshold, at which the clock switches into "final" mode.
     */
    let finalTimeInSeconds: Int
    
    /* ################################################################## */
    /**
     This is the current time. It can be set to change the time in the timer. The new value is clamped to the timer range.
     */
    var currentTime: Int { didSet { self.currentTime = Int(min(max(currentTime, 0), self.startingTimeInSeconds)) } }
    
    /* ################################################################## */
    /**
     Default initializer
     
     We specify all three thresholds. The starting threshold is required. The other two are optional, and will be ignored, if not specified.
     We also require at least a tick handler callback. A threshold handler callback is optional.
     
    - parameter startingTimeInSeconds: This is the beginning (total) countdown time.
    - parameter warningTimeInSeconds: This is the threshold, at which the clock switches into "warning" mode.
    - parameter finalTimeInSeconds: This is the threshold, at which the clock switches into "final" mode.
    - parameter transitionHandler: The callback for each transition. This is optional.
    - parameter startImmediately: If true (default is false), the timer will start as soon as the instance is initialized.
    - parameter tickHandler: The callback for each tick. This is required, and can be a tail completion.
     */
    init(startingTimeInSeconds inStartingTimeInSeconds: Int,
         warningTimeInSeconds inWarningTimeInSeconds: Int = 0,
         finalTimeInSeconds inFinalTimeInSeconds: Int = 0,
         transitionHandler inTransitionHandler: TimerTransitionHandler? = nil,
         startImmediately inStartImmediately: Bool = false,
         tickHandler inTickHandler: @escaping TimerTickHandler
    ) {
        // NOTE: Starting from now, I am ignoring previous convention, and always specifying "self.", when referencing properties and methods.
        self.startingTimeInSeconds = inStartingTimeInSeconds
        self.warningTimeInSeconds = inWarningTimeInSeconds
        self.finalTimeInSeconds = inFinalTimeInSeconds
        self.currentTime = inStartingTimeInSeconds
        self._transitionHandler = inTransitionHandler
        self._tickHandler = inTickHandler
        
        #if DEBUG
            print("TimerEngine: fullRange: \(self.fullRange)")
            print("TimerEngine: startRange: \(self.startRange)")
            print("TimerEngine: warnRange: \(self.warnRange)")
            print("TimerEngine: finalRange: \(self.finalRange)")
        #endif

        if inStartImmediately {
            self.start()
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension TimerEngine {
    /* ################################################################## */
    /**
     This is the timer mode (computed from the timer state). Read-Only.
     */
    var mode: Mode {
        var timeMode: Mode = self._timer?.isRunning ?? false ? .countdown
                        : 0 == self.currentTime ? .alarm
                            : nil == self._timer ? .stopped
                                : .paused(self._lastMode)
        
        if self._timer?.isRunning ?? false {
            switch self.currentTime {
            case finalRange:
                timeMode = .final
                
            case warnRange:
                timeMode = .warning
                
            case startRange:
                timeMode = .countdown
                
            default:
                break
            }
        }
        
        return timeMode
    }
    
    /* ################################################################## */
    /**
     This is a closed range, from one second after the warn or final (if no warn), or the very beginning (if no final), to (and including) the start time.
     
     > NOTE: The range needs to be at least one second long, to be valid.
     */
    var startRange: ClosedRange<Int> {
        if 0 < self.warnRange.upperBound,
           self.warnRange.upperBound < self.startingTimeInSeconds {
            return (self.warnRange.upperBound + 1)...self.startingTimeInSeconds
        } else if 0 < self.finalRange.upperBound,
                  self.finalRange.upperBound < self.startingTimeInSeconds {
            return (self.finalRange.upperBound + 1)...self.startingTimeInSeconds
        } else {
            return self.fullRange
        }
    }

    /* ################################################################## */
    /**
     This is a closed range, from one second after the final, or the very beginning, to (and including) the warn time.
     
     > NOTE: If no warn time (set to 0), then this returns an empty range. The range needs to be at least one second long, to be valid.
     */
    var warnRange: ClosedRange<Int> {
        if 0 < self.finalRange.upperBound,
           self.finalRange.upperBound < self.warningTimeInSeconds {
            return (self.finalRange.upperBound + 1)...self.warningTimeInSeconds
        } else {
            return 0...0
        }
    }
    
    /* ################################################################## */
    /**
     This is a closed range, from the very beginning, to (and including) the final time.
     
     > NOTE: If no final time (set to 0), then this returns an empty range. The range needs to be at least one second long, to be valid.
     */
    var finalRange: ClosedRange<Int> {
        if 0 < (self.finalTimeInSeconds - 1) {
            return 1...self.finalTimeInSeconds
        } else {
            return 0...0
        }
    }

    /* ################################################################## */
    /**
     This is the entire timer range, expressed as a closed seconds range.
     */
    var fullRange: ClosedRange<Int> { return 0...self.startingTimeInSeconds }

    /* ################################################################## */
    /**
     Returns true, if the timer is currently "ticking."
     */
    var isTicking: Bool { return self._timer?.isRunning ?? false }
    
    /* ################################################################## */
    /**
     This returns an "optimized" string, with the current countdown time.
    */
    var timerDisplay: String {
        let currentTime = self.currentTime
        let hour = currentTime / Self._secondsInHour
        let minute = currentTime / Self._secondsInMinute - (hour * Self._secondsInMinute)
        let second = currentTime - ((hour * Self._secondsInHour) + (minute * Self._secondsInMinute))
        if (1..<Self._maxHours).contains(hour) {
            return String(format: "%d:%02d:%02d", hour, minute, second)
        } else if (1..<Self._maxMinutes).contains(minute) {
            return String(format: "%d:%02d", minute, second)
        } else if (1..<Self._maxSeconds).contains(second) {
            return String(format: "%d", second)
        } else {
            return ""
        }
    }
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
        guard inSuccess else {
            #if DEBUG
                print("TimerEngine: timerCallback(\(inSuccess))")
            #endif
            return
        }
        
        #if DEBUG
            print("TimerEngine: timerCallback(\(inSuccess))")
        #endif
        
        if let lastTick = self._lastTick,
           1 <= Int(-lastTick.timeIntervalSinceNow) {
            self.currentTime -= 1
            #if DEBUG
                if self._lastTick != .now {
                    print("\tTimerEngine: difference from last tick, in seconds: \(self._lastTick?.timeIntervalSinceNow ?? 0)")
                }
                print("\tTimerEngine: updated currentTime: \(self.currentTime)")
                if self.mode != self._lastMode {
                    print("\tTimerEngine: last mode: \(self._lastMode), new mode: \(self.mode)")
                }
            #endif

            if self.mode != self._lastMode,
               let transitionHandler = self._transitionHandler {
                #if DEBUG
                    print("\tTimerEngine: transitionHandler(\(self._lastMode), \(self.mode))")
                #endif
                transitionHandler(self, self._lastMode, self.mode)
            }
            
            self._tickHandler(self)

            if 0 < self.currentTime {
                self._lastTick = .now
                self._lastMode = self.mode
            } else {
                self.end()
            }
        } else if nil == self._lastTick {
            self._lastTick = .now
            self.currentTime = self.startingTimeInSeconds
            self._transitionHandler?(self, .stopped, .countdown)
            self._tickHandler(self)
        }
        
        if .alarm == self.mode || .stopped == self.mode {
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
     Starts the timer from the beginning. It will do so, from any timer state.
     
     This will interrupt any current timer.
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
     This stops the timer, and resets it to the starting point, with no alarm. It will do so, from any timer state.
     
     This will interrupt any current timer.
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
     This forces the timer into alarm mode. It will do so, from any timer state.
     
     This will interrupt any current timer.
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
     This pauses a running timer. The timer must already be in `.countdown` state.
     */
    func pause() {
        if case .paused(let lastMode) = self.mode {
            #if DEBUG
                print("TimerEngine: trying to pause a paused timer. Last mode was: \(lastMode)")
            #endif
        } else {
            self._timer?.isRunning = false
            self._transitionHandler?(self, self._lastMode, .paused(self._lastMode))
        }
    }
    
    /* ################################################################## */
    /**
     This resumes a paused timer. The timer must already be in `.paused` state.
     */
    func resume() {
        if case .paused(let lastMode) = self.mode {
            self._timer?.isRunning = true
            self._transitionHandler?(self, .paused(lastMode), lastMode)
        } else {
            #if DEBUG
                print("TimerEngine: trying to resume a running timer.")
            #endif
        }
    }
}
