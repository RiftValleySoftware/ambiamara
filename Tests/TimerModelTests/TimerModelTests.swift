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
        XCTAssertIdentical(timerModel.allTimers.first, timer)
        XCTAssertIdentical(timerModel[0].allTimers.first, timer)
        XCTAssertIdentical(timerModel[0][0], timer)
        XCTAssertIdentical(timerModel[0], timer.group)
        XCTAssertIdentical(timerModel, timer.model)
        XCTAssertIdentical(timerModel.allTimers.first, timer)
        XCTAssertIdentical(timerModel[indexPath: IndexPath(item: 0, section: 0)], timer)
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
        
        // We fill 4 groups of timers.
        for groupIndex in 0..<5 {
            for timerIndex in 0..<TimerGroup.maxTimersInGroup {
                let indexPath = IndexPath(item: timerIndex, section: groupIndex)
                let timer = timerModel.createNewTimer(at: indexPath)
                // This allows us to make sure the timers are the proper ones (We could use the ID, but this also tests the setting of the timer values).
                let timeComp = 4 + (groupIndex * TimerGroup.maxTimersInGroup) + timerIndex
                timer.startingTimeInSeconds = timeComp
                timer.warningTimeInSeconds = timeComp / 2
                timer.finalTimeInSeconds = timeComp / 4
                
                let referencedTimer = timerModel.getTimer(at: indexPath)
                XCTAssertIdentical(referencedTimer, timer)
                XCTAssertIdentical(timer.group?.model?[indexPath: indexPath], referencedTimer)
                XCTAssertIdentical(timer.model?[indexPath: indexPath], timer)
            }
        }
        
        XCTAssertEqual(timerModel.count, 5)
        XCTAssertEqual(timerModel.allTimers.count, TimerGroup.maxTimersInGroup * 5)
        timerModel.forEach { XCTAssertEqual($0.count, TimerGroup.maxTimersInGroup) }
        
        // Make sure that the new timers are where they are supposed to be.
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
                    XCTAssertIdentical(timer.group?.model?[indexPath: indexPath], referencedTimer)
                    XCTAssertIdentical(timer.model?[indexPath: indexPath], timer)
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
    
    /* ################################################################## */
    /**
     This inserts timers into a model, and ensures that they are where they are supoosed to be, and that other timers move to make room.
     */
    func testInsert() {
        print("TimerModelTests.testInsert (START)")
        let timerModel = TimerModel()
        
        for groupIndex in 0..<5 {
            // We don't "max out" each row, so we can insert. If we max out, we get runtime errors.
            for timerIndex in 0..<(TimerGroup.maxTimersInGroup - 1) {
                let indexPath = IndexPath(item: timerIndex, section: groupIndex)
                let timer = timerModel.createNewTimer(at: indexPath)
                let timeComp = 4 + (groupIndex * TimerGroup.maxTimersInGroup) + timerIndex
                timer.startingTimeInSeconds = timeComp
                timer.warningTimeInSeconds = timeComp / 2
                timer.finalTimeInSeconds = timeComp / 4
            }
        }
        
        // Insert a new timer into the middle of the model.
        let firstTimerIndexPath = IndexPath(item: 1, section: 2)
        let firstTimer = timerModel.createNewTimer(at: firstTimerIndexPath)
        
        XCTAssertNotNil(firstTimer)
        XCTAssertEqual(firstTimer.indexPath, firstTimerIndexPath)
        XCTAssertEqual(firstTimer.startingTimeInSeconds, 0)

        // Make sure that the one after it, is the one that used to be where it is.
        let compTimerIndexPath = IndexPath(item: firstTimerIndexPath.item + 1, section: firstTimerIndexPath.section)
        let compTimer = timerModel.getTimer(at: compTimerIndexPath)
        XCTAssertEqual(compTimer.indexPath, compTimerIndexPath)
        let timeComp = 4 + (compTimerIndexPath.section * TimerGroup.maxTimersInGroup) + compTimerIndexPath.item - 1
        XCTAssertEqual(compTimer.startingTimeInSeconds, timeComp)

        // Make sure the one before, was left alone.
        let compTimer2IndexPath = IndexPath(item: firstTimerIndexPath.item - 1, section: firstTimerIndexPath.section)
        let compTimer2 = timerModel.getTimer(at: compTimer2IndexPath)
        XCTAssertEqual(compTimer2.indexPath, compTimer2IndexPath)
        let timeComp2 = 4 + (compTimer2IndexPath.section * TimerGroup.maxTimersInGroup) + compTimer2IndexPath.item
        XCTAssertEqual(compTimer2.startingTimeInSeconds, timeComp2)

        // Add a timer to the end of an existing group.
        let secondTimerIndex = 3
        let secondTimer = timerModel.createNewTimerAtEndOf(group: secondTimerIndex)
        XCTAssertEqual(secondTimer.indexPath, IndexPath(item: TimerGroup.maxTimersInGroup - 1, section: secondTimerIndex))
        XCTAssertEqual(timerModel[secondTimerIndex].last?.startingTimeInSeconds, 0)
        XCTAssertIdentical(timerModel[secondTimerIndex].last, secondTimer)

        // Create a new group at the end of the model (group end).
        let thirdTimerIndex = 5
        let thirdTimer = timerModel.createNewTimerAtEndOf(group: thirdTimerIndex)
        XCTAssertEqual(thirdTimer.indexPath, IndexPath(item: 0, section: thirdTimerIndex))
        XCTAssertEqual(timerModel[thirdTimerIndex].last?.startingTimeInSeconds, 0)
        XCTAssertIdentical(timerModel[thirdTimerIndex].last, thirdTimer)

        // Create a new group at the end of the model (index path).
        let fourthTimerIndexPath = IndexPath(item: 0, section: 6)
        let fourthTimer = timerModel.createNewTimer(at: fourthTimerIndexPath)
        XCTAssertEqual(fourthTimer.indexPath, fourthTimerIndexPath)
        XCTAssertEqual(timerModel[indexPath: fourthTimerIndexPath].startingTimeInSeconds, 0)
        XCTAssertIdentical(timerModel[fourthTimerIndexPath.section].first, fourthTimer)

        print("TimerModelTests.testInsert (END)\n")
    }
    
    /* ################################################################## */
    /**
     This tests deletion of timers, using either the indexpath, or direct deletion from a timer instance.
     It also makes sure that a group is deleted, if all its timers are removed.
     */
    func testDelete() {
        print("TimerModelTests.testDelete (START)")
        let timerModel = TimerModel()
        
        // We fill 4 groups of timers.
        for groupIndex in 0..<5 {
            for timerIndex in 0..<TimerGroup.maxTimersInGroup {
                let timer = timerModel.createNewTimer(at: IndexPath(item: timerIndex, section: groupIndex))
                let timeComp = 4 + (groupIndex * TimerGroup.maxTimersInGroup) + timerIndex
                timer.startingTimeInSeconds = timeComp
                timer.warningTimeInSeconds = timeComp / 2
                timer.finalTimeInSeconds = timeComp / 4
            }
        }
        
        let deletePath = IndexPath(item: 2, section: 2)
        let deletedTimer = timerModel.removeTimer(from: deletePath)
        XCTAssertNotNil(deletedTimer)
        XCTAssertEqual(TimerGroup.maxTimersInGroup - 1, timerModel[deletePath.section].count)
        let replacement = timerModel.getTimer(at: deletePath)
        XCTAssertNotNil(replacement)
        var previous = timerModel.getTimer(at: IndexPath(item: 1, section: 2))
        XCTAssertNotNil(previous)
        XCTAssertNotEqual(replacement, deletedTimer)
        XCTAssertNotEqual(previous, deletedTimer)
        XCTAssertEqual(replacement.startingTimeInSeconds, deletedTimer.startingTimeInSeconds + 1)
        XCTAssertEqual(previous.startingTimeInSeconds, deletedTimer.startingTimeInSeconds - 1)
        XCTAssertTrue(replacement.delete())
        XCTAssertEqual(TimerGroup.maxTimersInGroup - 2, timerModel[deletePath.section].count)
        XCTAssertIdentical(previous, timerModel[deletePath.section].last)
        XCTAssertTrue(previous.delete())
        previous = timerModel.getTimer(at: IndexPath(item: 0, section: 2))
        XCTAssertIdentical(previous, timerModel[deletePath.section].last)
        XCTAssertTrue(previous.delete())
        XCTAssertEqual(timerModel.count, 4)
        XCTAssertEqual(timerModel[deletePath.section][0].startingTimeInSeconds, 4 + (3 * TimerGroup.maxTimersInGroup))
        print("TimerModelTests.testDelete (END)\n")
    }
    
    /* ################################################################## */
    /**
     This moves some timers around. It will move from full groups, to ones with one slot,
     then it will create new groups, and remove all the timers from a group, causing the group to be removed.
     */
    func testMove() {
        print("TimerModelTests.testMove (START)")
        let timerModel = TimerModel()
        var fullGroups = [Int]()
        var availableGroups = [Int]()
        
        // We fill 4 groups of timers, but every other group has 1 less timer (gives room to move).
        for groupIndex in 0..<5 {
            for timerIndex in 0..<(0 == (groupIndex % 2) ? TimerGroup.maxTimersInGroup : TimerGroup.maxTimersInGroup - 1) {
                let timer = timerModel.createNewTimer(at: IndexPath(item: timerIndex, section: groupIndex))
                let timeComp = 4 + (groupIndex * TimerGroup.maxTimersInGroup) + timerIndex
                timer.startingTimeInSeconds = timeComp
                timer.warningTimeInSeconds = timeComp / 2
                timer.finalTimeInSeconds = timeComp / 4
            }
            
            if 0 == (groupIndex % 2) {
                fullGroups.append(groupIndex)
            } else {
                availableGroups.append(groupIndex)
            }
        }
        
        // Basic move inside the existing rows.
        let from1 = IndexPath(item: 2, section: fullGroups[0])
        let to1 = IndexPath(item: 0, section: availableGroups[0])
        
        XCTAssertFalse(timerModel.canInsertTimer(at: IndexPath(item: 0, section: fullGroups[0])))
        XCTAssertTrue(timerModel.canInsertTimer(at: to1))
        
        let timer1 = timerModel.getTimer(at: from1)
        timerModel.moveTimer(from: from1, to: to1)
        let timer2 = timerModel.getTimer(at: to1)
        
        XCTAssertIdentical(timer1, timer2)
        XCTAssertEqual(timerModel[indexPath: to1].startingTimeInSeconds, 6 + (from1.section * TimerGroup.maxTimersInGroup))
        
        // Create a new section
        let from2 = IndexPath(item: 0, section: fullGroups[1])
        let to2 = IndexPath(item: 0, section: 5)
        
        XCTAssertTrue(timerModel.canInsertTimer(at: to2))
        XCTAssertFalse(timerModel.canInsertTimer(at: from2))
        XCTAssertFalse(timerModel.canInsertTimer(at: IndexPath(item: 1, section: 5)))

        let timer3 = timerModel.getTimer(at: from2)
        XCTAssertEqual(timerModel.count, 5)
        XCTAssertTrue(timerModel.canInsertTimer(at: to2))
        timerModel.moveTimer(from: from2, to: to2)
        XCTAssertEqual(timerModel.count, 6)
        let timer4 = timerModel.getTimer(at: to2)
        
        XCTAssertIdentical(timer3, timer4)
        XCTAssertEqual(timerModel[indexPath: to2].startingTimeInSeconds, 4 + (from2.section * TimerGroup.maxTimersInGroup))

        // Make a few moves that empty out the first group (meaning it gets removed).
        let from3 = IndexPath(item: 0, section: 0)
        let to3 = IndexPath(item: 1, section: to2.section)
        let from4 = IndexPath(item: 0, section: 0)
        let to4 = IndexPath(item: 2, section: to2.section)
        let from5 = IndexPath(item: 0, section: 0)
        let to5 = IndexPath(item: 3, section: to2.section)

        let soonToBeFirst = timerModel.getTimer(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(timerModel.count, 6)
        XCTAssertTrue(timerModel.canInsertTimer(at: to3))
        let newFirst = timerModel.moveTimer(from: from3, to: to3)
        XCTAssertEqual(timerModel.count, 6)
        let movedNewFirst = timerModel[indexPath: to3]
        XCTAssertTrue(timerModel.canInsertTimer(at: to4))
        timerModel.moveTimer(from: from4, to: to4)
        XCTAssertEqual(timerModel.count, 6)
        XCTAssertTrue(timerModel.canInsertTimer(at: to5))
        timerModel.moveTimer(from: from5, to: to5)
        XCTAssertFalse(timerModel.canInsertTimer(at: to5))
        XCTAssertEqual(timerModel.count, 5)
        XCTAssertIdentical(timerModel.getTimer(at: IndexPath(item: 0, section: 0)), soonToBeFirst)
        XCTAssertNotIdentical(newFirst, soonToBeFirst)
        XCTAssertIdentical(movedNewFirst, newFirst)

        print("TimerModelTests.testMove (END)\n")
    }
}
