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
// MARK: Private API (Callbacks)
/* ###################################################################################################################################### */
private extension TimerEngine {
    /* ################################################################## */
    /**
     This is the "first-level" callback from the timer. It can be called in any thread.
     
     - parameter inTimer: The timer object.
     - parameter inSuccess: True, if the timer completed its term.
     */
    func _timerCallback(_ inTimer: RVS_BasicGCDTimer, _ inSuccess: Bool) {
        guard inSuccess,
              !inTimer.isInvalid,
              inTimer.isRunning
        else {
            #if DEBUG
                print("TimerEngine: timerCallback(\(inSuccess)) -Rejected Call")
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

            if self.mode != self._lastMode {
                if let transitionHandler = self.transitionHandler {
                    #if DEBUG
                        print("\tTimerEngine: transitionHandler(\(self._lastMode), \(self.mode))")
                    #endif
                    transitionHandler(self, self._lastMode, self.mode)
                }
                self._lastMode = self.mode
            }
            
            self.tickHandler?(self)

            if 0 < self.currentTime {
                self._lastTick = .now
                self._lastMode = self.mode
            } else {
                self.end()
            }
        } else if nil == self._lastTick {
            self._lastTick = .now
            self.currentTime = self.startingTimeInSeconds
            if self._lastMode != self.mode {
                self.transitionHandler?(self, self._lastMode, self.mode)
                self._lastMode = self.mode
            }
            self.tickHandler?(self)
        }
        
        if .alarm == self.mode || .stopped == self.mode {
            self._timer?.isRunning = false
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Main Timer Engine Class -
/* ###################################################################################################################################### */
/**
 This class implements the "executable heart" of the timer app.
 
 # BASIC OVERVIEW
 
 This is a countdown timer, in seconds. It starts from a "starting" time, and counts down to 0, at which time it starts an alarm.
 
 It is a class, as opposed to a struct, so it can be referenced, and so that it can be easily mutated.
 
 The "granularity" of the timer is seconds. It does not deal with fractions of a second. Callbacks only happen on the second or state transitions, and can occur in any thread.
 
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
open class TimerEngine: Codable, Identifiable {
    /* ###################################################################################################################################### */
    // MARK: Private API (Static Properties)
    /* ###################################################################################################################################### */
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

    /* ###################################################################################################################################### */
    // MARK: Private API (Instance Properties)
    /* ###################################################################################################################################### */
    /* ################################################################## */
    /**
     This is the actual timer instance that runs the clock.
     */
    private var _timer: RVS_BasicGCDTimer?
    
    /* ################################################################## */
    /**
     This is only used for pausing and resuming. It contains the fraction of a second that was left, when the timer was paused.
     */
    private var _remainder: TimeInterval = 0
    
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

    /* ###################################################################################################################################### */
    // MARK: Public API (Typealias)
    /* ###################################################################################################################################### */
    /* ################################################################## */
    /**
     This is the structure of the callback for each "tick," handed to the instance. It is called once a second. It may be called in any thread.
     
     - parameter: The timer engine instance calling it.
     */
    public typealias TimerTickHandler = (_: TimerEngine) -> Void
    
    /* ################################################################## */
    /**
     This is the structure of the callback for mode transitions, handed to the instance. It is called, once only, when the timer mode changes. It may be called in any thread.
     
     - parameter: The timer engine instance calling it.
     - parameter: The mode we have transitioned from.
     - parameter: The mode we have transitioned into.
     */
    public typealias TimerTransitionHandler = (_: TimerEngine, _: Mode, _: Mode) -> Void
    
    /* ###################################################################################################################################### */
    // MARK: Public API (Enums)
    /* ###################################################################################################################################### */
    /* ################################################################################################################################## */
    // MARK: Codable Coding Keys Enum
    /* ################################################################################################################################## */
    /**
     These are part of the Codable conformance. They are used to mark the various field in the encoder/decoder.
     */
    public enum CodingKeys: String, CodingKey {
        /* ############################################################## */
        /**
         The instance ID (UUID)
         */
        case id

        /* ############################################################## */
        /**
         The starting (total) time (Int).
         */
        case startingTimeInSeconds

        /* ############################################################## */
        /**
         The warning threshold time (Int).
         */
        case warningTimeInSeconds

        /* ############################################################## */
        /**
         The final threshold time (Int).
         */
        case finalTimeInSeconds

        /* ############################################################## */
        /**
         The current countdown time (Int).
         */
        case currentTime

        /* ############################################################## */
        /**
         The time remaining, between the last tick, and the time of the pause (TimeInterval).
         */
        case remainder
        
        /* ############################################################## */
        /**
         The last mode (String).
         */
        case lastMode
    }
    
    /* ################################################################################################################################## */
    // MARK: Timer Mode State Enum
    /* ################################################################################################################################## */
    /**
     This defines the six timer states
     */
    public indirect enum Mode: Equatable, CustomStringConvertible {
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
        public var description: String {
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
    
    /* ###################################################################################################################################### */
    // MARK: Public API (Instance Properties)
    /* ###################################################################################################################################### */
    /* ################################################################## */
    /**
     This is the unique ID of this instance.
     */
    public var id: UUID

    /* ################################################################## */
    /**
     This is the beginning (total) countdown time.
     */
    public var startingTimeInSeconds: Int

    /* ################################################################## */
    /**
     This is the threshold, at which the clock switches into "warning" mode.
     */
    public var warningTimeInSeconds: Int
    
    /* ################################################################## */
    /**
     This is the threshold, at which the clock switches into "final" mode.
     */
    public var finalTimeInSeconds: Int

    /* ################################################################## */
    /**
     The callback for the tick handler. This can be called in any thread.
     */
    public var tickHandler: TimerTickHandler?
    
    /* ################################################################## */
    /**
     The callback for the transition handler. This can be called in any thread. It may also be nil.
     */
    public var transitionHandler: TimerTransitionHandler?

    /* ################################################################## */
    /**
     This is the current time. It can be set to change the time in the timer. The new value is clamped to the timer range.
     */
    public var currentTime: Int { didSet { self.currentTime = Int(min(max(currentTime, 0), self.startingTimeInSeconds)) } }
    
    /* ###################################################################################################################################### */
    // MARK: Public API (Initializers)
    /* ###################################################################################################################################### */
    /* ################################################################## */
    /**
     Default initializer
     
     We specify all three thresholds. The starting threshold is required. The other two are optional, and will be ignored, if not specified.
  
     - parameter startingTimeInSeconds: This is the beginning (total) countdown time. If not supplied, is set to 0.
     - parameter warningTimeInSeconds: This is the threshold, at which the clock switches into "warning" mode. If not supplied, is set to 0.
     - parameter finalTimeInSeconds: This is the threshold, at which the clock switches into "final" mode. If not supplied, is set to 0.
     - parameter transitionHandler: The callback for each transition. This is optional.
     - parameter id: The ID of this instance (Standard UUID). It must be unique, in the scope of this app. A new UUID is assigned, if not provided.
     - parameter startImmediately: If true (default is false), the timer will start as soon as the instance is initialized.
     - parameter tickHandler: The callback for each tick. This can be a tail completion, and is optional.
     */
    public init(startingTimeInSeconds inStartingTimeInSeconds: Int = 0,
                warningTimeInSeconds inWarningTimeInSeconds: Int = 0,
                finalTimeInSeconds inFinalTimeInSeconds: Int = 0,
                transitionHandler inTransitionHandler: TimerTransitionHandler? = nil,
                id inID: UUID = UUID(),
                startImmediately inStartImmediately: Bool = false,
                tickHandler inTickHandler: TimerTickHandler? = nil
    ) {
        // NOTE: Starting from now, I am ignoring previous convention, and always specifying "self.", when referencing properties and methods.
        self.startingTimeInSeconds = inStartingTimeInSeconds
        self.warningTimeInSeconds = inWarningTimeInSeconds
        self.finalTimeInSeconds = inFinalTimeInSeconds
        self.currentTime = inStartingTimeInSeconds
        self.transitionHandler = inTransitionHandler
        self.id = inID
        self.tickHandler = inTickHandler
        self._remainder = 0
        
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
    
    /* ################################################################## */
    /**
     Codable Conformance. Decoder Initializer.
     
     - parameter from: The decoder with the state.
     */
    public required init(from inDecoder: any Decoder) throws {
        self.tickHandler = nil
        self.transitionHandler = nil
        self._timer = nil

        let values = try inDecoder.container(keyedBy: CodingKeys.self)
        
        self.startingTimeInSeconds = try values.decode(Int.self, forKey: .startingTimeInSeconds)
        self.warningTimeInSeconds = try values.decode(Int.self, forKey: .warningTimeInSeconds)
        self.finalTimeInSeconds = try values.decode(Int.self, forKey: .finalTimeInSeconds)
        self.currentTime = try values.decode(Int.self, forKey: .currentTime)
        self.id = try values.decode(UUID.self, forKey: .id)
        self._remainder = try values.decode(TimeInterval.self, forKey: .remainder)
        
        switch try values.decode(String.self, forKey: .lastMode) {
        case "countdown":
            self._lastMode = .countdown
            
        case "warning":
            self._lastMode = .warning
            
        case "final":
            self._lastMode = .final
            
        default:
            self._lastMode = .stopped
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Public API (Computed Read/Write Properties)
/* ###################################################################################################################################### */
public extension TimerEngine {
    /* ################################################################## */
    /**
     This returns the entire timer state as a simple dictionary, suitable for use in plists.
     The instance can be saved or restored from this. Restoring stops the timer.
     
     > NOTE: This does not affect the `tickHandler` or `transitionHandler` properties.
     */
    var asDictionary: [String: any Hashable] {
        get {
            var ret = [String: any Hashable]()
            
            ret[CodingKeys.startingTimeInSeconds.rawValue] = self.startingTimeInSeconds
            ret[CodingKeys.warningTimeInSeconds.rawValue] = self.warningTimeInSeconds
            ret[CodingKeys.finalTimeInSeconds.rawValue] = self.finalTimeInSeconds
            ret[CodingKeys.currentTime.rawValue] = self.currentTime
            ret[CodingKeys.id.rawValue] = self.id
            ret[CodingKeys.remainder.rawValue] = self._remainder
            
            switch self._lastMode {
            case .countdown:
                ret[CodingKeys.lastMode.rawValue] = "countdown"

            case .warning:
                ret[CodingKeys.lastMode.rawValue] = "warning"

            case .final:
                ret[CodingKeys.lastMode.rawValue] = "final"

            default:
                ret[CodingKeys.lastMode.rawValue] = "stopped"
            }
            
            return ret
        }
        
        set {
            self._timer?.isRunning = false
            self._timer?.invalidate()
            self._timer = nil
            
            self.startingTimeInSeconds = newValue[CodingKeys.startingTimeInSeconds.rawValue] as? Int ?? 0
            self.warningTimeInSeconds = newValue[CodingKeys.warningTimeInSeconds.rawValue] as? Int ?? 0
            self.finalTimeInSeconds = newValue[CodingKeys.finalTimeInSeconds.rawValue] as? Int ?? 0
            self.currentTime = newValue[CodingKeys.currentTime.rawValue] as? Int ?? 0
            self.id = newValue[CodingKeys.id.rawValue] as? UUID ?? UUID()
            self._remainder = newValue[CodingKeys.remainder.rawValue] as? TimeInterval ?? 0

            switch newValue[CodingKeys.lastMode.rawValue] as? String {
            case "countdown":
                self._lastMode = .countdown
                
            case "warning":
                self._lastMode = .warning
                
            case "final":
                self._lastMode = .final
                
            default:
                self._lastMode = .stopped
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Public API (Computed Read-Only Properties)
/* ###################################################################################################################################### */
public extension TimerEngine {
    /* ################################################################## */
    /**
     This is the timer mode (computed from the timer state). Read-Only.
     */
    var mode: Mode {
        var timeMode: Mode = (self._timer?.isRunning ?? false) && (0 < self.currentTime) ? .countdown
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
     
     > NOTE: If no final time (set to 0), then this returns an empty range. The range needs to be at least one second long (value of 2), to be valid.
     */
    var finalRange: ClosedRange<Int> {
        if 1 < self.finalTimeInSeconds {
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
// MARK: Public API (Instance Methods)
/* ###################################################################################################################################### */
public extension TimerEngine {
    /* ################################################################## */
    /**
     Starts the timer from the beginning. It will do so, from any timer state.
     
     This will interrupt any current timer.
     */
    func start() {
        self._timer = RVS_BasicGCDTimer(timeIntervalInSeconds: Self._timerInterval,
                                        onlyFireOnce: false,
                                        completion: self._timerCallback
        )
        
        self.currentTime = self.startingTimeInSeconds
        self._timer?.isRunning = true
        self.transitionHandler?(self, .stopped, .countdown)
        self._lastMode = .countdown
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
        if .stopped != self._lastMode {
            self.transitionHandler?(self, self._lastMode, .stopped)
            self._lastMode = .stopped
        }
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
        if .alarm != self._lastMode {
            self.transitionHandler?(self, self._lastMode, .alarm)
            self._lastMode = .alarm
        }
    }

    /* ################################################################## */
    /**
     This pauses a running timer. The timer must already be in `.countdown`, `warning`, or `final` state.
     - returns: The state of the instance, just prior to pausing (empty, if failed). Can be ignored.
     */
    @discardableResult
    func pause() -> [String: any Hashable] {
        var ret = [String: any Hashable]()
        
        switch self.mode {
        case .countdown, .warning, .final:
            ret = self.asDictionary
            self._lastMode = self.mode
            self._timer?.isRunning = false
            self._remainder = self._lastTick?.timeIntervalSinceNow ?? 0
            self.transitionHandler?(self, self._lastMode, .paused(self._lastMode))
            
        case .paused(let lastMode):
            #if DEBUG
                print("TimerEngine: trying to pause a paused timer. Last mode was: \(lastMode)")
            #endif
            fallthrough
            
        default:
            #if DEBUG
                print("TimerEngine: pause not performed.")
            #endif
            break
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This resumes a paused timer. The timer must already be in `.paused` state, or a new state should be provided.
     
     You can use this method to set a timer to a saved state, and start it going immediately.
     
     > NOTE: This does not affect the `tickHandler` or `transitionHandler` properties, unless they are provided as method arguments.
            If the `tickHandler` or `transitionHandler` method arguments are supplied, and the resume fails, they will not be applied.

     - parameter inState: The saved state of the timer. If provided, the timer is set to that state, and started immediately, as opposed to a regular resume.
     - parameter transitionHandler: The callback for each transition. This is optional.
     - parameter tickHandler: The callback for each tick. This can be a tail completion, and is optional.
     - returns: True, if the resume was successful.
     */
    @discardableResult
    func resume(_ inState: [String: any Hashable]? = nil,
                transitionHandler inTransitionHandler: TimerTransitionHandler? = nil,
                tickHandler inTickHandler: TimerTickHandler? = nil
                ) -> Bool {
        guard (inState ?? [:]).isEmpty else {
            if let state = inState {
                #if DEBUG
                    print("TimerEngine: restoring to state as resume.")
                #endif
                asDictionary = state
                self.transitionHandler = inTransitionHandler ?? transitionHandler
                self.tickHandler = inTickHandler ?? tickHandler
                self._timer = RVS_BasicGCDTimer(timeIntervalInSeconds: Self._timerInterval,
                                                onlyFireOnce: false,
                                                completion: self._timerCallback
                )
                self._lastTick = Date.now.addingTimeInterval(self._remainder)
                self._timer?.isRunning = true
                self.transitionHandler?(self, self._lastMode, self.mode)
                return true
            } else {
                #if DEBUG
                    print("TimerEngine: ERROR: bad state supplied for resume.")
                #endif
                return false
            }
        }
        
        if case .paused(let lastMode) = self.mode {
            #if DEBUG
                print("TimerEngine: resuming a paused timer.")
            #endif
            if nil == self._timer {
                self._timer = RVS_BasicGCDTimer(timeIntervalInSeconds: Self._timerInterval,
                                                onlyFireOnce: false,
                                                completion: self._timerCallback
                )
            }
            self._lastTick = Date.now.addingTimeInterval(self._remainder)
            self._timer?.isRunning = true
            self.transitionHandler?(self, .paused(lastMode), lastMode)
            self.transitionHandler = inTransitionHandler ?? transitionHandler
            self.tickHandler = inTickHandler ?? tickHandler
            return true
        } else {
            #if DEBUG
                print("TimerEngine: ERROR: trying to resume a running timer.")
            #endif
            return false
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Public API (Codable Conformance)
/* ###################################################################################################################################### */
public extension TimerEngine {
    /* ################################################################## */
    /**
     Codable Conformance: The Encoder.
     
     - parameter to: The Encoder to be loaded with our state.
     */
    func encode(to inEncoder: any Encoder) throws {
        var container = inEncoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.startingTimeInSeconds, forKey: .startingTimeInSeconds)
        try container.encode(self.warningTimeInSeconds, forKey: .warningTimeInSeconds)
        try container.encode(self.finalTimeInSeconds, forKey: .finalTimeInSeconds)
        try container.encode(self.currentTime, forKey: .currentTime)
        try container.encode(self.id, forKey: .id)
        try container.encode(self._remainder, forKey: .remainder)
        
        switch self._lastMode {
        case .countdown:
            try container.encode("countdown", forKey: .lastMode)

        case .warning:
            try container.encode("warning", forKey: .lastMode)

        case .final:
            try container.encode("final", forKey: .lastMode)

        default:
            try container.encode("stopped", forKey: .lastMode)
        }
    }
}
