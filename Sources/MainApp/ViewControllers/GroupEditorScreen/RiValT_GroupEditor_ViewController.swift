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
// MARK: - The Main View Controller for the Matrix of Timers -
/* ###################################################################################################################################### */
/**
 This is the view controller for the "multi-timer" screen, where we can arrange timers in groups and add new ones.

 It allows the user to drag and drop timers, so they can visually rearrange the matrix.
 
 ## BASIC STRUCTURE
 
 This controller displays a [UICollectionView](https://developer.apple.com/documentation/uikit/uicollectionview) instance, filled with vertical rows, representing "timer groups." Each row is a group.
 
 Each group can have up to 4 horizontally-arranged timers. Timers in a group, execute sequentially, from left, to right.
 
 When a timer transitions from a left timer, to the one to its right (the left timer ends, and starts the right timer automatically), a "transition sound" may be played.
 
 When the rightmost timer ends, the "alarm sound" is played.
 
 The user can drag timers around, by long-pressing on a timer. The timer can move within a group, or from one group to another.
 
 Groups can have options specified, that apply to all timers in a group. When a timer is moved from one group to another, it adapts to the group setings for the new group.
 
 ### Timer Selection and Group Selection
 
 One timer must always be selected. This is indicated by a black background, and a colored digital font for the timer value[s].
 
 If a timer is selected, then its group is also selected. Group selection is indicated by a horizontal "gradient" highlight, across the row.
 
 If there is more than one row, or more than one timer in a group, then a number will appear, at the right end of the row selection highlight.
 
 If there is more than one timer in the group, then this number will be a tappable button. Tapping it, will advance the timer selection, wrapping, if at the end.
 
 ## GLOBAL SETTINGS
 
 In the left of the Navigation Bar, is a "gear" icon. This displays a popover, with checkboxes that affect options for the entire app (not just single groups).
 
 ### Start Timer Immediately Checkbox
 
 If this checkbox is checked, then hitting the "Play" triangle will immediately start the timer. If it is unchecked, then the timer will start in a "paused" state, and will require an additional step, to start counting down.
 
 ### "One-Tap" Timer Editing Checkbox
 
 If this checkbox is checked, then simply tapping on a timer, will bring in the Timer Editor Screen for that timer.
 
 If it is unchecked, then tapping on a timer will simply select the timer, and an "Edit" item will appear in the Toolbar, at the bottom of the screen.
 
 That "Edit" item will need to be tapped, to bring in the Timer Editor Screen for whichever timer is selected.
 
 ### Show Toolbar In Timer Checkbox (Not displayed for Mac -Mac always shows the toolbar, and it can't be hidden)
 
 In iPhone and iPad, you can have a toolbar optionally displayed across the bottom of the Running Timer Screen. This toolbar is always shown, for Mac Catalyst.
 
 If the toolbar is shown, then the user must tap on items in the toolbar, to control the timer.
 
 If the toolbar is not shown, then swipe and tap gestures are used to control the running timer (discussed in the Running Timer Screen).
 
 ### Auto-Hide Toolbar Checkbox (Only displayed when "Show Toolbar In Timer" is shown and selected)
 
 If this is selected, then the toolbar will fade out, after a few seconds of user inactivity (the timer keeps going, though). Tapping on the screen, brings the toolbar back.
 
 ### About This App Button
 
 Tapping on this button will dismiss the popover, and bring in the "About This App" Screen.
 
 ## GROUP SETTINGS
 
 In the top, right of the Navigation Bar, are two items: A little "screen" icon, representing the current display mode for the group, and a "clock" icon, representing the final alarm state for the group.
 
 These apply to the currently selected group, and may change, to reflect the current group's setting.
 
 ### Display Type
 
 Tapping on the Display icon, brings up a popover, allowing the user to select the type of Running Timer Display to be used for the group. It is a simple popover, with a segmented switch, and a preview area, under it, showing the display type.
 
 ### Sounds
 
 Tapping on the sound icon, will bring up a ppopver, allowing the user to choose a final alarm sound, and, optionally, a transition sound (only shown, when there is more than one timer in the group).
 
 This popover is a bit more complex than the Display Popover, as it has a segmented switch, allowing the user to choose the type of alarm to use, at the end of the countdown, an optional picker, for selecting a sound, and, optionally, a second picker, allowing the user to select a transition sound.
 
 ## TOOLBAR
 
 There's a toolbar, displayed at the bottom of the screen, that affects the selected timer.
 
 ### Delete Button (Trash Can Icon)
 
 Selecting this, will bring up a confirmation alert, asking if you really want to delete the timer. If you confirm, the timer is deleted, and the next one is selected.
 
 ### Play Button (Triangle)
 
 Selecting this, starts the selected timer (goes directly to the Running Timer Screen).
 
 ### Edit Button (Optional)
 
 This is only displayed, if "One-Tap Edit" is off. Selecting it, opens the Timer Editor Screen for the selected timer.
 */
