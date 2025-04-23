/*
 © Copyright 2018-2022, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_Persistent_Prefs
import RVS_Generic_Swift_Toolbox

/* ###################################################################################################################################### */
// MARK: - Persistent Settings Class -
/* ###################################################################################################################################### */
/**
 This class stores our timer settings as app persistent storage.
 */
class RiValT_Settings: RVS_PersistentPrefs {
    /* ################################################################################################################################## */
    // MARK: RVS_PersistentPrefs Conformance
    /* ################################################################################################################################## */
    /// This is an enumeration that will list the prefs keys for us.
    enum Keys: String {
        /* ############################################################## */
        /**
         The timers, stored as a Dictionary (key is the ID).
         */
        case timerModel

        /* ############################################################## */
        /**
         The various other settings, like alarms and whatnot. These apply to groups, with the order of the array corresponding to the group array.
         */
        case groupSettings

        /* ############################################################## */
        /**
         These are all the keys, in an Array of String.
         */
        static var allKeys: [String] { [
                                        timerModel.rawValue,
                                        groupSettings.rawValue
                                        ]
        }
    }
    
    /* ########################################################## */
    /**
     - returns: An Array of Strings, representing the URIs of the sounds avaialable for alarms.
     */
    class var soundURIs: [String] {
        let ret = Bundle.main.paths(forResourcesOfType: "mp3", inDirectory: "Alarms").map { $0.urlEncodedString ?? "" }.sorted { a, b in
            if let soundA = URL(string: a.urlEncodedString ?? "")?.lastPathComponent.localizedVariant,
               let soundB = URL(string: b.urlEncodedString ?? "")?.lastPathComponent.localizedVariant {
                return soundA < soundB
            } else { return false }
        }
        
        #if DEBUG
            print("Alarm Sounds: \(ret.compactMap { URL(string: $0.urlEncodedString ?? "")?.lastPathComponent.localizedVariant })")
        #endif
        
        return ret
    }
    
    /* ########################################################## */
    /**
     - returns: An Array of Strings, representing the URIs of the sounds avaialable for transition notifications.
     */
    class var transitionSoundURIs: [String] {
        let ret = Bundle.main.paths(forResourcesOfType: "mp3", inDirectory: "Sounds").map { $0.urlEncodedString ?? "" }.sorted { a, b in
            if let soundA = URL(string: a.urlEncodedString ?? "")?.lastPathComponent.localizedVariant,
               let soundB = URL(string: b.urlEncodedString ?? "")?.lastPathComponent.localizedVariant {
                return soundA < soundB
            } else { return false }
        }
        
        #if DEBUG
            print("Transition Sounds: \(ret.compactMap { URL(string: $0.urlEncodedString ?? "")?.lastPathComponent.localizedVariant })")
        #endif
        
        return ret
    }

    /* ################################################################## */
    /**
     The keys (for determining storage).
     */
    override var keys: [String] { Keys.allKeys }

    /* ################################################################## */
    /**
     The timers, stored as a Dictionary (key is the ID).
     */
    var timerModel: [[[String : any Hashable]]] {
        get {
            let rawValues = self.values[Keys.timerModel.rawValue] as? [[NSDictionary]] ?? []
            var groups = [[[String: any Hashable]]]()
            rawValues.forEach { inGroup in
                var groupTemp = [[String: any Hashable]]()
                inGroup.forEach { inTimer in
                    var timerTemp = [String: any Hashable]()
                    print("inTimer: \(inTimer)")
                    inTimer.forEach { inKey, inValue in
                        if let key = inKey as? String,
                           let value = inValue as? any Hashable {
                            timerTemp[key] = value
                        }
                    }
                    groupTemp.append(timerTemp)
                }
                groups.append(groupTemp)
            }
            return groups
        }
        set { self.values[Keys.timerModel.rawValue] = newValue }
    }
}
