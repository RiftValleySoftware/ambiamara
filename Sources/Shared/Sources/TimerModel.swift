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
// MARK: - Additional Accessors for the Timer Class -
/* ###################################################################################################################################### */
extension TimerEngine {
    /* ############################################################## */
    /**
     Simple cast to the wrapper instance that "owns" this timer.
     */
    var wrapper: Timer? { refCon as? Timer }
    
    /* ############################################################## */
    /**
     The group to which this timer's container belongs.
     */
    var group: TimerGroup? { wrapper?.group }
}

/* ###################################################################################################################################### */
// MARK: - Wrapper Struct for Timers -
/* ###################################################################################################################################### */
/**
 This struct is used as a wrapper for each individual timer, and provides accessors.
 
 We make it a class, so it can be easily mutated and referenced.
 */
class Timer: Equatable {
    /* ################################################################## */
    /**
     This is the structure of the callback for each "tick," handed to the instance. It is called once a second. This will always be called in the main thread.
     
     - parameter timer: The timer wrapper instance calling it.
     */
    public typealias TimerTickHandler = (_ timer: Timer) -> Void
    
    /* ################################################################## */
    /**
     This is the structure of the callback for mode transitions, handed to the instance. It is called, once only, when the timer mode changes. This will always be called in the main thread.
     
     - parameter timer: The timer wrapper instance calling it.
     - parameter fromMode: The mode we have transitioned from.
     - parameter toMode: The mode we have transitioned into.
     */
    public typealias TimerTransitionHandler = (_ timer: Timer, _ fromMode: TimerEngine.Mode, _ toMode: TimerEngine.Mode) -> Void
    
    /* ############################################################## */
    /**
     Equatable Conformance
     
     - parameter lhs: The left-hand side of the comparison.
     - parameter rhs: The right-hand side of the comparison.
     
     - returns: True, if they are equal (same ID).
     */
    static func == (lhs: Timer, rhs: Timer) -> Bool { lhs.id == rhs.id }
    
    /* ############################################################## */
    /**
     The actual timer engine.
     */
    private let _engine = TimerEngine()
    
    /* ############################################################## */
    /**
     The group to which this container belongs.
     */
    var group: TimerGroup?

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

    /* ############################################################## */
    /**
     Default initializer.
     
     - parameter inGroup: The group to which this container belongs. This is optional.
     - parameter inStartingTimeInSeconds: This is the beginning (total) countdown time. If not supplied, is set to 0.
     - parameter inWarningTimeInSeconds: This is the threshold, at which the clock switches into "warning" mode. If not supplied, is set to 0.
     - parameter inFinalTimeInSeconds: This is the threshold, at which the clock switches into "final" mode. If not supplied, is set to 0.
     - parameter inTransitionHandler: The callback for each transition. This is optional.
     - parameter inTickHandler: The callback for each tick. This can be a tail completion, and is optional.
     */
    init(group inGroup: TimerGroup? = nil,
         startingTimeInSeconds inStartingTimeInSeconds: Int = 0,
         warningTimeInSeconds inWarningTimeInSeconds: Int = 0,
         finalTimeInSeconds inFinalTimeInSeconds: Int = 0,
         transitionHandler inTransitionHandler: TimerTransitionHandler? = nil,
         tickHandler inTickHandler: TimerTickHandler? = nil
    ) {
        self.group = inGroup
        self._engine.refCon = self
        self._engine.tickHandler = self._internalTickHandler
        self._engine.transitionHandler = self._internalTransitionHandler
        self._engine.startingTimeInSeconds = inStartingTimeInSeconds
        self._engine.warningTimeInSeconds = inWarningTimeInSeconds
        self._engine.finalTimeInSeconds = inFinalTimeInSeconds
        self._engine.tickHandler = self._internalTickHandler
        self._engine.transitionHandler = self._internalTransitionHandler
        self.transitionHandler = inTransitionHandler
        self.tickHandler = inTickHandler
    }
    
