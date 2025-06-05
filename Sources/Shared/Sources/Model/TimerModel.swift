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
// MARK: - Additional Accessors for the Timer Engine Class -
/* ###################################################################################################################################### */
extension TimerEngine {
    /* ############################################################## */
    /**
     Simple cast to the wrapper instance that "owns" this timer.
     */
    var timer: Timer? { refCon as? Timer }
    
    /* ############################################################## */
    /**
     The group to which this timer's container belongs.
     */
    var group: TimerGroup? { timer?.group }
    
    /* ############################################################## */
    /**
     The model that contains this timer.
     */
    var model: TimerModel? { group?.model }
}

/* ###################################################################################################################################### */
// MARK: - Model Container -
/* ###################################################################################################################################### */
/**
 This contains an entire model of the timer app.
 
 The model consists of groups, which consist of timers. Each timer is a "wrapped" ``TimerEngine`` instance.
 
 It also handles timer and group selection. There can only be one selected timer, and that timer's group, is the selected group.
 
 This is where the "meat" of the app functionality lives. We handle groups of timers, as well as moving timers around in the groups.
 
 This is a class, so it can be referenced.
 */
class TimerModel: Equatable {
    /* ############################################################## */
    /**
     Equatable Conformance
     
     - parameter lhs: The left-hand side of the comparison.
     - parameter rhs: The right-hand side of the comparison.
     
     - returns: True, if the two models are the same.
     */
    static func == (lhs: TimerModel, rhs: TimerModel) -> Bool { lhs._groups == rhs._groups }
    
