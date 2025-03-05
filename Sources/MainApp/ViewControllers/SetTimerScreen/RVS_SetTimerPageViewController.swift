/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import RVS_Generic_Swift_Toolbox

/* ###################################################################################################################################### */
// MARK: - Overall "Wrapper" View Controller -
/* ###################################################################################################################################### */
/**
 This view established an overall context for the set timer screen. It contains a page view controller, that is used to select the timer being edited.
 It also has a toolbar, allowing selection of the timer, as well as adding and deleting timers.
 */
class RVS_SetTimerWrapper: RVS_AmbiaMara_BaseViewController {
    /* ################################################################## */
    /**
     The size of the two settings popovers.
    */
    private static let _settingsPopoverWidthInDisplayUnits = CGFloat(400)

    /* ################################################################## */
    /**
     The ID for the segue, to show the about screen.
    */
    private static let _aboutViewSegueID = "ShowAboutView"
    
    /* ################################################################## */
    /**
     The ID for the segue, to start the timer.
    */
    private static let _startTimerSegueID = "start-timer"

    /* ################################################################## */
    /**
     This will provide haptic/audio feedback for subtle events.
     */
    private var _selectionFeedbackGenerator: UISelectionFeedbackGenerator?

    /* ################################################################## */
    /**
     This will provide haptic/audio feedback for more significant events.
     */
    private var _impactFeedbackGenerator: UIImpactFeedbackGenerator?

    /* ################################################################## */
    /**
     This will list our timer toolbar items.
    */
    private var _timerBarItems: [UIBarButtonItem] = []

    /* ################################################################## */
    /**
     The settings popover bar button item.
    */
    @IBOutlet weak var settingsButton: UIButton?
    
    /* ################################################################## */
    /**
     The set alarm popover bar button item.
    */
    @IBOutlet weak var alarmSetButton: UIButton?

    /* ################################################################## */
    /**
     The label for the currently selected timer.
     */
    @IBOutlet weak var timerLabel: UILabel?
    
    /* ################################################################## */
    /**
     This is a container view for our page view controller view.
     */
    @IBOutlet weak var pageViewContainer: UIView?
    
    /* ################################################################## */
    /**
     This is the page view controller that we use to swipe-select timers.
     */
    var pageViewController: RVS_SetTimerPageViewController?
    
    /* ################################################################## */
    /**
     This is a reference to the current active timer screen.
     */
    weak var currentActiveTimerScreen: RVS_SetTimerAmbiaMara_ViewController?

    /* ################################################################## */
    /**
     If a popover is being displayed, we reference it here (so we put it away, when we need to).
    */
    weak var currentDisplayedPopover: UIViewController?

    /* ################################################################## */
    /**
     The current screen state.
    */
    var state: RVS_SetTimerAmbiaMara_ViewController.States = .start

    /* ################################################################## */
    /**
     The toolbar at the bottom of the screen, allowing selection of timers, as well as adding and deleting timers.
     */
    @IBOutlet weak var timerSelectionToolbar: UIToolbar?
    
    /* ################################################################## */
    /**
     This is the leftmost button, the trash icon.
    */
    @IBOutlet weak var trashBarButtonItem: UIBarButtonItem?
    
