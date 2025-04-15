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
        timerModel.forEach { XCTAssertTrue($0.isEmpty) }
        print("TimerModelTests.testSimpleInstantiation (END)\n")
    }
    
    /* ################################################################## */
    /**
     */
    func testCreateSimple() {
        print("TimerModelTests.testCreateSimple (START)")
        let timerModel = TimerModel()
        let timer = timerModel.createNewTimer(at: IndexPath(item: 0, section: 0))
        XCTAssertFalse(timerModel.isEmpty)
        XCTAssertEqual(timerModel.count, 1)
        XCTAssertEqual(timerModel[0][0], timer)
        XCTAssertEqual(timerModel[0], timer.group)
        XCTAssertEqual(timerModel, timer.model)
        XCTAssertEqual(timerModel.allTimers.first, timer)
        print("TimerModelTests.testCreateSimple (END)\n")
    }
}
