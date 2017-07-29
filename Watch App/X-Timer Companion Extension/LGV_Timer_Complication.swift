//
//  LGV_Timer_Complication.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 6/27/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//

import ClockKit

/* ###################################################################################################################################### */
class LGV_Timer_ComplicationDataSource: NSObject, CLKComplicationDataSource {
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
    }
    
    /* ################################################################## */
    /**
     */
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        handler(nil)
    }
    
    /* ################################################################## */
    /**
     */
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        handler(nil)
        
    }
}
