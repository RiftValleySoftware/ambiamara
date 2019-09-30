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
    // MARK: - Private Instance Properties
    /* ############################################################################################################################## */
    /// This is the index of this pref.
    private var _index: Int = -1
    
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
    
    /* ################################################################## */
    /**
     This is the key for this instance.
     
     It uses the index property to determine the String to return.
     */
    override public var key: String {
        get {
            if 0 <= _index {
                return String(format: type(of: self)._mainListKeyPrefix, _index)
            }
            
            return super.key
        }
        
        set {
            _ = newValue    // NOP
        }
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
    public init(index inIndex: Int) {
        super.init()
        _index = inIndex
    }
}
