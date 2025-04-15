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
     This just creates a timer model, and ensures that it's empty
     */
    func testSimpleInstantiation() {
        print("TimerModelTests.testSimpleInstantiation (START)")
        let timerModel = TimerModel()
        XCTAssertTrue(timerModel.isEmpty)
        XCTAssertTrue(timerModel.allTimers.isEmpty)
        print("TimerModelTests.testSimpleInstantiation (END)\n")
    }
    
    /* ################################################################## */
    /**
     This just creates one timer, and makes sure that it has everything we expect.
     It tests the various ways that we can reference the groups and timers.
     */
    func testCreateSimple() {
        print("TimerModelTests.testCreateSimple (START)")
        let timerModel = TimerModel()
        let timer = timerModel.createNewTimer(at: IndexPath(item: 0, section: 0))
        timer.startingTimeInSeconds = 10
        timer.warningTimeInSeconds = 5
        timer.finalTimeInSeconds = 2
        XCTAssertFalse(timerModel.isEmpty)
        XCTAssertEqual(timerModel.count, 1)
        XCTAssertEqual(timerModel[0].count, 1)
        XCTAssertEqual(timerModel.allTimers.first, timer)
        XCTAssertEqual(timerModel[0].allTimers.first, timer)
        XCTAssertEqual(timerModel[0][0], timer)
        XCTAssertEqual(timerModel[0], timer.group)
        XCTAssertEqual(timerModel, timer.model)
        XCTAssertEqual(timerModel.allTimers.first, timer)
        XCTAssertEqual(timerModel.allTimers.first?.startingTimeInSeconds, timer.startingTimeInSeconds)
        XCTAssertEqual(timerModel.allTimers.first?.startingTimeInSeconds, 10)
        XCTAssertEqual(timerModel[0].allTimers.first?.warningTimeInSeconds, timer.warningTimeInSeconds)
        XCTAssertEqual(timerModel[0].allTimers.first?.warningTimeInSeconds, 5)
        XCTAssertEqual(timerModel[0][0].finalTimeInSeconds, timer.finalTimeInSeconds)
        XCTAssertEqual(timerModel[0][0].finalTimeInSeconds, 2)
        XCTAssertEqual(timer.group?.allTimers.first?.finalTimeInSeconds, 2)
        XCTAssertEqual(timer.model?.allTimers.first?.finalTimeInSeconds, 2)
        XCTAssertEqual(timer.group?.model?.allTimers.first?.finalTimeInSeconds, 2)
        timerModel[0][0].finalTimeInSeconds = 3
        XCTAssertEqual(timer.group?.model?.allTimers.first?.finalTimeInSeconds, 3)
        print("TimerModelTests.testCreateSimple (END)\n")
    }
    
    /* ################################################################## */
    /**
     This makes sure that everything is put where it's supposed to be, and that the iterators are working properly.
     */
    func testCreateMultiple() {
        print("TimerModelTests.testCreateMultiple (START)")
        let timerModel = TimerModel()
        
        var timeCountdown = 4

        for groupIndex in 0..<5 {
            for timerIndex in 0..<TimerGroup.maxTimersInGroup {
                let indexPath = IndexPath(item: timerIndex, section: groupIndex)
                let timer = timerModel.createNewTimer(at: indexPath)
                let timeComp = 4 + (groupIndex * TimerGroup.maxTimersInGroup) + timerIndex
                timer.startingTimeInSeconds = timeComp
                timer.warningTimeInSeconds = timeComp / 2
                timer.finalTimeInSeconds = timeComp / 4
                
                let referencedTimer = timerModel.getTimer(at: indexPath)
                XCTAssertIdentical(referencedTimer, timer)
                timeCountdown += 1
            }
        }
        
        XCTAssertEqual(timerModel.count, 5)
        XCTAssertEqual(timerModel.allTimers.count, TimerGroup.maxTimersInGroup * 5)
        timerModel.forEach { XCTAssertEqual($0.count, TimerGroup.maxTimersInGroup) }
        
        var timeComp = 4
        var expectedGroupIndex = 0
        timerModel.forEach { group in
            var expectedTimerIndex = 0
            group.forEach { timer in
                if let indexPath = timer.indexPath {
                    XCTAssertEqual(indexPath, IndexPath(item: expectedTimerIndex, section: expectedGroupIndex))
                    XCTAssertEqual(timer.startingTimeInSeconds, timeComp)
                    XCTAssertEqual(timer.warningTimeInSeconds, timeComp / 2)
                    XCTAssertEqual(timer.finalTimeInSeconds, timeComp / 4)
                    
                    let referencedTimer = timerModel.getTimer(at: indexPath)
                    XCTAssertIdentical(referencedTimer, timer)
                    timeComp += 1
                } else {
                    XCTFail(#function + ": unexpected nil indexPath")
                }
                expectedTimerIndex += 1
            }
            expectedGroupIndex += 1
        }
        
        print("TimerModelTests.testCreateMultiple (END)\n")
    }
}
