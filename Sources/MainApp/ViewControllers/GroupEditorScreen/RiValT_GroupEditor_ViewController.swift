/*
 © Copyright 2018-2026, The Great Rift Valley Software Company. All rights reserved.
 
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
 Long-pressing the space around the timers selects that row and lifts the whole group for vertical reordering.
 
 Groups can have options specified, that apply to all timers in a group. When a timer is moved from one group to another, it adapts to the group setings for the new group.
 
 ### Timer Selection and Group Selection
 
 One timer must always be selected. This is indicated by a black background, and a colored digital font for the timer value[s].
 
 If a timer is selected, then its group is also selected. Group selection is indicated by a horizontal "gradient" highlight, across the row.
 
 If there is more than one row, or more than one timer in a group, then a number will appear, at the right end of the row selection highlight.
 
 When Combine Timers is off and the group has multiple timers, tapping this number selects the next timer, wrapping to the first after the last.
 
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

    /// Distance from an existing row boundary at which to preview a new row.
    private static let _insertionSnapDistance = CGFloat(12)
    
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

    /** A proposed new group, expressed in the unchanged model's section coordinates. */
    private(set) var insertionPreviewSection: Int?
    /// The temporary view that marks where dropping a timer will create a group.
    private var _insertionPreviewView: UIView?
    /// The insertion preview's frame in collection view coordinates.
    private var _insertionPreviewFrame = CGRect.zero
    /// Lets a timer cross a row boundary before opening space for a new group.
    private var _insertionPreviewTask: Task<Void, Never>?

    /** The displayed number includes the uncommitted insertion, if any. */
    func displayedGroupNumber(for inSection: Int) -> Int {
        inSection + 1 + ((self.insertionPreviewSection.map { inSection >= $0 }) == true ? 1 : 0)
    }

    /** Opens or closes a row without adding anything to the timer model or snapshot. */
    private func setInsertionPreview(_ inSection: Int?) {
        guard self.insertionPreviewSection != inSection,
              let collectionView = self.collectionView else { return }
        self.insertionPreviewSection = inSection
        self._insertionPreviewView?.removeFromSuperview()
        self._insertionPreviewView = nil
        self._insertionPreviewFrame = .zero
        self.createLayout()
        collectionView.layoutIfNeeded()
        guard let section = inSection,
              let attributes = collectionView.layoutAttributesForItem(at: IndexPath(item: 0, section: section)) else { return }
        let height = RiValT_BaseCollectionCell.itemSize.heightDimension.dimension + 1
        let frame = CGRect(x: 0, y: attributes.frame.minY - height - Self._itemGuttersInDisplayUnits - 1,
                           width: collectionView.bounds.width, height: height)
        self._insertionPreviewFrame = frame
        let preview = UIView(frame: frame.insetBy(dx: 4, dy: 2))
        preview.backgroundColor = self.view.tintColor.withAlphaComponent(0.18)
        preview.layer.cornerRadius = SectionBackgroundView.rowCornerRadius
        preview.layer.borderWidth = 2
        preview.layer.borderColor = self.view.tintColor.cgColor
        preview.isUserInteractionEnabled = false
        let number = UILabel(frame: CGRect(x: preview.bounds.width - 40, y: 0, width: 40, height: preview.bounds.height))
        number.font = .systemFont(ofSize: 30)
        number.text = " \(section + 1) "
        number.textColor = .label
        preview.addSubview(number)
        collectionView.addSubview(preview)
        self._insertionPreviewView = preview
    }

    /** Records the accepted destination and gives one selection tick per snap. */
    private func updateDropPosition(_ inPosition: DropPosition?) {
        guard self._dropPosition != inPosition else { return }
        self._dropPosition = inPosition
        self._insertionPreviewTask?.cancel()
        self._insertionPreviewTask = nil
        if case .newGroup(let section) = inPosition {
            self._insertionPreviewTask = Task { [weak self] in
                try? await Task.sleep(for: .milliseconds(180))
                guard let self, !Task.isCancelled else { return }
                self._insertionPreviewTask = nil
                self.setInsertionPreview(section)
                self.giveDropFeedback(at: .newGroup(section))
            }
            return
        }
        if let collectionView = self.collectionView {
            collectionView.collectionViewLayout.invalidateLayout()
            UIView.animate(withDuration: 0.18, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction]) {
                collectionView.layoutIfNeeded()
            }
        }
        if let inPosition { self.giveDropFeedback(at: inPosition) }
    }

    /// Gives feedback only when the preview snaps to a different position.
    private func giveDropFeedback(at inPosition: DropPosition) {
        guard self._lastDropPosition != inPosition else { return }
        self._lastDropPosition = inPosition
        self.selectionHaptic()
    }

    /** Tests row boundaries in the layout without the insertion gap. */
    private func insertionSection(at inLocation: CGPoint, source inSource: IndexPath) -> Int? {
        if let section = self.insertionPreviewSection,
           self._insertionPreviewFrame.insetBy(dx: 0, dy: -Self._insertionSnapDistance).contains(inLocation) {
            return section
        }
        self.setInsertionPreview(nil)
        guard self.timerModel.count > 1 else { return nil }
        for section in 1..<self.timerModel.count {
            guard let attributes = self.collectionView?.layoutAttributesForItem(at: IndexPath(item: 0, section: section)) else { continue }
            let boundary = attributes.frame.minY - Self._itemGuttersInDisplayUnits - 1
            // A single-timer row moved to either adjacent boundary would leave the order unchanged.
            if self.timerModel[inSource.section].count == 1,
               section == inSource.section || section == inSource.section + 1 { continue }
            if abs(inLocation.y - boundary) < Self._insertionSnapDistance { return section }
        }
        return nil
    }

    /// Resolves a timer slot from the row and the original column centers, which stay fixed during a nudge.
    private func timerDropPosition(at inLocation: CGPoint, from inSource: TimerDragSource) -> DropPosition? {
        guard let section = (0...self.timerModel.count).first(where: { self.groupFrame(at: $0)?.contains(inLocation) == true }) else { return nil }
        if section == self.timerModel.count {
            return .timer(IndexPath(item: 0, section: section))
        }
        let count = self.timerModel[section].count
        let lastSlot = section == inSource.indexPath.section ? count - 1 : count
        let column = Int(((inLocation.x - inSource.firstColumnCenter) / inSource.columnSpacing).rounded())
        let destination = IndexPath(item: min(lastSlot, max(0, column)), section: section)
        guard self.timerModel.canInsertTimer(at: destination, from: inSource.indexPath) else { return nil }
        return .timer(destination)
    }

    /* ############################################################## */
    /**
     This is set to true, if we want to override the pref.
     */
    var forceStart: Bool = false

    /** Recognizes row starts before any single-tap action is delivered. */
    var rowDoubleTapRecognizer: UITapGestureRecognizer?
    
    /* ############################################################## */
    /// The saved scroll position, if one has been established.
    private var _lastScrollPos: CGPoint?

    /* ############################################################## */
    /**
     The settings button, in the navbar.
     */
    @IBOutlet weak var settingsBarButtonItem: UIBarButtonItem?

    /* ############################################################## */
    /// The selected group's summary, overlaid on the scrolling timer matrix.
    @IBOutlet private weak var groupSummaryLabel: UILabel?

    /// Backdrops for the scrolling rows beneath the summary and toolbar.
    private let _headerBlur = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    private let _toolbarBlur = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    private let _headerBlurTint = CAGradientLayer()
    private let _toolbarBlurTint = CAGradientLayer()

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
    @IBOutlet weak var toolbarEditButton: RiValT_DisappearingBarButton?

    /* ############################################################## */
    /**
     This is the datasource for the collection view. We manage it dynamically.
     */
    var dataSource: UICollectionViewDiffableDataSource<Int, RiValT_TimerArray_Placeholder>?

    /* ############################################################## */
    /**
     Identifies each kind of snap position, including an uncommitted new row.
     */
    private enum DropPosition: Equatable {
        /// A drop position within an existing group.
        case timer(IndexPath)
        /// An insertion boundary where the drop would create a group.
        case newGroup(Int)
    }

    /// The starting position and column geometry, before any cells have moved.
    private struct TimerDragSource {
        let indexPath: IndexPath
        let firstColumnCenter: CGFloat
        let columnSpacing: CGFloat
    }

    /// The local timer drag session and its currently accepted destination.
    private weak var _timerDragSession: UIDragSession?
    private var _dropPosition: DropPosition?

    /// Keeps the original cell hidden while UIKit displays the lifted timer.
    private var _liftedTimerIndexPath: IndexPath? {
        didSet {
            if oldValue != self._liftedTimerIndexPath {
                self.collectionView?.collectionViewLayout.invalidateLayout()
            }
        }
    }

    /** The last position that produced feedback, kept through transient invalid proposals. */
    private var _lastDropPosition: DropPosition?

    /** Gives every completed or cancelled drag a single, strong impact. */
    private let _dragEndFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)

    /// The preview and placement state for a drag of an entire group.
    private struct GroupDrag {
        /// The original group being moved.
        let group: TimerGroup
        /// The group's section index when the drag began.
        let source: Int
        /// The current proposed section for the group.
        var destination: Int
        /// The original row rectangle in collection view coordinates.
        let frame: CGRect
        /// The vertical offset from the touch to the row's center.
        let grabOffsetY: CGFloat
        /// The rendered row that follows the touch.
        let preview: UIView
        /// The recognizer that supplies the drag state and touch position.
        let gesture: UILongPressGestureRecognizer
    }

    /// The active whole-group drag, if any.
    private var _groupDrag: GroupDrag?
    /// The display link that drives edge scrolling during a group drag.
    private var _groupScrollLink: CADisplayLink?
    
    /* ############################################################## */
    /**
     This allows us to force-close the popover, easily.
     */
    weak var currentPopover: UIPopoverPresentationController?

    /// The iPad settings popover can reflow while its presenting window is resized.
    private var presentedIPadSettings: RiValT_Settings_ViewController? {
        guard UIDevice.current.userInterfaceIdiom == .pad, !ProcessInfo.processInfo.isMacCatalystApp else { return nil }
        return (self.presentedViewController ?? self.navigationController?.presentedViewController) as? RiValT_Settings_ViewController
    }
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
        self.navigationItem.backButtonTitle = "SLUG-TIMERS-BACK".localizedVariant
        self.groupSummaryLabel?.maximumContentSizeCategory = .extraExtraExtraLarge
        self.collectionView?.isDirectionalLockEnabled = true
        let doubleTapper = UITapGestureRecognizer(target: self, action: #selector(self.groupDoubleTapped))
        doubleTapper.numberOfTapsRequired = 2
        doubleTapper.delaysTouchesBegan = true
        self.collectionView?.addGestureRecognizer(doubleTapper)
        self.rowDoubleTapRecognizer = doubleTapper

        let groupPress = UILongPressGestureRecognizer(target: self, action: #selector(groupLongPressed))
        groupPress.delegate = self
        self.collectionView?.addGestureRecognizer(groupPress)
        doubleTapper.require(toFail: groupPress)
        self.settingsBarButtonItem?.accessibilityLabel = "SLUG-ACC-SETTINGS-BUTTON-LABEL".localizedVariant
        self.settingsBarButtonItem?.accessibilityHint = "SLUG-ACC-SETTINGS-BUTTON-HINT".localizedVariant
        self.toolbarDeleteButton?.accessibilityIdentifier = "targetItem"
        self.toolbarDeleteButton?.accessibilityLabel = "SLUG-ACC-TOOLBAR-DELETE-LABEL".localizedVariant
        self.toolbarDeleteButton?.accessibilityHint = "SLUG-ACC-TOOLBAR-DELETE-HINT".localizedVariant
        self.toolbarPlayButton?.accessibilityLabel = "SLUG-ACC-TOOLBAR-PLAY-LABEL".localizedVariant
        self.toolbarPlayButton?.accessibilityHint = "SLUG-ACC-TOOLBAR-PLAY-HINT".localizedVariant
        self.toolbarEditButton?.accessibilityLabel = "SLUG-ACC-TOOLBAR-EDIT-LABEL".localizedVariant
        self.toolbarEditButton?.accessibilityHint = "SLUG-ACC-TOOLBAR-EDIT-HINT".localizedVariant
        
        let appearance = UIToolbarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.backgroundImage = nil
        self.toolbar?.standardAppearance = appearance
        self.toolbar?.scrollEdgeAppearance = appearance

        if let collectionView = self.collectionView {
            if #available(iOS 26.0, *) {
                collectionView.topEdgeEffect.isHidden = true
                collectionView.bottomEdgeEffect.isHidden = true
            }
            for (blur, tint) in [(self._headerBlur, self._headerBlurTint), (self._toolbarBlur, self._toolbarBlurTint)] {
                blur.isUserInteractionEnabled = false
                blur.isHidden = true
                blur.contentView.layer.addSublayer(tint)
                self.view.insertSubview(blur, aboveSubview: collectionView)
            }
        }
        self.registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (controller: RiValT_GroupEditor_ViewController, _) in
            controller.view.setNeedsLayout()
        }
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
        // The timer editor can change a timer's contents or delete it entirely.
        self.updateSnapshot(reloadingData: true)
        self.checkForFastForward()
    }

    /* ############################################################## */
    /**
     Called just after the view appeared.
     
     - parameter inIsAnimated: True, if the appearance is animated.
     */
    override func viewDidAppear(_ inIsAnimated: Bool) {
        super.viewDidAppear(inIsAnimated)
        if self._lastScrollPos == nil,
           let collectionView = self.collectionView,
           let selectedSectionIndex = self.timerModel?.selectedTimer?.indexPath,
           selectedSectionIndex.section < collectionView.numberOfSections,
           selectedSectionIndex.item < collectionView.numberOfItems(inSection: selectedSectionIndex.section) {
            collectionView.scrollToItem(at: selectedSectionIndex, at: .bottom, animated: false)
            self._lastScrollPos = collectionView.contentOffset
        }
        self.updateScrollEdgeBlurVisibility()
    }

    /* ############################################################## */
    /**
     Called just before the view disappears.
     
     - parameter inIsAnimated: True, if the disappearance is animated.
     */
    override func viewWillDisappear(_ inIsAnimated: Bool) {
        self.finishGroupDrag(commit: false)
        RiValT_Settings.ephemeralFirstTime = false
        self._lastScrollPos = collectionView?.contentOffset
        super.viewWillDisappear(inIsAnimated)
    }
    
    /* ############################################################## */
    /**
     Called when the view lays out its view hierarchy.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.presentedIPadSettings?.viewIfLoaded?.setNeedsLayout()
        // Replacing the layout or snapshot while UIKit is opening a drop gap resets its preview.
        guard self._groupDrag == nil, self._timerDragSession == nil, self.collectionView?.hasActiveDrop != true else { return }
        if let collectionView = self.collectionView {
            var insets = collectionView.contentInset
            insets.top = self.groupSummaryLabel?.bounds.height ?? 0
            insets.bottom = self.toolbar?.bounds.height ?? 0
            if collectionView.contentInset != insets {
                // The first and last rows clear the overlays at their respective scroll limits.
                let lastScrollPos = self._lastScrollPos
                collectionView.contentInset = insets
                collectionView.verticalScrollIndicatorInsets = UIEdgeInsets(top: insets.top, left: 0, bottom: insets.bottom, right: 0)
                self._lastScrollPos = lastScrollPos
            }
        }
        self.setupDataSource()
        self.createLayout()
        self.updateSnapshot()
        self.watchDelegate?.updateSettings()
        if let lastScrollPos = self._lastScrollPos {
            self.collectionView?.setContentOffset(lastScrollPos, animated: false)
        } else if let collectionView = self.collectionView,
                  let selectedSectionIndex = self.timerModel?.selectedTimer?.indexPath,
                  selectedSectionIndex.section < collectionView.numberOfSections,
                  selectedSectionIndex.item < collectionView.numberOfItems(inSection: selectedSectionIndex.section) {
            collectionView.scrollToItem(at: selectedSectionIndex, at: .centeredVertically, animated: false)
            self._lastScrollPos = collectionView.contentOffset
        }
        self.updateToolbar()
        if let groupSummaryLabel = self.groupSummaryLabel {
            self.layoutScrollEdgeBlur(self._headerBlur, tint: self._headerBlurTint, behind: groupSummaryLabel, atTop: true)
        }
        if let toolbar = self.toolbar {
            self.layoutScrollEdgeBlur(self._toolbarBlur, tint: self._toolbarBlurTint, behind: toolbar, atTop: false)
        }
        self.updateScrollEdgeBlurVisibility()
    }

    /// Fades in the blur toward the outside of the list, then blends it back into the surrounding background.
    private func layoutScrollEdgeBlur(_ blur: UIVisualEffectView, tint: CAGradientLayer, behind overlay: UIView, atTop: Bool) {
        let overlayFrame = overlay.convert(overlay.bounds, to: self.view)
        let bounds = self.view.bounds
        let insideFade: CGFloat = 16
        let outsideSpace = atTop ? overlayFrame.minY - bounds.minY : bounds.maxY - overlayFrame.maxY
        let outsideFade = max(0, min(16, outsideSpace))
        let frame = CGRect(x: bounds.minX, y: overlayFrame.minY - (atTop ? outsideFade : insideFade),
                           width: bounds.width, height: insideFade + overlayFrame.height + outsideFade)
        guard overlayFrame.height > 0 else { return }

        // Match the screen gradient so the material blends into the background around the rows.
        let background = self.gradientLayer as? CAGradientLayer
        let solidColor = (self.view.backgroundColor ?? .systemBackground).resolvedColor(with: self.traitCollection).cgColor
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        tint.frame = (background?.frame ?? bounds).offsetBy(dx: -frame.minX, dy: -frame.minY)
        tint.colors = background?.colors ?? [solidColor, solidColor]
        tint.opacity = !atTop && !self.isDarkMode ? 0.93 : 0.76
        CATransaction.commit()

        guard blur.frame != frame else { return }
        blur.frame = frame

        let gradient = CAGradientLayer()
        gradient.frame = blur.bounds
        gradient.startPoint = CGPoint(x: 0.5, y: atTop ? 1 : 0)
        gradient.endPoint = CGPoint(x: 0.5, y: atTop ? 0 : 1)
        // Reach full blur just inside the overlay so row details soften before meeting the controls.
        let overlayStart = Double(insideFade / frame.height)
        let fullBlur = Double((insideFade + overlayFrame.height * 0.18) / frame.height)
        let overlayEnd = Double((insideFade + overlayFrame.height) / frame.height)
        gradient.locations = [0, NSNumber(value: overlayStart), NSNumber(value: fullBlur), NSNumber(value: overlayEnd), 1]
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.7).cgColor,
                           UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        let mask = UIView(frame: blur.bounds)
        mask.layer.addSublayer(gradient)
        blur.mask = mask
    }

    /// Applies the backdrops only at edges where the list extends behind the controls.
    private func updateScrollEdgeBlurVisibility() {
        guard let collectionView = self.collectionView else { return }
        let viewport = collectionView.bounds.inset(by: collectionView.adjustedContentInset)
        let hasContent = collectionView.contentSize.height > 0
        self._headerBlur.isHidden = !hasContent || viewport.minY <= 0
        self._toolbarBlur.isHidden = !hasContent || viewport.maxY >= collectionView.contentSize.height
    }

    /* ################################################################## */
    /**
     Called to allow us to do something when we change layout size (like rotating)
     
     - parameter inSize: The new size
     - parameter inCoordinator: The coordinator object.
     */
    override func viewWillTransition(to inSize: CGSize, with inCoordinator: any UIViewControllerTransitionCoordinator) {
        self.finishGroupDrag(commit: false)
        super.viewWillTransition(to: inSize, with: inCoordinator)
        guard self.presentedIPadSettings == nil else { return }
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
     Refreshes the controls after a popover has finished dismissing.

     - parameter inController: The dismissed popover controller.
     */
    func popoverPresentationControllerDidDismissPopover(_ inController: UIPopoverPresentationController) {
        self.updateToolbar()
        self.setUpNavBarItems()
        self.currentPopover = nil
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
        soundSettingsButtonItem.tintColor = .accent
        let displaySettingsButtonItem = DisplayBarButtonItem()
        displaySettingsButtonItem.isAccessibilityElement = true
        displaySettingsButtonItem.accessibilityLabel = "SLUG-ACC-DISPLAY-SETTINGS-BUTTON-LABEL".localizedVariant
        displaySettingsButtonItem.accessibilityHint = "SLUG-ACC-DISPLAY-SETTINGS-BUTTON-HINT".localizedVariant
        displaySettingsButtonItem.group = self.timerModel.selectedTimer?.group
        displaySettingsButtonItem.target = self
        displaySettingsButtonItem.action = #selector(displaySettingsButtonHit)
        displaySettingsButtonItem.tintColor = .accent
        if #available(iOS 26.0, *) {
            soundSettingsButtonItem.hidesSharedBackground = true
            displaySettingsButtonItem.hidesSharedBackground = true
        }
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
        let layout = UICollectionViewCompositionalLayout { [weak self] inSection, _ -> NSCollectionLayoutSection? in
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
            
            let background = NSCollectionLayoutDecorationItem.background(elementKind: SectionBackgroundView.reuseIdentifier)
            if self?.insertionPreviewSection == inSection {
                let height = RiValT_BaseCollectionCell.itemSize.heightDimension.dimension + 1
                section.contentInsets.top = height
                background.contentInsets.top = height
            }
            section.decorationItems = [background]
            section.visibleItemsInvalidationHandler = { [weak self] items, _, _ in
                guard let self else { return }
                guard let drag = self._groupDrag else {
                    self.applyTimerDropLayout(to: items, in: inSection)
                    return
                }
                // Slide the intervening rows into the vacated slot. The lifted row travels in a separate view.
                var offset: CGFloat = 0
                if inSection > drag.source && inSection <= drag.destination {
                    offset = -drag.frame.height
                } else if inSection >= drag.destination && inSection < drag.source {
                    offset = drag.frame.height
                }
                for item in items {
                    item.alpha = inSection == drag.source ? 0 : 1
                    item.transform = CGAffineTransform(translationX: 0, y: offset)
                }
            }
            
            return section
        }
        
        layout.register(SectionBackgroundView.self, forDecorationViewOfKind: SectionBackgroundView.reuseIdentifier)
        
        self.collectionView?.collectionViewLayout = layout
    }

    /// Closes the lifted timer's slot and opens space at the proposed destination.
    private func applyTimerDropLayout(to inItems: [any NSCollectionLayoutVisibleItem], in inSection: Int) {
        let source = self._timerDragSession?.localContext as? TimerDragSource
        let sourceItem = source?.indexPath.section == inSection ? source?.indexPath.item : nil
        let destinationItem: Int?
        if case .timer(let destination) = self._dropPosition, destination.section == inSection {
            destinationItem = destination.item
        } else {
            destinationItem = nil
        }
        let isTrailingRow = inSection == self.timerModel.count
        let addCellIndex = isTrailingRow ? 0 : TimerGroup.maxTimersInGroup - 1
        let hidesAddCell = destinationItem != nil && sourceItem == nil
            && (isTrailingRow || self.timerModel[inSection].count == addCellIndex)
        for item in inItems where item.representedElementCategory == .cell {
            let index = item.indexPath.item
            // Keep the source slot in place whenever the timer has no valid destination.
            let closesSourceSlot = self._dropPosition != nil && (sourceItem.map { index > $0 } ?? false)
            let shiftedIndex = index - (closesSourceSlot ? 1 : 0)
            let opensDestinationSlot = destinationItem.map { shiftedIndex >= $0 } ?? false
            let targetIndex = shiftedIndex + (opensDestinationSlot ? 1 : 0)
            item.transform = CGAffineTransform(translationX: CGFloat(targetIndex - index) * (source?.columnSpacing ?? 0), y: 0)
            let isLiftedTimer = item.indexPath == self._liftedTimerIndexPath
            let isHiddenAddCell = hidesAddCell && index == addCellIndex
            item.alpha = isLiftedTimer || isHiddenAddCell ? 0 : 1
        }
    }
    
    /* ############################################################## */
    /**
     This sets up the data source cells.
     */
    func setupDataSource() {
        // Keep the populated snapshot when another layout pass occurs during startup.
        guard self.dataSource == nil, let collectionView = self.collectionView else { return }
        self.dataSource = UICollectionViewDiffableDataSource<Int, RiValT_TimerArray_Placeholder>(collectionView: collectionView) { [self] inCollectionView, inIndexPath, inItem in
            var ret = UICollectionViewCell()
            
            // If this cell has a timer, we create a timer cell.
            if let timer = inItem.timer,
               let cell = inCollectionView.dequeueReusableCell(withReuseIdentifier: RiValT_TimerArray_IconCell.reuseIdentifier, for: inIndexPath) as? RiValT_TimerArray_IconCell {
                self.configureTimerCell(cell, with: timer, at: inIndexPath)
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

    /// Configures the timer display and its accessibility state together.
    private func configureTimerCell(_ inCell: RiValT_TimerArray_IconCell, with inTimer: Timer, at inIndexPath: IndexPath) {
        inCell.configure(with: inTimer, indexPath: inIndexPath, myController: self)
        inCell.isAccessibilityElement = true
        inCell.accessibilityLabel = String(format: "SLUG-ACC-COLLECTION-TIMER-FORMAT-LABEL".localizedVariant, inIndexPath.item + 1, inIndexPath.section + 1)
        inCell.accessibilityTraits = inTimer.isSelected ? [.button, .selected] : .button
        inCell.accessibilityCustomActions = self.groupAccessibilityActions(for: inTimer)
    }

    /// Refreshes the selection in place so the drag can capture the existing views.
    private func selectTimerForDrag(at inIndexPath: IndexPath, in inCollectionView: UICollectionView) {
        let previous = self.timerModel.selectedTimer?.indexPath
        guard previous != inIndexPath else { return }
        self.timerModel.selectTimer(inIndexPath)
        let changesGroup = previous?.section != inIndexPath.section
        for indexPath in [previous, inIndexPath].compactMap({ $0 }) {
            if let timer = self.timerModel.getTimer(at: indexPath),
               let cell = inCollectionView.cellForItem(at: indexPath) as? RiValT_TimerArray_IconCell {
                self.configureTimerCell(cell, with: timer, at: indexPath)
            }
            let group = self.timerModel[indexPath.section]
            if changesGroup && !group.isFull {
                let addPath = IndexPath(item: group.count, section: indexPath.section)
                (inCollectionView.cellForItem(at: addPath) as? RiValT_TimerArray_AddCell)?.configure(indexPath: addPath, myController: self)
            }
        }
        self.updateGroupSummary()
        self.updateToolbar()
        self.setUpNavBarItems()
        inCollectionView.collectionViewLayout.invalidateLayout()
        inCollectionView.layoutIfNeeded()
    }

    /* ############################################################## */
    /**
     This updates the collection view snapshot. Reloading also refreshes cells whose timer contents or selection changed.
     */
    func updateSnapshot(reloadingData: Bool = false) {
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

        if reloadingData {
            self.dataSource?.applySnapshotUsingReloadData(snapshot)
        } else {
            self.dataSource?.apply(snapshot, animatingDifferences: false)
        }
        self.updateGroupSummary()
        self.updateToolbar()
        self.setUpNavBarItems()
    }

    /// Shows the group duration and, for groups with multiple timers, the Combine Timers status.
    func updateGroupSummary() {
        guard let timer = self.timerModel.selectedTimer, let group = timer.group, let groupIndex = group.index else {
            self.groupSummaryLabel?.text = nil
            return
        }

        let total = TimerCountdown(timer, combineTimers: true).totalDuration
        let duration = Duration.seconds(total).formatted(.units(allowed: [.hours, .minutes, .seconds], width: .narrow))
        var summary = String.localizedStringWithFormat("SLUG-GROUP-EDITOR-SUMMARY".localizedVariant, groupIndex + 1, duration)
        if group.count > 1 {
            let status = RiValT_Settings().combineTimers ? "SLUG-GROUP-EDITOR-COMBINE-ON" : "SLUG-GROUP-EDITOR-COMBINE-OFF"
            summary += "\n" + status.localizedVariant
        }
        if self.groupSummaryLabel?.text != summary {
            self.groupSummaryLabel?.text = summary
        }
    }
    
    /* ############################################################## */
    /**
     This updates the items in the toolbar.
     */
    func updateToolbar() {
        self.toolbarDeleteButton?.isEnabled = 1 < self.timerModel.allTimers.count
        self.toolbarPlayButton?.isEnabled = false
        self.toolbarEditButton?.isEnabled = !RiValT_Settings().oneTapEditing
        guard let timer = self.timerModel.selectedTimer else { return }
        self.toolbarPlayButton?.isEnabled = 0 < timer.startingTimeInSeconds
        self.toolbarPlayButton?.image = UIImage(systemName: 0 < timer.startingTimeInSeconds ? "play.fill" : "play.slash")
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension RiValT_GroupEditor_ViewController {
    /** The selected group's trailing slot and the bottom add-group slot can show a plus button. */
    func canAddTimer(at indexPath: IndexPath) -> Bool {
        if indexPath.section == self.timerModel.count {
            return indexPath.item == 0
        }
        guard let group = self.timerModel.selectedGroup else { return false }
        return group.index == indexPath.section && indexPath.item == group.count && !group.isFull
    }

    /** Only a button that was visible when the user tapped can create a timer. */
    func addTimer(from cell: RiValT_TimerArray_AddCell) {
        guard self._groupDrag == nil, let collectionView,
              let indexPath = collectionView.indexPath(for: cell), self.canAddTimer(at: indexPath)
        else { return }

        self.timerModel.createNewTimer(at: indexPath).isSelected = true
        self._lastScrollPos = nil
        self.impactHaptic(1.0)
        self.updateSettings()
        self.updateSnapshot(reloadingData: true)
        collectionView.scrollToItem(at: IndexPath(item: 0, section: self.timerModel.count), at: .top, animated: true)
        self.goEditYourself(optionalTitle: "SLUG-NEW-TIMER".localizedVariant)
    }

    /* ############################################################## */
    /**
     Called when the toolbar delete timer button is hit.
     
     - parameter: ignored.
     */
    @IBAction func toolbarDeleteButtonHit(_: Any) {
        /// Removes the confirmed preset and updates the editor and Watch selection when another timer is selected.
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
                self.watchDelegate?.publishSnapshot()
            }
        }
        
        let messageText = "SLUG-DELETE-CONFIRM-MESSAGE".localizedVariant
        
        let alertController = UIAlertController(title: "SLUG-DELETE-CONFIRM-HEADER".localizedVariant, message: messageText, preferredStyle: .alert)
        
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
        
        okAction.setAccessibility(label: "SLUG-ACC-DELETE-TIMER-CONFIRM-LABEL", hint: "SLUG-ACC-DELETE-TIMER-CONFIRM-HINT")
        alertController.addAction(okAction)

        let cancelAction = UIAlertAction(title: "SLUG-CANCEL-BUTTON-TEXT".localizedVariant, style: .cancel, handler: nil)

        cancelAction.setAccessibility(label: "SLUG-ACC-DELETE-TIMER-CANCEL-LABEL", hint: "SLUG-ACC-DELETE-TIMER-CANCEL-HINT")
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

    /// Presents a Group Editor popover with its pointer anchored to the originating bar button.
    private func presentPopover(_ controller: RiValT_GroupEditor_Popover, from item: UIBarButtonItem) {
        controller.modalPresentationStyle = .popover
        guard let popover = controller.popoverPresentationController else { return }
        popover.delegate = self
        let bar = navigationController?.navigationBar
        guard let sourceView = bar ?? view else { return }
        bar?.layoutIfNeeded()
        // A view-and-rect anchor keeps the outlined pointer below the button on iOS 26 and later.
        popover.sourceView = sourceView
        if let frame = item.frame(in: sourceView), !frame.isEmpty {
            popover.sourceRect = frame
        } else if let screen = sourceView.window?.windowScene?.screen, !item.accessibilityFrame.isEmpty {
            popover.sourceRect = sourceView.convert(item.accessibilityFrame, from: screen.coordinateSpace)
        } else {
            let margins = sourceView.layoutMarginsGuide.layoutFrame
            let isLeading = item === settingsBarButtonItem
            let isLeft = isLeading == (sourceView.effectiveUserInterfaceLayoutDirection == .leftToRight)
            let anchorY = bar?.bounds.maxY ?? sourceView.safeAreaLayoutGuide.layoutFrame.minY
            popover.sourceRect = CGRect(x: isLeft ? margins.minX : margins.maxX, y: anchorY, width: 1, height: 1)
        }
        popover.permittedArrowDirections = .up
        popover.backgroundColor = RiValT_GroupEditor_PopoverBackgroundView.fillColor
        popover.popoverBackgroundViewClass = RiValT_GroupEditor_PopoverBackgroundView.self
        self.present(controller, animated: true)
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
        self.presentPopover(controller, from: inBarButtonItem)
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
        self.presentPopover(controller, from: inBarButtonItem)
    }

    /* ############################################################## */
    /**
     The main settings button was hit.
     
     - parameter: ignored.
     */
    @IBAction func settingsButtonHit(_ inBarButtonItem: UIBarButtonItem) {
        self.impactHaptic()
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: RiValT_Settings_ViewController.storyboardID) as? RiValT_Settings_ViewController else { return }
        controller.myOwner = self
        self.presentPopover(controller, from: inBarButtonItem)
    }
    
    /* ############################################################## */
    /**
     Selects an unselected row, or starts the first timer in an already selected row.
     
     - parameter inTapGesture: The tap that caused the call.
     */
    @objc func groupDoubleTapped(_ inTapGesture: UITapGestureRecognizer) {
        guard self._groupDrag == nil, let collectionView = self.collectionView else { return }
        let location = inTapGesture.location(in: collectionView)
        guard let section = (0..<self.timerModel.count).first(where: { groupFrame(at: $0)?.contains(location) == true }) else { return }

        guard self.timerModel[section].isSelected else {
            self.collectionView(collectionView, didSelectItemAt: IndexPath(item: 0, section: section))
            self.watchDelegate?.publishSnapshot()
            return
        }

        startGroupFromFirstTimer(self.timerModel[section])
    }

    /// Selects the first preset and starts the group if that preset has a nonzero duration.
    ///
    /// - Returns: Whether the running timer screen was opened.
    @discardableResult
    private func startGroupFromFirstTimer(_ group: TimerGroup) -> Bool {
        guard self._groupDrag == nil, group.isSelected, let timer = group.first, let collectionView else { return false }
        self._lastScrollPos = collectionView.contentOffset
        timer.isSelected = true
        self.updateSettings()
        self.updateSnapshot()
        collectionView.reloadData()
        self.watchDelegate?.publishSnapshot()
        guard 0 < timer.startingTimeInSeconds else { return false }
        self.impactHaptic()
        self.forceStart = true
        self.performSegue(withIdentifier: RiValT_RunningTimer_ContainerViewController.segueID, sender: timer)
        return true
    }

    /// Offer the row's double-tap and group drag commands on the selected timer.
    private func groupAccessibilityActions(for timer: Timer) -> [UIAccessibilityCustomAction] {
        guard timer.isSelected, let group = timer.group, let index = group.index else { return [] }
        var actions: [UIAccessibilityCustomAction] = []
        if let first = group.first, first.startingTimeInSeconds > 0 {
            actions.append(UIAccessibilityCustomAction(name: "SLUG-ACC-GROUP-START-ACTION".localizedVariant) { [weak self, weak group] _ in
                guard let group else { return false }
                return self?.startGroupFromFirstTimer(group) ?? false
            })
        }
        for (offset, name) in [(-1, "SLUG-ACC-GROUP-MOVE-UP-ACTION"), (1, "SLUG-ACC-GROUP-MOVE-DOWN-ACTION")] where (0..<timerModel.count).contains(index + offset) {
            actions.append(UIAccessibilityCustomAction(name: name.localizedVariant) { [weak self, weak group] _ in
                guard let self, let group, group.isSelected, let source = group.index else { return false }
                let destination = source + offset
                guard (0..<self.timerModel.count).contains(destination),
                      self.timerModel.moveGroup(from: source, before: offset > 0 ? destination + 1 : destination) else { return false }
                self.updateSnapshot(reloadingData: true)
                self.watchDelegate?.updateSettings()
                if let path = self.timerModel.selectedTimer?.indexPath, let collectionView = self.collectionView {
                    collectionView.scrollToItem(at: path, at: .centeredVertically, animated: false)
                    collectionView.layoutIfNeeded()
                    UIAccessibility.post(notification: .layoutChanged, argument: collectionView.cellForItem(at: path))
                }
                return true
            })
        }
        return actions
    }

    /* ############################################################## */
    /** Selects an unselected row without editing a timer. */
    @objc func groupBackgroundTapped(_ inTapGesture: UITapGestureRecognizer) {
        if let backgroundView = inTapGesture.view as? SectionBackgroundView,
           let collectionView = self.collectionView,
           let group = backgroundView.myGroup,
           let groupIndex = group.index,
           (0..<(self.timerModel?.count ?? 0)).contains(groupIndex),
           !group.isSelected {
            self.collectionView(collectionView, didSelectItemAt: IndexPath(item: 0, section: groupIndex))
            self.watchDelegate?.publishSnapshot()
        }
    }
    
    /* ############################################################## */
    /**
     The number at the end of a group was hit.
     
     - parameter inTapGesture: The tap that caused the call.
     */
    @objc func groupBackgroundNumberTapped(_ inTapGesture: UITapGestureRecognizer) {
        selectNextTimerInGroup()
    }

    /// Cycles selection within the group when timers are shown separately.
    ///
    /// - Returns: Whether the selection advanced.
    @discardableResult
    func selectNextTimerInGroup() -> Bool {
        guard self._groupDrag == nil, !RiValT_Settings().combineTimers, let timer = self.timerModel.selectedTimer,
              let group = timer.group, group.count > 1, let path = timer.indexPath, let collectionView else { return false }
        let next = IndexPath(item: (path.item + 1) % group.count, section: path.section)
        let oldValue = RiValT_Settings().oneTapEditing
        RiValT_Settings().oneTapEditing = false
        self.collectionView(collectionView, didSelectItemAt: next)
        RiValT_Settings().oneTapEditing = oldValue
        self.watchDelegate?.publishSnapshot()
        return true
    }
}

/* ###################################################################################################################################### */
// MARK: Moving a whole group
/* ###################################################################################################################################### */
extension RiValT_GroupEditor_ViewController: UIGestureRecognizerDelegate {
    /// Returns the layout rectangle of the group decoration at a section index.
    private func groupFrame(at section: Int) -> CGRect? {
        self.collectionView?.collectionViewLayout.layoutAttributesForDecorationView(
            ofKind: SectionBackgroundView.reuseIdentifier, at: IndexPath(item: 0, section: section)
        )?.frame
    }

    /// Finds the touched group when the press is on its background.
    private func groupSectionForDrag(at point: CGPoint) -> Int? {
        guard let collectionView, let model = self.timerModel, model.count > 1,
              self._groupDrag == nil, self._timerDragSession == nil,
              !collectionView.hasActiveDrag, !collectionView.hasActiveDrop else { return nil }
        if let indexPath = collectionView.indexPathForItem(at: point), model.isValid(indexPath: indexPath) {
            return nil
        }
        return (0..<model.count).first { self.groupFrame(at: $0)?.contains(point) == true }
    }

    /// Allows the group drag recognizer to receive touches on a group background.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        self.groupSectionForDrag(at: touch.location(in: self.collectionView)) != nil
    }

    /// Starts, updates, commits, or cancels a whole-group drag as the long press changes state.
    @objc func groupLongPressed(_ gesture: UILongPressGestureRecognizer) {
        guard let collectionView else { return }
        switch gesture.state {
        case .began:
            let point = gesture.location(in: collectionView)
            guard let source = self.groupSectionForDrag(at: point), let row = self.groupFrame(at: source) else { return }
            let group = self.timerModel[source]
            if !group.isSelected {
                self.selectTimerForDrag(at: IndexPath(item: 0, section: source), in: collectionView)
            }
            let frame = CGRect(x: collectionView.bounds.minX, y: row.minY, width: collectionView.bounds.width, height: row.height)
            let image = UIGraphicsImageRenderer(size: frame.size).image { context in
                context.cgContext.translateBy(x: -frame.minX, y: -frame.minY)
                collectionView.layer.render(in: context.cgContext)
            }
            let preview = UIImageView(image: image)
            preview.frame = collectionView.convert(frame, to: self.view)
            preview.isUserInteractionEnabled = false
            preview.accessibilityElementsHidden = true
            preview.layer.shadowPath = UIBezierPath(roundedRect: preview.bounds, cornerRadius: SectionBackgroundView.rowCornerRadius).cgPath
            preview.layer.shadowOpacity = 0.45
            preview.layer.shadowRadius = 8
            preview.layer.shadowOffset = CGSize(width: 0, height: 4)
            // The list clips its edges. Lift above it so the shadow and enlarged row have room to draw.
            self.view.insertSubview(preview, aboveSubview: collectionView)
            self._groupDrag = GroupDrag(group: group, source: source, destination: source, frame: frame,
                                        grabOffsetY: frame.midY - point.y, preview: preview, gesture: gesture)
            collectionView.collectionViewLayout.invalidateLayout()
            if !UIAccessibility.isReduceMotionEnabled {
                // Cap the expansion on wider displays to keep the lifted row inside the side margins.
                let scale = min(1.04, 1 + 24 / frame.width)
                UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut) {
                    preview.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            }
            self.impactHaptic(1.0)
            self._dragEndFeedbackGenerator.prepare()
            let link = CADisplayLink(target: self, selector: #selector(scrollDuringGroupDrag))
            link.preferredFramesPerSecond = 30
            link.add(to: .main, forMode: .common)
            self._groupScrollLink = link

        case .changed:
            updateGroupDragPosition()
        case .ended:
            updateGroupDragPosition()
            finishGroupDrag(commit: true)
        case .cancelled, .failed:
            finishGroupDrag(commit: false)
        default:
            break
        }
    }

    /// Moves the row preview and updates the proposed destination when it crosses a section boundary.
    private func updateGroupDragPosition() {
        guard let drag = self._groupDrag, let collectionView else { return }
        // All group rows have the same layout height. The trailing Add Group row is outside the reorderable range.
        let firstCenter = drag.frame.midY - CGFloat(drag.source) * drag.frame.height
        let lastCenter = firstCenter + CGFloat(self.timerModel.count - 1) * drag.frame.height
        let fingerY = drag.gesture.location(in: collectionView).y
        let centerY = min(lastCenter, max(firstCenter, fingerY + drag.grabOffsetY))
        drag.preview.center = collectionView.convert(CGPoint(x: drag.frame.midX, y: centerY), to: self.view)
        let destination = Int(((centerY - firstCenter) / drag.frame.height).rounded())
        if destination != drag.destination {
            self._groupDrag?.destination = destination
            collectionView.collectionViewLayout.invalidateLayout()
            self.selectionHaptic()
        }
    }

    /// Scroll vertically while the finger rests near an edge, including when there are no new touch events.
    @objc private func scrollDuringGroupDrag(_ link: CADisplayLink) {
        guard let drag = self._groupDrag, let collectionView else { return }
        let inset = collectionView.adjustedContentInset
        let top = collectionView.bounds.minY + inset.top
        let bottom = collectionView.bounds.maxY - inset.bottom
        let edge = min(48, (bottom - top) / 4)
        guard edge > 0 else { return }
        let fingerY = drag.gesture.location(in: collectionView).y
        let above = max(0, top + edge - fingerY)
        let below = max(0, fingerY - (bottom - edge))
        let speed = min(1, max(-1, (below - above) / edge)) * 360  // Points per second.
        let offset = collectionView.contentOffset
        let distance = speed * CGFloat(link.targetTimestamp - link.timestamp)
        let maxY = collectionView.contentSize.height - collectionView.bounds.height + inset.bottom
        let y = max(-inset.top, min(maxY, offset.y + distance))
        guard y != offset.y else { return }
        collectionView.setContentOffset(CGPoint(x: offset.x, y: y), animated: false)
        updateGroupDragPosition()
    }

    /// Clears the drag and commits the reorder if requested and the group is still at its original section.
    private func finishGroupDrag(commit: Bool) {
        guard let drag = self._groupDrag else { return }
        self._groupScrollLink?.invalidate()
        self._groupScrollLink = nil
        self._groupDrag = nil
        drag.preview.removeFromSuperview()
        let boundary = drag.destination > drag.source ? drag.destination + 1 : drag.destination
        if commit, drag.group.index == drag.source, self.timerModel.moveGroup(from: drag.source, before: boundary) {
            self.updateSnapshot()
        }
        self.updateSettings()
        self.createLayout()
        self.collectionView?.reloadData()
        self.view.setNeedsLayout()
        self._dragEndFeedbackGenerator.impactOccurred(intensity: 1.0)
    }
}

/* ###################################################################################################################################### */
// MARK: UICollectionViewDragDelegate Conformance
/* ###################################################################################################################################### */
extension RiValT_GroupEditor_ViewController: UICollectionViewDragDelegate {
    /// Hides the cell after UIKit has captured and lifted its preview.
    func collectionView(_ inCollectionView: UICollectionView, dragSessionWillBegin inSession: UIDragSession) {
        guard self._timerDragSession === inSession,
              let source = inSession.localContext as? TimerDragSource else { return }
        self._liftedTimerIndexPath = source.indexPath
    }

    /// Clears the timer drop preview and provides feedback when the drag session ends.
    func collectionView(_ inCollectionView: UICollectionView, dragSessionDidEnd inSession: UIDragSession) {
        guard self._timerDragSession === inSession else { return }
        self._liftedTimerIndexPath = nil
        self.setInsertionPreview(nil)
        self.updateDropPosition(nil)
        self._timerDragSession = nil
        self._lastDropPosition = nil
        if !inCollectionView.hasActiveDrop {
            self.updateSnapshot(reloadingData: true)
            self.view.setNeedsLayout()
        }
        self.updateSettings()
        self._dragEndFeedbackGenerator.impactOccurred(intensity: 1.0)
    }

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
        let firstColumn = IndexPath(item: 0, section: inIndexPath.section)
        guard self._groupDrag == nil, self._timerDragSession == nil, 1 < self.timerModel.allTimers.count,
              let timer = self.timerModel.getTimer(at: inIndexPath),
              let firstColumnCenter = inCollectionView.layoutAttributesForItem(at: firstColumn)?.center.x
        else { return [] }
        let columnWidth = RiValT_BaseCollectionCell.itemSize.widthDimension.dimension
        let spacing = inCollectionView.effectiveUserInterfaceLayoutDirection == .rightToLeft ? -columnWidth : columnWidth
        self._timerDragSession = inSession
        self._lastDropPosition = .timer(inIndexPath)
        inSession.localContext = TimerDragSource(indexPath: inIndexPath, firstColumnCenter: firstColumnCenter, columnSpacing: spacing)
        self.selectTimerForDrag(at: inIndexPath, in: inCollectionView)
        self.impactHaptic(1.0)
        self._dragEndFeedbackGenerator.prepare()
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
    /// Only timer drags that started in this editor can change the matrix.
    func collectionView(_ inCollectionView: UICollectionView, canHandle inSession: UIDropSession) -> Bool {
        guard let dragSession = inSession.localDragSession else { return false }
        return self._timerDragSession === dragSession
    }

    /// Clears the proposed insertion when a timer leaves the drop area.
    func collectionView(_ inCollectionView: UICollectionView, dropSessionDidExit inSession: UIDropSession) {
        self.setInsertionPreview(nil)
        self.updateDropPosition(nil)
    }

    /// Refreshes the cells when the timer drop animation ends.
    func collectionView(_ inCollectionView: UICollectionView, dropSessionDidEnd inSession: UIDropSession) {
        // Refresh selection once UIKit has finished animating the drop.
        if self._timerDragSession == nil {
            self.updateSnapshot(reloadingData: true)
            self.view.setNeedsLayout()
        }
    }

    /* ############################################################## */
    /**
     Called to vet the current drag state.
     
     - parameter inCollectionView: The collection view.
     - parameter inSession: The session for the drag.
     
     - returns: the disposition proposal for the drag.
     */
    func collectionView(_ inCollectionView: UICollectionView,
                        dropSessionDidUpdate inSession: UIDropSession,
                        withDestinationIndexPath _: IndexPath?
    ) -> UICollectionViewDropProposal {
        guard let source = inSession.localDragSession?.localContext as? TimerDragSource,
              let timer = inSession.items.first?.localObject as? Timer,
              self.timerModel.getTimer(at: source.indexPath) === timer
        else {
            self.setInsertionPreview(nil)
            self.updateDropPosition(nil)
            return UICollectionViewDropProposal(operation: .cancel)
        }
        let location = inSession.location(in: inCollectionView)
        let insertion = self.insertionSection(at: location, source: source.indexPath)
        let position = insertion.map(DropPosition.newGroup) ?? self.timerDropPosition(at: location, from: source)
        self.updateDropPosition(position)
        // A native insertion gap changes UIKit's own hit target. The editor lays out the preview for this position.
        return UICollectionViewDropProposal(operation: position == nil ? .cancel : .move, intent: .unspecified)
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
        guard let position = self._dropPosition,
              let source = (inCoordinator.session.localDragSession?.localContext as? TimerDragSource)?.indexPath,
              let item = inCoordinator.items.first, let timer = item.dragItem.localObject as? Timer,
              self.timerModel.getTimer(at: source) === timer
        else { return }

        self._insertionPreviewTask?.cancel()
        self._insertionPreviewTask = nil
        self._dropPosition = nil
        self.setInsertionPreview(nil)
        inCollectionView.collectionViewLayout.invalidateLayout()
        switch position {
        case .newGroup(let section):
            guard (1..<self.timerModel.count).contains(section) else { return }
            self.timerModel.moveTimerToNewGroup(from: source, before: section)
        case .timer(let destination):
            guard source != destination, self.timerModel.canInsertTimer(at: destination, from: source) else { return }
            self.timerModel.moveTimer(from: source, to: destination)
        }
        // The source path may now belong to another timer in the new snapshot.
        self._liftedTimerIndexPath = nil
        self.updateSnapshot()
        if let destination = timer.indexPath {
            inCollectionView.layoutIfNeeded()
            inCoordinator.drop(item.dragItem, toItemAt: destination)
        }
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
        guard self._groupDrag == nil, (0..<self.timerModel.count).contains(inIndexPath.section) else { return }
        let group = self.timerModel[inIndexPath.section]
        let shouldEdit: Bool
        if group.isSelected {
            guard let timer = self.timerModel.getTimer(at: inIndexPath) else { return }
            timer.isSelected = true
            shouldEdit = RiValT_Settings().oneTapEditing
        } else {
            // Discard any tap already in progress. Starting this row takes two fresh taps.
            self.rowDoubleTapRecognizer?.isEnabled = false
            self.rowDoubleTapRecognizer?.isEnabled = true
            group.first?.isSelected = true
            shouldEdit = false
        }

        self._lastScrollPos = inCollectionView.contentOffset
        self.impactHaptic()
        self.updateSettings()
        self.updateSnapshot(reloadingData: true)

        if shouldEdit {
            self.goEditYourself()
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
        guard let lastScrollPos = self._lastScrollPos else { return inOffset }
        inCollectionView.setContentOffset(lastScrollPos, animated: false)
        return lastScrollPos
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
        self.updateScrollEdgeBlurVisibility()
    }
}
