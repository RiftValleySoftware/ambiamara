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
    static let s_NoAppID = "NoApp"
    static let s_ControllerContextKey = "Controller"
    static let s_TimerContextKey = "Timer"
    static let s_CurrentTimeContextKey = "CurrentTime"
    
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
            let contextInfo:[String:Any] = [type(of: self).s_ControllerContextKey:self, type(of: self).s_TimerContextKey: LGV_Timer_Watch_ExtensionDelegate.delegateObject.timers[timerIndex]]
            
            self.pushController(withName: type(of: self).s_ModalTimerID, context: contextInfo)
        }
    }
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.topLabel.setText("LGV_TIMER-WATCH-NOT-ACTIVE-TOP-MESSAGE".localizedVariant)
        self.bottomLabel.setText("LGV_TIMER-WATCH-NOT-ACTIVE-BOTTOM-MESSAGE".localizedVariant)
        LGV_Timer_Watch_ExtensionDelegate.delegateObject.firstInterfaceController = self
        self.updateUI()
    }
    
    /* ################################################################## */
    /**
     */
    override func updateUI() {
        super.updateUI()
        DispatchQueue.main.async {
            self.timerDisplayTable.setNumberOfRows(LGV_Timer_Watch_ExtensionDelegate.delegateObject.timers.count, withRowType: type(of: self).s_TableRowID)
            for rowIndex in 0..<LGV_Timer_Watch_ExtensionDelegate.delegateObject.timers.count {
                if let tableRow = self.timerDisplayTable.rowController(at: rowIndex) as? LGV_Timer_Watch_MainInterfaceTableRowController {
                    let timer = LGV_Timer_Watch_ExtensionDelegate.delegateObject.timers[rowIndex]
                    if let color = timer[LGV_Timer_Data_Keys.s_timerDataColorKey] as? UIColor {
                        tableRow.timerNameLabel.setTextColor(color)
                        tableRow.timeDisplayLabel.setTextColor(color)
                        if let timerName = timer[LGV_Timer_Data_Keys.s_timerDataTimerNameKey] as? String {
                            tableRow.timerNameLabel.setText(timerName)
                        }
                    }
                    
                    if let time = timer[LGV_Timer_Data_Keys.s_timerDataTimeSetKey] as? NSNumber {
                        let timeTotal = time.intValue
                        let timeInHours: Int = timeTotal / 3600
                        let timeInMinutes = (timeTotal - (timeInHours * 3600)) / 60
                        let timeInSeconds = timeTotal - ((timeInHours * 3600) + (timeInMinutes * 60))
                        let displayString = String(format: "%02d:%02d:%02d", timeInHours, timeInMinutes, timeInSeconds)
                        tableRow.timeDisplayLabel.setText(displayString)
                    }
                    
                    if let displayModeNum = timer[LGV_Timer_Data_Keys.s_timerDataDisplayModeKey] as? NSNumber {
                        let displayMode = TimerDisplayMode(rawValue: displayModeNum.intValue)
                        tableRow.displayFormatImage.setHidden(.Podium != displayMode)
                    }
                }
            }
            
            if LGV_Timer_Watch_ExtensionDelegate.delegateObject.appDisconnected {
                self.popToRootController()
                self.noAppConnectedDisplay.setHidden(false)
                self.timerDisplayTable.setHidden(true)
            } else {
                self.noAppConnectedDisplay.setHidden(true)
                self.timerDisplayTable.setHidden(false)
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        LGV_Timer_Watch_ExtensionDelegate.delegateObject.sendSelectMessage(timerUID: LGV_Timer_Watch_ExtensionDelegate.delegateObject.getTimerUIDForIndex(rowIndex))
        self.pushTimer(rowIndex)
    }
}
