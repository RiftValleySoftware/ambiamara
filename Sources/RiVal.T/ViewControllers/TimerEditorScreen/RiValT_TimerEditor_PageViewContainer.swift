/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_Generic_Swift_Toolbox
import RVS_UIKit_Toolbox

/* ###################################################################################################################################### */
// MARK: - The Main Page View Controller for the Timer Editor Screens -
/* ###################################################################################################################################### */
/**
 */
class RiValT_TimerEditor_PageViewController: UIPageViewController {
    /* ############################################################## */
    /**
     */
    weak var pageViewContainerViewController: RiValT_TimerEditor_PageViewContainer?
    
    /* ############################################################## */
    /**
     The currently selected timer editor view controller.
     */
    var currentlySelectedTimerEditor: RiValT_EditTimer_ViewController? { self.viewControllers?.first as? RiValT_EditTimer_ViewController }

    /* ############################################################## */
    /**
     The group for the current timer.
     */
    var timer: Timer? { self.currentlySelectedTimerEditor?.timer }

    /* ############################################################## */
    /**
     The group for the current timer.
     */
    var group: TimerGroup? { self.timer?.group }
}

/* ###################################################################################################################################### */
// MARK: - The Main Page View Container for the Timer Editor Screen -
/* ###################################################################################################################################### */
/**
 */
class RiValT_TimerEditor_PageViewContainer: RiValT_Base_ViewController {
    /* ############################################################## */
    /**
     */
    weak var pageViewController: RiValT_TimerEditor_PageViewController?
    
    /* ############################################################## */
    /**
     The container view for the page view controller.
     */
    @IBOutlet weak var pageViewContainer: UIView?

