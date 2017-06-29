//
//  LGV_Timer_Watch_RunningTimerInterfaceController.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 6/20/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//

import WatchKit

class LGV_Timer_Watch_RunningTimerInterfaceController: LGV_Timer_Watch_BaseInterfaceController {
    enum TimerMode {
        case Green, Yellow, Red, Alarm
    }
    
    static let s_OffLightName = "Watch-OffLight"
    static let s_GreenLightName = "Watch-GreenLight"
    static let s_YellowLightName = "Watch-YellowLight"
    static let s_RedLightName = "Watch-RedLight"
    
    static var screenID: String { get { return "RunningTimer"} }
    
    @IBOutlet var displayDigitsLabel: WKInterfaceLabel!
    @IBOutlet var displayTrafficLightsGroup: WKInterfaceGroup!
    @IBOutlet var greenLightImage: WKInterfaceImage!
    @IBOutlet var yellowLightImage: WKInterfaceImage!
    @IBOutlet var redLightImage: WKInterfaceImage!
    @IBOutlet var overallGroup: WKInterfaceGroup!

    var myController: LGV_Timer_Watch_MainTimerHandlerInterfaceController! = nil
    var oldMode: TimerMode = .Green
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBAction func buttonTapped() {
        if self.myController.currentTimeInSeconds == 0 {
            self.myController.stopTimer()
        }
    }
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func updateUI() {
        self.updateUI(inSeconds: nil)
    }
    
    /* ################################################################## */
    /**
     */
    func updateUI(inSeconds: Int! = nil) {
        self.myController.currentTimeInSeconds = inSeconds
        if let displayMode = TimerDisplayMode(rawValue: ((self.timer[LGV_Timer_Data_Keys.s_timerDataDisplayModeKey] as? NSNumber)?.intValue)!) {
            DispatchQueue.main.async {
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
                            switch inSeconds {
                            case 0:
                                self.oldMode = .Alarm
                                self.alarm()
                                
                            case 1...finalSeconds:
                                if .Red != self.oldMode {
                                    WKInterfaceDevice.current().play(.directionDown)
                                }
                                self.oldMode = .Red
                                self.finalLights()
                                
                            case (finalSeconds + 1)...warnSeconds:
                                if .Yellow != self.oldMode {
                                    WKInterfaceDevice.current().play(.click)
                                }
                                self.oldMode = .Yellow
                                self.warningLights()
                                
                            default:
                                self.oldMode = .Green
                                self.startingLights()
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
    func startingLights() {
        let greenName = type(of: self).s_GreenLightName
        let offName = type(of: self).s_OffLightName
        
        self.greenLightImage.setImageNamed(greenName)
        self.yellowLightImage.setImageNamed(offName)
        self.redLightImage.setImageNamed(offName)
    }
    
    /* ################################################################## */
    /**
     */
    func warningLights() {
        let yellowName = type(of: self).s_YellowLightName
        let offName = type(of: self).s_OffLightName
        
        self.greenLightImage.setImageNamed(offName)
        self.yellowLightImage.setImageNamed(yellowName)
        self.redLightImage.setImageNamed(offName)
    }
    
    /* ################################################################## */
    /**
     */
    func finalLights() {
        let redName = type(of: self).s_RedLightName
        let offName = type(of: self).s_OffLightName
        
        self.greenLightImage.setImageNamed(offName)
        self.yellowLightImage.setImageNamed(offName)
        self.redLightImage.setImageNamed(redName)
    }
    
    /* ################################################################## */
    /**
     */
    func animateBackground() {
        if let color = self.myController.timer[LGV_Timer_Data_Keys.s_timerDataColorKey] as? UIColor {
            self.overallGroup.setBackgroundColor(color)
            self.animate(withDuration: 0.5, animations: {
                self.overallGroup.setBackgroundColor(UIColor.clear)
            })
        }
    }
    
    /* ################################################################## */
    /**
     */
    func alarm() {
        self.animateBackground()
        WKInterfaceDevice.current().play(.success)
    }
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.oldMode = .Green
        if let contextInfo = context as? [String:Any] {
            if let controller = contextInfo[LGV_Timer_Watch_MainAppInterfaceController.s_ControllerContextKey] as? LGV_Timer_Watch_MainTimerHandlerInterfaceController {
                self.myController = controller
                self.myController.modalTimerScreen = self
            }
            
            if let timer = contextInfo[LGV_Timer_Watch_MainAppInterfaceController.s_TimerContextKey] as? [String:Any] {
                self.timer = timer

                if let name = self.timer[LGV_Timer_Data_Keys.s_timerDataTimerNameKey] as? String {
                    self.setTitle(name)
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func willActivate() {
        super.willActivate()
        if let color = self.timer[LGV_Timer_Data_Keys.s_timerDataColorKey] as? UIColor {
            self.displayDigitsLabel.setTextColor(color)
        }

        if let displayMode = TimerDisplayMode(rawValue: ((self.timer[LGV_Timer_Data_Keys.s_timerDataDisplayModeKey] as? NSNumber)?.intValue)!) {
            switch displayMode {
            case    .Podium:
                self.displayTrafficLightsGroup.setHidden(false)
                self.displayDigitsLabel.setHidden(true)
                break
                
            case    .Digital:
                self.displayDigitsLabel.setHidden(false)
                self.displayTrafficLightsGroup.setHidden(true)
                break
                
            case    .Dual:
                self.displayTrafficLightsGroup.setHidden(false)
                self.displayDigitsLabel.setHidden(false)
                break
            }
        }
        
        self.updateUI(inSeconds: self.myController.currentTimeInSeconds)
    }
    
    /* ################################################################## */
    /**
     */
    override func willDisappear() {
        super.willDisappear()
        
        if nil != self.myController {
            self.myController.modalTimerScreen = nil
            LGV_Timer_Watch_ExtensionDelegate.delegateObject.sendStopMessage(timerUID: self.myController.timerUID)
        }
    }
}
