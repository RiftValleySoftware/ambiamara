/**
© Copyright 2019, The Great Rift Valley Software Company. All rights reserved.

This code is proprietary and confidential code,
It is NOT to be reused or combined into any application,
unless done so, specifically under written license from The Great Rift Valley Software Company.

The Great Rift Valley Software Company: https://riftvalleysoftware.com
*/

import Foundation

/* ################################################################################################################################## */
// MARK: - App-Specific Preferences Class
/* ################################################################################################################################## */
/**
 This is the specific class that is instantiated on behalf of a timer.
 You instantiate one of these, per timer, based on the key.
 */
public class AmbiaMara_Prefs: RVS_PersistentPrefs {
    /// These are keys for the data stored in each prefs set.
    public enum Keys: String, CaseIterable {
        /// The set time, as an Int, in seconds.
        case timeInSeconds
        /// The warning time, as an Int, in seconds.
        case warningTimeInSeconds
        /// The final time, as an Int, in seconds.
        case finalTimeInSeconds
        /**
         The timer mode, as an Int:
           - -1: Digital
           -  0: Both
           -  1: Podium
         */
        case mode
    }
    
    /* ############################################################################################################################## */
    // MARK: - Private Static Properties
    /* ############################################################################################################################## */
    /// This is the key for the set, as a format. It needs an Int, which will be the 0-based index of the timer.
    private static let _mainListKeyPrefix = "timer-%d"
    
    /* ############################################################################################################################## */
    // MARK: - Public Overridden Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This calculated property MUST be overridden by subclasses.
     It is an Array of String, containing the keys used to store and retrieve the values from persistent storage.
     */
    override public var keys: [String] {
        return Keys.allCases.compactMap { return $0.rawValue }
    }
    
    /* ############################################################################################################################## */
    // MARK: - Public Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     The timer's set time, in seconds.
     */
    public var timeInSeconds: Int {
        get {
            if let ret = self[Keys.timeInSeconds.rawValue] as? Int {
                return ret
            }
            return 0
        }
        
        set {
            self[Keys.timeInSeconds.rawValue] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     The timer's yellow (warning) time, in seconds. Only applies if mode is >= 0
     */
    public var warningTimeInSeconds: Int {
        get {
            if let ret = self[Keys.warningTimeInSeconds.rawValue] as? Int {
                return ret
            }
            return 0
        }
        
        set {
            self[Keys.warningTimeInSeconds.rawValue] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     The timer's red (final) time, in seconds. Only applies if mode is >= 0
     */
    public var finalTimeInSeconds: Int {
        get {
            if let ret = self[Keys.finalTimeInSeconds.rawValue] as? Int {
                return ret
            }
            return 0
        }
        
        set {
            self[Keys.finalTimeInSeconds.rawValue] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     The timer mode, as an Int:
       - -1: Digital
       -  0: Both
       -  1: Podium
     */
    public var mode: Int {
        get {
            if let ret = self[Keys.mode.rawValue] as? Int {
                return ret
            }
            return 0
        }
        
        set {
            self[Keys.mode.rawValue] = newValue
        }
    }
    
    /* ############################################################################################################################## */
    // MARK: - Public Init
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     Initialize with an index and initial values.
     
     - parameter index: The Integer index (0-based) of this parameter.
     - parameter values: A String-keyed Dictionary of Int, with our values. The keys must match the keys Array.
     */
    public init(index inIndex: Int, values inValues: [String: Int]) {
        super.init(key: String(format: Self._mainListKeyPrefix, inIndex), values: inValues)
    }
}

/* ################################################################################################################################## */
// MARK: - Main State Class
/* ################################################################################################################################## */
/**
 */
public class TimerState {
    /* ############################################################################################################################## */
    // MARK: - Private Instance Variables
    /* ############################################################################################################################## */
    /// This is a list of the timers, as saved prefs.
    private var _timers: [AmbiaMara_Prefs] = []
    
    /* ############################################################################################################################## */
    // MARK: - Public Instance Variables
    /* ############################################################################################################################## */
    /// The selected timer as an index into the list
    var selectedTimerIndex: Int = -1 {
        didSet {
            
        }
    }
}

/* ################################################################################################################################## */
// MARK: - Main State Class (Array Behavior Support)
/* ################################################################################################################################## */
/**
 */
extension TimerState {
    /* ################################################################## */
    /**
     Allows a simple integer-indexed (0-based) of our prefs Array.
     
     - parameter inIndex: A 0-based index into our prefs Array.
     */
    public subscript(_ inIndex: Int) -> Element {
        return _timers[inIndex]
    }

    /* ################################################################## */
    /**
     */
    public func append(_ inElement: Element) {
        _timers.append(inElement)
    }
    
    /* ################################################################## */
    /**
     */
    public func insert(_ inElement: Element, at inAt: Int) {
        _timers.insert(inElement, at: inAt)
    }
    
    /* ################################################################## */
    /**
     */
    public func remove(at inAt: Int) {
        _timers[inAt].clear()   // Make sure that we clear the element from our stored prefs.
        _timers.remove(at: inAt)
    }
}

/* ################################################################################################################################## */
// MARK: - Main State Class (Sequence Support)
/* ################################################################################################################################## */
/**
 */
extension TimerState: Sequence {
    /// The sequenced element is one of our prefs instances.
    public typealias Element = AmbiaMara_Prefs
    /// The iterator iterates as an Array of our prefs.
    public typealias Iterator = Array<AmbiaMara_Prefs>.Iterator
    
    /* ################################################################## */
    /**
     Returns the number of items we have in our prefs Array.
     */
    public var count: Int {
        return _timers.count
    }
    
    /* ################################################################## */
    /**
     - returns: an Array iterator of our prefs.
     */
    public func makeIterator() -> TimerState.Iterator {
        return _timers.makeIterator()
    }
}
