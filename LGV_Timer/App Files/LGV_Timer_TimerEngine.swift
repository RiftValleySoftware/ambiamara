//
//  LGV_Timer_TimerEngine.swift
//  X-Timer
//
//  Created by Chris Marshall on 7/9/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//

import UIKit

/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_TimerEngine: NSObject, Sequence {
    var prefs = LGV_Timer_StaticPrefs.prefs
    
    var timers:[TimerSettingTuple] {
        get { return self.prefs.appStatus.timers }
        set { self.prefs.appStatus.timers = newValue }
    }
    
    var count: Int {
        get { return self.prefs.appStatus.count }
    }
    
    // MARK: - Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func createNewTimer() -> TimerSettingTuple {
        return self.prefs.appStatus.createNewTimer()
    }
    
    // MARK: - Sequence Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    subscript(_ index: Int) -> TimerSettingTuple {
        return self.prefs.appStatus[index]
    }
    
    /* ################################################################## */
    /**
     */
    func indexOf(_ inUID: String) -> Int {
        return prefs.appStatus.indexOf(inUID)
    }
    
    /* ################################################################## */
    /**
     */
    func indexOf(_ inObject: TimerSettingTuple) -> Int {
        return prefs.appStatus.indexOf(inObject)
    }
    
    /* ################################################################## */
    /**
     */
    func contains(_ inObject: TimerSettingTuple) -> Bool {
        return prefs.appStatus.contains(inObject)
    }
    
    /* ################################################################## */
    /**
     */
    func contains(_ inUID: String) -> Bool {
        return prefs.appStatus.contains(inUID)
    }
    
    /* ################################################################## */
    /**
     */
    func makeIterator() -> AnyIterator<TimerSettingTuple> {
        var nextIndex = 0
        
        // Return a "bottom-up" iterator for the list.
        return AnyIterator() {
            if nextIndex == self.prefs.appStatus.count {
                return nil
            }
            nextIndex += 1
            return self.prefs.appStatus[nextIndex - 1]
        }
    }
    
    /* ################################################################## */
    /**
     */
    func append(_ inObject: TimerSettingTuple) {
        self.prefs.appStatus.append(inObject)
    }
    
    /* ################################################################## */
    /**
     */
    func remove(at index: Int) {
        self.prefs.appStatus.remove(at: index)
    }
}