class RiValT_GroupEditor_ViewController: RiValT_Base_ViewController {
    /* ############################################################## */
    /**
     The width of the "gutters" around each cell.
     */
    private static let _itemGuttersInDisplayUnits = CGFloat(4)
    
    /* ############################################################## */
    /**
     The ID of the segue to edit a timer.
     */
    private static let _timerEditSegueID = "edit-timer"
    
    /* ############################################################## */
    /**
     The storyboard ID for instantiating the class.
     */
    private static let _aboutScreenSegueID = "show-about"

    /* ############################################################## */
    /**
     Used to track scrolling, and to prevent horizontal scroll.
     */
    private var _initialContentOffset: CGPoint = .zero

    /* ############################################################## */
    /**
     This is set to true, if we want to override the pref.
     */
    var forceStart: Bool = false
    
    /* ############################################################## */
    /**
     Maintains the last scroll position, for iterating a row.
     */
    private var _lastScrollPos = CGPoint.zero

    /* ############################################################## */
    /**
     The settings button, in the navbar.
     */
    @IBOutlet weak var settingsBarButtonItem: UIBarButtonItem?

    /* ############################################################## */
    /**
     The main collection view.
     */
    @IBOutlet weak var collectionView: UICollectionView?
    
    /* ############################################################## */
    /**
     The toolbar at the bottom of the screen.
     */
    @IBOutlet weak var toolbar: UIToolbar?

    /* ############################################################## */
    /**
     The trash button in the toolbar.
     */
    @IBOutlet weak var toolbarDeleteButton: UIBarButtonItem?

    /* ############################################################## */
    /**
     The "Play" (start) button in the toolbar.
     */
    @IBOutlet weak var toolbarPlayButton: UIBarButtonItem?

    /* ############################################################## */
    /**
     The edit button in the toolbar.
     */
    @IBOutlet weak var toolbarEditButton: UIBarButtonItem?
    
    /* ############################################################## */
    /**
     This is the datasource for the collection view. We manage it dynamically.
     */
    var dataSource: UICollectionViewDiffableDataSource<Int, RiValT_TimerArray_Placeholder>?

    /* ############################################################## */
    /**
     Used to prevent overeager haptics.
     */
    var lastIndexPath: IndexPath?
    