    /* ############################################################## */
    /**
     The toolbar at the bottom.
     */
    @IBOutlet weak var toolbar: UIToolbar?
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension RiValT_TimerEditor_PageViewContainer {
    /* ############################################################## */
    /**
     The currently selected timer editor view controller.
     */
    var currentlySelectedTimerEditor: RiValT_EditTimer_ViewController? { pageViewController?.currentlySelectedTimerEditor }

    /* ############################################################## */
    /**
     The group for the current timer.
     */
    var timer: Timer? { self.pageViewController?.timer }

    /* ############################################################## */
    /**
     The group for the current timer.
     */
    var group: TimerGroup? { self.pageViewController?.group }
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RiValT_TimerEditor_PageViewContainer {
    /* ############################################################## */
    /**
     Called when the view has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        let appearance = UIToolbarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.backgroundImage = UIImage()
        self.toolbar?.standardAppearance = appearance
        self.toolbar?.scrollEdgeAppearance = appearance
        self.toolbar?.isTranslucent = true
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navAppearance.backgroundColor = .clear
        navAppearance.backgroundImage = UIImage()
        self.navigationController?.navigationBar.standardAppearance = navAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navAppearance
        pageViewController?.dataSource = self
        pageViewController?.delegate = self
        guard let firstViewController = storyboard?.instantiateViewController(withIdentifier: RiValT_EditTimer_ViewController.storyboardID) as? RiValT_EditTimer_ViewController else { return }
        firstViewController.myContainer = self
        firstViewController.timer = self.timerModel?.selectedTimer
        pageViewController?.setViewControllers( [firstViewController], direction: .forward, animated: false, completion: nil)
        self.setUpToolbar()
    }
    
    /* ############################################################## */
    /**
     Called when the view is about to appear
     
     - parameter inIsAnimated: True, if the appearance is animated.
     */
    override func viewWillAppear(_ inIsAnimated: Bool) {
        super.viewWillAppear(inIsAnimated)
        self.navigationController?.isNavigationBarHidden = false
    }

    /* ############################################################## */
    /**
     Called when we are to segue to another view controller.

     - parameter inSegue: The segue instance.
     - parameter inData: An opaque parameter with any associated data.
     */
    override func prepare(for inSegue: UIStoryboardSegue, sender inData: Any?) {
        if let destination = inSegue.destination as? RiValT_TimerEditor_PageViewController {
            destination.pageViewContainerViewController = self
            self.pageViewController = destination
        } else if let destination = inSegue.destination as? RiValT_RunningTimer_ContainerViewController,
                  let timer = inData as? Timer {
            destination.timer = timer
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RiValT_TimerEditor_PageViewContainer {
    /* ############################################################## */
    /**
     This sets up the bottom toolbar.
     */
    func setUpToolbar() {
        guard let timerIndexPath = self.timer?.indexPath,
              let timerGroup = self.group
        else { return }
        var toolbarItems = [UIBarButtonItem]()
        self.toolbar?.items = []
        if 1 < timerGroup.count {
            toolbarItems.append(UIBarButtonItem.flexibleSpace())

            for index in 0..<timerGroup.count {
                let timerButton = UIBarButtonItem()
                timerButton.image = UIImage(systemName: "\(index + 1).square\(index == timerIndexPath.item ? ".fill" : "")")
                timerButton.isEnabled = index != timerIndexPath.item
                timerButton.target = self
                timerButton.tag = index
                timerButton.action = #selector(toolbarTimerHit)
                timerButton.isAccessibilityElement = true
                timerButton.accessibilityLabel = String(format: "SLUG-ACC-TOOLBAR-TIMER-FORMAT-LABEL".localizedVariant, index + 1)
                timerButton.accessibilityHint = "SLUG-ACC-TOOLBAR-TIMER-HINT".localizedVariant
                toolbarItems.append(timerButton)
                toolbarItems.append(UIBarButtonItem.flexibleSpace())
            }
            
            self.toolbar?.setItems(toolbarItems, animated: false)
            self.toolbar?.isHidden = false
            var titleString = String(format: "SLUG-EDIT-FORMAT".localizedVariant, timerIndexPath.item + 1)
            if 1 < self.timerModel.count {
                titleString += String(format: "SLUG-PAREN-GROUP-FORMAT".localizedVariant, timerIndexPath.section + 1)
            }
            self.navigationItem.title = titleString
        } else {
            self.toolbar?.isHidden = true
            var titleString = "SLUG-EDIT-TIMER".localizedVariant
            if 1 < self.timerModel.count {
                titleString += String(format: "SLUG-PAREN-GROUP-FORMAT".localizedVariant, timerIndexPath.section + 1)
            }
            self.navigationItem.title = titleString
        }
        
        self.toolbar?.setNeedsLayout()
        self.toolbar?.layoutIfNeeded()
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension RiValT_TimerEditor_PageViewContainer {
    /* ############################################################## */
    /**
     Called when one of the numbered timer squares in the toolbar is hit.
     
     - parameter inButton: The timer button.
     */
    @objc func toolbarTimerHit(_ inButton: UIBarButtonItem) {
        guard let groupIndex = self.timer?.indexPath?.section,
              let timer = timerModel.getTimer(at: IndexPath(item: inButton.tag, section: groupIndex)),
              let newTimerIndex = timer.indexPath?.item,
              let currentTimerIndex = self.timerModel?.selectedTimer?.indexPath?.item
        else { return }
        
        let direction: UIPageViewController.NavigationDirection = newTimerIndex > currentTimerIndex ? .forward : .reverse
        
        guard let firstViewController = storyboard?.instantiateViewController(withIdentifier: RiValT_EditTimer_ViewController.storyboardID) as? RiValT_EditTimer_ViewController else { return }
        firstViewController.myContainer = self
        firstViewController.timer = timer
        timer.isSelected = true
        self.impactHaptic()
        pageViewController?.setViewControllers( [firstViewController], direction: direction, animated: true, completion: nil)
        self.setUpToolbar()
    }
}

/* ###################################################################################################################################### */
// MARK: UIPageViewControllerDataSource Conformance
/* ###################################################################################################################################### */
extension RiValT_TimerEditor_PageViewContainer: UIPageViewControllerDataSource {
    /* ################################################################## */
    /**
     Called to provide a new view controller, when swiping.
     
     - parameter: The page view controller (ignored).
     - parameter viewControllerBefore: The view controller for the timer that will be AFTER ours
     */
    func pageViewController(_: UIPageViewController, viewControllerBefore inNextViewController: UIViewController) -> UIViewController? {
        guard 1 < timerModel.allTimers.count,
              let nextViewController = inNextViewController as? RiValT_EditTimer_ViewController,
              let nextIndexPath = nextViewController.timer?.indexPath,
              let group = self.group
        else { return nil }
        let ret = storyboard?.instantiateViewController(withIdentifier: RiValT_EditTimer_ViewController.storyboardID) as? RiValT_EditTimer_ViewController
        ret?.myContainer = self
        let newIndex = nextIndexPath.item - 1
        guard (0..<group.count).contains(newIndex) else { return nil }
        ret?.timer = group[newIndex]
        return ret
    }
    
    /* ################################################################## */
    /**
     Called to provide a new view controller, when swiping.
     
     - parameter: The page view controller (ignored).
     - parameter viewControllerAfter: The view controller for the timer that will be BEFORE ours
    */
    func pageViewController(_: UIPageViewController, viewControllerAfter inPrevViewController: UIViewController) -> UIViewController? {
        guard 1 < timerModel.allTimers.count,
              let prevViewController = inPrevViewController as? RiValT_EditTimer_ViewController,
              let prevIndexPath = prevViewController.timer?.indexPath,
              let group = self.group
        else { return nil }
        let ret = storyboard?.instantiateViewController(withIdentifier: RiValT_EditTimer_ViewController.storyboardID) as? RiValT_EditTimer_ViewController
        ret?.myContainer = self
        let newIndex = prevIndexPath.item + 1
        guard (0..<group.count).contains(newIndex) else { return nil }
        ret?.timer = group[newIndex]
        return ret
    }
}

/* ###################################################################################################################################### */
// MARK: UIPageViewControllerDelegate Conformance
/* ###################################################################################################################################### */
extension RiValT_TimerEditor_PageViewContainer: UIPageViewControllerDelegate {
    /* ################################################################## */
    /**
     Called when a swipe has completed.
     
     - parameter: The page view controller (ignored).
     - parameter didFinishAnimating: True, if the animation completed (ignored).
     - parameter previousViewControllers: The previous view controllers (ignored).
     - parameter transitionCompleted: True, if the transition completed (ignored).
    */
    func pageViewController(_: UIPageViewController, didFinishAnimating: Bool, previousViewControllers: [UIViewController], transitionCompleted inCompleted: Bool) {
        guard let group = self.group,
              let timerIndex = self.currentlySelectedTimerEditor?.timer?.indexPath?.item
        else { return }
        self.currentlySelectedTimerEditor?.timer?.isSelected = true
        if 1 < group.count,
           (1..<(group.count - 1)).contains(timerIndex) {
            impactHaptic()
        } else {
            impactHaptic(1.0)
        }
        setUpToolbar()
    }
}
