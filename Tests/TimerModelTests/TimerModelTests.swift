/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import XCTest

/* ###################################################################################################################################### */
// MARK: - Unit Tests for the Timer Model -
/* ###################################################################################################################################### */
/**
 These will run faceless tests on the timer model.
 */
class TimerModelTests: XCTestCase {
    /* ################################################################## */
    /**
     */
    func testSimpleInstantiation() {
        print("TimerModelTests.testSimpleInstantiation (START)")
        let timerModel = TimerModel()
        XCTAssertTrue(timerModel.isEmpty)
        print("TimerModelTests.testSimpleInstantiation (END)\n")
    }
}
