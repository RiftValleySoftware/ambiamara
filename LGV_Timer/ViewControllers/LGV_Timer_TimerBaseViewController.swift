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
 This is a base class for view controllers used in the app.
 */
@IBDesignable class LGV_Timer_TimerBaseViewController: UIViewController {
    // MARK: - IB Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is the top (initial) color of the background gradient.
     */
    @IBInspectable var gradientTopColor: UIColor = UIColor.black
    
    /* ################################################################## */
    /**
     This is the bottom (final) color of the background gradient.
     */
    @IBInspectable var gradientBottomColor: UIColor = UIColor.darkGray
    
    /* ################################################################## */
    /**
     This is the color for the tab bar items that are not selected.
     */
    @IBInspectable var unselectedTabItemColor: UIColor = UIColor.lightGray
    
    // MARK: - Instance Properties
    /* #################################################################################################################################*/
    /* ################################################################## */
    /**
     This is a gradient that is displayed across the background, from top to bottom, using the two colors specified in the IB properties.
     */
    let gradientLayer = CAGradientLayer()
    
    // MARK: - Instance Calculated Properties
    /* #################################################################################################################################*/
    /* ################################################################## */
    /**
     This gets the Navigation Bar Title, and sets the Navigation Bar Title from a given localization token.
     */
    var screenTitle: String {
        get {
            var ret: String = ""
            
            if let title = self.navigationItem.title {
                ret = title
            }
            
            return ret
        }
        
        set {
            self.navigationItem.title = newValue.localizedVariant
        }
    }
    
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view has finished loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        self.gradientLayer.colors = [self.gradientTopColor.cgColor, self.gradientBottomColor.cgColor]
        
        self.gradientLayer.locations = [0.0, 1.0]
        
        self.view.layer.sublayers?.insert(self.gradientLayer, at: 0)
        
        // The nav item for timers is set by the bar manager.
        if (type(of: self) != LGV_Timer_TimerNavController.self) && (nil != self.navigationItem.title) {
            self.navigationItem.title = self.navigationItem.title!.localizedVariant
        }
    }
    
    /* ################################################################## */
    /**
     Called when the layout is changed.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.gradientLayer.frame = self.view.bounds
    }
    
    /* ################################################################## */
    /**
     Called when the will appear.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navController = self.navigationController {
            navController.navigationBar.barTintColor = self.gradientTopColor
        }
        
        if let tabController = self.tabBarController {
            tabController.tabBar.barTintColor = self.gradientBottomColor
            tabController.tabBar.unselectedItemTintColor = self.unselectedTabItemColor
        }
    }
}
