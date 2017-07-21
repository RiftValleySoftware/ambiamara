//
//  LGV_Timer_Watch_MainAppInterfaceController.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 6/23/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//

import WatchKit

/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_Watch_MainInterfaceTableRowController: NSObject {
    @IBOutlet var timerNameLabel: WKInterfaceLabel!
    @IBOutlet var timeDisplayLabel: WKInterfaceLabel!
    @IBOutlet var displayFormatImage: WKInterfaceImage!
}

/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_Watch_MainAppInterfaceController: LGV_Timer_Watch_BaseInterfaceController {
    static let s_TableRowID = "TimerRow"
    static let s_ModalTimerID = "IndividualTimer"
    static let s_ControllerContextKey = "Controller"
    static let s_TimerContextKey = "Timer"
    static let s_CurrentTimeContextKey = "CurrentTime"
    
    static var screenID: String { get { return "MainScreen"} }
    
    var myCurrentTimer: LGV_Timer_Watch_MainTimerHandlerInterfaceController! = nil

    @IBOutlet var timerDisplayTable: WKInterfaceTable!
    @IBOutlet var topLabel: WKInterfaceLabel!
    @IBOutlet var bottomLabel: WKInterfaceLabel!
    @IBOutlet var noAppConnectedDisplay: WKInterfaceGroup!
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func pushTimer(_ timerIndex: Int) {
        DispatchQueue.main.async {
        }
    }
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        LGV_Timer_Watch_ExtensionDelegate.delegateObject.timerListController = self
        self.topLabel.setText("LGV_TIMER-WATCH-NOT-ACTIVE-TOP-MESSAGE".localizedVariant)
        self.bottomLabel.setText("LGV_TIMER-WATCH-NOT-ACTIVE-BOTTOM-MESSAGE".localizedVariant)
        self.updateUI()
    }
    
    /* ################################################################## */
    /**
     */
    override func didAppear() {
    }
    
    /* ################################################################## */
    /**
     */
    override func updateUI() {
        super.updateUI()
        DispatchQueue.main.async {
            self.noAppConnectedDisplay.setHidden(false)
            self.timerDisplayTable.setHidden(true)
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        self.pushTimer(rowIndex)
    }
}
