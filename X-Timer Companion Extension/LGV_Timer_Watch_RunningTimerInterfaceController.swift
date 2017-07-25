//
//  LGV_Timer_Watch_RunningTimerInterfaceController.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 6/20/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//

import WatchKit

class LGV_Timer_Watch_RunningTimerInterfaceController: LGV_Timer_Watch_BaseInterfaceController {
    static var screenID: String { get { return "RunningTimer"} }
    
    static let s_OffLightName = "Watch-OffLight"
    static let s_GreenLightName = "Watch-GreenLight"
    static let s_YellowLightName = "Watch-YellowLight"
    static let s_RedLightName = "Watch-RedLight"
    
    @IBOutlet var displayDigitsLabel: WKInterfaceLabel!
    @IBOutlet var displayTrafficLightsGroup: WKInterfaceGroup!
    @IBOutlet var greenLightImage: WKInterfaceImage!
    @IBOutlet var yellowLightImage: WKInterfaceImage!
    @IBOutlet var redLightImage: WKInterfaceImage!
    @IBOutlet var overallGroup: WKInterfaceGroup!
    
    var controllerObject: LGV_Timer_Watch_MainTimerHandlerInterfaceController! = nil
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBAction func buttonTapped() {
    }
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func updateTimer(_ inTime: Int) {
        self.timerObject.currentTime = inTime
        self.updateUI()
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
    func alarm() {
    }
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func awake(withContext context: Any?) {
        if let contextTuple = context as? LGV_Timer_Watch_MainTimerHandlerInterfaceController.TimerPushContextTuple {
            self.timerObject = contextTuple.timerObject
            self.controllerObject = contextTuple.controllerObject
            self.controllerObject.modalTimerScreen = self
            self.displayDigitsLabel.setHidden(.Podium == self.timerObject.displayMode)
            self.displayTrafficLightsGroup.setHidden(.Digital == self.timerObject.displayMode)
            if let color = self.timerObject.storedColor as? UIColor {
                self.displayDigitsLabel.setTextColor(color)
            }
            self.updateUI()
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func willDisappear() {
        self.controllerObject.dontSendAnEvent = true
        self.controllerObject.modalTimerScreen = nil
        super.willDisappear()
    }
    
    /* ################################################################## */
    /**
     */
    override func updateUI() {
        if .Podium != self.timerObject.displayMode {
            let timeTuple = TimeTuple(self.timerObject.currentTime)
            let timeStringContents = String(format: "%02d:%02d:%02d", timeTuple.hours, timeTuple.minutes, timeTuple.seconds)
            self.displayDigitsLabel.setText(timeStringContents)
        }
        
        if .Digital != self.timerObject.displayMode {
            if (0 < self.timerObject.timeSet) && (0 < self.timerObject.timeSetPodiumFinal) && (self.timerObject.timeSetPodiumFinal < self.timerObject.timeSetPodiumWarn) {
                switch self.timerObject.currentTime {
                case 0:
                    self.alarm()
                    break
                    
                case 1...self.timerObject.timeSetPodiumFinal:
                    self.finalLights()
                    
                case self.timerObject.timeSetPodiumFinal + 1...self.timerObject.timeSetPodiumWarn:
                    self.warningLights()
                    
                default:
                    self.startingLights()
                }
            }
        }
    }
    
}