    /* ############################################################## */
    /**
     The groups that aggregate timers.
     */
    private var _groups: [TimerGroup] = []
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension TimerModel {
    /* ############################################################## */
    /**
     The number of groups in this model.
     */
    var count: Int { self._groups.count }
    
    /* ############################################################## */
    /**
     True, if there are no timer groups.
     */
    var isEmpty: Bool { self._groups.isEmpty }
    
    /* ############################################################## */
    /**
     All of the timer wrappers, in one simple array.
     */
    var allTimers: [Timer] { self._groups.flatMap(\.allTimers) }
    
    /* ############################################################## */
    /**
     this exports the current timer state, or allows you to recreate the group, based on a stored state.
     */
    var asArray: [[[String: any Hashable]]] {
        get { return self._groups.map { $0.asArray } }
        set { self._groups = newValue.map { TimerGroup(container: self, dictionary: $0) } }
    }
    
    /* ############################################################## */
    /**
     The first timer group
     */
    var first: TimerGroup? { self._groups.first }
    
    /* ############################################################## */
    /**
     The last timer group
     */
    var last: TimerGroup? { self._groups.last }
    
    /* ############################################################## */
    /**
     The selected timer. There can only be one.
     */
    var selectedTimer: Timer? { self.allTimers.first { $0.isSelected } }
    
    /* ############################################################## */
    /**
     The selected timer's group. There can only be one.
     */
    var selectedGroup: TimerGroup? { self.allTimers.first { $0.isSelected }?.group }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension TimerModel {
    /* ############################################################## */
    /**
     subscript access to the groups.
     
     - parameter inIndex: The 0-based index of the group.
     */
    subscript(_ inIndex: Int) -> TimerGroup {
        precondition( (0..<self._groups.count).contains(inIndex), "Index out of bounds")
        return self._groups[inIndex]
    }
    
    /* ############################################################## */
    /**
     subscript access to individual timers.
     
     - parameter inIndexPath: The index path to the timer.
     */
    subscript(indexPath inIndexPath: IndexPath) -> Timer {
        precondition((0..<self._groups.count).contains(inIndexPath.section), "Group Index out of bounds")
        precondition((0..<self._groups[inIndexPath.section].count).contains(inIndexPath.item), "Timer Index out of bounds")
        
        return self.getTimer(at: inIndexPath)!
    }
    
    /* ############################################################## */
    /**
     Test if the index path is valid for the model.
     
     - parameter inIndexPath: The index path to be tested.
     
     - returns: True, if the index path is valid for the model.
     */
    func isValid(indexPath inIndexPath: IndexPath) -> Bool { (0..<self.count).contains(inIndexPath.section) && (0..<self[inIndexPath.section].count).contains(inIndexPath.row) }

    /* ############################################################## */
    /**
     This tests, to see if a timer can be created at, or moved into, the index path.
     
     - parameter inIndexPath: The indexpath we are testing.
     - parameter inFrom: Optional. If provided, then it is the source path of the item (for moving within a full groaup).
     */
    func canInsertTimer(at inIndexPath: IndexPath, from inFrom: IndexPath? = nil) -> Bool {
        guard (0...self.count).contains(inIndexPath.section) else { return false }
        
        if inIndexPath.section < self.count {
            if self[inIndexPath.section].count == TimerGroup.maxTimersInGroup {
                return nil != inFrom && inFrom!.section == inIndexPath.section && self[inIndexPath.section].count <= TimerGroup.maxTimersInGroup
            } else {
                return self[inIndexPath.section].count < TimerGroup.maxTimersInGroup
            }
        } else {
            return 0 == inIndexPath.item
        }
    }
    
    /* ############################################################## */
    /**
     Accessor for an individual timer, within the model.
     
     - parameter inFrom: The indexpath to the timer. This must represent a valid, existing timer.
     
     - returns: The timer instance, or nil, if the indexPath was not valid.
     */
    func getTimer(at inFrom: IndexPath) -> Timer? {
        guard (0..<self._groups.count).contains(inFrom.section),
              (0..<self._groups[inFrom.section].count).contains(inFrom.item)
        else { return nil }

        return self._groups[inFrom.section][inFrom.item]
    }
    
    /* ############################################################## */
    /**
     This will deselect all the timers in the model, with the possible exception of the given timer.
     
     - parameter inTimerPath: If this is set to a valid index path in the model, that timer will not have its selection state modified (either selected, or not selected). Optional. If not given, all timers are deselected.
     */
    func deselectAllTimers(except inTimerPath: IndexPath? = nil) {
        for timer in self.allTimers where inTimerPath != timer.indexPath {
            timer.isSelected = false
        }
    }
    
    /* ############################################################## */
    /**
     This will select the timer given (deselects all others).
     
     - parameter inTimerPath: Must be valid within the model. The timer to select.
     */
    func selectTimer(_ inTimerPath: IndexPath) {
        self.getTimer(at: inTimerPath)?.isSelected = true
    }

    /* ############################################################## */
    /**
     This creates a new, uninitialized timer instance, at the given index path anywhere in the model.
     
     - parameter inTo: The index path of the new timer. It can include one beyond the end (appending a new timer, or even a new section, with a new timer).
     
     - returns: The new timer instance (can be ignored).
     */
    @discardableResult
    func createNewTimer(at inTo: IndexPath) -> Timer {
        precondition((0...self.count).contains(inTo.section), "Group Index out of bounds")
        
        if self.count == inTo.section {
            self._groups.append(TimerGroup(container: self))
        }
        
        precondition((0...self[inTo.section].count).contains(inTo.item), "Timer Index out of bounds")
        precondition(self[inTo.section].count < TimerGroup.maxTimersInGroup, "There is no room for a new timer in this group.")
        
        let timerContainer = Timer(group: self[inTo.section])
        
        if self[inTo.section].count == inTo.item {
            self[inTo.section]._timers.append(timerContainer)
        } else {
            self[inTo.section]._timers.insert(timerContainer, at: inTo.item)
        }
        
        return timerContainer
    }
    
    /* ############################################################## */
    /**
     This creates a new, uninitialized timer instance, at the end of the indexed section
     
     - parameter inSection: The 0-based section index.
     
     - returns: The new timer instance. Can be ignored.
     */
    @discardableResult
    func createNewTimerAtEndOf(group inSection: Int) -> Timer {
        precondition((0...self._groups.count).contains(inSection), "Group Index out of bounds")
        if self.count == inSection {
            return self.createNewTimer(at: IndexPath(item: 0, section: inSection))
        } else {
            return self.createNewTimer(at: IndexPath(item: self._groups[inSection].count, section: inSection))
        }
    }

    /* ############################################################## */
    /**
     This removes a timer from anywhere in the model.
     
     - parameter inFrom: The index path to the timer to be removed.
     
     - returns: The deleted timer (can be ignored).
     */
    @discardableResult
    func removeTimer(from inFrom: IndexPath) -> Timer {
        precondition((0..<self.count).contains(inFrom.section), "Group Index out of bounds")
        precondition((0..<self[inFrom.section].count).contains(inFrom.item), "Timer Index out of bounds")
        
        let timerContainer = self[inFrom.section]._timers.remove(at: inFrom.item)

        self._groups = self.compactMap { !$0.isEmpty ? $0 : nil }

        if timerContainer.isSelected {
            let newGroup = Swift.max(0, Swift.min(self.count - 1, inFrom.section))
            let itemIndex = newGroup != inFrom.section ? self[newGroup].count - 1 : inFrom.item
            let newItem = Swift.max(0, Swift.min(self[newGroup].count - 1, itemIndex))
            self[newGroup][newItem].isSelected = true
        }
        return timerContainer
    }
    
    /* ############################################################## */
    /**
     This moves a timer from one part of the model, to another.
     
     - parameter inFrom: The place the timer originates.
     - parameter inTo: The destination. This can include one beyond the end (appending).
     
     - returns: The moved timer (can be ignored).
     */
    @discardableResult
    func moveTimer(from inFrom: IndexPath, to inTo: IndexPath) -> Timer {
        precondition((0...self.count).contains(inFrom.section), "Group Index out of bounds")
        precondition((0...self[inFrom.section].count).contains(inFrom.item), "Timer Index out of bounds")
        
        let timerContainer = self[inFrom.section]._timers.remove(at: inFrom.item)
        
        if self.count == inTo.section {
            self._groups.append(TimerGroup(container: self))
        }

        if self[inTo.section].count <= inTo.item {
            self[inTo.section]._timers.append(timerContainer)
        } else {
            self[inTo.section]._timers.insert(timerContainer, at: inTo.item)
        }
        
        timerContainer.group = self[inTo.section]
        
        self._groups = self.compactMap { !$0.isEmpty ? $0 : nil }
        
        return timerContainer
    }
}

/* ###################################################################################################################################### */
// MARK: Sequence Conformance
/* ###################################################################################################################################### */
extension TimerModel: Sequence {
    /* ############################################################## */
    /**
     This is an alias for our iterator.
     */
    typealias Iterator = TimerModelIterator
    
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
         This has a reference to the timer groups to be iterated.
         */
        let data: TimerModel
        
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
                return self.data[self.data.count - self.count]
            }
        }
    }

    /* ############################################################## */
    /**
     Creates a new, primed iterator.
     */
    func makeIterator() -> TimerModelIterator {
        TimerModelIterator(data: self, count: self.count)
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension TimerModel: CustomDebugStringConvertible {
    /* ############################################################## */
    /**
     Emits a formatted string, describing the model.
     */
    var debugDescription: String { self._groups.map { $0.debugDescription }.joined(separator: "\n") }
}

/* ###################################################################################################################################### */
// MARK: - Grouped Timers -
/* ###################################################################################################################################### */
/**
 This is a group of sequential timers.
 
 The timers are executed in the order of their storage in the `_timers` array.
 
 This is a class, so it can be referenced.
 */
class TimerGroup: Equatable {
    /* ################################################################################################################################## */
    // MARK: - Extension for Integrating Persistent Settings -
    /* ################################################################################################################################## */
    /**
     This enum defines one of the three different display types for a running timer.
     */
    enum SoundType {
        /* ############################################################## */
        /**
         No sound, no vibration
         */
        case none

        /* ############################################################## */
        /**
         No sound, vibration
         */
        case vibrate

        /* ############################################################## */
        /**
         Sound, no vibration
         */
        case sound(soundFileName: String)

        /* ############################################################## */
        /**
         Sound, vibration
         */
        case soundVibrate(soundFileName: String)

        /* ############################################################## */
        /**
         Returns the image associated with this state.
         */
        var image: UIImage? {
            switch self {
            case .none:
                return UIImage(systemName: "bell.slash")
            case .sound:
                return UIImage(systemName: "alarm.fill")
            case .vibrate:
                return UIImage(systemName: "iphone.radiowaves.left.and.right")
            case .soundVibrate:
                return UIImage(systemName: "alarm.waves.left.and.right.fill")
            }
        }
        
        /* ############################################################## */
        /**
         Returns the position in the sound type segmented switch.
         */
        var segmentedPosition: Int {
            switch self {
            case .none:
                return 0
            case .sound:
                return 1
            case .vibrate:
                return 2
            case .soundVibrate:
                return 3
            }
        }
        
        /* ############################################################## */
        /**
         Returns a string, describing the state.
         */
        var description: String {
            switch self {
            case .none:
                return "SLUG-NO-SOUND".localizedVariant
            case .sound:
                return "SLUG-SOUND-ONLY".localizedVariant
            case .vibrate:
                return "SLUG-VIBRATE-ONLY".localizedVariant
            case .soundVibrate:
                return "SLUG-SOUND-VIBRATE".localizedVariant
            }
        }
    }
    
    /* ################################################################################################################################## */
    // MARK: - Extension for Integrating Persistent Settings -
    /* ################################################################################################################################## */
    /**
     This enum defines one of the three different display types for a running timer.
     */
    enum DisplayType: String, CaseIterable {
        /* ############################################################## */
        /**
         This displays massive "LED" numbers.
         */
        case numerical

        /* ############################################################## */
        /**
         This displays a circle, winding down.
         */
        case circular
        
        /* ############################################################## */
        /**
         This displays three "stoplights."
         */
        case stoplights
        
        /* ############################################################## */
        /**
         Returns the image associated with this state.
         */
        var image: UIImage? {
            switch self {
            case .numerical:
                return UIImage(named: "DisplayDigits")
            case .circular:
                return UIImage(named: "DisplayCircle")
            case .stoplights:
                return UIImage(named: "DisplayDots")
            }
        }
    }
    
    /* ############################################################## */
    /**
     Equatable Conformance
     
     - parameter lhs: The left-hand side of the comparison.
     - parameter rhs: The right-hand side of the comparison.
     
     - returns: True, if the two groups are the same.
     */
    static func == (lhs: TimerGroup, rhs: TimerGroup) -> Bool { lhs._timers == rhs._timers }
    
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
    var id: UUID = UUID()
    
    /* ############################################################## */
    /**
     The type of display for the group.
     */
    var displayType: DisplayType = .numerical
    
    /* ############################################################## */
    /**
     The final alarm sound.
     */
    var soundType: SoundType = .none
    
    /* ############################################################## */
    /**
     The sound used for transitions between timers in the group.
     */
    var transitionSoundFilename: String?

    /* ############################################################## */
    /**
     The container that "owns" this group.
     */
    var model: TimerModel?
    
    /* ############################################################## */
    /**
     Main Initializer
     
     - parameter inContainer: The container that "owns" this group.
     - parameter inDictionary: The dictionary that contains the preserved state.
     */
    init(container inContainer: TimerModel, dictionary inDictionary: [[String: any Hashable]]? = nil) {
        self.model = inContainer
        
        if let newValue = inDictionary,
           !newValue.isEmpty {
            let firstValue: [String: any Hashable] = newValue[0]
            
            if let idString = firstValue["id"] as? String,
               !idString.isEmpty,
               let id = UUID(uuidString: idString) {
                self.id = id
            }
            
            if let displayTypeString = firstValue["displayType"] as? String,
               !displayTypeString.isEmpty,
               let displayType = DisplayType(rawValue: displayTypeString) {
                self.displayType = displayType
            }
            
            if let transitionSoundFilenameString = firstValue["transitionSoundFilename"] as? String,
               !transitionSoundFilenameString.isEmpty,
               let tempURL = URL(string: transitionSoundFilenameString)?.lastPathComponent {
                self.transitionSoundFilename = tempURL
            } else {
                self.transitionSoundFilename = nil
            }
            
            if let soundTypeString = firstValue["soundTypeString"] as? String,
               !soundTypeString.isEmpty {
                switch soundTypeString {
                case "vibrate":
                    self.soundType = .vibrate
                case "sound", "soundVibrate":
                    if let mainSoundFileName = firstValue["mainSoundFileName"] as? String,
                       !mainSoundFileName.isEmpty,
                       let tempURL = URL(string: mainSoundFileName)?.lastPathComponent {
                        self.soundType = "sound" == soundTypeString ? .sound(soundFileName: tempURL) : .soundVibrate(soundFileName: tempURL)
                    } else {
                        fallthrough
                    }
                default:
                    self.soundType = .none
                }
            }

            let remainingValues = 1 < newValue.count ? Array(newValue[1...]) : []
            self._timers = remainingValues.map { Timer(group: self, dictionary: $0) }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension TimerGroup {
    /* ############################################################## */
    /**
     The number of timers in this group.
     */
    var count: Int { self._timers.count }
    
    /* ############################################################## */
    /**
     True, if there are no timers.
     */
    var isEmpty: Bool { self._timers.isEmpty }
    
    /* ############################################################## */
    /**
     True, if one of the group's timers is selected (READ ONLY).
     */
    var isSelected: Bool { self._timers.contains(where: { $0.isSelected }) }
    
    /* ############################################################## */
    /**
     True, if there is no more room for timers.
     */
    var isFull: Bool { self.count >= Self.maxTimersInGroup }

    /* ############################################################## */
    /**
     this exports the current timer state, or allows you to recreate the group, based on a stored state.
     */
    var asArray: [[String: any Hashable]] {
        get {
            var ret: [[String: any Hashable]] = [
                ["id": UUID().uuidString,
                 "displayType": self.displayType.rawValue,
                 "transitionSoundFilename": self.transitionSoundFilename ?? ""
                ]
            ]
            
            switch self.soundType {
            case .vibrate:
                ret[0]["soundTypeString"] = "vibrate"
            case .sound(soundFileName: let soundFileName):
                ret[0]["soundTypeString"] = "sound"
                ret[0]["mainSoundFileName"] = soundFileName
            case .soundVibrate(soundFileName: let soundFileName):
                ret[0]["soundTypeString"] = "soundVibrate"
                ret[0]["mainSoundFileName"] = soundFileName
            default:
                break
            }
            
            self._timers.forEach {
                ret.append($0.asDictionary)
            }
            return ret
        }
        set {
            if !newValue.isEmpty {
                let firstValue: [String: any Hashable] = newValue[0]
                if let idString = firstValue["id"] as? String,
                   !idString.isEmpty,
                   let id = UUID(uuidString: idString) {
                    self.id = id
                }
                
                if let displayTypeString = firstValue["displayType"] as? String,
                   !displayTypeString.isEmpty,
                   let displayType = DisplayType(rawValue: displayTypeString) {
                    self.displayType = displayType
                }
                
                if let transitionSoundFilenameString = firstValue["transitionSoundFilename"] as? String,
                   !transitionSoundFilenameString.isEmpty {
                    self.transitionSoundFilename = transitionSoundFilenameString
                } else {
                    self.transitionSoundFilename = nil
                }
                
                if let soundTypeString = firstValue["soundTypeString"] as? String,
                   !soundTypeString.isEmpty {
                    switch soundTypeString {
                    case "vibrate":
                        self.soundType = .vibrate
                    case "sound", "soundVibrate":
                        if let mainSoundFileName = firstValue["mainSoundFileName"] as? String,
                           !mainSoundFileName.isEmpty {
                            self.soundType = "sound" == soundTypeString ? .sound(soundFileName: mainSoundFileName) : .soundVibrate(soundFileName: mainSoundFileName)
                        } else {
                            fallthrough
                        }
                    default:
                        self.soundType = .none
                    }
                }

                let remainingValues = 1 < newValue.count ? Array(newValue[1...]) : []
                self._timers = remainingValues.map { Timer(group: self, dictionary: $0) }
            }
        }
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
    
    /* ############################################################## */
    /**
     All of the timer wrappers.
     */
    var allTimers: [Timer] {
        self._timers
    }
    
    /* ############################################################## */
    /**
     The first timer
     */
    var first: Timer? { self._timers.first }
    
    /* ############################################################## */
    /**
     The last timer
     */
    var last: Timer? { self._timers.last }
    
    /* ############################################################## */
    /**
     The selected timer (nil, if none selected).
     */
    var selectedTimer: Timer? { self.allTimers.filter { $0.isSelected }.first }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension TimerGroup {
    /* ############################################################## */
    /**
     Simple subscript access to the timers.
     
     - parameter inIndex: The 0-based index of the timer we want to reference.
     */
    subscript(_ inIndex: Int) -> Timer {
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
        
        let newInstance = Timer(group: self)
        
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
// MARK: Hashable Conformance
/* ###################################################################################################################################### */
extension TimerGroup: Hashable {
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
         This has a reference to the timer group to be iterated.
         */
        let data: TimerGroup
        
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
                return self.data[self.data.count - self.count]
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
        TimerGroupIterator(data: self, count: self.count)
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension TimerGroup: CustomDebugStringConvertible {
    /* ############################################################## */
    /**
     Emits a formatted string, describing the model.
     */
    var debugDescription: String { "Display Type: \(self.displayType)\nTransition Sound: \(String(describing: self.transitionSoundFilename))\nAlarm Sound: \(self.soundType)\n\(self.allTimers.map { $0.debugDescription }.joined(separator: "\n"))" }
}

/* ###################################################################################################################################### */
// MARK: - Wrapper Struct for Timers -
/* ###################################################################################################################################### */
/**
 This is used as a wrapper for each individual timer, and provides accessors.
 
 We make it a class, so it can be easily referenced.
 */
class Timer: Equatable {
    /* ################################################################## */
    /**
     This is the structure of the callback for each "tick," handed to the instance. It is called once a second. This will always be called in the main thread.
     
     - parameter timer: The timer wrapper instance calling it.
     */
    public typealias TickHandler = (_ timer: Timer) -> Void
    
    /* ################################################################## */
    /**
     This is the structure of the callback for mode transitions, handed to the instance. It is called, once only, when the timer mode changes. This will always be called in the main thread.
     
     - parameter timer: The timer wrapper instance calling it.
     - parameter fromMode: The mode we have transitioned from.
     - parameter toMode: The mode we have transitioned into.
     */
    public typealias TransitionHandler = (_ timer: Timer, _ fromMode: TimerEngine.Mode, _ toMode: TimerEngine.Mode) -> Void
    
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
    public var tickHandler: TickHandler?
    
    /* ################################################################## */
    /**
     The callback for the transition handler. This can be called in any thread. It may also be nil.
     */
    public var transitionHandler: TransitionHandler?
    
    /* ################################################################## */
    /**
     If true, then this timer is the selected timer. There can only be one.
     */
    public var isSelected: Bool = false {
        didSet {
            if self.isSelected {
                model?.deselectAllTimers(except: self.indexPath)
            }
        }
    }

    /* ############################################################## */
    /**
     Default initializer.
     
     - parameter inGroup: The group to which this container belongs. This is required.
     - parameter inStartingTimeInSeconds: This is the beginning (total) countdown time. If not supplied, is set to 0.
     - parameter inWarningTimeInSeconds: This is the threshold, at which the clock switches into "warning" mode. If not supplied, is set to 0.
     - parameter inFinalTimeInSeconds: This is the threshold, at which the clock switches into "final" mode. If not supplied, is set to 0.
     - parameter inTransitionHandler: The callback for each transition. This is optional.
     - parameter inTickHandler: The callback for each tick. This can be a tail completion, and is optional.
     */
    init(group inGroup: TimerGroup,
         startingTimeInSeconds inStartingTimeInSeconds: Int = 0,
         warningTimeInSeconds inWarningTimeInSeconds: Int = 0,
         finalTimeInSeconds inFinalTimeInSeconds: Int = 0,
         transitionHandler inTransitionHandler: TransitionHandler? = nil,
         tickHandler inTickHandler: TickHandler? = nil
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
         transitionHandler inTransitionHandler: TransitionHandler? = nil,
         tickHandler inTickHandler: TickHandler? = nil
    ) {
        self.group = inGroup
        self._engine.asDictionary = inDictionary
        self.isSelected = inDictionary["isSelected"] as? Bool ?? false
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
     The timer's ultimate model.
     */
    var model: TimerModel? { self.group?.model }
    
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
     Returns the timer mode.
     */
    var timerMode: TimerEngine.Mode { self._engine.mode }

    /* ############################################################## */
    /**
     Returns true, if the timer is currently ticking
     */
    var isTimerRunning: Bool { self._engine.isTicking }
    
    /* ############################################################## */
    /**
     Returns true, if the timer is paused.
     */
    var isTimerPaused: Bool {
        if case .paused = self.timerMode {
            return true
        }
        
        return false
    }
    
    /* ############################################################## */
    /**
     Returns true, if the timer has reached warning mode.
     */
    var isTimerInWarning: Bool { .warning == self.timerMode }
    
    /* ############################################################## */
    /**
     Returns true, if the timer has reached final mode.
     */
    var isTimerInFinal: Bool { .final == self.timerMode }
    
    /* ############################################################## */
    /**
     Returns true, if the timer is in "alarm" state
     */
    var isTimerInAlarm: Bool { .alarm == self.timerMode }
    
    /* ############################################################## */
    /**
     Returns true, if the timer is at the final point
     */
    var isTimerAtEnd: Bool { 0 == self.currentTime }
    
    /* ############################################################## */
    /**
     Returns true, if the timer is at the starting point
     */
    var isTimerAtStart: Bool { self.startingTimeInSeconds == self.currentTime }

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
        get {
            var ret = self._engine.asDictionary
            if self.isSelected {
                ret["isSelected"] = true
            }
            return ret
        }
        set {
            self._engine.asDictionary = newValue
            self.isSelected = newValue["isSelected"] as? Bool ?? false
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension Timer {
    /* ################################################################## */
    /**
     This simply sets the last paused time, to 0.
     */
    func resetLastPausedTime() {
        self._engine.resetLastPausedTime()
    }

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
     This removes the timer from the model.
     
     - returns: True, if the deletion was successful. May be ignored.
     */
    @discardableResult
    func delete() -> Bool {
        guard let indexPath = self.indexPath else { return false }
        return self == self.model?.removeTimer(from: indexPath)
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
     
     - returns: True, if the resume was successful. Can be ignored.
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
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension Timer: CustomDebugStringConvertible {
    /* ############################################################## */
    /**
     Emits a formatted string, describing the model.
     */
    var debugDescription: String {
        "ID: \(self.id)\nStart Time: \(self.startingTimeInSeconds)\nWarning Time: \(self.warningTimeInSeconds)\nFinal Time: \(self.finalTimeInSeconds)\nCurrent Time: \(self.currentTime)\nPreciseTime: \(String(describing: self.currentPreciseTime))"
    }
}
