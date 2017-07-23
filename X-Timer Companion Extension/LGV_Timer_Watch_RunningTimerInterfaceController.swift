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
            self.updateUI()
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func updateUI() {
    }
    
}