    /* ############################################################## */
    /**
     This allows us to force-close the popover, easily.
     */
    weak var currentPopover: UIPopoverPresentationController?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RiValT_GroupEditor_ViewController {
    /* ############################################################## */
    /**
     Called when the view has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        RiValT_AppDelegate.appDelegateInstance?.groupEditorController = self
        let appearance = UIToolbarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.backgroundImage = nil
        self.toolbar?.standardAppearance = appearance
        self.toolbar?.scrollEdgeAppearance = appearance
        self.collectionView?.isDirectionalLockEnabled = true
        self.navigationItem.backButtonTitle = "SLUG-TIMERS-BACK".localizedVariant
        self.settingsBarButtonItem?.image = UIImage(systemName: "gear")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 30, weight: .bold))
        self.settingsBarButtonItem?.accessibilityLabel = "SLUG-ACC-SETTINGS-BUTTON-LABEL".localizedVariant
        self.settingsBarButtonItem?.accessibilityHint = "SLUG-ACC-SETTINGS-BUTTON-HINT".localizedVariant
        self.toolbarDeleteButton?.accessibilityIdentifier = "targetItem"
        self.toolbarDeleteButton?.accessibilityLabel = "SLUG-ACC-TOOLBAR-DELETE-LABEL".localizedVariant
        self.toolbarDeleteButton?.accessibilityHint = "SLUG-ACC-TOOLBAR-DELETE-HINT".localizedVariant
        self.toolbarPlayButton?.accessibilityLabel = "SLUG-ACC-TOOLBAR-PLAY-LABEL".localizedVariant
        self.toolbarPlayButton?.accessibilityHint = "SLUG-ACC-TOOLBAR-PLAY-HINT".localizedVariant
        self.toolbarEditButton?.accessibilityLabel = "SLUG-ACC-TOOLBAR-EDIT-LABEL".localizedVariant
        self.toolbarEditButton?.accessibilityHint = "SLUG-ACC-TOOLBAR-EDIT-HINT".localizedVariant
    }

    /* ############################################################## */
    /**
     Called just before the view appears.
     
     We use the opportunity to switch to the editor, if we have just one timer, and this is the first time through.
     
     - parameter inIsAnimated: True, if the appearance is animated.
     */
    override func viewWillAppear(_ inIsAnimated: Bool) {
        super.viewWillAppear(inIsAnimated)
        self.navigationController?.isNavigationBarHidden = false
        self.checkForFastForward()
    }

    /* ############################################################## */
    /**
     Called just after the view appeared.
     
     - parameter inIsAnimated: True, if the appearance is animated.
     */
    override func viewDidAppear(_ inIsAnimated: Bool) {
        super.viewDidAppear(inIsAnimated)
        self.watchDelegate?.sendApplicationContext()
        if .zero == self._lastScrollPos,
           let collectionView = self.collectionView,
           let selectedSectionIndex = self.timerModel?.selectedTimer?.indexPath {
            collectionView.scrollToItem(at: selectedSectionIndex, at: .bottom, animated: false)
            self._lastScrollPos = collectionView.contentOffset
        }
    }

    /* ############################################################## */
    /**
     Called just before the view disappears.
     
     - parameter inIsAnimated: True, if the disappearance is animated.
     */
    override func viewWillDisappear(_ inIsAnimated: Bool) {
        RiValT_Settings.ephemeralFirstTime = false
        self._lastScrollPos = collectionView?.contentOffset ?? .zero
        super.viewWillDisappear(inIsAnimated)
    }
    
    /* ############################################################## */
    /**
     Called when the view lays out its view hierarchy.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupDataSource()
        self.createLayout()
        self.updateSnapshot()
        self.watchDelegate?.updateSettings()
        if .zero != self._lastScrollPos {
            self.collectionView?.setContentOffset(self._lastScrollPos, animated: false)
        } else if let collectionView = self.collectionView,
                  let selectedSectionIndex = self.timerModel?.selectedTimer?.indexPath {
            collectionView.scrollToItem(at: selectedSectionIndex, at: .centeredVertically, animated: false)
            self._lastScrollPos = collectionView.contentOffset
        }
    }

    /* ################################################################## */
    /**
     Called to allow us to do something when we change layout size (like rotating)
     
     - parameter inSize: The new size
     - parameter inCoordinator: The coordinator object.
     */
    override func viewWillTransition(to inSize: CGSize, with inCoordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: inSize, with: inCoordinator)
        self.currentPopover?.presentedViewController.dismiss(animated: true)
        self.currentPopover = nil
    }
    
    /* ################################################################## */
    /**
     Called to allow us to do something before dismissing a popover.
     
     - parameter: ignored.
     
     - returns: True (all the time).
     */
    override func popoverPresentationControllerShouldDismissPopover(_: UIPopoverPresentationController) -> Bool {
        self.setUpNavBarItems()
        self.currentPopover = nil
        return true
    }
    
    /* ################################################################## */
    /**
     Called to allow us to do something before displaying a popover.
     
     - parameter inController: The popover controller about to be displayed.
     */
    override func prepareForPopoverPresentation(_ inController: UIPopoverPresentationController) {
        self.currentPopover = inController
    }
    
