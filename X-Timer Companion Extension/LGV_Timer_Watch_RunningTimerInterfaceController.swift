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
    @IBOutlet var displayDigitsLabel: WKInterfaceLabel!
    @IBOutlet var displayTrafficLightsGroup: WKInterfaceGroup!
    @IBOutlet var greenLightImage: WKInterfaceImage!
    @IBOutlet var yellowLightImage: WKInterfaceImage!
    @IBOutlet var redLightImage: WKInterfaceImage!
}
