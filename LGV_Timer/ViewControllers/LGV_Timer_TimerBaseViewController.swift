//
//  LGV_Timer_TimerBaseViewController.swift
//  LGV_Timer
//
//  Created by Chris Marshall on 5/24/17.
//  Copyright © 2017 Little Green Viper Software Development LLC. All rights reserved.
//
/* ###################################################################################################################################### */
/**
 */

import UIKit

/* ###################################################################################################################################### */
/**
 */
@IBDesignable class LGV_Timer_TimerBaseViewController: UIViewController {
    @IBInspectable var gradientTopColor: UIColor = UIColor.green {
        didSet{
            self.view.setNeedsLayout()
        }
    }
    @IBInspectable var gradientBottomColor: UIColor = UIColor.blue {
        didSet{
            self.view.setNeedsLayout()
        }
    }
}
