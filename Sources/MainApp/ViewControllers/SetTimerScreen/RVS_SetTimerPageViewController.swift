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
 */
class RVS_SetTimerWrapper: RVS_AmbiaMara_BaseViewController {
    /* ################################################################## */
    /**
     The maximum number of timers we can have.
    */
    private static let _maximumNumberOfTimers = 6

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
     */
    @IBOutlet weak var pageViewContainer: UIView?
    
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
     */
    @IBOutlet weak var timerLabel: UILabel?
    
    /* ################################################################## */
    /**
     */
    weak var pageViewController: RVS_SetTimerPageViewController?
    
    /* ################################################################## */
    /**
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
    
    /* ################################################################## */
    /**
     The current timer, routed from the settings.
    */
    var currentTimer: RVS_AmbiaMara_Settings.TimerSettings {
        get { RVS_AmbiaMara_Settings().currentTimer }
        set { RVS_AmbiaMara_Settings().currentTimer = newValue  }
    }

    /* ################################################################## */
    /**
     This will list our timer toolbar items.
    */
    private var _timerBarItems: [UIBarButtonItem] {
        var ret = [UIBarButtonItem]()
        
        guard let items = timerSelectionToolbar?.items else { return [] }
        
        for item in items.enumerated() where (2..<(items.count - 2)).contains(item.offset) {
            ret.append(item.element)
        }
        
        return ret
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
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let pageViewContainer,
              let pvc = storyboard?.instantiateViewController(withIdentifier: RVS_SetTimerPageViewController.storyboardID) as? RVS_SetTimerPageViewController,
              let pvcView = pvc.view,
              let initialController = storyboard?.instantiateViewController(withIdentifier: RVS_SetTimerAmbiaMara_ViewController.storyboardID) as? RVS_SetTimerAmbiaMara_ViewController
        else { return }
        
        initialController.container = self
        pvc.dataSource = self
        pvc.setViewControllers( [initialController], direction: .forward, animated: false, completion: nil)

        pageViewContainer.addSubview(pvcView)
        pvcView.translatesAutoresizingMaskIntoConstraints = false
        pvcView.topAnchor.constraint(equalTo: pageViewContainer.topAnchor).isActive = true
        pvcView.bottomAnchor.constraint(equalTo: pageViewContainer.bottomAnchor).isActive = true
        pvcView.leadingAnchor.constraint(equalTo: pageViewContainer.leadingAnchor).isActive = true
        pvcView.trailingAnchor.constraint(equalTo: pageViewContainer.trailingAnchor).isActive = true

        addChild(pvc)
        pvc.didMove(toParent: self)
        pageViewController = pvc

        _selectionFeedbackGenerator = UISelectionFeedbackGenerator()
        _selectionFeedbackGenerator?.prepare()
        
        _impactFeedbackGenerator = UIImpactFeedbackGenerator()
        _impactFeedbackGenerator?.prepare()

        timerSelectionToolbar?.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        timerSelectionToolbar?.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        setUpToolbar()
    }
    
