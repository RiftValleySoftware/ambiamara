/**
 © Copyright 2018, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

/* ###################################################################################################################################### */
/**
 */

import UIKit

/* ###################################################################################################################################### */
/**
 This is an abstract base class for view controllers used in the app.
 */
@IBDesignable
class A_TimerBaseViewController: UIViewController {
    /* ################################################################################################################################## */
    // MARK: - Instance Constant Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is the initial size for our header label.
     */
    let headerFontSize: CGFloat = 20
    
    /* ################################################################################################################################## */
    // MARK: - Instance Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is a label that is used to replace the Navigation title. We replace it for accessibility reasons.
     */
    var titleLabel: UILabel!

    /* ################################################################################################################################## */
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
    
    /* ################################################################################################################################## */
    // MARK: - Instance Properties
    /* #################################################################################################################################*/
    /* ################################################################## */
    /**
     This is a gradient that is displayed across the background, from top to bottom, using the two colors specified in the IB properties.
     */
    let gradientLayer = CAGradientLayer()

    /* ################################################################################################################################## */
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
    
    /* ################################################################################################################################## */
    // MARK: - IBAction Instance Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called to select the succeeding Tab
     
     :param: _ The gesture recognizer that triggered this (ignored)
     */
    @IBAction func selectNextPage(_: UIGestureRecognizer) {
        if let selectedIndex = Timer_AppDelegate.appDelegateObject.timerEngine.selectedTimerIndex {
            if selectedIndex < (Timer_AppDelegate.appDelegateObject.timerEngine.count - 1) {
                Timer_AppDelegate.appDelegateObject.timerEngine.selectedTimerIndex += 1
            }
        } else {
            Timer_AppDelegate.appDelegateObject.timerEngine.selectedTimerIndex = 0
        }
    }
    
    /* ################################################################## */
    /**
     Called to select the preceeding Tab
     
     :param: _ The gesture recognizer that triggered this (ignored)
     */
    @IBAction func selectPreviousPage(_: UIGestureRecognizer) {
        if Timer_AppDelegate.appDelegateObject.timerEngine.selectedTimerIndex >= 0 {
            let prevIndex = Timer_AppDelegate.appDelegateObject.timerEngine.selectedTimerIndex - 1
            Timer_AppDelegate.appDelegateObject.timerEngine.selectedTimerIndex = prevIndex
        }
    }
    
    /* ################################################################################################################################## */
    // MARK: - Base Class Override Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view has finished loading.
     
     Paints the rear gradient layer.
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        // If the user is running high contrast, we give it to them.
        if UIAccessibility.isDarkerSystemColorsEnabled && !(self is TimerRuntimeViewController) {
            self.gradientTopColor = UIColor.darkGray
            self.gradientBottomColor = UIColor.black
        }
        
        self.gradientLayer.colors = [self.gradientTopColor.cgColor, self.gradientBottomColor.cgColor]
        self.gradientLayer.locations = [0.0, 1.0]
        
        self.view.layer.sublayers?.insert(self.gradientLayer, at: 0)
        
        // The nav item for timers is set by the bar manager.
        if (type(of: self) != TimerNavController.self) && (nil != self.navigationItem.title) {
            self.titleLabel = UILabel()
            self.titleLabel.font = UIFont.boldSystemFont(ofSize: self.headerFontSize)
            self.titleLabel.textColor = UIColor.white
            self.titleLabel.adjustsFontSizeToFitWidth = true
            self.titleLabel.text = self.navigationItem.title!.localizedVariant
            self.titleLabel.isAccessibilityElement = true
            self.navigationItem.titleView = self.titleLabel
        }
    }
    
    /* ################################################################## */
    /**
     Called when the layout is changed.
     
     Resets the gradient layer frame to fill the screen.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.gradientLayer.frame = self.view.bounds
    }
    
    /* ################################################################## */
    /**
     Called when the will appear.
     
     Sets the app styling to navBar and TabBar.
     
     :param: animated ignored by this function, but passed to the superclass.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navController = self.navigationController {
            let navBar = navController.navigationBar
            navBar.barTintColor = self.gradientTopColor
            navBar.tintColor = self.view.tintColor
            navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
        
        if let tabController = self.tabBarController {
            tabController.tabBar.barTintColor = self.gradientBottomColor
            tabController.tabBar.unselectedItemTintColor = self.view.tintColor
        }
        
        self.addAccessibilityStuff()
    }
    
    /* ################################################################################################################################## */
    /**
     This method applies the app styling to the "More..." view.
     */
    func gussyUpTheMoreNavigation() {
        if let navBar = self.navigationController?.navigationBar {
            self.tabBarController?.moreNavigationController.navigationBar.tintColor = navBar.tintColor
            self.tabBarController?.moreNavigationController.navigationBar.barStyle = navBar.barStyle
            self.tabBarController?.moreNavigationController.navigationBar.barTintColor = navBar.barTintColor
            self.tabBarController?.moreNavigationController.view.tintColor = UIColor.black
            self.tabBarController?.moreNavigationController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
    }
    
    /* ################################################################################################################################## */
    /**
     This method adds all the accessibility stuff. It is meant to be overridden.
     */
    func addAccessibilityStuff() {
        // This is meant to be overridden.
    }
}