    /* ############################################################## */
    /**
     Called when we are to segue to another view controller.

     - parameter inSegue: The segue instance.
     - parameter inData: An opaque parameter with any associated data.
     */
    override func prepare(for inSegue: UIStoryboardSegue, sender inData: Any?) {
        if let destination = inSegue.destination as? RiValT_RunningTimer_ContainerViewController,
           let timer = inData as? Timer {
            destination.timer = timer
            destination.forceStart = self.forceStart
        } else if let destination = inSegue.destination as? RiValT_TimerEditor_PageViewContainer,
                  let optionalString = inData as? String,
                  !optionalString.isEmpty {
            destination.optionalTitle = optionalString
        }
        
        self.forceStart = false
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RiValT_GroupEditor_ViewController {
    /* ############################################################## */
    /**
     This simply opens the about this app screen.
     */
    func openAboutScreen() {
        self.performSegue(withIdentifier: Self._aboutScreenSegueID, sender: nil)
    }
    
    /* ############################################################## */
    /**
     We set up the navbar buttons.
     */
    func setUpNavBarItems() {
        let soundSettingsButtonItem = SoundBarButtonItem()
        soundSettingsButtonItem.isAccessibilityElement = true
        soundSettingsButtonItem.accessibilityLabel = "SLUG-ACC-SOUND-SETTINGS-BUTTON-LABEL".localizedVariant
        soundSettingsButtonItem.accessibilityHint = "SLUG-ACC-SOUND-SETTINGS-BUTTON-HINT".localizedVariant
        soundSettingsButtonItem.group = self.timerModel.selectedTimer?.group
        soundSettingsButtonItem.target = self
        soundSettingsButtonItem.action = #selector(soundSettingsButtonHit)
        let displaySettingsButtonItem = DisplayBarButtonItem()
        displaySettingsButtonItem.isAccessibilityElement = true
        displaySettingsButtonItem.accessibilityLabel = "SLUG-ACC-DISPLAY-SETTINGS-BUTTON-LABEL".localizedVariant
        displaySettingsButtonItem.accessibilityHint = "SLUG-ACC-DISPLAY-SETTINGS-BUTTON-HINT".localizedVariant
        displaySettingsButtonItem.group = self.timerModel.selectedTimer?.group
        displaySettingsButtonItem.target = self
        displaySettingsButtonItem.action = #selector(displaySettingsButtonHit)
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.rightBarButtonItems = [soundSettingsButtonItem, UIBarButtonItem.flexibleSpace(), displaySettingsButtonItem]
    }

    /* ############################################################## */
    /**
     If the first time through, and we only have one timer, we go straight to the editor.
     */
    func checkForFastForward() {
        let wasFirstTime = RiValT_Settings.ephemeralFirstTime
        RiValT_Settings.ephemeralFirstTime = false
        if wasFirstTime,
           2 > self.navigationController?.viewControllers.count ?? 0,
           1 == timerModel.allTimers.count {
            self.goEditYourself()
        }
    }

    /* ############################################################## */
    /**
     This establishes the display layout for our collection view.
     
     Each group of timers is a row, with up to 4 timers each.
     
     At the end of rows with less than 4 timers, or at the end of the collection view, we have "add" items.
     */
    func createLayout() {
        let layout = UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
            // The reason for the weird width, is to prevent the end "add" item from vertically flowing.
            // This only happens, if there are 3 items already there, and a new item is being dragged in from another group.
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.5),
                                                   heightDimension: .absolute(RiValT_BaseCollectionCell.itemSize.heightDimension.dimension + 1)
            )

            let item = NSCollectionLayoutItem(layoutSize: RiValT_TimerArray_IconCell.itemSize)

            item.contentInsets = NSDirectionalEdgeInsets(top: Self._itemGuttersInDisplayUnits + 1,
                                                         leading: Self._itemGuttersInDisplayUnits + 1,
                                                         bottom: Self._itemGuttersInDisplayUnits,
                                                         trailing: Self._itemGuttersInDisplayUnits
            )
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            section.decorationItems = [.background(elementKind: SectionBackgroundView.reuseIdentifier)]
            
            return section
        }
        
        layout.register(SectionBackgroundView.self, forDecorationViewOfKind: SectionBackgroundView.reuseIdentifier)
        