    /* ################################################################## */
    /**
     This is the rightmost button, the add button.
    */
    @IBOutlet weak var addBarButtonItem: UIBarButtonItem?
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension RVS_SetTimerWrapper {
    /* ################################################################## */
    /**
     The maximum number of timers we can have.
    */
    private var _maximumNumberOfTimers: Int { .pad == UIDevice.current.userInterfaceIdiom ? 14 : 6 }

    /* ################################################################## */
    /**
     The current timer, routed from the settings.
    */
    var currentTimer: RVS_AmbiaMara_Settings.TimerSettings {
        get { RVS_AmbiaMara_Settings().currentTimer }
        set { RVS_AmbiaMara_Settings().currentTimer = newValue  }
    }
    
    /* ############################################################## */
    /**
     - returns: The index of the following timer. Nil, if no following timer.
                This "circles around," so the last timer points to the first timer.
     */
    private var _nextTimerIndex: Int? {
        guard 1 < RVS_AmbiaMara_Settings().numberOfTimers else { return nil }
        
        let nextIndex = RVS_AmbiaMara_Settings().currentTimerIndex + 1
        
        guard nextIndex < RVS_AmbiaMara_Settings().numberOfTimers else { return nil }
        
        return nextIndex
    }
    
    /* ############################################################## */
    /**
     - returns: The index of the previous timer. Nil, if no previous timer.
                This "circles around," so the first timer points to the last timer.
     */
    private var _previousTimerIndex: Int? {
        guard 1 < RVS_AmbiaMara_Settings().numberOfTimers else { return nil }
        
        let previousIndex = RVS_AmbiaMara_Settings().currentTimerIndex - 1
        
        guard 0 <= previousIndex else { return nil }
        
        return previousIndex
    }

}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RVS_SetTimerWrapper {
    /* ################################################################## */
    /**
     Called when the view hierarchy has been established, but before display.
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        _selectionFeedbackGenerator = UISelectionFeedbackGenerator()
        _selectionFeedbackGenerator?.prepare()
        
        _impactFeedbackGenerator = UIImpactFeedbackGenerator()
        _impactFeedbackGenerator?.prepare()

        timerSelectionToolbar?.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        timerSelectionToolbar?.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        settingsButton?.accessibilityLabel = "SLUG-ACC-SETTINGS-BUTTON-LABEL".accessibilityLocalizedVariant
        settingsButton?.accessibilityHint = "SLUG-ACC-SETTINGS-BUTTON".accessibilityLocalizedVariant
        alarmSetButton?.accessibilityLabel = "SLUG-ACC-ALARM-BUTTON-LABEL".accessibilityLocalizedVariant
        alarmSetButton?.accessibilityHint = "SLUG-ACC-ALARM-BUTTON".accessibilityLocalizedVariant
        
        guard let pageViewContainer,
              let pvc = storyboard?.instantiateViewController(withIdentifier: RVS_SetTimerPageViewController.storyboardID) as? RVS_SetTimerPageViewController,
              let pvcView = pvc.view
        else { return }
        
        pageViewController = pvc

        pvc.dataSource = self
        pvc.delegate = self
        addChild(pvc)
        pvc.didMove(toParent: self)

        pageViewContainer.addSubview(pvcView)
        pvcView.translatesAutoresizingMaskIntoConstraints = false
        pvcView.topAnchor.constraint(equalTo: pageViewContainer.topAnchor).isActive = true
        pvcView.bottomAnchor.constraint(equalTo: pageViewContainer.bottomAnchor).isActive = true
        pvcView.leadingAnchor.constraint(equalTo: pageViewContainer.leadingAnchor).isActive = true
        pvcView.trailingAnchor.constraint(equalTo: pageViewContainer.trailingAnchor).isActive = true
    }
    
    /* ############################################################## */
    /**
     Called when the view is about to appear.
     We use this to start the "fade in" animation.
     
     - parameter inIsAnimated: True, if the transition is to be animated (ignored, but sent to the superclass).
     */
    override func viewWillAppear(_ inIsAnimated: Bool) {
        super.viewWillAppear(inIsAnimated)
        
        if 0 == RVS_AmbiaMara_Settings().numberOfTimers {
            addHit()
        } else if let initialController = storyboard?.instantiateViewController(withIdentifier: RVS_SetTimerAmbiaMara_ViewController.storyboardID) as? RVS_SetTimerAmbiaMara_ViewController {
            initialController.timerIndex = RVS_AmbiaMara_Settings().currentTimerIndex
            initialController.container = self
            pageViewController?.setViewControllers( [initialController], direction: .forward, animated: false, completion: nil)
            setUpToolbar()
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension RVS_SetTimerWrapper {
    /* ################################################################## */
    /**
     Called a timer bar button item has been hit.
     - parameter inToolbarButton: the button for the selected timer.
    */
    @objc func selectToolbarItem(_ inToolbarButton: UIBarButtonItem) {
        let tag = inToolbarButton.tag
        guard (1...RVS_AmbiaMara_Settings().numberOfTimers).contains(tag) else { return }
        if hapticsAreAvailable {
            _selectionFeedbackGenerator?.selectionChanged()
            _selectionFeedbackGenerator?.prepare()
        }
        selectPageWithIndex(tag - 1)
    }
    
    /* ################################################################## */
    /**
     Called when the add bar button item has been hit.
     - parameter: ignored.
    */
    @IBAction func addHit(_: Any! = nil) {
        if _maximumNumberOfTimers > _timerBarItems.count {
            RVS_AmbiaMara_Settings().add(andSelect: true)
            state = .start
            guard let newController = storyboard?.instantiateViewController(withIdentifier: RVS_SetTimerAmbiaMara_ViewController.storyboardID) as? RVS_SetTimerAmbiaMara_ViewController else { return }
            newController.container = self
            newController.timerIndex = RVS_AmbiaMara_Settings().numberOfTimers - 1
            pageViewController?.setViewControllers( [newController], direction: .forward, animated: false, completion: nil)
        }
    }
    
    /* ################################################################## */
    /**
     Called when the trash bar button item has been hit.
     This puts up a confirmation screen, asking if the user is sure they want to delete the timer.
     - parameter: ignored.
    */
    @IBAction func trashHit(_: Any) {
        if 1 < _timerBarItems.count {
            if hapticsAreAvailable {
                _impactFeedbackGenerator?.impactOccurred(intensity: CGFloat(UIImpactFeedbackGenerator.FeedbackStyle.rigid.rawValue))
                _impactFeedbackGenerator?.prepare()
            }

            let timerTag = currentTimer.index + 1
            let startTimeAsComponents = currentTimer.startTimeAsComponents
            guard 2 < startTimeAsComponents.count else { return }

            var timeString: String

            if 0 < startTimeAsComponents[0] {
                timeString = "\(String(format: "%d", startTimeAsComponents[0])):\(String(format: "%02d", startTimeAsComponents[1])):\(String(format: "%02d", startTimeAsComponents[2]))"
            } else if 0 < startTimeAsComponents[1] {
                timeString = "\(String(format: "%d", startTimeAsComponents[1])):\(String(format: "%02d", startTimeAsComponents[2]))"
            } else {
                timeString = String(startTimeAsComponents[2])
            }
            
            let message = timeString.isEmpty || "0" == timeString
                ? String(format: "SLUG-DELETE-CONFIRM-MESSAGE-FORMAT-ZERO".localizedVariant, timerTag)
                : String(format: "SLUG-DELETE-CONFIRM-MESSAGE-FORMAT".localizedVariant, timerTag, timeString)
            let alertController = UIAlertController(title: "SLUG-DELETE-CONFIRM-HEADER".localizedVariant, message: message, preferredStyle: .alert)

            let okAction = UIAlertAction(title: "SLUG-DELETE-BUTTON-TEXT".localizedVariant, style: .destructive) { [weak self] _ in
                if let currentTimer = self?.currentTimer {
                    if self?.hapticsAreAvailable ?? false {
                        self?._impactFeedbackGenerator?.impactOccurred(intensity: CGFloat(UIImpactFeedbackGenerator.FeedbackStyle.rigid.rawValue))
                        self?._impactFeedbackGenerator?.prepare()
                    }
                    let nextIndex = max(0, currentTimer.index - 1)
                    RVS_AmbiaMara_Settings().remove(timer: currentTimer)
                    self?.selectPageWithIndex(nextIndex)
                }
                self?.state = .start
                self?.setUpToolbar()
            }
            
            alertController.addAction(okAction)

            let cancelAction = UIAlertAction(title: "SLUG-CANCEL-BUTTON-TEXT".localizedVariant, style: .cancel) { [weak self] _ in
                if self?.hapticsAreAvailable ?? false {
                    self?._selectionFeedbackGenerator?.selectionChanged()
                    self?._selectionFeedbackGenerator?.prepare()
                }
            }

            alertController.addAction(cancelAction)

            present(alertController, animated: true, completion: nil)
        }
    }

    /* ################################################################## */
    /**
     This is called, when someone selects the Settings Bar Button.
     It displays a popover, with various app settings.
     - parameter inButtonItem: the bar button item.
     */
    @IBAction func displaySettingsPopover(_ inButtonItem: UIButton) {
        if let popoverController = storyboard?.instantiateViewController(identifier: RVS_SettingsAmbiaMara_PopoverViewController.storyboardID) as? RVS_SettingsAmbiaMara_PopoverViewController {
            if hapticsAreAvailable {
                _selectionFeedbackGenerator?.selectionChanged()
                _selectionFeedbackGenerator?.prepare()
            }
            popoverController.modalPresentationStyle = .popover
            popoverController.myController = self
            popoverController.popoverPresentationController?.sourceView = inButtonItem
            popoverController.popoverPresentationController?.delegate = self
            popoverController.preferredContentSize = CGSize(width: Self._settingsPopoverWidthInDisplayUnits, height: RVS_SettingsAmbiaMara_PopoverViewController.settingsPopoverHeightInDisplayUnits)
            currentDisplayedPopover = popoverController
            present(popoverController, animated: true)
       }
    }
    
    /* ################################################################## */
    /**
     This is called, when someone selects the Alarm Set Bar Button.
     It displays a popover, with tools to select the audible (or vibratory) alarm.
     - parameter inButtonItem: the bar button item.
     */
    @IBAction func displayAlarmSetupPopover(_ inButtonItem: UIButton) {
        if let popoverController = storyboard?.instantiateViewController(identifier: RVS_SetAlarmAmbiaMara_PopoverViewController.storyboardID) as? RVS_SetAlarmAmbiaMara_PopoverViewController {
            if hapticsAreAvailable {
                _selectionFeedbackGenerator?.selectionChanged()
                _selectionFeedbackGenerator?.prepare()
            }
            popoverController.modalPresentationStyle = .popover
            popoverController.myController = self
            popoverController.popoverPresentationController?.sourceView = inButtonItem
            popoverController.popoverPresentationController?.delegate = self
            popoverController.preferredContentSize = CGSize(width: Self._settingsPopoverWidthInDisplayUnits, height: RVS_SetAlarmAmbiaMara_PopoverViewController.settingsPopoverHeightInDisplayUnits)
            currentDisplayedPopover = popoverController
            present(popoverController, animated: true)
       }
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RVS_SetTimerWrapper {
    /* ################################################################## */
    /**
     This is called to select a specific page.
     
     - parameter inIndex: The 0-based index of the page to be selected.
     - parameter direction: An optional forced direction. Leave nil, or don't specify, to automate.
     */
    func selectPageWithIndex(_ inIndex: Int, direction inDirection: UIPageViewController.NavigationDirection? = nil) {
        guard (0..<RVS_AmbiaMara_Settings().numberOfTimers).contains(inIndex),
              let viewControllers = pageViewController?.viewControllers,
              !viewControllers.isEmpty,
              let viewController = storyboard?.instantiateViewController(withIdentifier: RVS_SetTimerAmbiaMara_ViewController.storyboardID) as? RVS_SetTimerAmbiaMara_ViewController
        else { return }
        viewController.container = self
        viewController.timerIndex = inIndex
        let direction: UIPageViewController.NavigationDirection = inDirection ?? (inIndex > RVS_AmbiaMara_Settings().currentTimerIndex ? .forward : .reverse)
        pageViewController?.setViewControllers([viewController], direction: direction, animated: true)
    }
    
    /* ################################################################## */
    /**
     This sets the timer label, at the top.
    */
    func setTimerLabel() {
        timerLabel?.text = 1 < RVS_AmbiaMara_Settings().numberOfTimers ? String(format: "SLUG-TIMER-TITLE-FORMAT".localizedVariant, currentTimer.index + 1) : " "
    }
    
    /* ################################################################## */
    /**
     This sets up the toolbar, by adding all the timers.
    */
    func setUpToolbar() {
        guard let items = timerSelectionToolbar?.items,
              1 < items.count,
              let addItem = items.last
        else { return }
            
        var newItems: [UIBarButtonItem] = [items[0], UIBarButtonItem.flexibleSpace()]
        if 1 < RVS_AmbiaMara_Settings().numberOfTimers {
            _timerBarItems = []
            let currentTag = currentTimer.index + 1
            setTimerLabel()
            for timer in RVS_AmbiaMara_Settings().timers.enumerated() {
                let tag = timer.offset + 1
                let timerButton = UIBarButtonItem()
                let startTimeAsComponents = timer.element.startTimeAsComponents
                if 2 < startTimeAsComponents.count {
                    var timeString: String
                    if 0 < startTimeAsComponents[0] {
                        timeString = "\(String(format: "%d", startTimeAsComponents[0])):\(String(format: "%02d", startTimeAsComponents[1])):\(String(format: "%02d", startTimeAsComponents[2]))"
                    } else if 0 < startTimeAsComponents[1] {
                        timeString = "\(String(format: "%d", startTimeAsComponents[1])):\(String(format: "%02d", startTimeAsComponents[2]))"
                    } else {
                        timeString = String(startTimeAsComponents[2])
                    }
                    
                    timerButton.tag = tag
                    let imageName = "\(tag).circle\(currentTag != tag ? ".fill" : "")"
                    timerButton.image = UIImage(systemName: imageName)?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large))
                    timerButton.accessibilityLabel = String(format: "SLUG-ACC-TIMER-BUTTON-LABEL-FORMAT".accessibilityLocalizedVariant, tag)
                    timerButton.accessibilityHint = String(format: "SLUG-ACC-TIMER-BUTTON-HINT-\(currentTag == tag ? "IS" : "NOT")-FORMAT".accessibilityLocalizedVariant, timeString)
                    timerButton.isEnabled = currentTag != tag
                    timerButton.target = self
                    timerButton.tintColor = timerButton.isEnabled ? UIColor(named: "AccentColor") : .label
                    timerButton.action = #selector(selectToolbarItem(_:))
                    newItems.append(timerButton)
                    newItems.append(UIBarButtonItem.flexibleSpace())
                    _timerBarItems.append(timerButton)
                }
            }
            trashBarButtonItem?.accessibilityHint = String(format: "SLUG-ACC-DELETE-TIMER-BUTTON-FORMAT".accessibilityLocalizedVariant, currentTag)
        } else {
            navigationItem.title = nil
            trashBarButtonItem?.accessibilityHint = nil
        }
        
        newItems.append(addItem)
        
        timerSelectionToolbar?.setItems(newItems, animated: false)
        
        trashBarButtonItem?.isEnabled = 1 < _timerBarItems.count
        addBarButtonItem?.isEnabled = _maximumNumberOfTimers > _timerBarItems.count
        addBarButtonItem?.accessibilityHint = _maximumNumberOfTimers > _timerBarItems.count ? "SLUG-ACC-ADD-TIMER-BUTTON".accessibilityLocalizedVariant : nil
    }

    /* ################################################################## */
    /**
     This makes sure the alarm icon at the top, is the correct one.
    */
    func setAlarmIcon() {
        alarmSetButton?.setImage(UIImage(systemName: RVS_AmbiaMara_Settings().alarmMode ? "bell.fill" : "bell.slash.fill"), for: .normal)
    }
}

/* ###################################################################################################################################### */
// MARK: Segues
/* ###################################################################################################################################### */
extension RVS_SetTimerWrapper {
    /* ################################################################## */
    /**
     This shows the about screen.
    */
    func showAboutScreen() {
        performSegue(withIdentifier: Self._aboutViewSegueID, sender: nil)
    }

    /* ################################################################## */
    /**
     Start the timer.
    */
    func startTimer() {
        performSegue(withIdentifier: Self._startTimerSegueID, sender: nil)
    }
}

/* ###################################################################################################################################### */
// MARK: UIPageViewControllerDataSource Conformance
/* ###################################################################################################################################### */
extension RVS_SetTimerWrapper: UIPageViewControllerDataSource {
    /* ################################################################## */
    /**
     Called to provide a new view controller, when swiping.
     
     - parameter: The page view controller (ignored).
     - parameter viewControllerBefore: The view controller for the timer that will be AFTER ours
     */
    func pageViewController(_: UIPageViewController, viewControllerBefore: UIViewController) -> UIViewController? {
        guard 1 < RVS_AmbiaMara_Settings().numberOfTimers else { return nil }
        let ret = storyboard?.instantiateViewController(withIdentifier: RVS_SetTimerAmbiaMara_ViewController.storyboardID) as? RVS_SetTimerAmbiaMara_ViewController
        ret?.container = self
        let nextIndex = RVS_AmbiaMara_Settings().currentTimerIndex - 1
        let lastIndex = RVS_AmbiaMara_Settings().numberOfTimers - 1
        guard (0...lastIndex).contains(nextIndex) else {
            if hapticsAreAvailable {
                _impactFeedbackGenerator?.impactOccurred(intensity: 1.0)
                _impactFeedbackGenerator?.prepare()
            }
            return nil
        }
        let newIndex = nextIndex
        ret?.timerIndex = newIndex
        if hapticsAreAvailable {
            if 0 == newIndex || lastIndex == newIndex {
                _impactFeedbackGenerator?.impactOccurred()
                _impactFeedbackGenerator?.prepare()
            } else {
                _selectionFeedbackGenerator?.selectionChanged()
                _selectionFeedbackGenerator?.prepare()
            }
        }
        return ret
    }
    
    /* ################################################################## */
    /**
     Called to provide a new view controller, when swiping.
     
     - parameter: The page view controller (ignored).
     - parameter viewControllerAfter: The view controller for the timer that will be BEFORE ours
    */
    func pageViewController(_: UIPageViewController, viewControllerAfter: UIViewController) -> UIViewController? {
        guard 1 < RVS_AmbiaMara_Settings().numberOfTimers else { return nil }
        let ret = storyboard?.instantiateViewController(withIdentifier: RVS_SetTimerAmbiaMara_ViewController.storyboardID) as? RVS_SetTimerAmbiaMara_ViewController
        ret?.container = self
        let nextIndex = RVS_AmbiaMara_Settings().currentTimerIndex + 1
        let lastIndex = RVS_AmbiaMara_Settings().numberOfTimers - 1
        guard (0...lastIndex).contains(nextIndex) else {
            if hapticsAreAvailable {
                _impactFeedbackGenerator?.impactOccurred(intensity: 1.0)
                _impactFeedbackGenerator?.prepare()
            }
            return nil
        }
        let newIndex = nextIndex
        ret?.timerIndex = newIndex
        if hapticsAreAvailable {
            if 0 == newIndex || lastIndex == newIndex {
                _impactFeedbackGenerator?.impactOccurred()
                _impactFeedbackGenerator?.prepare()
            } else {
                _selectionFeedbackGenerator?.selectionChanged()
                _selectionFeedbackGenerator?.prepare()
            }
        }
        return ret
    }
}

/* ###################################################################################################################################### */
// MARK: UIPageViewControllerDelegate Conformance
/* ###################################################################################################################################### */
extension RVS_SetTimerWrapper: UIPageViewControllerDelegate {
    /* ################################################################## */
    /**
     Called when a swipe has completed.
     
     - parameter: The page view controller (ignored).
     - parameter didFinishAnimating: True, if the animation completed (ignored).
     - parameter previousViewControllers: The previous view controllers (ignored).
     - parameter transitionCompleted: True, if the transition completed (ignored).
    */
    func pageViewController(_: UIPageViewController, didFinishAnimating: Bool, previousViewControllers: [UIViewController], transitionCompleted: Bool) {
        setUpToolbar()
        setAlarmIcon()
        setTimerLabel()
    }
}

/* ###################################################################################################################################### */
// MARK: UIPopoverPresentationControllerDelegate Conformance
/* ###################################################################################################################################### */
extension RVS_SetTimerWrapper: UIPopoverPresentationControllerDelegate {
    /* ################################################################## */
    /**
     Called to ask if there's any possibility of this being displayed in another way.
     
     - parameter for: The presentation controller we're talking about.
     - returns: No way, Jose.
     */
    func adaptivePresentationStyle(for: UIPresentationController) -> UIModalPresentationStyle { .none }
    
    /* ################################################################## */
    /**
     Called to ask if there's any possibility of this being displayed in another way (when the screen is rotated).
     
     - parameter for: The presentation controller we're talking about.
     - parameter traitCollection: The traits, describing the new orientation.
     - returns: No way, Jose.
     */
    func adaptivePresentationStyle(for: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle { .none }
}

/* ###################################################################################################################################### */
// MARK: - Timer Selection Page View Controller -
/* ###################################################################################################################################### */
/**
 This is the page view controller that we use for swipe-selecting the timers.
 */
class RVS_SetTimerPageViewController: UIPageViewController {
    /* ################################################################## */
    /**
     The storyboard ID, for instantiating the class.
     */
    static let storyboardID = "RVS_SetTimerPageViewController"
}
