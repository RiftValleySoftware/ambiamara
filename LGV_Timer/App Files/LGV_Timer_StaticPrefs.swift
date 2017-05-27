//
//  LGV_Timer_StaticPrefs.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 5/24/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//

import Foundation

// MARK: - Prefs Class -
/* ###################################################################################################################################### */
/**
 This is a very simple "persistent user prefs" class. It is instantiated as a SINGLETON, and provides a simple, property-oriented gateway
 to the simple persistent user prefs in iOS. It shouldn't be used for really big, important prefs, but is ideal for the basic "settings"
 type of prefs most users set in their "gear" screen.
 */
class LGV_Timer_StaticPrefs {
    // MARK: - Private Static Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /** This is the key for the prefs used by this app. */
    private static let _mainPrefsKey: String = "LGV_Timer_StaticPrefs"
    /** This is how we enforce a SINGLETON pattern. */
    private static var _sSingletonPrefs: LGV_Timer_StaticPrefs! = nil

    // MARK: - Private Variable Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /** We load the user prefs into this Dictionary object. */
    private var _loadedPrefs: NSMutableDictionary! = nil
    
    // MARK: - Private Enums
    /* ################################################################################################################################## */
    /* ################################################################## */
    /** These are the keys we use for our persistent prefs dictionary. */
    private enum PrefsKeys: String {
        /** This will be a Boolean pref, indicating whether or not the clock should keep the phone from going to sleep while it's active. */
        case KeepAwakeClock = "KeepAwakeClock"
        /** This will be a Boolean pref, indicating whether or not the stopwatch should keep the phone from going to sleep while it's active. */
        case KeepAwakeStopwatch = "KeepAwakeStopwatch"
        /** This will be a Boolean pref, indicating whether or not the stopwatch will display a lap counter. */
        case UseLapsStopwatch = "UseLapsStopwatch"
    }
    
    // MARK: - Private Initializer
    /* ################################################################################################################################## */
    /* ################################################################## */
    /** We do this to prevent the class from being instantiated in a different context than our controlled one. */
    private init(){/* Sergeant Schultz says: "I do nut'ing. Nut-ING!" */}

    // MARK: - Private Instance Methods
    /* ################################################################## */
    /**
     This method loads the main prefs into our instance storage.
     
     NOTE: This will overwrite any unsaved changes to the current _loadedPrefs property.
     
     - returns: a Bool. True, if the load was successful.
     */
    private func _loadPrefs() -> Bool {
        if nil == self._loadedPrefs {
            if let temp = UserDefaults.standard.object(forKey: type(of: self)._mainPrefsKey) as? NSDictionary {
                self._loadedPrefs = NSMutableDictionary(dictionary: temp)
            } else {
                self._loadedPrefs = NSMutableDictionary()
            }
        }
        
        return nil != self._loadedPrefs
    }
    
    // MARK: - Private Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This method simply saves the main preferences Dictionary into the standard user defaults.
     */
    private func _savePrefs() {
        UserDefaults.standard.set(self._loadedPrefs, forKey: type(of: self)._mainPrefsKey)
    }
    
    // MARK: - Class Static Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is how the singleton instance is instantiated and accessed. Always use this variable to capture the prefs object.
     
     The syntax is:
     
     let myPrefs = AppStaticPrefs.prefs
     
     - returns the current prefs object.
     */
    static var prefs: LGV_Timer_StaticPrefs {
        get {
            if nil == self._sSingletonPrefs {
                self._sSingletonPrefs = LGV_Timer_StaticPrefs()
            }
            
            return self._sSingletonPrefs
        }
    }
    
    /* ################################################################## */
    /**
     This tells us whether or not the device is set for military time.
     
     - returns: True, if the device is set for Ante Meridian (AM/PM) time.
     */
    static var using12hClockFormat: Bool {
        get {
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            
            let dateString = formatter.string(from: Date())
            let amRange = dateString.range(of: formatter.amSymbol)
            let pmRange = dateString.range(of: formatter.pmSymbol)
            
            return !(pmRange == nil && amRange == nil)
        }
    }
    
    // MARK: - Internal Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This method is a public interface to the private method.
     */
    func savePrefs() {
        self._savePrefs()
    }
    
    // MARK: - Internal Instance Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var clockKeepsDeviceAwake: Bool {
        get {
            var ret: Bool = false
            
            if self._loadPrefs() {
                if let temp = self._loadedPrefs.object(forKey: PrefsKeys.KeepAwakeClock.rawValue) as? NSNumber {
                    ret = temp.boolValue
                }
            }
            
            return ret
        }
        
        set {
            if self._loadPrefs() {
                let savedVal = NSNumber(value: newValue)
                self._loadedPrefs.setObject(savedVal, forKey: PrefsKeys.KeepAwakeClock.rawValue as NSCopying)
                
                self._savePrefs()
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    var stopwatchKeepsDeviceAwake: Bool {
        get {
            var ret: Bool = false
            
            if self._loadPrefs() {
                if let temp = self._loadedPrefs.object(forKey: PrefsKeys.KeepAwakeStopwatch.rawValue) as? NSNumber {
                    ret = temp.boolValue
                }
            }
            
            return ret
        }
        
        set {
            if self._loadPrefs() {
                let savedVal = NSNumber(value: newValue)
                self._loadedPrefs.setObject(savedVal, forKey: PrefsKeys.KeepAwakeStopwatch.rawValue as NSCopying)
                
                self._savePrefs()
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    var stopwatchTracksLaps: Bool {
        get {
            var ret: Bool = true
            
            if self._loadPrefs() {
                if let temp = self._loadedPrefs.object(forKey: PrefsKeys.UseLapsStopwatch.rawValue) as? NSNumber {
                    ret = temp.boolValue
                }
            }
            
            return ret
        }
        
        set {
            if self._loadPrefs() {
                let savedVal = NSNumber(value: newValue)
                self._loadedPrefs.setObject(savedVal, forKey: PrefsKeys.UseLapsStopwatch.rawValue as NSCopying)
                
                self._savePrefs()
            }
        }
    }
}
