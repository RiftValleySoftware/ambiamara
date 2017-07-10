//
//  LGV_Timer_StaticPrefs.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 5/24/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//

import UIKit

extension UIColor {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        if let components = self.cgColor.components {
            return (components[0], components[1], components[2], components[3])
        }
        return(0,0,0,0)
    }
}

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
    /** This is the key for the app status prefs used by this app. */
    private static let _appStatusPrefsKey: String = "LGV_Timer_AppStatus"
    /** This is how we enforce a SINGLETON pattern. */
    private static var _sSingletonPrefs: LGV_Timer_StaticPrefs! = nil
    /** This contains our color theme palette. */
    private static let _sviewBundleName = "LGV_Timer_ColorThemes"
    
    // MARK: - Private Variable Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /** We load the user prefs into this Dictionary object. */
    private var _loadedPrefs: NSMutableDictionary! = nil
    /** This will contain the UILabels that are used for the color theme. */
    private var _pickerPepperArray: [UILabel] = []
    /** This contains the application status. */
    private var _appStatus: LGV_Timer_AppStatus! = nil
    
    // MARK: - Private Enums
    /* ################################################################################################################################## */
    /* ################################################################## */
    /** These are the keys we use for our persistent prefs dictionary. */
    private enum PrefsKeys: String {
        /** This will be an array of dictionaries, with a list of timers. */
        case TimerList = "TimerList"
        case AppStatus = "AppStatus"
    }
    
    // MARK: - Private Static Constants
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     These are the thresholds that we apply to our timer when automatically determining the "traffic lights" for podium mode.
     */
    static let _podiumModeWarningThreshold: Float  = (6 / 36)
    static let _podiumModeFinalThreshold: Float    = (3 / 36)
    
    // MARK: - Internal Enums
    /* ################################################################################################################################## */
    /* ################################################################## */
    /** These are the keys we use for our timer prefs dictionary. */
    enum TimerPrefKeys: String {
        case TimeSet            = "TimeSet"
        case TimeSetPodiumWarn  = "TimeSetPodiumWarn"
        case TimeSetPodiumFinal = "TimeSetPodiumFinal"
        case DisplayMode        = "DisplayMode"
        case ColorTheme         = "ColorTheme"
        case AlertMode          = "AlertMode"
        case SoundID            = "SoundID"
        case UID                = "UID"
    }
    
    // MARK: - Private Initializer
    /* ################################################################################################################################## */
    /* ################################################################## */
    /** We do this to prevent the class from being instantiated in a different context than our controlled one. */
    private init(){/* Sergeant Schultz says: "I do nut'ing. Nut-ING!" */}
    
    
    // MARK: - Private Class Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    private class func _convertTimerToStorage(_ inTimer: TimerSettingTuple) -> NSDictionary {
        let tempSetting = NSMutableDictionary()
        
        tempSetting.setValue(NSNumber(value: inTimer.timeSet), forKey: TimerPrefKeys.TimeSet.rawValue)
        tempSetting.setValue(NSNumber(value: inTimer.timeSetPodiumWarn), forKey: TimerPrefKeys.TimeSetPodiumWarn.rawValue)
        tempSetting.setValue(NSNumber(value: inTimer.timeSetPodiumFinal), forKey: TimerPrefKeys.TimeSetPodiumFinal.rawValue)
        tempSetting.setValue(NSNumber(value: inTimer.displayMode.rawValue), forKey: TimerPrefKeys.DisplayMode.rawValue)
        tempSetting.setValue(NSNumber(value: inTimer.colorTheme), forKey: TimerPrefKeys.ColorTheme.rawValue)
        tempSetting.setValue(NSNumber(value: inTimer.alertMode.rawValue), forKey: TimerPrefKeys.AlertMode.rawValue)
        tempSetting.setValue(NSNumber(value: inTimer.soundID), forKey: TimerPrefKeys.SoundID.rawValue)
        tempSetting.setValue(inTimer.uid as NSString, forKey: TimerPrefKeys.UID.rawValue)
        
        return tempSetting
    }
    
    /* ################################################################## */
    /**
     */
    private class func _convertStorageToTimer(_ inTimer: NSDictionary) -> TimerSettingTuple {
        let tempSetting:TimerSettingTuple = self.defaultTimer
        
        if let timeSet = inTimer.object(forKey: TimerPrefKeys.TimeSet.rawValue) as? NSNumber {
            tempSetting.timeSet = timeSet.intValue
        }
        
        if let timeSetPodiumWarn = inTimer.object(forKey: TimerPrefKeys.TimeSetPodiumWarn.rawValue) as? NSNumber {
            tempSetting.timeSetPodiumWarn = timeSetPodiumWarn.intValue
        }
        
        if let timeSetPodiumFinal = inTimer.object(forKey: TimerPrefKeys.TimeSetPodiumFinal.rawValue) as? NSNumber {
            tempSetting.timeSetPodiumFinal = timeSetPodiumFinal.intValue
        }
        
        if let displayMode = inTimer.object(forKey: TimerPrefKeys.DisplayMode.rawValue) as? NSNumber {
            if let displayModeType = TimerDisplayMode(rawValue: displayMode.intValue) {
                tempSetting.displayMode = displayModeType
            }
        }
        
        if let colorTheme = inTimer.object(forKey: TimerPrefKeys.ColorTheme.rawValue) as? NSNumber {
            tempSetting.colorTheme = colorTheme.intValue
        }
        
        if let alertMode = inTimer.object(forKey: TimerPrefKeys.AlertMode.rawValue) as? NSNumber {
            if let alertModeType = AlertMode(rawValue: alertMode.intValue) {
                tempSetting.alertMode = alertModeType
            }
        }
        
        if let soundID = inTimer.object(forKey: TimerPrefKeys.SoundID.rawValue) as? NSNumber {
            tempSetting.soundID = soundID.intValue
        }
        
        if let uid = inTimer.object(forKey: TimerPrefKeys.UID.rawValue) as? NSString {
            tempSetting.uid = uid as String
        } else {
            tempSetting.uid = NSUUID().uuidString
        }

        return tempSetting
    }
    
    // MARK: - Private Instance Methods
    /* ################################################################################################################################## */
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
        
        if let temp = UserDefaults.standard.object(forKey: type(of: self)._appStatusPrefsKey) as? LGV_Timer_AppStatus {
            self._appStatus = temp
        }
        
        if nil != self._loadedPrefs {
            if nil == self._loadedPrefs.object(forKey: PrefsKeys.TimerList.rawValue) {
                let tempSetting:NSMutableArray = []

                // If we are at a starting point, we "prime the pump" with timers.
                let timer = type(of: self).defaultTimer
                tempSetting.add(type(of:self)._convertTimerToStorage(timer))

                self._loadedPrefs.setObject(tempSetting, forKey: PrefsKeys.TimerList.rawValue as NSCopying)
           }
        }
        
        return nil != self._loadedPrefs
    }
    
    /* ################################################################## */
    /**
     This method simply saves the main preferences Dictionary into the standard user defaults.
     */
    private func _savePrefs() {
        UserDefaults.standard.set(self._appStatus, forKey: type(of: self)._appStatusPrefsKey)
    }
    
    // MARK: - Internal Static Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This returns one default configurasion timer "tuple" object.
     */
    static var defaultTimer: TimerSettingTuple {
        get {
            let ret: TimerSettingTuple = TimerSettingTuple()
            return ret
        }
    }
    
    // MARK: - Internal Class Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This calculates the auto-calculation for the "warning," or "yellow traffic light" for the Podium Mode timer.
     
     :param: inTimerSet The value of the countdown timer.
     
     :returns: an Int, with the warning threshold.
     */
    class func calcPodiumModeWarningThresholdForTimerValue(_ inTimerSet: Int) -> Int {
        return max(0, min(inTimerSet, Int(ceil(Float(inTimerSet) * self._podiumModeWarningThreshold))))
    }
    
    /* ################################################################## */
    /**
     This calculates the auto-calculation for the "final," or "red traffic light" for the Podium Mode timer.
     
     :param: inTimerSet The value of the countdown timer.
     
     :returns: an Int, with the final threshold.
     */
    class func calcPodiumModeFinalThresholdForTimerValue(_ inTimerSet: Int) -> Int {
        return max(0, min(calcPodiumModeWarningThresholdForTimerValue(inTimerSet), Int(ceil(Float(inTimerSet) * self._podiumModeFinalThreshold))))
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
    
    // MARK: - Internal Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This method is a public interface to the private method.
     */
    func savePrefs() {
        self._savePrefs()
    }
    
    /* ################################################################## */
    /**
     */
    func getIndexOfTimer(_ inUID: String) -> Int {
        var ret = 0
        
        let timers = self.timers
        
        for timer in timers {
            if timer.uid == inUID {
                return ret
            }
            ret += 1
        }
        
        return -1
    }
    
    /* ################################################################## */
    /**
     */
    func getTimerPrefsForUID(_ inUID: String) -> TimerSettingTuple! {
        let timers = self.timers
        
        for timer in timers {
            if timer.uid == inUID {
                return timer
            }
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     */
    func updateTimer(_ inTimer: TimerSettingTuple) {
        for index in 0..<self.timers.count {
            if self.timers[index].uid == inTimer.uid {
                self.timers[index] = inTimer
                self.savePrefs()
                break
            }
        }
    }
    
    // MARK: - Internal Instance Calculated Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This sets/returns a list of timers. We must have at least one timer.
     */
    var timers:[TimerSettingTuple] {
        get {
            var ret: [TimerSettingTuple] = []
            
            if self._loadPrefs() {
                if let temp = self._loadedPrefs.object(forKey: PrefsKeys.TimerList.rawValue) as? NSArray {
                    for index in 0..<temp.count {
                        if let arrayElement = temp[index] as? NSDictionary {
                            let temp: TimerSettingTuple = type(of:self)._convertStorageToTimer(arrayElement)
                            ret.append(temp)
                        }
                    }
                }
            }
            
            // We're not allowed to have zero timers.
            if 0 == ret.count {
                ret.append(type(of: self).defaultTimer)
            }

            return ret
        }
        
        set {
            if nil != self._loadedPrefs {
                let tempSetting:NSMutableArray = []
                
                for timer in newValue {
                    let timerInstance = type(of:self)._convertTimerToStorage(timer)
                    tempSetting.add(timerInstance)
                }
                
                // We're not allowed to have zero timers.
                if 0 == tempSetting.count {
                    tempSetting.add(type(of:self)._convertTimerToStorage(type(of: self).defaultTimer))
                }
                
                self._loadedPrefs.setObject(tempSetting, forKey: PrefsKeys.TimerList.rawValue as NSCopying)
                self._savePrefs()
            }
        }
    }
    
    /* ################################################################## */
    /**
     Returns the value in an easily readable format.
     */
    var description: String {
        get {
            var ret = "timers: ["
            
            for timer in self.timers {
                ret += "\n" + timer.description
            }
            
            ret += "]"
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     Returns the current app status.
     */
    var appStatus: LGV_Timer_AppStatus {
        get { return self._appStatus }
    }
    
    /* ################################################################## */
    /**
     Returns the color palettes.
     */
    var pickerPepperArray: [UILabel] {
        get {
            if self._pickerPepperArray.isEmpty {
                if let view = UINib(nibName: type(of: self)._sviewBundleName, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? UIView {
                    for subView in view.subviews {
                        if let label = subView as? UILabel {
                            self._pickerPepperArray.append(label)
                        }
                    }
                }
            }
            
            return self._pickerPepperArray
        }
    }
}