        self.collectionView?.collectionViewLayout = layout
    }
    
    /* ############################################################## */
    /**
     This sets up the data source cells.
     */
    func setupDataSource() {
        guard let collectionView = self.collectionView else { return }
        self.dataSource = UICollectionViewDiffableDataSource<Int, RiValT_TimerArray_Placeholder>(collectionView: collectionView) { [self] inCollectionView, inIndexPath, _ in
            var ret = UICollectionViewCell()
            
            // If this cell has a timer, we create a timer cell.
            if let timer = self.timerModel.getTimer(at: inIndexPath),
               let cell = inCollectionView.dequeueReusableCell(withReuseIdentifier: RiValT_TimerArray_IconCell.reuseIdentifier, for: inIndexPath) as? RiValT_TimerArray_IconCell {
                cell.configure(with: timer, indexPath: inIndexPath, myController: self)
                cell.isAccessibilityElement = true
                cell.accessibilityLabel = String(format: "SLUG-ACC-COLLECTION-TIMER-FORMAT-LABEL".localizedVariant, inIndexPath.item, inIndexPath.section)
                cell.accessibilityHint = "SLUG-ACC-COLLECTION-TIMER-HINT".localizedVariant
                ret = cell
            // Otherwise, we create an add cell.
            } else if let cell = inCollectionView.dequeueReusableCell(withReuseIdentifier: RiValT_TimerArray_AddCell.reuseIdentifier, for: inIndexPath) as? RiValT_TimerArray_AddCell {
                cell.configure(indexPath: inIndexPath, myController: self)
                ret = cell
            }
            
            return ret
        }
        
        collectionView.dataSource = self.dataSource
    }

    /* ############################################################## */
    /**
     This updates the collection view snapshot.
     */
    func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, RiValT_TimerArray_Placeholder>()
        for (sectionIndex, group) in self.timerModel.enumerated() {
            snapshot.appendSections([sectionIndex])
            snapshot.appendItems(group.allTimers.map { RiValT_TimerArray_Placeholder(timer: $0) }, toSection: sectionIndex)
            if !group.isFull {
                snapshot.appendItems([RiValT_TimerArray_Placeholder()], toSection: sectionIndex)
            }
        }
        
        let lastSection = timerModel.count
        snapshot.appendSections([lastSection])
        snapshot.appendItems([RiValT_TimerArray_Placeholder()], toSection: lastSection)

        self.dataSource?.apply(snapshot, animatingDifferences: false)
        self.updateToolbar()
        self.setUpNavBarItems()
    }
    
    /* ############################################################## */
    /**
     This updates the items in the toolbar.
     */
    func updateToolbar() {
        self.toolbarDeleteButton?.isEnabled = false
        self.toolbarPlayButton?.isEnabled = false
        self.toolbarEditButton?.isEnabled = false
        guard let timer = self.timerModel.selectedTimer else { return }
        self.toolbarDeleteButton?.isEnabled = 1 < self.timerModel.allTimers.count
        self.toolbarPlayButton?.isEnabled = 0 < timer.startingTimeInSeconds
        self.toolbarPlayButton?.image = UIImage(systemName: 0 < timer.startingTimeInSeconds ? "play.fill" : "play.slash")
        self.toolbarEditButton?.isEnabled = !RiValT_Settings().oneTapEditing
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension RiValT_GroupEditor_ViewController {
    /* ############################################################## */
    /**
     Called when the toolbar delete timer button is hit.
     
     - parameter: ignored.
     */
    @IBAction func toolbarDeleteButtonHit(_: Any) {
        func _executeDelete() {
            guard let timer = self.timerModel.selectedTimer,
                  let indexPath = timer.indexPath,
                  1 < self.timerModel.allTimers.count
            else { return }
            
            self.timerModel.removeTimer(from: indexPath)

            if let timer = self.timerModel.selectedTimer,
               let indexPath = timer.indexPath,
               let collectionView = self.collectionView {
                let oldValue = RiValT_Settings().oneTapEditing
                RiValT_Settings().oneTapEditing = false
                self.collectionView(collectionView, didSelectItemAt: IndexPath(item: indexPath.item, section: indexPath.section))
                RiValT_Settings().oneTapEditing = oldValue
                self.watchDelegate?.sendApplicationContext()
            }
        }
        
        let messageText = "SLUG-DELETE-CONFIRM-MESSAGE"
        
        let alertController = UIAlertController(title: "SLUG-DELETE-CONFIRM-HEADER", message: messageText, preferredStyle: .alert)
        
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
     Called when the "Play" button is hit.
     
     - parameter: ignored (and can be omitted).
     */
    @IBAction func toolbarPlayButtonHit(_: UIBarButtonItem! = nil) {
        self.impactHaptic()
        self.watchDelegate.sendCommand(command: .start)
        self.performSegue(withIdentifier: RiValT_RunningTimer_ContainerViewController.segueID, sender: self.timerModel.selectedTimer)
    }
    
    /* ############################################################## */
    /**
     Called when the Watch wants us to play.
     */
    func remotePlay() {
        self.forceStart = true
        self.performSegue(withIdentifier: RiValT_RunningTimer_ContainerViewController.segueID, sender: self.timerModel.selectedTimer)
    }

    /* ############################################################## */
    /**
     Called when the "Edit" button is hit.
     
     - parameter: ignored.
     */
    @IBAction func toolbarEditButtonHit(_: Any! = nil) {
        self.impactHaptic()
        self.goEditYourself()
    }
    
    /* ############################################################## */
    /**
     Called to segue to the editor screen.
     */
    func goEditYourself(optionalTitle inTitle: String? = nil) {
        self.performSegue(withIdentifier: Self._timerEditSegueID, sender: inTitle)
    }

    /* ############################################################## */
    /**
     The sound settings button was hit.
     
     - parameter: ignored.
     */
    @IBAction func soundSettingsButtonHit(_ inBarButtonItem: UIBarButtonItem) {
        self.impactHaptic()
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: RiValT_SoundSettings_ViewController.storyboardID) as? RiValT_SoundSettings_ViewController else { return }
        controller.group = self.timerModel.selectedTimer?.group
        controller.modalPresentationStyle = .popover
        controller.popoverPresentationController?.delegate = self
        controller.popoverPresentationController?.barButtonItem = inBarButtonItem
        self.present(controller, animated: true, completion: nil)
    }

    /* ############################################################## */
    /**
     The dsiplay settings button was hit.
     
     - parameter: ignored.
     */
    @IBAction func displaySettingsButtonHit(_ inBarButtonItem: UIBarButtonItem) {
        self.impactHaptic()
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: RiValT_DisplaySettings_ViewController.storyboardID) as? RiValT_DisplaySettings_ViewController else { return }
        controller.group = self.timerModel.selectedTimer?.group
        controller.modalPresentationStyle = .popover
        controller.popoverPresentationController?.delegate = self
        controller.popoverPresentationController?.barButtonItem = inBarButtonItem
        self.present(controller, animated: true, completion: nil)
    }

    /* ############################################################## */
    /**
     The main settings button was hit.
     
     - parameter: ignored.
     */
    @IBAction func settingsButtonHit(_ inBarButtonItem: UIBarButtonItem) {
        self.impactHaptic()
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: RiValT_Settings_ViewController.storyboardID) as? RiValT_Settings_ViewController else { return }
        controller.modalPresentationStyle = .popover
        controller.popoverPresentationController?.delegate = self
        controller.popoverPresentationController?.barButtonItem = inBarButtonItem
        self.present(controller, animated: true, completion: nil)
    }
    
    /* ############################################################## */
    /**
     The background of a group line was hit.
     
     - parameter inTapGesture: The tap that caused the call.
     */
    @objc func groupBackgroundTapped(_ inTapGesture: UITapGestureRecognizer) {
        if let backgroundView = inTapGesture.view as? SectionBackgroundView,
           let collectionView = self.collectionView,
           let group = backgroundView.myGroup,
           let groupIndex = group.index,
           (0..<(self.timerModel?.count ?? 0)).contains(groupIndex),
           !group.isSelected {
            group.first?.isSelected = true
            let oldValue = RiValT_Settings().oneTapEditing
            RiValT_Settings().oneTapEditing = false
            self.collectionView(collectionView, didSelectItemAt: IndexPath(item: 0, section: groupIndex))
            RiValT_Settings().oneTapEditing = oldValue
            self.watchDelegate?.sendApplicationContext()
        }
    }
    
    /* ############################################################## */
    /**
     The number at the end of a group was hit.
     
     - parameter inTapGesture: The tap that caused the call.
     */
    @objc func groupBackgroundNumberTapped(_ inTapGesture: UITapGestureRecognizer) {
        if let group = self.timerModel.selectedTimer?.group,
           1 < group.count {
            var currentSelectedIndex = -1
            
            group.forEach { inTimer in
                if inTimer.isSelected,
                   let index = inTimer.indexPath?.item {
                    currentSelectedIndex = index < (group.count - 1) ? index : -1
                }
            }
            
            currentSelectedIndex += 1
            
            group[currentSelectedIndex].isSelected = true
            if let collectionView = self.collectionView,
               let groupIndex = group.index {
                let oldValue = RiValT_Settings().oneTapEditing
                RiValT_Settings().oneTapEditing = false
                self.collectionView(collectionView, didSelectItemAt: IndexPath(item: currentSelectedIndex, section: groupIndex))
                RiValT_Settings().oneTapEditing = oldValue
                self.watchDelegate?.sendApplicationContext()
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: UICollectionViewDragDelegate Conformance
/* ###################################################################################################################################### */
extension RiValT_GroupEditor_ViewController: UICollectionViewDragDelegate {
    /* ############################################################## */
    /**
     Called when a drag starts.
     
     This allows us to configure the "drag preview."
     
     - parameter inCollectionView: The collection view.
     - parameter inIndexPath: The index path of the item being dragged.
     
     - returns: The drag parameters, or nil, if the item can't be dragged.
     */
    func collectionView(_ inCollectionView: UICollectionView,
                        dragPreviewParametersForItemAt inIndexPath: IndexPath) -> UIDragPreviewParameters? {
        if let cell = inCollectionView.cellForItem(at: inIndexPath) {
            let parameters = UIDragPreviewParameters()
            parameters.backgroundColor = .clear
            parameters.backgroundColor = .clear
            parameters.visiblePath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.cornerRadius)
            parameters.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.cornerRadius)
            return parameters
        }
        
        return nil
    }

    /* ############################################################## */
    /**
     Called when a drag starts.
     
     If the item can't be dragged (the "add" items, or the timer, if there is only one), then an empty array is returned.

     - parameter inCollectionView: The collection view.
     - parameter inSession: The session for the drag.
     - parameter inIndexPath: The index path of the item being dragged.
     
     - returns: The wrapper item for the drag.
     */
    func collectionView(_ inCollectionView: UICollectionView,
                        itemsForBeginning inSession: UIDragSession,
                        at inIndexPath: IndexPath
    ) -> [UIDragItem] {
        guard 1 < self.timerModel.allTimers.count,
              self.timerModel.isValid(indexPath: inIndexPath)
        else { return [] }
        self.lastIndexPath = inIndexPath
        inSession.localContext = inIndexPath
        self.timerModel.selectTimer(inIndexPath)
        self.impactHaptic(1.0)
        inCollectionView.reloadData()
        let timer = self.timerModel[indexPath: inIndexPath]
        let provider = NSItemProvider(object: timer.id.uuidString as NSString)
        let dragItem = UIDragItem(itemProvider: provider)
        dragItem.localObject = timer

        return [dragItem]
    }
}

/* ###################################################################################################################################### */
// MARK: UICollectionViewDropDelegate Conformance
/* ###################################################################################################################################### */
extension RiValT_GroupEditor_ViewController: UICollectionViewDropDelegate {
    /* ############################################################## */
    /**
     Called to vet the current drag state.
     
     - parameter inCollectionView: The collection view (ignored).
     - parameter inSession: The session for the drag.
     - parameter inIndexPath: The index path of the item being dragged.
     
     - returns: the disposition proposal for the drag.
     */
    func collectionView(_ inCollectionView: UICollectionView,
                        dropSessionDidUpdate inSession: UIDropSession,
                        withDestinationIndexPath inIndexPath: IndexPath?
    ) -> UICollectionViewDropProposal {
        if let sourceIndexPath = inSession.localDragSession?.localContext as? IndexPath,
           let destinationIndexPath = inIndexPath,
           self.timerModel.canInsertTimer(at: destinationIndexPath, from: sourceIndexPath) {
            if self.lastIndexPath != inIndexPath {
                self.selectionHaptic()
                self.lastIndexPath = inIndexPath
            }
            
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        } else {
            return UICollectionViewDropProposal(operation: .cancel)
        }
    }

    /* ############################################################## */
    /**
     Called when the drag ends, with a plop.
     
     - parameter inCollectionView: The collection view.
     - parameter inCoordinator: The drop coordinator.
     */
    func collectionView(_ inCollectionView: UICollectionView,
                        performDropWith inCoordinator: UICollectionViewDropCoordinator
    ) {
        guard let sourceIndexPath = inCoordinator.session.localDragSession?.localContext as? IndexPath,
              let destinationIndexPath = inCoordinator.destinationIndexPath,
              sourceIndexPath != destinationIndexPath
        else { return }

        self.lastIndexPath = nil
        self.impactHaptic(1.0)
        self.timerModel.moveTimer(from: sourceIndexPath, to: destinationIndexPath)
        self.updateSnapshot()
    }
}

/* ###################################################################################################################################### */
// MARK: UICollectionViewDelegate Conformance
/* ###################################################################################################################################### */
extension RiValT_GroupEditor_ViewController: UICollectionViewDelegate {
    /* ############################################################## */
    /**
     Called when an item in the collection view is tapped.
     
     - parameter inCollectionView: The collection view.
     - parameter inIndexPath: The index path of the item being tapped.
     */
    func collectionView(_ inCollectionView: UICollectionView,
                        didSelectItemAt inIndexPath: IndexPath
    ) {
        var shouldScroll = false
        var shouldEdit = RiValT_Settings().oneTapEditing
        var optionalTitle: String?

        self._lastScrollPos = inCollectionView.contentOffset

        if (inIndexPath.section == self.timerModel?.count ?? 0) || (self.timerModel?[inIndexPath.section].isSelected ?? false),
           nil == self.timerModel.getTimer(at: inIndexPath) {
            self.timerModel.createNewTimer(at: inIndexPath)
            self.impactHaptic(1.0)
            shouldScroll = true
            shouldEdit = true
            optionalTitle = "SLUG-NEW-TIMER".localizedVariant
            self._lastScrollPos = .zero
        } else if (0..<(self.timerModel?.count ?? 0)).contains((inIndexPath.section)),
                  !(self.timerModel?[inIndexPath.section].isSelected ?? false) {
            self.timerModel?[inIndexPath.section].first?.isSelected = true
            self.watchDelegate?.sendApplicationContext()
            self.impactHaptic()
            shouldEdit = shouldEdit && nil != self.timerModel.getTimer(at: inIndexPath)
        } else {
            self.impactHaptic()
        }
        
        if !(self.timerModel.getTimer(at: inIndexPath)?.isSelected ?? false) {
            self.timerModel.getTimer(at: inIndexPath)?.isSelected = true
            self.watchDelegate?.sendApplicationContext()
        }
        
        self.updateSettings()
        self.updateSnapshot()
        inCollectionView.reloadData()
                
        if shouldScroll {
            inCollectionView.scrollToItem(at: IndexPath(item: 0, section: self.timerModel.count), at: .top, animated: true)
        }
        
        if shouldEdit {
            self.goEditYourself(optionalTitle: optionalTitle)
        }
    }
    
    /* ############################################################## */
    /**
     Called when the collection view has been rebuilt, and we need to check the scroll position.
     
     We use this to reset the offset.
     
     - parameter inCollectionView: The collection view.
     - parameter inOffset: The current offset.
     */
    func collectionView(_ inCollectionView: UICollectionView, targetContentOffsetForProposedContentOffset inOffset: CGPoint) -> CGPoint {
        if .zero != self._lastScrollPos {
            inCollectionView.setContentOffset(self._lastScrollPos, animated: false)
        }
        return self._lastScrollPos
    }
}

/* ###################################################################################################################################### */
// MARK: UIScrollViewDelegate Conformance
/* ###################################################################################################################################### */
/**
 The reason for this extension, is simply to prevent the collection view from scrolling horizontally.
 
 We define the area to be wider than the display, in order to prevent vertical "reflowing," when we get to 3 items, and another item is dragged in,
 but we don't want the user to be able to scroll out of the display.
 */
extension RiValT_GroupEditor_ViewController: UIScrollViewDelegate {
    /* ############################################################## */
    /**
     Called when a scroll begins.
     
     - parameter inScrollView: The collection view (as a scroll view).
     */
    func scrollViewWillBeginDragging(_ inScrollView: UIScrollView) {
        self._initialContentOffset = inScrollView.contentOffset
    }
    
    /* ############################################################## */
    /**
     Called when a scroll actually happens.
     
     - parameter inScrollView: The collection view (as a scroll view).
     */
    func scrollViewDidScroll(_ inScrollView: UIScrollView) {
        inScrollView.contentOffset.x = self._initialContentOffset.x
        self._lastScrollPos = inScrollView.contentOffset
    }
}