    /* ############################################################## */
    /**
     Initializer with group and preset dictionary.
     
     - parameter inGroup: The group to which this instance belongs.
     - parameter inDictionary: The timer state, as a dictionary.
     - parameter inTransitionHandler: The callback for each transition. This is optional.
     - parameter inTickHandler: The callback for each tick. This can be a tail completion, and is optional.
     */
    init(group inGroup: TimerGroup? = nil,
         dictionary inDictionary: [String: any Hashable],
         transitionHandler inTransitionHandler: TimerTransitionHandler? = nil,
         tickHandler inTickHandler: TimerTickHandler? = nil
    ) {
        self.group = inGroup
        self._engine.asDictionary = inDictionary
        self._engine.refCon = self
        self._engine.tickHandler = self._internalTickHandler
        self._engine.transitionHandler = self._internalTransitionHandler
        self.transitionHandler = inTransitionHandler
        self.tickHandler = inTickHandler
    }
}

/* ###################################################################################################################################### */
// MARK: Read-Only Computed Properties
/* ###################################################################################################################################### */
extension Timer {
    /* ############################################################## */
    /**
     The timer's unique ID.
     */
    var id: UUID { self._engine.id }
    
    /* ############################################################## */
    /**
     This is the 00:00:00 format of the time, as a string.
     */
    var timerDisplay: String { self._engine.timerDisplay }
    
    /* ############################################################## */
    /**
     The index path of this timer, in the model.
     */
    var indexPath: IndexPath? {
        if let model = self.group?.model {
            for (sectionIndex, group) in model.enumerated() {
                for (itemIndex, timer) in group.enumerated() where timer == self {
                    return IndexPath(item: itemIndex, section: sectionIndex)
                }
            }
        }
        
        return nil
    }
}

/* ###################################################################################################################################### */
// MARK: Read/Write Computed Properties
/* ###################################################################################################################################### */
extension Timer {
    /* ############################################################## */
    /**
     This is the saved state of the timer. It may be extracted, or supplied.
     */
    var timerState: [String: any Hashable] {
        get { self._engine.asDictionary }
        set { self._engine.asDictionary = newValue }
    }
    
    /* ############################################################## */
    /**
     This is a direct accessor for the timer's starting time.
     */
    var startingTimeInSeconds: Int {
        get { self._engine.startingTimeInSeconds }
        set { self._engine.startingTimeInSeconds = newValue }
    }
    
    /* ############################################################## */
    /**
     This is a direct accessor for the timer's warning time.
     */
    var warningTimeInSeconds: Int {
        get { self._engine.warningTimeInSeconds }
        set { self._engine.warningTimeInSeconds = newValue }
    }
    
    /* ############################################################## */
    /**
     This is a direct accessor for the timer's final time.
     */
    var finalTimeInSeconds: Int {
        get { self._engine.finalTimeInSeconds }
        set { self._engine.finalTimeInSeconds = newValue }
    }
    
    /* ############################################################## */
    /**
     This is a direct accessor for the timer's current countdown time (integer).
     */
    var currentTime: Int {
        get { self._engine.currentTime }
        set { self._engine.currentTime = newValue }
    }
    
    /* ############################################################## */
    /**
     This is a direct accessor for the timer's current countdown time (precise).
     */
    var currentPreciseTime: TimeInterval? {
        get { self._engine.currentPreciseTime }
        set { self._engine.currentPreciseTime = newValue }
    }
    
