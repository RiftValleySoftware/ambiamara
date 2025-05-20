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
// MARK: - The Main Page View Container for the Timer Editor Screen -
/* ###################################################################################################################################### */
/**
 This class acts as a "wrapper" for an instance of the ``RiValT_TimerEditor_PageViewController`` class. It also provides a Navigation Item, as well as a toolbar, for selecting amongst multiple timers in a group.
 
 If there is only one timer in the group, then the toolbar is not displayed.
 
 If there are more than one timers, the toolbar has numbered squares, representing each timer. Selecting a numbered square, brings that timer into the editor.
 
 This also presents a "Delete" (trashcan) icon in the upper right corner (Navigation Bar). That acts in exactly the same manner as the "Delete" button in the Group Editor Screen. Selecting it, brings up a confirmation alert, and choosing to delete, will dismiss the screen.
 */
class RiValT_TimerEditor_PageViewContainer: RiValT_Base_ViewController {
    /* ############################################################## */
    /**
     The page view controller that manages the group of timer screens.
     */
    weak var pageViewController: RiValT_TimerEditor_PageViewController?
    
    /* ############################################################## */
    /**
     If there is a string here, it is used as the title of the screen, instead of the format.
     */
    var optionalTitle: String?
    
    /* ############################################################## */
    /**
     This is set to true, if we want to override the pref.
     */
    var forceStart: Bool = false

    /* ############################################################## */
    /**
     The container view for the page view controller.
     */
    @IBOutlet weak var pageViewContainer: UIView?

    /* ############################################################## */
    /**
     The toolbar at the bottom. This acts like a page control.
     */
    @IBOutlet weak var toolbar: UIToolbar?
    
    /* ############################################################## */
    /**
     The delete button, in the navbar.
     */
    @IBOutlet weak var deleteBarButton: UIBarButtonItem?
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
        appearance.backgroundImage = nil
        self.toolbar?.standardAppearance = appearance
        self.toolbar?.scrollEdgeAppearance = appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navAppearance.backgroundColor = .clear
        navAppearance.backgroundImage = UIImage()
        self.navigationController?.navigationBar.standardAppearance = navAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navAppearance
        pageViewController?.dataSource = self
        pageViewController?.delegate = self
        self.deleteBarButton?.accessibilityLabel = "SLUG-ACC-NAVBAR-DELETE-LABEL".localizedVariant
        self.deleteBarButton?.accessibilityHint = "SLUG-ACC-NAVBAR-DELETE-HINT".localizedVariant
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
        guard let firstViewController = storyboard?.instantiateViewController(withIdentifier: RiValT_EditTimer_ViewController.storyboardID) as? RiValT_EditTimer_ViewController else { return }
        firstViewController.myContainer = self
        firstViewController.timer = self.timerModel?.selectedTimer
        pageViewController?.setViewControllers( [firstViewController], direction: .forward, animated: false, completion: nil)
        self.currentlySelectedTimerEditor?.timeTypeSegmentedControl?.selectedSegmentIndex = 0
        self.deleteBarButton?.isEnabled = 1 < (self.timer?.model?.allTimers.count ?? 0)
        self.forceStart = false
        self.setUpToolbar()
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
            destination.forceStart = self.forceStart
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
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
                timerButton.image = UIImage(systemName: "\(index + 1).square\(index == timerIndexPath.item ? ".fill" : "")")?.applyingSymbolConfiguration(.init(pointSize: 40))
                timerButton.imageInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
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
            self.navigationItem.title = self.optionalTitle ?? titleString
        } else {
            self.toolbar?.isHidden = true
            var titleString = "SLUG-EDIT-TIMER".localizedVariant
            if 1 < self.timerModel.count {
                titleString += String(format: "SLUG-PAREN-GROUP-FORMAT".localizedVariant, timerIndexPath.section + 1)
            }
            self.navigationItem.title = self.optionalTitle ?? titleString
        }
        
        self.optionalTitle = nil
    }
    
    /* ############################################################## */
    /**
     Called when the Watch wants us to play.
     */
    func remotePlay() {
        self.forceStart = true
        self.performSegue(withIdentifier: RiValT_RunningTimer_ContainerViewController.segueID, sender: self.timerModel.selectedTimer)
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension RiValT_TimerEditor_PageViewContainer {
    /* ############################################################## */
    /**
     The delete button in the navbar was hit.
     */
    @IBAction func deleteButtonHit(_ inButton: UIBarButtonItem) {
        func _executeDelete() {
            guard let timer = self.timerModel.selectedTimer,
                  let indexPath = timer.indexPath,
                  1 < self.timerModel.allTimers.count
            else { return }
            
            self.timerModel.removeTimer(from: indexPath)

            self.navigationController?.popViewController(animated: true)
        }
        
        let messageText = "SLUG-DELETE-2-CONFIRM-MESSAGE"
        
        let alertController = UIAlertController(title: "SLUG-DELETE-2-CONFIRM-HEADER", message: messageText, preferredStyle: .alert)
        
        // This simply displays the main message as left-aligned.
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left

        let attributedMessageText = NSMutableAttributedString(
            string: messageText,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body),
                NSAttributedString.Key.foregroundColor: UIColor.label
            ]
        )
        
        alertController.setValue(attributedMessageText, forKey: "attributedMessage")
        
        let okAction = UIAlertAction(title: "SLUG-DELETE-BUTTON-TEXT".localizedVariant, style: .destructive) { _ in _executeDelete() }
        
        alertController.addAction(okAction)

        let cancelAction = UIAlertAction(title: "SLUG-CANCEL-BUTTON-TEXT".localizedVariant, style: .cancel, handler: nil)

        alertController.addAction(cancelAction)

        self.impactHaptic(1.0)

        alertController.localizeStuff()
        
        present(alertController, animated: true, completion: nil)
    }

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
        self.watchDelegate?.updateSettings()
        self.impactHaptic()
        self.pageViewController?.setViewControllers( [firstViewController], direction: direction, animated: true, completion: nil)
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
        self.watchDelegate?.updateSettings()
        if 1 < group.count,
           (1..<(group.count - 1)).contains(timerIndex) {
            self.impactHaptic()
        } else {
            self.impactHaptic(1.0)
        }
        self.setUpToolbar()
    }
}