    /* ################################################################## */
    /**
     This sets up the toolbar, by adding all the timers.
    */
    func setUpToolbar() {
        if let items = timerSelectionToolbar?.items {
            guard 1 < items.count else { return }
            var newItems: [UIBarButtonItem] = [items[0], items[1], items[items.count - 2], items[items.count - 1]]
            if 1 < RVS_AmbiaMara_Settings().numberOfTimers {
                let currentTag = currentTimer.index + 1
                navigationItem.title = String(format: "SLUG-TIMER-TITLE-FORMAT".localizedVariant, currentTag)
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
                        let imageName = "\(tag).circle\(currentTag != tag ? "" : ".fill")"
                        timerButton.image = UIImage(systemName: imageName)?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large))
                        timerButton.accessibilityLabel = String(format: "SLUG-ACC-TIMER-BUTTON-LABEL-FORMAT".accessibilityLocalizedVariant, tag)
                        timerButton.accessibilityHint = String(format: "SLUG-ACC-TIMER-BUTTON-HINT-\(currentTag == tag ? "IS" : "NOT")-FORMAT".accessibilityLocalizedVariant, timeString)
                        timerButton.isEnabled = currentTag != tag
                        timerButton.target = self
                        timerButton.tintColor = view?.tintColor
                        timerButton.action = #selector(selectToolbarItem(_:))
                        newItems.insert(timerButton, at: 2 + timer.offset)
                    }
                }
                trashBarButtonItem?.accessibilityHint = String(format: "SLUG-ACC-DELETE-TIMER-BUTTON-FORMAT".accessibilityLocalizedVariant, currentTag)
            } else {
                navigationItem.title = nil
            }
            
            timerSelectionToolbar?.setItems(newItems, animated: false)
            
            trashBarButtonItem?.isEnabled = 1 < _timerBarItems.count
            addBarButtonItem?.isEnabled = Self._maximumNumberOfTimers > _timerBarItems.count
            addBarButtonItem?.accessibilityHint = "SLUG-ACC-ADD-TIMER-BUTTON".accessibilityLocalizedVariant
        }
    }
    
    /* ################################################################## */
    /**
     Called when the add bar button item has been hit.
     - parameter: ignored.
    */
    @objc func selectToolbarItem(_ inToolbarButton: UIBarButtonItem) {
        let tag = inToolbarButton.tag
        guard (1...RVS_AmbiaMara_Settings().numberOfTimers).contains(tag) else { return }
        if hapticsAreAvailable {
            _selectionFeedbackGenerator?.selectionChanged()
            _selectionFeedbackGenerator?.prepare()
        }
        RVS_AmbiaMara_Settings().currentTimerIndex = tag - 1
        setUpToolbar()
    }
    
    /* ################################################################## */
    /**
     Called when the add bar button item has been hit.
     - parameter: ignored.
    */
    @IBAction func addHit(_: Any) {
        if Self._maximumNumberOfTimers > _timerBarItems.count {
            RVS_AmbiaMara_Settings().add(andSelect: true)
            state = .start
            setUpToolbar()
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
            let alertController = UIAlertController(title: "SLUG-DELETE-CONFIRM-HEADER".localizedVariant, message: message, preferredStyle: .alert
            )

            let okAction = UIAlertAction(title: "SLUG-DELETE-BUTTON-TEXT".localizedVariant, style: .destructive, handler: { [weak self] _ in
                if let currentTimer = self?.currentTimer {
                    if self?.hapticsAreAvailable ?? false {
                        self?._impactFeedbackGenerator?.impactOccurred(intensity: CGFloat(UIImpactFeedbackGenerator.FeedbackStyle.rigid.rawValue))
                        self?._impactFeedbackGenerator?.prepare()
                    }
                    RVS_AmbiaMara_Settings().remove(timer: currentTimer)
                }
                self?.setUpToolbar()
                self?.state = .start
                self?.setUpButtons()
            })
            
            alertController.addAction(okAction)

            let cancelAction = UIAlertAction(title: "SLUG-CANCEL-BUTTON-TEXT".localizedVariant, style: .cancel, handler: { [weak self] _ in
                if self?.hapticsAreAvailable ?? false {
                    self?._selectionFeedbackGenerator?.selectionChanged()
                    self?._selectionFeedbackGenerator?.prepare()
                }
            })

            alertController.addAction(cancelAction)

            present(alertController, animated: true, completion: nil)
        }
    }
    
    /* ################################################################## */
    /**
     */
    func setUpButtons() {
        
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

    /* ################################################################## */
    /**
     This makes sure the alarm icon at the top, is the correct one.
    */
    func setAlarmIcon() {
        alarmSetButton?.setImage(UIImage(systemName: RVS_AmbiaMara_Settings().alarmMode ? "bell.fill" : "bell.slash.fill"), for: .normal)
    }

    /* ################################################################## */
    /**
     This shows the about screen.
    */
    func showAboutScreen() {
        performSegue(withIdentifier: Self._aboutViewSegueID, sender: nil)
    }
}

/* ###################################################################################################################################### */
// MARK: UIPageViewControllerDataSource Conformance
/* ###################################################################################################################################### */
extension RVS_SetTimerWrapper: UIPageViewControllerDataSource {
    /* ################################################################## */
    /**
     */
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let ret = storyboard?.instantiateViewController(withIdentifier: RVS_SetTimerAmbiaMara_ViewController.storyboardID) as? RVS_SetTimerAmbiaMara_ViewController
        ret?.container = self
        return ret
    }
    
    /* ################################################################## */
    /**
     */
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let ret = storyboard?.instantiateViewController(withIdentifier: RVS_SetTimerAmbiaMara_ViewController.storyboardID) as? RVS_SetTimerAmbiaMara_ViewController
        ret?.container = self
        return ret
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
 */
class RVS_SetTimerPageViewController: UIPageViewController {
    /* ################################################################## */
    /**
     The storyboard ID, for instantiating the class.
     */
    static let storyboardID = "RVS_SetTimerPageViewController"
}
