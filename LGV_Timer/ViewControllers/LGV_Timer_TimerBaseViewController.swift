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
    @IBInspectable var gradientTopColor: UIColor = UIColor.black {
        didSet{
            self.view.setNeedsLayout()
        }
    }
    @IBInspectable var gradientBottomColor: UIColor = UIColor.darkGray {
        didSet{
            self.view.setNeedsLayout()
        }
    }
    
    let gradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.gradientLayer.colors = [self.gradientTopColor.cgColor, self.gradientBottomColor.cgColor]
        
        self.gradientLayer.locations = [0.0, 1.0]
        
        self.view.layer.addSublayer(self.gradientLayer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.gradientLayer.frame = self.view.bounds
    }
}
