//
//  LGV_Timer_Watch_NoAppInterfaceController.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 6/23/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//

import WatchKit

/* ###################################################################################################################################### */
/**
 */
class LGV_Timer_Watch_NoAppInterfaceController: WKInterfaceController {
    @IBOutlet var timerDismissTextButtonLabel: WKInterfaceLabel!
    @IBOutlet var timerDismissTextButtonBottomLabel: WKInterfaceLabel!
    
    var myController: LGV_Timer_Watch_MainInterfaceController! = nil
    
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.timerDismissTextButtonLabel.setText("LGV_TIMER-WATCH-NOT-ACTIVE-TOP-MESSAGE".localizedVariant)
        self.timerDismissTextButtonBottomLabel.setText("LGV_TIMER-WATCH-NOT-ACTIVE-BOTTOM-MESSAGE".localizedVariant)
        if let contextInfo = context as? [String:Any] {
            if let controller = contextInfo[LGV_Timer_Watch_MainInterfaceController.s_ControllerContextKey] as? LGV_Timer_Watch_MainInterfaceController {
                self.myController = controller
                self.myController.offTheChainInterfaceController = self
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    override func willDisappear() {
        self.myController.offTheChainInterfaceController = nil
    }
}
