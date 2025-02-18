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
     */
    @IBOutlet weak var pageViewContainer: UIView?

    /* ################################################################## */
    /**
     */
    weak var pageViewController: RVS_SetTimerPageViewController?

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var timerSelectionToolbar: UIToolbar?
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
        storyboard?.instantiateViewController(withIdentifier: RVS_SetTimerAmbiaMara_ViewController.storyboardID) as? RVS_SetTimerAmbiaMara_ViewController
    }
    
    /* ################################################################## */
    /**
     */
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        storyboard?.instantiateViewController(withIdentifier: RVS_SetTimerAmbiaMara_ViewController.storyboardID) as? RVS_SetTimerAmbiaMara_ViewController
    }
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
