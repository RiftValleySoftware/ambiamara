//
//  LGV_Timer_Watch_MainTimerHandlerInterfaceController.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 6/19/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//

import WatchKit
import Foundation

/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_Watch_MainTimerHandlerInterfaceController: WKInterfaceController {
    private var _currentTimeInSeconds: Int = 0
    private var _lastTimerDate: Date! = nil
    private var _timer: [String:Any]! = nil
    private var _myController: LGV_Timer_Watch_MainInterfaceController! = nil
    
    var timerUID: String = ""
    
    @IBOutlet var trafficLightIcon: WKInterfaceImage!
    @IBOutlet var timeDisplayGroup: WKInterfaceGroup!
    @IBOutlet var timeDisplayLabel: WKInterfaceLabel!
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBAction func startButtonHit() {
        self._myController.sendStartMessage(timerUID: self.timerUID)
    }
    
    /* ################################################################## */
    /**
     */
    func updateUI(inSeconds: Int! = nil) {
        DispatchQueue.main.async {
            if nil != inSeconds {
                self._currentTimeInSeconds = inSeconds
            } else {
                if let timeSetNum = self._timer[LGV_Timer_Data_Keys.s_timerDataTimeSetKey] as? NSNumber {
                    self._currentTimeInSeconds = timeSetNum.intValue
                }
            }
            
            let timeTotal = max(0, self._currentTimeInSeconds)
            let timeInHours: Int = timeTotal / 3600
            let timeInMinutes = (timeTotal - (timeInHours * 3600)) / 60
            let timeInSeconds = timeTotal - ((timeInHours * 3600) + (timeInMinutes * 60))
            let displayString = String(format: "%02d:%02d:%02d", timeInHours, timeInMinutes, timeInSeconds)
            self.timeDisplayLabel.setText(displayString)
        }
    }

    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if let contextInfo = context as? [String:Any] {
            if let controller = contextInfo[LGV_Timer_Watch_MainInterfaceController.s_ControllerContextKey] as? LGV_Timer_Watch_MainInterfaceController {
                self._myController = controller
                self._myController.myCurrentTimer = self
            }
            
            if let timer = contextInfo[LGV_Timer_Watch_MainInterfaceController.s_TimerContextKey] as? [String:Any] {
                self._timer = timer
                if let color = self._timer[LGV_Timer_Data_Keys.s_timerDataColorKey] as? UIColor {
                    self.timeDisplayLabel.setTextColor(color)
                }
                
                if let name = self._timer[LGV_Timer_Data_Keys.s_timerDataTimerNameKey] as? String {
                    self.setTitle(name)
                }
                
                if let displayModeNum = self._timer[LGV_Timer_Data_Keys.s_timerDataDisplayModeKey] as? NSNumber {
                    let displayMode = TimerDisplayMode(rawValue: displayModeNum.intValue)
                    self.trafficLightIcon.setHidden(.Podium != displayMode)
                }
                
                if let uid = self._timer[LGV_Timer_Data_Keys.s_timerDataUIDKey] as? String {
                    self.timerUID = uid
                }
            }
            
            self.updateUI()
        }
    }

    /* ################################################################## */
    /**
     */
    override func willActivate() {
        super.willActivate()
    }

    /* ################################################################## */
    /**
     */
    override func didDeactivate() {
        super.didDeactivate()
        if (nil != self._myController) && (nil != self._myController.myCurrentTimer) {
            if self._myController.myCurrentTimer == self {
                self._myController.myCurrentTimer = nil
            }
        }
    }
}
