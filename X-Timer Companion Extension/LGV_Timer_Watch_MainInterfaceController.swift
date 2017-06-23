//
//  LGV_Timer_Watch_MainInterfaceController.swift
//  X-Timer Companion Extension
//
//  Created by Chris Marshall on 6/19/17.
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
class LGV_Timer_Watch_MainInterfaceController: WKInterfaceController {
    static let s_TableRowID = "TimerRow"
    static let s_ModalTimerID = "IndividualTimer"
    static let s_NoAppID = "NoApp"
    static let s_ControllerContextKey = "Controller"
    static let s_TimerContextKey = "Timer"
    static let s_CurrentTimeContextKey = "CurrentTime"
    
    var offTheChainInterfaceController: LGV_Timer_Watch_NoAppInterfaceController! = nil
    var myCurrentTimer: LGV_Timer_Watch_MainTimerHandlerInterfaceController! = nil
    
    @IBOutlet var timerDisplayTable: WKInterfaceTable!
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func updateUI() {
        DispatchQueue.main.async {
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
        }
    }
    
    /* ################################################################## */
    /**
     */
    func pushTimer(_ timerIndex: Int) {
        DispatchQueue.main.async {
            if nil == self.myCurrentTimer {
                if let uid = LGV_Timer_Watch_ExtensionDelegate.delegateObject.timers[timerIndex][LGV_Timer_Data_Keys.s_timerDataUIDKey] as? String {
                    LGV_Timer_Watch_ExtensionDelegate.delegateObject.sendSelectMessage(timerUID: uid)
                }
                
                let contextInfo:[String:Any] = [type(of: self).s_ControllerContextKey:self, type(of: self).s_TimerContextKey: LGV_Timer_Watch_ExtensionDelegate.delegateObject.timers[timerIndex]]
                
                self.pushController(withName: type(of: self).s_ModalTimerID, context: contextInfo)
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func dismissTimers() {
        DispatchQueue.main.async {
            self.popToRootController()
            self.updateUI()
        }
    }
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        LGV_Timer_Watch_ExtensionDelegate.delegateObject.sendSelectMessage()
        self.myCurrentTimer = nil
        self.updateUI()
    }
    
    /* ################################################################## */
    /**
     */
    override func willActivate() {
        super.willActivate()
        self.updateUI()
    }
    
    /* ################################################################## */
    /**
     */
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    /* ################################################################## */
    /**
     */
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        LGV_Timer_Watch_ExtensionDelegate.delegateObject.sendSelectMessage(timerUID: LGV_Timer_Watch_ExtensionDelegate.delegateObject.getTimerUIDForIndex(rowIndex))
        self.pushTimer(rowIndex)
    }
}
