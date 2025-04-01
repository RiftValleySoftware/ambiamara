/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import XCTest

/* ###################################################################################################################################### */
// MARK: - Unit Tests for the Timer Engine -
/* ###################################################################################################################################### */
/**
 These will run faceless tests on the timer engine.
 */
class TimerEngineTests: XCTestCase {
    /* ################################################################## */
    /**
     This tests just the most basic instantiation, with only the two required parameters.
     
     It ticks twice (so three callbacks, because the first callback is made at start).
     */
    func testSimpleInstantiation() {
        print("TimerEngineTests.testSimpleInstantiation (START)\n")
        var seconds = 2
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = seconds + 1
        
        /* ############################################################## */
        /**
         The callback for the individual second ticks. May be called in any thread.
         
         - parameter inTimerEngine: The timer engine.
         */
        func tickHandler(_ inTimerEngine: TimerEngine) {
            print("\tTimerEngineTests.testSimpleInstantiation - Tick: \(inTimerEngine.currentTime)")
            XCTAssertEqual(inTimerEngine.currentTime, seconds, "The current time should match the seconds.")
            seconds -= 1
            expectation.fulfill()
        }
        
        let instanceUnderTest = TimerEngine(startingTimeInSeconds: seconds, tickHandler: tickHandler)
        
        XCTAssertFalse(instanceUnderTest.isTicking, "The timer should not be ticking.")
        
        instanceUnderTest.start()
        
        XCTAssertTrue(instanceUnderTest.isTicking, "The timer should be ticking.")
        
        wait(for: [expectation], timeout: 2.5)
        
        XCTAssertEqual(instanceUnderTest.mode, .alarm, "We should be in alarm mode.")
        XCTAssertEqual(-1, seconds, "We should be out of seconds.")
        
        print("TimerEngineTests.testSimpleInstantiation (END)\n")
    }
    
    /* ################################################################## */
    /**
     This tests the transition from one state to the next.
     It also tests the immediate start.
     */
    func testTransition() {
        print("TimerEngineTests.testTransition (START)\n")
        let totalTimeInSeconds = 8
        let warnTimeInSeconds = 4
        let finalTimeInSeconds = 2
        
        var seconds = totalTimeInSeconds

        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = totalTimeInSeconds + 1
        
        /* ############################################################## */
        /**
         The callback for the individual second ticks. May be called in any thread.
         
         - parameter inTimerEngine: The timer engine.
         */
        func tickHandler(_ inTimerEngine: TimerEngine) {
            let currentTime = inTimerEngine.currentTime
            
            print("\tTimerEngineTests.testTransition - Tick: \(currentTime), Mode: \(inTimerEngine.mode)")
            XCTAssertEqual(currentTime, seconds, "The current time should match the seconds.")
            
            switch currentTime {
            case 0:
                XCTAssertEqual(inTimerEngine.mode, .alarm, "We should be in alarm mode (\(currentTime)).")
            case inTimerEngine.startRange:
                XCTAssertEqual(inTimerEngine.mode, .countdown, "We should be in countdown mode (\(currentTime)).")
            case inTimerEngine.warnRange:
                XCTAssertEqual(inTimerEngine.mode, .warning, "We should be in warning mode (\(currentTime)).")
            case inTimerEngine.finalRange:
                XCTAssertEqual(inTimerEngine.mode, .final, "We should be in final mode (\(currentTime)).")
            default :
                XCTFail( "Unhandled case: \(currentTime)" )
            }
            seconds -= 1
            expectation.fulfill()
        }
        
        let instanceUnderTest = TimerEngine(startingTimeInSeconds: totalTimeInSeconds,
                                            warningTimeInSeconds: warnTimeInSeconds,
                                            finalTimeInSeconds: finalTimeInSeconds,
                                            startImmediately: true,
                                            tickHandler: tickHandler)
        
        wait(for: [expectation], timeout: TimeInterval(totalTimeInSeconds) + 0.5)
        
        XCTAssertEqual(instanceUnderTest.mode, .alarm, "We should be in alarm mode.")
        XCTAssertEqual(-1, seconds, "We should be out of seconds.")

        print("TimerEngineTests.testTransition (END)\n")
    }
}
