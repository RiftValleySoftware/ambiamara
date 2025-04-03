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
        
        wait(for: [expectation], timeout: 2.25)
        
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
        let totalTimeInSeconds = 6  // Six is the minimum time, if we want both a warning and a final, as each range needs to be at least one full second long.
        let warnTimeInSeconds = 4
        let finalTimeInSeconds = 2
        
        var seconds = totalTimeInSeconds

        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = totalTimeInSeconds + 6
        
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
        
        /* ################################################################## */
        /**
         Called when the timer experiences a state transition.
         
         - parameter inTimerEngine: The timer engine.
         - parameter inFromMode: The previous mode (state).
         - parameter inToMode: The current (new) mode (state).
         */
        func transitionHandler(_ inTimerEngine: TimerEngine, _ inFromMode: TimerEngine.Mode, _ inToMode: TimerEngine.Mode) {
            let currentTime = inTimerEngine.currentTime
            print("\tTimerEngineTests.testTransition - Transition at \(currentTime) seconds, from \(inFromMode) to \(inToMode)")
            XCTAssertEqual(inTimerEngine.mode, inToMode, "To should be equal to the mode.")

            switch currentTime {
            case 0:
                XCTAssertEqual(inTimerEngine.mode, .alarm, "We should be in alarm mode (\(currentTime)).")
                XCTAssertEqual(.final, inFromMode, "From should be final.")
                XCTAssertEqual(.alarm, inToMode, "To should be alarm.")
            case inTimerEngine.startRange:
                XCTAssertEqual(inTimerEngine.mode, .countdown, "We should be in countdown mode (\(currentTime)).")
                XCTAssertEqual(.stopped, inFromMode, "From should be stopped.")
                XCTAssertEqual(.countdown, inToMode, "To should be countdown.")
            case inTimerEngine.warnRange:
                XCTAssertEqual(inTimerEngine.mode, .warning, "We should be in warning mode (\(currentTime)).")
                XCTAssertEqual(.countdown, inFromMode, "From should be countdown.")
                XCTAssertEqual(.warning, inToMode, "To should be warning.")
            case inTimerEngine.finalRange:
                XCTAssertEqual(inTimerEngine.mode, .final, "We should be in final mode (\(currentTime)).")
                XCTAssertEqual(.warning, inFromMode, "From should be warning.")
                XCTAssertEqual(.final, inToMode, "To should be final.")
            default :
                XCTFail( "Unhandled case: \(currentTime)" )
            }
            expectation.fulfill()
        }
        
        let instanceUnderTest = TimerEngine(startingTimeInSeconds: totalTimeInSeconds,
                                            warningTimeInSeconds: warnTimeInSeconds,
                                            finalTimeInSeconds: finalTimeInSeconds,
                                            transitionHandler: transitionHandler,
                                            startImmediately: true,
                                            tickHandler: tickHandler)
        
        wait(for: [expectation], timeout: TimeInterval(totalTimeInSeconds) + 0.25)
        
        XCTAssertEqual(instanceUnderTest.mode, .alarm, "We should be in alarm mode.")
        XCTAssertEqual(-1, seconds, "We should be out of seconds.")

        print("TimerEngineTests.testTransition (END)\n")
    }
    
    /* ################################################################## */
    /**
     This will pause and resume the timer, in each of its phases.
     */
    func testPauseResume1() {
        print("TimerEngineTests.testPauseResume1 (START)\n")
        let totalTimeInSeconds = 8
        let warnTimeInSeconds = 4
        let finalTimeInSeconds = 2
        
        let firstPauseStart = TimeInterval(2.1)
        let firstPauseLength = TimeInterval(5.3)

        let secondPauseStart = TimeInterval(4.5)
        let secondPauseLength = TimeInterval(1.1)

        let thirdPauseStart = TimeInterval(7.1)
        let thirdPauseLength = TimeInterval(6.1)

        var seconds = totalTimeInSeconds
        let expectationWaitTimeout: TimeInterval = TimeInterval(totalTimeInSeconds) + firstPauseLength + secondPauseLength + thirdPauseLength + 0.5
        
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = totalTimeInSeconds + 7
        
        /* ############################################################## */
        /**
         The callback for the individual second ticks. May be called in any thread.
         
         - parameter inTimerEngine: The timer engine.
         */
        func tickHandler(_ inTimerEngine: TimerEngine) {
            let currentTime = inTimerEngine.currentTime
            
            print("\tTimerEngineTests.testPauseResume1 - Tick: \(currentTime), Mode: \(inTimerEngine.mode)")
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
                                            tickHandler: tickHandler)
        
        DispatchQueue(label: "first").asyncAfter(wallDeadline: .now() + firstPauseStart) {
            instanceUnderTest.pause()
            print("\tTimerEngineTests.testPauseResume1 - Pausing at \(instanceUnderTest.currentTime) seconds.")
            let marker = Date.now
            XCTAssertEqual(.paused(.countdown), instanceUnderTest.mode, "We should be in paused(countdown) mode.")
            XCTAssertEqual(6, instanceUnderTest.currentTime, "We should be at six seconds.")
            DispatchQueue(label: "first.wait").asyncAfter(deadline: .now() + firstPauseLength) {
                let difference = Date.now.timeIntervalSince(marker)
                print("\tTimerEngineTests.testPauseResume1 - Resuming, after \(difference) seconds paused, at \(instanceUnderTest.currentTime) seconds.")
                instanceUnderTest.resume()
                XCTAssertTrue((firstPauseLength..<(firstPauseLength + 0.1)).contains(difference), "Resume should have occurred within \(firstPauseLength + 0.1) seconds.")
                XCTAssert(.countdown == instanceUnderTest.mode, "We should be in countdown mode.")
                XCTAssert(6 == instanceUnderTest.currentTime, "We should be at six seconds.")
                expectation.fulfill()
            }
            expectation.fulfill()
        }
        
        DispatchQueue(label: "second").asyncAfter(wallDeadline: .now() + firstPauseLength + secondPauseStart) {
            instanceUnderTest.pause()
            print("\tTimerEngineTests.testPauseResume1 - Pausing at \(instanceUnderTest.currentTime) seconds.")
            let marker = Date.now
            XCTAssertEqual(.paused(.warning), instanceUnderTest.mode, "We should be in paused(warning) mode.")
            XCTAssertEqual(4, instanceUnderTest.currentTime, "We should be at four seconds.")
            DispatchQueue(label: "second.wait").asyncAfter(deadline: .now() + secondPauseLength) {
                let difference = Date.now.timeIntervalSince(marker)
                print("\tTimerEngineTests.testPauseResume1 - Resuming, after \(difference) seconds paused, at \(instanceUnderTest.currentTime) seconds.")
                instanceUnderTest.resume()
                XCTAssertTrue((secondPauseLength..<(secondPauseLength + 0.1)).contains(difference), "Resume should have occurred within \(secondPauseLength + 0.1) seconds.")
                XCTAssertEqual(.warning, instanceUnderTest.mode, "We should be in warning mode.")
                XCTAssertEqual(4, instanceUnderTest.currentTime, "We should be at four seconds.")
                expectation.fulfill()
            }
            expectation.fulfill()
        }
        
        DispatchQueue(label: "third").asyncAfter(wallDeadline: .now() + firstPauseLength + secondPauseLength + thirdPauseStart) {
            instanceUnderTest.pause()
            print("\tTimerEngineTests.testPauseResume1 - Pausing at \(instanceUnderTest.currentTime) seconds.")
            let marker = Date.now
            XCTAssertEqual(.paused(.final), instanceUnderTest.mode, "We should be in paused(final) mode.")
            XCTAssertEqual(2, instanceUnderTest.currentTime, "We should be at two seconds.")
            DispatchQueue(label: "third.wait").asyncAfter(deadline: .now() + thirdPauseLength) {
                let difference = Date.now.timeIntervalSince(marker)
                print("\tTimerEngineTests.testPauseResume1 - Resuming, after \(difference) seconds paused, at \(instanceUnderTest.currentTime) seconds.")
                instanceUnderTest.resume()
                XCTAssertTrue((thirdPauseLength..<(thirdPauseLength + 0.1)).contains(difference), "Resume should have occurred within \(thirdPauseLength + 0.1) seconds.")
                XCTAssertEqual(.final, instanceUnderTest.mode, "We should be in final mode.")
                XCTAssertEqual(2, instanceUnderTest.currentTime, "We should be at two seconds.")
                expectation.fulfill()
            }
            expectation.fulfill()
        }

        instanceUnderTest.start()
        
        wait(for: [expectation], timeout: expectationWaitTimeout)
        
        XCTAssertEqual(instanceUnderTest.mode, .alarm, "We should be in alarm mode.")
        XCTAssertEqual(-1, seconds, "We should be out of seconds.")

        print("TimerEngineTests.testPauseResume1 (END)\n")
    }
    
    /* ################################################################## */
    /**
     This will pause and resume the timer, but save and restore the state.
     */
    func testPauseResume2() {
        print("TimerEngineTests.testPauseResume2 (START)\n")
        print("TimerEngineTests.testPauseResume2 (END)\n")
        let totalTimeInSeconds = 4
        let firstPauseStart = TimeInterval(2.3)
        let firstPauseLength = TimeInterval(4)
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 1
        let expectationWaitTimeout: TimeInterval = TimeInterval(totalTimeInSeconds) + firstPauseLength + 0.5

        var initialInstanceUnderTest: TimerEngine? = TimerEngine(startingTimeInSeconds: totalTimeInSeconds)
        var secondInstanceUnderTest: TimerEngine?
        
        var savedState: Dictionary<String, any Hashable>?
        
        var marker = Date.now

        DispatchQueue.global().asyncAfter(wallDeadline: .now() + firstPauseStart) {
            let difference = Date.now.timeIntervalSince(marker)
            marker = Date.now
            print("\tTimerEngineTests.testPauseResume2 - Pausing at \(difference) seconds.")
            savedState = initialInstanceUnderTest?.pause()
            initialInstanceUnderTest = nil
        }
       
        DispatchQueue.global().asyncAfter(wallDeadline: .now() + firstPauseStart + firstPauseLength) {
            let difference = Date.now.timeIntervalSince(marker)
            secondInstanceUnderTest = TimerEngine(startingTimeInSeconds: 0, transitionHandler: { _, _, inTo in if .alarm == inTo { expectation.fulfill() } })
            secondInstanceUnderTest?.resume(savedState)
            print("\tTimerEngineTests.testPauseResume2 - Resuming, after \(difference) seconds paused, at \(secondInstanceUnderTest?.currentTime ?? 0) seconds.")
        }
        
        initialInstanceUnderTest?.start()
        
        wait(for: [expectation], timeout: expectationWaitTimeout)
        
        XCTAssertNil(initialInstanceUnderTest, "This should be gone.")
        XCTAssertEqual(secondInstanceUnderTest?.mode, .alarm, "We should be in alarm mode.")
    }
}
