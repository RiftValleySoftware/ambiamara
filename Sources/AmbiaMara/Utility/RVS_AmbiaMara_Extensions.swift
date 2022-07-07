/*
 © Copyright 2018-2022, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit

/* ###################################################################################################################################### */
// MARK: CGFloat Extension
/* ###################################################################################################################################### */
/**
 This makes it easier to convert between Degrees and Radians.
 */
extension CGFloat {
    /* ################################################################## */
    /**
     - returns: a float (in degrees), as Radians
     */
    var radians: CGFloat { CGFloat(Double.pi) * (self / 180) }
}
