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
    let timer = TimerEngine()
    
    /* ############################################################## */
    /**
     The group to which this container belongs.
     */
    var group: TimerGroup?

    /* ############################################################## */
    /**
     Default initializer.
     
     - parameter inStartingTimeInSeconds: This is the beginning (total) countdown time. If not supplied, is set to 0.
     - parameter inWarningTimeInSeconds: This is the threshold, at which the clock switches into "warning" mode. If not supplied, is set to 0.
     - parameter inFinalTimeInSeconds: This is the threshold, at which the clock switches into "final" mode. If not supplied, is set to 0.
     - parameter group: The group to which this container belongs. This is optional.
     - parameter inTransitionHandler: The callback for each transition. This is optional.
     - parameter inTickHandler: The callback for each tick. This can be a tail completion, and is optional.
     */
    init(startingTimeInSeconds inStartingTimeInSeconds: Int = 0,
         warningTimeInSeconds inWarningTimeInSeconds: Int = 0,
         finalTimeInSeconds inFinalTimeInSeconds: Int = 0,
         group inGroup: TimerGroup? = nil,
         transitionHandler inTransitionHandler: TimerEngine.TimerTransitionHandler? = nil,
         tickHandler inTickHandler: TimerEngine.TimerTickHandler? = nil
    ) {
        self.timer.refCon = self
        self.group = inGroup
        self.timer.transitionHandler = inTransitionHandler
        self.timer.tickHandler = inTickHandler
        self.timer.startingTimeInSeconds = inStartingTimeInSeconds
        self.timer.warningTimeInSeconds = inWarningTimeInSeconds
        self.timer.finalTimeInSeconds = inFinalTimeInSeconds
    }
    
    /* ############################################################## */
    /**
     Initializer with group and preset dictionary.
     
     - parameter inGroup: The group to which this instance belongs.
     - parameter inDictionary: The timer state, as a dictionary.
     */
    init(group inGroup: TimerGroup? = nil,
         dictionary inDictionary: [String: any Hashable]) {
        self.group = inGroup
        self.timer.asDictionary = inDictionary
        self.timer.refCon = self
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
    var id: UUID { self.timer.id }
    
    /* ############################################################## */
    /**
     This is the 00:00:00 format of the time, as a string.
     */
    var timerDisplay: String { self.timer.timerDisplay }
}

/* ###################################################################################################################################### */
// MARK: Read/Write Computed Properties
/* ###################################################################################################################################### */
extension Timer {
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
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension Timer {
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
 
 */
class TimerGroup {
    /* ############################################################## */
    /**
     The maximum number of timers.
     */
    static let maxTimersInGroup = 4
    
    /* ############################################################## */
    /**
     These are the timers that comprise the group. The order of the array, is the order of timer execution.
     */
    var timers = [Timer]()
    
    /* ############################################################## */
    /**
     The container that "owns" this group.
     */
    var container: TimerModel
    
    /* ############################################################## */
    /**
     Main Initializer
     
     - parameter inContainer: The container that "owns" this group.
     */
    init(container inContainer: TimerModel, dictionary: [[String: any Hashable]]? = nil) {
        self.container = inContainer
        
        if let inDicts = dictionary {
            self.timers = inDicts.map { Timer(group: self, dictionary: $0) }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension TimerGroup {
    /* ############################################################## */
    /**
     this exports the current timer state, or allows you to recreate the group, based on a stored state.
     */
    var asArray: [[String: any Hashable]] {
        get { return self.timers.map { $0.timer.asDictionary } }
        set { self.timers = newValue.map { Timer(group: self, dictionary: $0) } }
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension TimerGroup {
    /* ############################################################## */
    /**
     Appends a new timer instance to the end of the array.
     
     - returns: A reference to the new timer instance. Nil, if the timer was not created.
     */
    func addTimer() -> Timer? {
        guard Self.maxTimersInGroup > timers.count else { return nil }
        
        let newInstance = Timer()
        
        self.timers.append(newInstance)
        
        return newInstance
    }
    
    /* ############################################################## */
    /**
     Deletes a timer from the array.
     
     - parameter inIndex: A 0-based index of the timer to be deleted. Must be 0..`timers.count`
     - returns: A reference to the deleted timer instance. Nil, if the timer was not found.
     */
    func deleteTimer(at inIndex: Int) -> Timer? {
        guard (0..<self.timers.count).contains(inIndex) else { return nil }
        return self.timers.remove(at: inIndex)
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
    subscript(_ inFrom: IndexPath) -> Timer? {
        guard (0..<self._sections.count).contains(inFrom.section),
              (0..<self._sections[inFrom.section].timers.count).contains(inFrom.item)
        else { return nil }
        
        return self._sections[inFrom.section].timers[inFrom.item]
    }
    
    /* ############################################################## */
    /**
     */
    func getTimer(at inFrom: IndexPath) -> Timer? { self[inFrom] }
    
    /* ############################################################## */
    /**
     */
    func createNewTimer(at inTo: IndexPath) -> Timer? {
        guard (0...self._sections.count).contains(inTo.section),
              (0...self._sections[inTo.section].timers.count).contains(inTo.item)
        else { return nil }
        
        if self._sections.count == inTo.section {
            self._sections.append(TimerGroup(container: self))
        }
        
        let timerContainer = Timer()
        
        if self._sections[inTo.section].timers.count == inTo.item {
            self._sections[inTo.section].timers.append(timerContainer)
        } else {
            self._sections[inTo.section].timers.insert(timerContainer, at: inTo.item)
        }
        
        return timerContainer
    }
    
    /* ############################################################## */
    /**
     */
    func createNewTimerAtEndOf(section inSection: Int) -> Timer? {
        guard (0..<self._sections.count).contains(inSection) else { return nil }
        return self.createNewTimer(at: IndexPath(item: self._sections[inSection].timers.count, section: inSection))
    }

    /* ############################################################## */
    /**
     */
    func removeTimer(from inFrom: IndexPath) -> Timer? {
        guard (0..<self._sections.count).contains(inFrom.section),
              (0..<self._sections[inFrom.section].timers.count).contains(inFrom.item)
        else { return nil }
        
        let timerContainer = self._sections[inFrom.section].timers.remove(at: inFrom.item)
        
        if self._sections[inFrom.section].timers.isEmpty {
            self._sections.remove(at: inFrom.section)
        }

        return timerContainer
    }
    
    /* ############################################################## */
    /**
     */
    func moveTimer(from inFrom: IndexPath, to inTo: IndexPath) -> Timer? {
        guard (0..<self._sections.count).contains(inFrom.section),
              (0...self._sections[inFrom.section].timers.count).contains(inFrom.item)
        else { return nil }
            
        let timerContainer = self._sections[inFrom.section].timers.remove(at: inFrom.item)
        var to = inTo
        
        if inFrom.section == inTo.section,
           inTo.item > inFrom.item {
            to.item -= 1
        } else if self._sections.count == to.section {
            self._sections.append(TimerGroup(container: self))
        }

        guard (0...self._sections[to.section].timers.count).contains(to.item) else { return nil }

        if self._sections[to.section].timers.count == to.item {
            self._sections[to.section].timers.append(timerContainer)
        } else {
            self._sections[to.section].timers.insert(timerContainer, at: to.item)
        }
        
        timerContainer.group = self._sections[to.section]
        
        if self._sections[inFrom.section].timers.isEmpty {
            self._sections.remove(at: inFrom.section)
        }
        
        return timerContainer
    }
}
