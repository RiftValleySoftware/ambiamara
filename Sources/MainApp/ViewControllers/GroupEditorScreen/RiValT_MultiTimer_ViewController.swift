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
// MARK: - Special Bar Button Item That Disappears, When Disabled -
/* ###################################################################################################################################### */
/**
 This will not turn grey. Instead, it will become clear.
 */
class RiValT_DisappearingBarButton: UIBarButtonItem {
    /* ################################################################## */
    /**
     If the control is disabled, we return clear.
     */
    override var isEnabled: Bool {
        get { super.isEnabled }
        set {
            super.isEnabled = newValue
            super.tintColor = newValue ? RiValT_AppDelegate.appDelegateInstance?.groupEditorController?.view?.tintColor : .clear
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Timer Extension for Display -
/* ###################################################################################################################################### */
extension Timer {
    /* ############################################################## */
    /**
     This returns an "optimized" string, with the HH:mm:ss format of the starting time. Empty, if none.
     */
    var setTimeDisplay: String {
        let currentTime = self.startingTimeInSeconds
        let hour = currentTime / TimerEngine.secondsInHour
        let minute = currentTime / TimerEngine.secondsInMinute - (hour * TimerEngine.secondsInMinute)
        let second = currentTime - ((hour * TimerEngine.secondsInHour) + (minute * TimerEngine.secondsInMinute))
        if (1..<TimerEngine.maxHours).contains(hour) {
            return String(format: "%d:%02d:%02d", hour, minute, second)
        } else if (1..<TimerEngine.maxMinutes).contains(minute) {
            return String(format: "%d:%02d", minute, second)
        } else if (1..<TimerEngine.maxSeconds).contains(second) {
            return String(format: "%d", second)
        } else {
            return ""
        }
    }
    
    /* ############################################################## */
    /**
     This returns an "optimized" string, with the HH:mm:ss format of the warning threshold time. Empty, if none.
     */
    var warnTimeDisplay: String {
        let currentTime = self.warningTimeInSeconds
        let hour = currentTime / TimerEngine.secondsInHour
        let minute = currentTime / TimerEngine.secondsInMinute - (hour * TimerEngine.secondsInMinute)
        let second = currentTime - ((hour * TimerEngine.secondsInHour) + (minute * TimerEngine.secondsInMinute))
        if (1..<TimerEngine.maxHours).contains(hour) {
            return String(format: "%d:%02d:%02d", hour, minute, second)
        } else if (1..<TimerEngine.maxMinutes).contains(minute) {
            return String(format: "%d:%02d", minute, second)
        } else if (1..<TimerEngine.maxSeconds).contains(second) {
            return String(format: "%d", second)
        } else {
            return ""
        }
    }
    
    /* ############################################################## */
    /**
     This returns an "optimized" string, with the HH:mm:ss format of the final threshold time. Empty, if none.
     */
    var finalTimeDisplay: String {
        let currentTime = self.finalTimeInSeconds
        let hour = currentTime / TimerEngine.secondsInHour
        let minute = currentTime / TimerEngine.secondsInMinute - (hour * TimerEngine.secondsInMinute)
        let second = currentTime - ((hour * TimerEngine.secondsInHour) + (minute * TimerEngine.secondsInMinute))
        if (1..<TimerEngine.maxHours).contains(hour) {
            return String(format: "%d:%02d:%02d", hour, minute, second)
        } else if (1..<TimerEngine.maxMinutes).contains(minute) {
            return String(format: "%d:%02d", minute, second)
        } else if (1..<TimerEngine.maxSeconds).contains(second) {
            return String(format: "%d", second)
        } else {
            return ""
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Internal Placeholder for the Add Items in the Matrix -
/* ###################################################################################################################################### */
/**
 This class allows us to have "placeholders," for the "add" items at the ends of the rows, or the bottom of the matrix.
 */
class RiValT_TimerArray_Placeholder {
    /* ############################################################## */
    /**
     If this is a placeholder for an existing timer, then we simply supply that.
     */
    var timer: Timer?
    
    /* ############################################################## */
    /**
     This is a local UUID for this item.
     */
    var _id: UUID = UUID()
    
    /* ############################################################## */
    /**
     Initializer.
     
     - parameter inTimer: If this represents an existing timer, that is supplied here. It is optional. If not supplied, this is considered an "add item" placeholder.
     */
    init(timer inTimer: Timer? = nil) {
        self.timer = inTimer
    }
}

/* ###################################################################################################################################### */
// MARK: Equatable Conformance
/* ###################################################################################################################################### */
extension RiValT_TimerArray_Placeholder: Equatable {
    /* ############################################################## */
    /**
     Equatable Conformance.
     
     - parameter lhs: The left-hand side of the comparison.
     - parameter rhs: The right-hand side of the comparison.
     - returns: True, if they are equal.
     */
    static func == (lhs: RiValT_TimerArray_Placeholder, rhs: RiValT_TimerArray_Placeholder) -> Bool { lhs.id == rhs.id }
}

/* ###################################################################################################################################### */
// MARK: Identifiable Conformance
/* ###################################################################################################################################### */
extension RiValT_TimerArray_Placeholder: Identifiable {
    /* ############################################################## */
    /**
     If we represent an existing timer, we use that UUID.
     */
    var id: UUID { timer?.id ?? self._id }
}

/* ###################################################################################################################################### */
// MARK: Hashable Conformance
/* ###################################################################################################################################### */
extension RiValT_TimerArray_Placeholder: Hashable {
    /* ############################################################## */
    /**
     Hash dealer.
     
     - parameter inOutHasher: The hasher we're loading up.
     */
    func hash(into inOutHasher: inout Hasher) {
        inOutHasher.combine(id)
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class for One Display Cell for the Collection View -
/* ###################################################################################################################################### */
/**
 This is a basic view class, for the display cells in the collection view.
 */
class RiValT_BaseCollectionCell: UICollectionViewCell {
    /* ############################################################## */
    /**
     The dimension of our cells.
     */
    static let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(74), heightDimension: .absolute(74))

    /* ################################################################## */
    /**
     This is the application-global timer model.
     
     It's an implicit optional, because the whole shebang goes into the crapper, if it doesn't work.
     */
    var timerModel: TimerModel! { RiValT_AppDelegate.appDelegateInstance?.timerModel }

    /* ############################################################## */
    /**
     The index path of this cell.
     */
    var indexPath: IndexPath?
    
    /* ############################################################## */
    /**
     The controller that "owns" this cell.
     */
    var myController: RiValT_MultiTimer_ViewController?

    /* ############################################################## */
    /**
     Configure this cell item with its index path.
     
     - parameter inIndexPath: The index path for the cell being represented.
     - parameter inMyController: The controller that "owns" this cell.
     */
    func configure(indexPath inIndexPath: IndexPath, myController inMyController: RiValT_MultiTimer_ViewController?) {
        self.indexPath = inIndexPath
        self.myController = inMyController
    }
}

/* ###################################################################################################################################### */
// MARK: - One Add Cell for the Collection View -
/* ###################################################################################################################################### */
/**
 This describes "add" cells in the collection view. These are simple "cross" buttons, that allow new timers to be appended.
 */
class RiValT_TimerArray_AddCell: RiValT_BaseCollectionCell {
    /* ############################################################## */
    /**
     The storyboard reuse ID
     */
    static let reuseIdentifier = "RiValT_TimerArray_AddCell"

    /* ############################################################## */
    /**
     Configure this cell item with its index path.
     
     - parameter inIndexPath: The index path for the cell being represented.
     - parameter inMyController: The controller that "owns" this cell.
     */
    override func configure(indexPath inIndexPath: IndexPath, myController inMyController: RiValT_MultiTimer_ViewController?) {
        super.configure(indexPath: inIndexPath, myController: inMyController)
        self.contentView.subviews.forEach { $0.removeFromSuperview() }
        if inIndexPath.section == RiValT_AppDelegate.appDelegateInstance?.timerModel.selectedTimer?.group?.index ?? -1 || self.indexPath?.section == timerModel.count {
            let newImage = UIImageView(image: UIImage(systemName: "plus.circle.fill")?
                .applyingSymbolConfiguration(.init(scale: self.indexPath?.section == timerModel.count ? .large : .small))
            )
            newImage.contentMode = .center
            newImage.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(newImage)
            newImage.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            newImage.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
            newImage.leftAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
            newImage.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
        }
        
        self.isAccessibilityElement = true
        self.accessibilityLabel = "SLUG-ACC-COLLECTION-TIMER-ADD-LABEL".localizedVariant
        self.accessibilityHint = "SLUG-ACC-COLLECTION-TIMER-ADD-HINT".localizedVariant
    }
}

/* ###################################################################################################################################### */
// MARK: - One Display Cell for the Collection View -
/* ###################################################################################################################################### */
/**
 This describes each cell, representing a timer, in the collection view.
 */
class RiValT_TimerArray_IconCell: RiValT_BaseCollectionCell {
    /* ############################################################## */
    /**
     The width of a selected timer border.
     */
    static let borderWidthInDisplayUnits = CGFloat(4)
    
    /* ############################################################## */
    /**
     The large variant of the digital display font.
     */
    static let digitalDisplayFontBig = UIFont(name: "Let\'s go Digital", size: 60)
    
    /* ############################################################## */
    /**
     The smaller variant of the digital display font.
     */
    static let digitalDisplayFontSmall = UIFont(name: "Let\'s go Digital", size: 20)

    /* ############################################################## */
    /**
     The storyboard reuse ID
     */
    static let reuseIdentifier = "RiValT_TimerArray_IconCell"
    
    /* ############################################################## */
    /**
     The timer item associated with this cell.
     */
    var item: Timer?

    /* ############################################################## */
    /**
     Configure this cell item with the timer, and its index path.
     
     - parameter inItem: The timer associated with this cell.
     - parameter inIndexPath: The index path for the cell being represented.
     - parameter inMyController: The controller that "owns" this cell.
     */
    func configure(with inItem: Timer, indexPath inIndexPath: IndexPath, myController inMyController: RiValT_MultiTimer_ViewController?) {
        let hasSetTime = 0 < inItem.startingTimeInSeconds
        let hasWarning = hasSetTime && 0 < inItem.warningTimeInSeconds
        let hasFinal = hasSetTime && 0 < inItem.finalTimeInSeconds

        self.contentView.backgroundColor = UIColor(named: "\(inItem.isSelected ? "Selected-" : "")Cell-Background")

        super.configure(indexPath: inIndexPath, myController: inMyController)
        
        self.item = inItem
        self.indexPath = inIndexPath
        self.contentView.subviews.forEach { $0.removeFromSuperview() }
        let startLabel = UILabel()
        startLabel.textColor = hasSetTime && inItem.isSelected ? UIColor(named: "Start-Color") : (hasSetTime || !inItem.isSelected ? (UIViewController().isDarkMode ? .black : .white) : .systemRed)
        startLabel.font = hasSetTime ? Self.digitalDisplayFontSmall : Self.digitalDisplayFontBig
        startLabel.text = hasSetTime ? inItem.setTimeDisplay : "0"
        startLabel.adjustsFontSizeToFitWidth = true
        startLabel.minimumScaleFactor = 0.25
        startLabel.textAlignment = hasSetTime ? .right : .center
        startLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(startLabel)
        if !hasWarning,
           !hasFinal {
            startLabel.centerYAnchor.constraint(greaterThanOrEqualTo: self.contentView.centerYAnchor).isActive = true
        }
        startLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 8).isActive = true
        startLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -8).isActive = true
        
        let warnLabel = UILabel()

        if hasWarning {
            warnLabel.textColor = inItem.isSelected ? UIColor(named: "Warn-Color") : UIViewController().isDarkMode ? .black : .white
            warnLabel.font = Self.digitalDisplayFontSmall
            warnLabel.text = inItem.warnTimeDisplay
            warnLabel.adjustsFontSizeToFitWidth = true
            warnLabel.minimumScaleFactor = 0.25
            warnLabel.textAlignment = .right
            warnLabel.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(warnLabel)
            if hasWarning,
               hasFinal {
                warnLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
            } else if !hasFinal {
                warnLabel.topAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
            }
            warnLabel.topAnchor.constraint(equalTo: startLabel.bottomAnchor).isActive = true
            warnLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 8).isActive = true
            warnLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -8).isActive = true
        }
        
        if hasFinal {
            let finalLabel = UILabel()
            
            finalLabel.textColor = inItem.isSelected ? UIColor(named: "Final-Color") : UIViewController().isDarkMode ? .black : .white
            finalLabel.font = Self.digitalDisplayFontSmall
            finalLabel.text = inItem.finalTimeDisplay
            finalLabel.adjustsFontSizeToFitWidth = true
            finalLabel.minimumScaleFactor = 0.25
            finalLabel.textAlignment = .right
            finalLabel.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(finalLabel)
            if hasWarning {
                finalLabel.topAnchor.constraint(equalTo: warnLabel.bottomAnchor).isActive = true
            } else {
                finalLabel.topAnchor.constraint(equalTo: startLabel.bottomAnchor).isActive = true
                finalLabel.topAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
            }
            finalLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 8).isActive = true
            finalLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -8).isActive = true
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - The Main View Controller for the Matrix of Timers -
/* ###################################################################################################################################### */
/**
 This is the view controller for the "multi-timer" screen, where we can arrange timers in groups and add new ones.

 It allows the user to drag and drop timers, so they can visually rearrange the matrix.
 */
class RiValT_MultiTimer_ViewController: RiValT_Base_ViewController {
    /* ################################################################################################################################## */
    // MARK: Custom Group Border Decorator
    /* ################################################################################################################################## */
    /**
     This class draws a border around the currently selected group.
     */
    class _SectionBackgroundView: UICollectionReusableView {
        /* ########################################################## */
        /**
         Used to register this class with the collection view.
         */
        static let reuseIdentifier = "SectionBackgroundView"
        
        /* ########################################################## */
        /**
         The controller that "owns" this instance.
         */
        var myController: RiValT_MultiTimer_ViewController? {
            RiValT_AppDelegate.appDelegateInstance?.groupEditorController
        }
        
        /* ########################################################## */
        /**
         The gesture recognizer that calls the handler.
         */
        weak var myTapRecognizer: UITapGestureRecognizer?

        /* ########################################################## */
        /**
         The group associated with this decorator.
         */
        weak var myGroup: TimerGroup?
        
        /* ########################################################## */
        /**
         We initialize with a frame, and set up our basic shape.
         */
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.layer.borderWidth = RiValT_TimerArray_IconCell.borderWidthInDisplayUnits
            self.layer.cornerRadius = 16
            self.clipsToBounds = true
            self.backgroundColor = .clear
        }
        
        /* ########################################################## */
        /**
         Required (and unsupported) coder init.
         */
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        /* ########################################################## */
        /**
         This is called to give the instance a chance to mess with the layout.
         
         We don't mess with it, but we use it as the best way to figure out what we'll be displaying.
         
         - parameter inLayoutAttributes: The layout attributes (which contain the current state).
         
         - returns: The layout attributes (with any mods, which we don't do).
         */
        override func preferredLayoutAttributesFitting(_ inLayoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
            self.subviews.forEach { $0.removeFromSuperview() }
            guard let group = RiValT_AppDelegate.appDelegateInstance?.timerModel.selectedTimer?.group else { return inLayoutAttributes }
            
            if (0..<(RiValT_AppDelegate.appDelegateInstance?.timerModel.count ?? 0)).contains(inLayoutAttributes.indexPath.section),
               let tempGroup = RiValT_AppDelegate.appDelegateInstance?.timerModel[inLayoutAttributes.indexPath.section] {
                myGroup = tempGroup
            } else {
                myGroup = nil
            }
            
            // If this group has a selected timer, then the entire group is considered to be selected, and we draw a border around it.
            self.layer.borderColor = (group.index == inLayoutAttributes.indexPath.section ? (UIColor(named: "Selected-Cell-Border") ?? .systemRed) : UIColor.clear).cgColor
            
            // If we have more than one group, we add a number to the right end, identifying the group.
            if group.index == inLayoutAttributes.indexPath.section,
               (1 < group.model?.count ?? 0) || (1 < group.count) {
                let groupNumberLabel = UILabel()
                groupNumberLabel.backgroundColor = UIColor(named: "Selected-Cell-Border")
                groupNumberLabel.textAlignment = .center
                groupNumberLabel.font = .boldSystemFont(ofSize: 30)
                groupNumberLabel.adjustsFontSizeToFitWidth = true
                groupNumberLabel.minimumScaleFactor = 0.5
                groupNumberLabel.text = " \(String(inLayoutAttributes.indexPath.section + 1)) "
                self.addSubview(groupNumberLabel)
                groupNumberLabel.translatesAutoresizingMaskIntoConstraints = false
                groupNumberLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
                groupNumberLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
                groupNumberLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
                groupNumberLabel.widthAnchor.constraint(equalToConstant: 38).isActive = true
                groupNumberLabel.cornerRadius = 12
                groupNumberLabel.clipsToBounds = true
                if 1 < group.count {
                    groupNumberLabel.isAccessibilityElement = true
                    groupNumberLabel.accessibilityLabel = "SLUG-ACC-GROUP-BUTTON-LABEL".localizedVariant
                    groupNumberLabel.accessibilityHint = "SLUG-ACC-GROUP-BUTTON-HINT".localizedVariant
                    groupNumberLabel.textColor = UIColor(named: "Selected-Cell-Action-Color")
                    groupNumberLabel.isUserInteractionEnabled = true
                    groupNumberLabel.addGestureRecognizer(UITapGestureRecognizer(target: RiValT_AppDelegate.appDelegateInstance?.groupEditorController, action: #selector(groupBackgroundNumberTapped)))
                } else {
                    groupNumberLabel.textColor = UIColor(named: "Group-Number")
                    groupNumberLabel.isUserInteractionEnabled = false
                    groupNumberLabel.isAccessibilityElement = false
                    groupNumberLabel.accessibilityLabel = nil
                    groupNumberLabel.accessibilityHint = nil
                }
            }
            
            // This allows us to select the group, when there's a tap, anywhere on the line.
            if nil != myGroup,
               nil == self.myTapRecognizer {
                let tapper = UITapGestureRecognizer(target: RiValT_AppDelegate.appDelegateInstance?.groupEditorController, action: #selector(groupBackgroundTapped))
                self.myTapRecognizer = tapper
                self.addGestureRecognizer(tapper)
            } else if nil == myGroup,
                      let recognizer = self.myTapRecognizer {
                self.removeGestureRecognizer(recognizer)
                self.myTapRecognizer = nil
            }
            
            return inLayoutAttributes
        }
    }
    
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
extension RiValT_MultiTimer_ViewController {
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
     Called just before the view disappears.
     
     - parameter inIsAnimated: True, if the disappearance is animated.
     */
    override func viewWillDisappear(_ inIsAnimated: Bool) {
        RiValT_Settings.ephemeralFirstTime = false
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
        self.setUpNavBarItems()
        self.watchDelegate?.updateSettings()
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
extension RiValT_MultiTimer_ViewController {
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
            
            section.decorationItems = [.background(elementKind: _SectionBackgroundView.reuseIdentifier)]
            
            return section
        }
        
        layout.register(_SectionBackgroundView.self, forDecorationViewOfKind: _SectionBackgroundView.reuseIdentifier)
        
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
extension RiValT_MultiTimer_ViewController {
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

            self.updateSnapshot()
            self.collectionView?.reloadData()
            self.updateSettings()
            self.impactHaptic(1.0)
            self.watchDelegate?.updateSettings()
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
        if let backgroundView = inTapGesture.view as? _SectionBackgroundView,
           let group = backgroundView.myGroup,
           let groupIndex = group.index,
           (0..<(self.timerModel?.count ?? 0)).contains(groupIndex),
           !group.isSelected {
            group.first?.isSelected = true
            self.watchDelegate?.updateSettings()
            self.updateSnapshot()
            self.impactHaptic()
            self.collectionView?.reloadData()
            self.setUpNavBarItems()
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
            
            group[currentSelectedIndex + 1].isSelected = true
            self.watchDelegate?.updateSettings()
            self.updateSnapshot()
            self.setUpNavBarItems()
            impactHaptic()
            self.collectionView?.reloadData()
        }
    }
}

/* ###################################################################################################################################### */
// MARK: UICollectionViewDragDelegate Conformance
/* ###################################################################################################################################### */
extension RiValT_MultiTimer_ViewController: UICollectionViewDragDelegate {
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
extension RiValT_MultiTimer_ViewController: UICollectionViewDropDelegate {
    /* ############################################################## */
    /**
     Called to vet the current drag state.
     
     - parameter: The collection view (ignored).
     - parameter inSession: The session for the drag.
     - parameter inIndexPath: The index path of the item being dragged.
     
     - returns: the disposition proposal for the drag.
     */
    func collectionView(_: UICollectionView,
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
        self.setUpNavBarItems()
    }
}

/* ###################################################################################################################################### */
// MARK: UICollectionViewDelegate Conformance
/* ###################################################################################################################################### */
extension RiValT_MultiTimer_ViewController: UICollectionViewDelegate {
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

        if (inIndexPath.section == self.timerModel?.count ?? 0) || (self.timerModel?[inIndexPath.section].isSelected ?? false),
           nil == self.timerModel.getTimer(at: inIndexPath) {
            self.timerModel.createNewTimer(at: inIndexPath)
            self.impactHaptic(1.0)
            shouldScroll = true
            shouldEdit = true
            optionalTitle = "SLUG-NEW-TIMER".localizedVariant
        } else if (0..<(self.timerModel?.count ?? 0)).contains((inIndexPath.section)),
                  !(self.timerModel?[inIndexPath.section].isSelected ?? false) {
            self.timerModel?[inIndexPath.section].first?.isSelected = true
            self.watchDelegate?.updateSettings()
            self.impactHaptic()
            shouldEdit = shouldEdit && nil != self.timerModel.getTimer(at: inIndexPath)
        } else {
            self.impactHaptic()
        }
        
        if !(self.timerModel.getTimer(at: inIndexPath)?.isSelected ?? false) {
            self.timerModel.getTimer(at: inIndexPath)?.isSelected = true
            self.watchDelegate?.updateSettings()
        }
        
        self.updateSettings()
        self.updateSnapshot()
        self.setUpNavBarItems()
        inCollectionView.reloadData()
        if shouldScroll {
            inCollectionView.scrollToItem(at: IndexPath(item: 0, section: inIndexPath.section + 1), at: .bottom, animated: true)
        } else {
            inCollectionView.scrollToItem(at: IndexPath(item: 0, section: inIndexPath.section), at: .centeredVertically, animated: true)
        }
        
        if shouldEdit {
            self.goEditYourself(optionalTitle: optionalTitle)
        }
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
extension RiValT_MultiTimer_ViewController: UIScrollViewDelegate {
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
    }
}
