//
//  LGV_Timer_Watch_MainTimerHandlerInterfaceController.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 6/19/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//

import WatchKit

/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_Watch_MainTimerHandlerInterfaceController: LGV_Timer_Watch_BaseInterfaceController {
    static var screenID: String { get { return "TimerScreen"} }
    typealias TimerPushContextTuple = (timerObject: TimerSettingTuple, controllerObject: LGV_Timer_Watch_MainTimerHandlerInterfaceController)
    
    var modalTimerScreen: LGV_Timer_Watch_RunningTimerInterfaceController! = nil
    var dontSendAnEvent: Bool = false
    
    @IBOutlet var trafficLightIcon: WKInterfaceImage!
    @IBOutlet var timeDisplayGroup: WKInterfaceGroup!
    @IBOutlet var timeDisplayLabel: WKInterfaceLabel!
    @IBOutlet var startButton: WKInterfaceButton!
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    @IBAction func startButtonHit() {
        self.pushTimer()
    }
    
    /* ################################################################## */
    /**
     */
    func alarm() {
    }
    
    /* ################################################################## */
    /**
     */
    func stopTimer() {
        if nil != self.modalTimerScreen {
            self.modalTimerScreen.dismiss()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func startTimer() {
    }
    
    /* ################################################################## */
    /**
     */
    func pushTimer() {
        DispatchQueue.main.async {
            let contextTuple = TimerPushContextTuple(self.timerObject, controllerObject: self)
            self.presentController(withName: LGV_Timer_Watch_RunningTimerInterfaceController.screenID, context: contextTuple)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func updateTimer(_ inTime: Int) {
        if nil != self.modalTimerScreen {
            self.modalTimerScreen.updateTimer(inTime)
        }
    }

    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func awake(withContext context: Any?) {
        if let timer = context as? TimerSettingTuple {
            self.timerObject = timer
            LGV_Timer_Watch_ExtensionDelegate.delegateObject.timerControllers.append(self)
            self.updateUI()
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func didAppear() {
        super.didAppear()
        if let delegateObject = LGV_Timer_Watch_ExtensionDelegate.delegateObject {
            if !self.dontSendAnEvent {
                delegateObject.sendSelectMessage(timerUID: self.timerObject.uid)
                delegateObject.ignoreSelectMessageFromPhone = false
            }
            self.dontSendAnEvent = false
       }
    }
    
    /* ################################################################## */
    /**
     */
    override func updateUI() {
        self.trafficLightIcon.setHidden(.Digital == self.timerObject.displayMode)
        if .Podium != self.timerObject.displayMode {
            if let color = self.timerObject.storedColor as? UIColor {
                self.timeDisplayLabel.setTextColor(color)
            }
        } else {
            self.timeDisplayLabel.setTextColor(UIColor.white)
        }
        
        let timeTuple = TimeTuple(self.timerObject.timeSet)
        let timeStringContents = String(format: "%02d:%02d:%02d", timeTuple.hours, timeTuple.minutes, timeTuple.seconds)
        var timeString:NSAttributedString! = nil
        
        if .Podium != self.timerObject.displayMode {
            if let titleFont = UIFont(name: "LetsgoDigital-Regular", size: 34) {
                timeString = NSAttributedString(string: timeStringContents, attributes: [NSAttributedStringKey.font:titleFont])
            }
        } else {
            timeString = NSAttributedString(string: timeStringContents, attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 30)])
        }
        
        self.timeDisplayLabel.setAttributedText(timeString)
    }
}
