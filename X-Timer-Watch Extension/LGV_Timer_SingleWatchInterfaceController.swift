//
//  LGV_Timer_SingleWatchInterfaceController.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 6/16/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//

import WatchKit
import Foundation


class LGV_Timer_SingleWatchInterfaceController: WKInterfaceController {
    @IBOutlet var timeDisplay: WKInterfaceLabel!
    @IBOutlet var stopButton: WKInterfaceButton!
    @IBOutlet var pauseStartButton: WKInterfaceButton!
    @IBOutlet var endButton: WKInterfaceButton!
    @IBOutlet var resetButton: WKInterfaceButton!
    private var _timer:[String:Any] = [:]

    @IBAction func stopButtonHit() {
    }
    @IBAction func pauseStartButtonHit() {
    }
    @IBAction func endButtonHit() {
    }
    @IBAction func resetButtonHit() {
    }
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self._timer = context as! [String:Any]
        if let color = self._timer[LGV_Timer_Data_Keys.s_timerDataColorKey] as? UIColor {
            self.timeDisplay.setTextColor(color)
            if let timeSetInSecondsNumber = self._timer[LGV_Timer_Data_Keys.s_timerDataTimeSetKey] as? NSNumber {
                let timeSetInSeconds = timeSetInSecondsNumber.intValue
                let hours = timeSetInSeconds / 3600
                let minutes = (timeSetInSeconds - (hours * 3600)) / 60
                let seconds = timeSetInSeconds - ((hours * 3600) + (minutes * 60))
                let displayString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
                self.timeDisplay.setText(displayString)
            }
        }
    }
}