    /* ################################################################## */
    /**
     This returns the entire timer state as a simple dictionary, suitable for use in plists.
     The instance can be saved or restored from this. Restoring stops the timer.
     
     > NOTE: This does not affect the `tickHandler` or `transitionHandler` properties.
     */
    var asDictionary: [String: any Hashable] {
        get { self._engine.asDictionary }
        set { self._engine.asDictionary = newValue }
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension Timer {
    /* ############################################################## */
    /**
     The callback for the individual second ticks. May be called in any thread.
     
     - parameter inTimerEngine: The timer engine.
     */
    private func _internalTickHandler(_ inTimerEngine: TimerEngine) {
        DispatchQueue.main.async { self.tickHandler?(self) }
    }
    
    /* ################################################################## */
    /**
     Called when the timer experiences a state transition.
     
     - parameter inTimerEngine: The timer engine.
     - parameter inFromMode: The previous mode (state).
     - parameter inToMode: The current (new) mode (state).
     */
    private func _internalTransitionHandler(_ inTimerEngine: TimerEngine, _ inFromMode: TimerEngine.Mode, _ inToMode: TimerEngine.Mode) {
        DispatchQueue.main.async { self.transitionHandler?(self, inFromMode, inToMode) }
    }

    /* ############################################################## */
    /**
     Starts the timer from the beginning. It will do so, from any timer state.
     
     This will interrupt any current timer.
     */
    func start() {
        self._engine.start()
    }
    
    /* ############################################################## */
    /**
     This stops the timer, and resets it to the starting point, with no alarm. It will do so, from any timer state.
     
     This will interrupt any current timer.
     */
    func stop() {
        self._engine.stop()
    }
    
    /* ################################################################## */
    /**
     This forces the timer into alarm mode. It will do so, from any timer state.
     
     This will interrupt any current timer.
     */
    func end() {
        self._engine.end()
    }
    
    /* ################################################################## */
    /**
     This pauses a running timer. The timer must already be in `.countdown`, `.warning`, or `.final` state.
     
     - returns: The state of the instance, just prior to pausing (empty, if failed). Can be ignored.
     */
    @discardableResult
    func pause() -> [String: any Hashable] {
        self._engine.pause()
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
        self._engine.resume(inState, transitionHandler: inTransitionHandler, tickHandler: inTickHandler)
    }
    
    /* ################################################################## */
    /**
     This forces the timer to sync directly to the given seconds. The date is the time that corresponds to the exact second. The timer is started, if it was not already running.
     
     > NOTE: This directly sets the timer to a running state, but the `tickHandler` and `transitionHandler` callbacks may not be immediately executed. The timer must already be in `.countdown`, `.warning`, or `.final` state.
     
     - parameter inSeconds: The actual integer second.
     - parameter inDate: The date that corresponds to the given second. If not supplied, .now is used.
     */
    func sync(to inSeconds: Int, date inDate: Date = .now) {
        self._engine.sync(to: inSeconds, date: inDate)
    }
}

/* ###################################################################################################################################### */
// MARK: Hashable Conformance
/* ###################################################################################################################################### */
extension Timer: Hashable {
    /* ############################################################## */
    /**
     Hash dealer.
     
     - parameter inOutHasher: The hasher we're loading up.
     */
    func hash(into inOutHasher: inout Hasher) {
        inOutHasher.combine(id)
    }
}

/* ###################################################################################################################################### */
// MARK: - Grouped Timers -
/* ###################################################################################################################################### */
/**
 This is a group of sequential timers.
 
 The timers are executed in the order of their storage in the `_timers` array.
 */
class TimerGroup: Equatable {
    /* ############################################################## */
    /**
     Equatable Conformance
     
     - parameter lhs: The left-hand side of the comparison.
     - parameter rhs: The right-hand side of the comparison.
     
     - returns: True, if the two grous are the same.
     */
    static func == (lhs: TimerGroup, rhs: TimerGroup) -> Bool { lhs.id == rhs.id }
    
    /* ############################################################## */
    /**
     The maximum number of timers.
     */
    static let maxTimersInGroup = 4
    
    /* ############################################################## */
    /**
     These are the timers that comprise the group. The order of the array, is the order of timer execution.
     */
    fileprivate var _timers = [Timer]()
    
    /* ############################################################## */
    /**
     A unique ID, for comparing.
     */
    let id = UUID()
    
    /* ############################################################## */
    /**
     The container that "owns" this group.
     */
    var model: TimerModel?
    
    /* ############################################################## */
    /**
     Main Initializer
     
     - parameter inContainer: The container that "owns" this group.
     */
    init(container inContainer: TimerModel, dictionary: [[String: any Hashable]]? = nil) {
        self.model = inContainer
        
        if let inDicts = dictionary {
            self._timers = inDicts.map { Timer(group: self, dictionary: $0) }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension TimerGroup {
    /* ############################################################## */
    /**
     */
    var count: Int { self._timers.count }
    
    /* ############################################################## */
    /**
     this exports the current timer state, or allows you to recreate the group, based on a stored state.
     */
    var asArray: [[String: any Hashable]] {
        get { return self._timers.map { $0.asDictionary } }
        set { self._timers = newValue.map { Timer(group: self, dictionary: $0) } }
    }
    
    /* ############################################################## */
    /**
     The index of this group, in the model.
     */
    var index: Int? {
        if let model = self.model {
            for (sectionIndex, group) in model.enumerated() where group == self {
                return sectionIndex
            }
        }
        
        return nil
    }
}

/* ###################################################################################################################################### */
// MARK: Sequence Conformance
/* ###################################################################################################################################### */
extension TimerGroup: Sequence {
    /* ################################################################################################################################## */
    // MARK: Iterator Conformance
    /* ################################################################################################################################## */
    struct TimerGroupIterator: IteratorProtocol {
        /* ########################################################## */
        /**
         We iterate timer wrappers.
         */
        typealias Element = Timer
        
        /* ########################################################## */
        /**
         This has a copy of the timers to be iterated.
         */
        let data: [Element]
        
        /* ########################################################## */
        /**
         This tracks the iteration.
         */
        var count: Int
        
        /* ########################################################## */
        /**
         Iterator (next element)
         */
        mutating func next() -> Element? {
            if 0 == self.count {
                return nil
            } else {
                defer { self.count -= 1 }
                return data[self.count]
            }
        }
    }

    /* ############################################################## */
    /**
     This is an alias for our iterator.
     */
    typealias Iterator = TimerGroupIterator
    
    /* ############################################################## */
    /**
     Returns a new, primed iterator.
     */
    func makeIterator() -> TimerGroupIterator {
        TimerGroupIterator(data: self._timers, count: self.count)
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension TimerGroup {
    /* ############################################################## */
    /**
     */
    subscript(_ inIndex: Int) -> Timer? {
        precondition( (0..<self._timers.count).contains(inIndex), "Index out of bounds")
        return self._timers[inIndex]
    }
    
    /* ############################################################## */
    /**
     Appends a new timer instance to the end of the array.
     
     - returns: A reference to the new timer instance. Nil, if the timer was not created.
     */
    func addTimer() -> Timer? {
        guard Self.maxTimersInGroup > _timers.count else { return nil }
        
        let newInstance = Timer()
        
        self._timers.append(newInstance)
        
        return newInstance
    }
    
    /* ############################################################## */
    /**
     Deletes a timer from the array.
     
     - parameter inIndex: A 0-based index of the timer to be deleted. Must be 0..`timers.count`
     - returns: A reference to the deleted timer instance. Nil, if the timer was not found.
     */
    func deleteTimer(at inIndex: Int) -> Timer? {
        guard (0..<self._timers.count).contains(inIndex) else { return nil }
        return self._timers.remove(at: inIndex)
    }
}

/* ###################################################################################################################################### */
// MARK: - Model Container -
/* ###################################################################################################################################### */
/**
 
 */
class TimerModel {
    /* ############################################################## */
    /**
     */
    private var _sections: [TimerGroup] = []
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension TimerModel {
    /* ############################################################## */
    /**
     */
    var count: Int { self._sections.count }
    
    /* ############################################################## */
    /**
     this exports the current timer state, or allows you to recreate the group, based on a stored state.
     */
    var asArray: [[[String: any Hashable]]] {
        get { return self._sections.map { $0.asArray } }
        set { self._sections = newValue.map { TimerGroup(container: self, dictionary: $0) } }
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension TimerModel {
    /* ############################################################## */
    /**
     */
    subscript(_ inIndex: Int) -> TimerGroup? {
        precondition( (0..<self._sections.count).contains(inIndex), "Index out of bounds")
        return self._sections[inIndex]
    }
    
    /* ############################################################## */
    /**
     */
    func getTimer(at inFrom: IndexPath) -> Timer? {
        guard (0..<self._sections.count).contains(inFrom.section),
              (0..<self._sections[inFrom.section]._timers.count).contains(inFrom.item)
        else { return nil }
        
        return self._sections[inFrom.section]._timers[inFrom.item]
    }
    
    /* ############################################################## */
    /**
     */
    func createNewTimer(at inTo: IndexPath) -> Timer? {
        guard (0...self._sections.count).contains(inTo.section),
              (0...self._sections[inTo.section]._timers.count).contains(inTo.item)
        else { return nil }
        
        if self._sections.count == inTo.section {
            self._sections.append(TimerGroup(container: self))
        }
        
        let timerContainer = Timer()
        
        if self._sections[inTo.section]._timers.count == inTo.item {
            self._sections[inTo.section]._timers.append(timerContainer)
        } else {
            self._sections[inTo.section]._timers.insert(timerContainer, at: inTo.item)
        }
        
        return timerContainer
    }
    
    /* ############################################################## */
    /**
     */
    func createNewTimerAtEndOf(section inSection: Int) -> Timer? {
        guard (0..<self._sections.count).contains(inSection) else { return nil }
        return self.createNewTimer(at: IndexPath(item: self._sections[inSection]._timers.count, section: inSection))
    }

    /* ############################################################## */
    /**
     */
    func removeTimer(from inFrom: IndexPath) -> Timer? {
        guard (0..<self._sections.count).contains(inFrom.section),
              (0..<self._sections[inFrom.section]._timers.count).contains(inFrom.item)
        else { return nil }
        
        let timerContainer = self._sections[inFrom.section]._timers.remove(at: inFrom.item)
        
        if self._sections[inFrom.section]._timers.isEmpty {
            self._sections.remove(at: inFrom.section)
        }

        return timerContainer
    }
    
    /* ############################################################## */
    /**
     */
    func moveTimer(from inFrom: IndexPath, to inTo: IndexPath) -> Timer? {
        guard (0..<self._sections.count).contains(inFrom.section),
              (0...self._sections[inFrom.section]._timers.count).contains(inFrom.item)
        else { return nil }
            
        let timerContainer = self._sections[inFrom.section]._timers.remove(at: inFrom.item)
        var to = inTo
        
        if inFrom.section == inTo.section,
           inTo.item > inFrom.item {
            to.item -= 1
        } else if self._sections.count == to.section {
            self._sections.append(TimerGroup(container: self))
        }

        guard (0...self._sections[to.section]._timers.count).contains(to.item) else { return nil }

        if self._sections[to.section]._timers.count == to.item {
            self._sections[to.section]._timers.append(timerContainer)
        } else {
            self._sections[to.section]._timers.insert(timerContainer, at: to.item)
        }
        
        timerContainer.group = self._sections[to.section]
        
        if self._sections[inFrom.section]._timers.isEmpty {
            self._sections.remove(at: inFrom.section)
        }
        
        return timerContainer
    }
}

/* ###################################################################################################################################### */
// MARK: Sequence Conformance
/* ###################################################################################################################################### */
extension TimerModel: Sequence {
    /* ################################################################################################################################## */
    // MARK: Iterator Conformance
    /* ################################################################################################################################## */
    struct TimerModelIterator: IteratorProtocol {
        /* ########################################################## */
        /**
         We iterate timer wrappers.
         */
        typealias Element = TimerGroup
        
        /* ########################################################## */
        /**
         This has a copy of the timer groups to be iterated.
         */
        let data: [Element]
        
        /* ########################################################## */
        /**
         This tracks the iteration.
         */
        var count: Int
        
        /* ########################################################## */
        /**
         Iterator (next element)
         */
        mutating func next() -> Element? {
            if 0 == self.count {
                return nil
            } else {
                defer { self.count -= 1 }
                return data[self.count]
            }
        }
    }

    /* ############################################################## */
    /**
     This is an alias for our iterator.
     */
    typealias Iterator = TimerModelIterator
    
    /* ############################################################## */
    /**
     Creates a new, primed iterator.
     */
    func makeIterator() -> TimerModelIterator {
        TimerModelIterator(data: self._sections, count: self.count)
    }
}
