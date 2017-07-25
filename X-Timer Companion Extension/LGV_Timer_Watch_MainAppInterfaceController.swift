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
    var dontSendAnEvent: Bool = false
    
    @IBOutlet var timerDisplayTable: WKInterfaceTable!
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func pushTimer(_ timerIndex: Int) {
        LGV_Timer_Watch_ExtensionDelegate.delegateObject.timerControllers[timerIndex].becomeCurrentPage()
    }
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        LGV_Timer_Watch_ExtensionDelegate.delegateObject.timerListController = self
        self.dontSendAnEvent = true
        self.updateUI()
    }
    
    /* ################################################################## */
    /**
     */
    override func didAppear() {
        if let delegateObject = LGV_Timer_Watch_ExtensionDelegate.delegateObject {
            delegateObject.timerListController = self
            if !self.dontSendAnEvent {
                delegateObject.sendSelectMessage()
            }
            self.dontSendAnEvent = false
            delegateObject.ignoreSelectMessageFromPhone = false
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func updateUI() {
        super.updateUI()
        LGV_Timer_Watch_ExtensionDelegate.delegateObject.timerControllers = []
        DispatchQueue.main.async {
            if let delegateObject = LGV_Timer_Watch_ExtensionDelegate.delegateObject {
                let weHaveTimers = (nil != delegateObject.appStatus) && (0 < delegateObject.appStatus.count)
                
                if weHaveTimers {
                    let numTimers = delegateObject.appStatus.count
                    self.timerDisplayTable.setNumberOfRows(numTimers, withRowType: type(of: self).s_TableRowID)
                    for index in 0..<numTimers {
                        if let rowObject = self.timerDisplayTable.rowController(at: index) as? LGV_Timer_Watch_MainInterfaceTableRowController {
                            let timerObject = delegateObject.appStatus[index]
                            rowObject.timerNameLabel.setText(String(format: "LGV_TIMER-TIMER-TITLE-FORMAT".localizedVariant, index + 1))
                            rowObject.displayFormatImage.setHidden(.Digital == timerObject.displayMode)
                            if .Podium != timerObject.displayMode {
                                if let color = timerObject.storedColor as? UIColor {
                                    rowObject.timerNameLabel.setTextColor(color)
                                    rowObject.timeDisplayLabel.setTextColor(color)
                                }
                            } else {
                                rowObject.timerNameLabel.setTextColor(UIColor.white)
                                rowObject.timeDisplayLabel.setTextColor(UIColor.white)
                            }
                            
                            let timeTuple = TimeTuple(timerObject.timeSet)
                            let timeStringContents = String(format: "%02d:%02d:%02d", timeTuple.hours, timeTuple.minutes, timeTuple.seconds)
                            var timeString:NSAttributedString! = nil
                            
                            if .Podium != timerObject.displayMode {
                                if let titleFont = UIFont(name: "LetsgoDigital-Regular", size: 14) {
                                    timeString = NSAttributedString(string: timeStringContents, attributes: [NSAttributedStringKey.font:titleFont])
                                }
                            } else {
                                timeString = NSAttributedString(string: timeStringContents, attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 12)])
                            }
                            
                            rowObject.timeDisplayLabel.setAttributedText(timeString)
                        }
                    }
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        self.pushTimer(rowIndex)
    }
}
