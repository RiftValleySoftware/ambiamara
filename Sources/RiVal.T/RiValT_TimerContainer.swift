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
// MARK: - Wrapper Struct for Timers -
/* ###################################################################################################################################### */
/**
 This struct is used as a wrapper for each individual timer, and provides accessors.
 */
struct RiValT_TimerContainer: Hashable {
    /* ############################################################## */
    /**
     */
    static func == (lhs: RiValT_TimerContainer, rhs: RiValT_TimerContainer) -> Bool { lhs.id == rhs.id }
    
    /* ############################################################## */
    /**
     */
    func hash(into inOutHasher: inout Hasher) {
        inOutHasher.combine(id)
    }
    
    /* ############################################################## */
    /**
     */
    private var _timerState: String = ""

    /* ############################################################## */
    /**
     */
    let timer: TimerEngine = TimerEngine()
    
    /* ############################################################## */
    /**
     */
    var id: UUID { timer.id }

    /* ############################################################## */
    /**
     */
    var timerDisplay: String { timer.timerDisplay }
}
