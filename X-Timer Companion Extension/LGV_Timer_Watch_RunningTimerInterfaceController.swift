//
//  LGV_Timer_Watch_RunningTimerInterfaceController.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 6/20/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//

import WatchKit
import Foundation

class LGV_Timer_Watch_RunningTimerInterfaceController: WKInterfaceController {
    static let s_OffLightName = "Watch-OffLight"
    static let s_GreenLightName = "Watch-GreenLight"
    static let s_YellowLightName = "Watch-YellowLight"
    static let s_RedLightName = "Watch-RedLight"
    
    @IBOutlet var displayDigitsLabel: WKInterfaceLabel!
    @IBOutlet var displayTrafficLightsGroup: WKInterfaceGroup!
    @IBOutlet var greenLightImage: WKInterfaceImage!
    @IBOutlet var yellowLightImage: WKInterfaceImage!
    @IBOutlet var redLightImage: WKInterfaceImage!
    
    var myController: LGV_Timer_Watch_MainTimerHandlerInterfaceController! = nil
    var timer:[String:Any] = [:]
    var timerUID: String = ""
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func updateUI(inSeconds: Int! = nil, inOldSeconds: Int! = nil) {
        DispatchQueue.main.async {
            if let displayMode = TimerDisplayMode(rawValue: ((self.timer[LGV_Timer_Data_Keys.s_timerDataDisplayModeKey] as? NSNumber)?.intValue)!) {
                if .Podium != displayMode {
                    let timeTotal = max(0, inSeconds)
                    let timeInHours: Int = timeTotal / 3600
                    let timeInMinutes = (timeTotal - (timeInHours * 3600)) / 60
                    let timeInSeconds = timeTotal - ((timeInHours * 3600) + (timeInMinutes * 60))
                    let displayString = String(format: "%02d:%02d:%02d", timeInHours, timeInMinutes, timeInSeconds)
                    self.displayDigitsLabel.setText(displayString)
                }
                
                if .Digital != displayMode {
                    if let warnSeconds = (self.timer[LGV_Timer_Data_Keys.s_timerDataTimeSetWarnKey] as? NSNumber)?.intValue {
                        if let finalSeconds = (self.timer[LGV_Timer_Data_Keys.s_timerDataTimeSetFinalKey] as? NSNumber)?.intValue {
                            if (0 < inSeconds) && (finalSeconds >= inSeconds) && (finalSeconds < inOldSeconds) {
                                self.final()
                            } else {
                                if (0 < inSeconds) && (warnSeconds >= inSeconds) && (warnSeconds < inOldSeconds) {
                                    self.warning()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func warning() {
        self.greenLightImage.setImage(UIImage(named: type(of: self).s_OffLightName))
        self.yellowLightImage.setImage(UIImage(named: type(of: self).s_YellowLightName))
        self.redLightImage.setImage(UIImage(named: type(of: self).s_OffLightName))
        WKInterfaceDevice.current().play(.click)
    }
    
    /* ################################################################## */
    /**
     */
    func final() {
        self.greenLightImage.setImage(UIImage(named: type(of: self).s_OffLightName))
        self.yellowLightImage.setImage(UIImage(named: type(of: self).s_OffLightName))
        self.redLightImage.setImage(UIImage(named: type(of: self).s_RedLightName))
        WKInterfaceDevice.current().play(.directionDown)
    }
    
    /* ################################################################## */
    /**
     */
    func alarm() {
        WKInterfaceDevice.current().play(.success)
    }
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if let contextInfo = context as? [String:Any] {
            if let controller = contextInfo[LGV_Timer_Watch_MainInterfaceController.s_ControllerContextKey] as? LGV_Timer_Watch_MainTimerHandlerInterfaceController {
                self.myController = controller
                self.myController.modalTimerScreen = self
                self.timer = myController.timer
                self.timerUID = myController.timerUID
                if let color = self.timer[LGV_Timer_Data_Keys.s_timerDataColorKey] as? UIColor {
                    self.displayDigitsLabel.setTextColor(color)
                }
                
                if let name = self.timer[LGV_Timer_Data_Keys.s_timerDataTimerNameKey] as? String {
                    self.setTitle(name)
                }
                
                if let currentTime = contextInfo[LGV_Timer_Watch_MainInterfaceController.s_CurrentTimeContextKey] as? Int {
                    self.updateUI(inSeconds: currentTime)
                } else {
                    if let timeSet = self.timer[LGV_Timer_Data_Keys.s_timerDataTimeSetKey] as? NSNumber {
                        self.updateUI(inSeconds: timeSet.intValue)
                    }
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func willActivate() {
        super.willActivate()
        if let displayMode = TimerDisplayMode(rawValue: ((self.timer[LGV_Timer_Data_Keys.s_timerDataDisplayModeKey] as? NSNumber)?.intValue)!) {
            switch displayMode {
            case    .Podium:
                self.displayDigitsLabel.setHidden(true)
                break
                
            case    .Digital:
                self.displayTrafficLightsGroup.setHidden(true)
                break
                
            case    .Dual:
                break
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func willDisappear() {
        super.willDisappear()
        
        if nil != self.myController {
            self.myController.modalTimerScreen = nil
        }
    }
}
