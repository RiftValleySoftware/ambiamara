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
 */
public class AmbiaMara_Prefs: RVS_PersistentPrefs {
    /* ############################################################################################################################## */
    // MARK: - Public Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This calculated property MUST be overridden by subclasses.
     It is an Array of String, containing the keys used to store and retrieve the values from persistent storage.
     */
    override public var keys: [String] {
        return []
    }
}
