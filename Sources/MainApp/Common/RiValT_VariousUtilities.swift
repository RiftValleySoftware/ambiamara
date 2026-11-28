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

extension UISegmentedControl {
    /// Some UIKit presentations expose the individual segments as native accessibility elements.
    func applySegmentAccessibility() {
        for index in 0..<min(numberOfSegments, accessibilityElementCount()) {
            guard let element = accessibilityElement(at: index) as? NSObject,
                  let image = imageForSegment(at: index) else { continue }
            element.accessibilityLabel = image.accessibilityLabel
            element.accessibilityHint = image.accessibilityHint
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - UIImage Extension to Create Gradients -
/* ###################################################################################################################################### */
extension UIImage {
    /**
     Create a simple gradient image from inStartColor on left and inEndColor on right (if horizontal), or inStartColor on top, and inEndColor on bottom (if vertical)
     
     - parameter inStartColor: left side or top
     - parameter inEndColor: right side or bottom
     - parameter inFrame: frame to be filled (Cannot be empty)
     - parameter inIsVertical: True, if the gradient is top to bottom (default is false)
     
     - returns: a gradient image, or a "nosign" image.
     */
    static func gradientImage(from inStartColor: UIColor, to inEndColor: UIColor, with inFrame: CGRect, isVertical inIsVertical: Bool = false) -> UIImage {
        var image: UIImage = UIImage(systemName: "nosign") ?? UIImage()
        
        if !inFrame.isEmpty {
            let tempGradientLayer = CAGradientLayer()
            tempGradientLayer.frame = inFrame
            tempGradientLayer.colors = [inStartColor.cgColor, inEndColor.cgColor]
            tempGradientLayer.startPoint = inIsVertical ? CGPoint(x: 0.5, y: 1.0) : CGPoint(x: 1.0, y: 0.5)
            tempGradientLayer.endPoint = inIsVertical ? CGPoint(x: 0.5, y: 0.0) : CGPoint(x: 0.0, y: 0.5)
            UIGraphicsBeginImageContext(CGSize(width: inFrame.width, height: inFrame.height))
            if let context = UIGraphicsGetCurrentContext() {
                tempGradientLayer.render(in: context)
                image = UIGraphicsGetImageFromCurrentImageContext() ?? image
            }
            UIGraphicsEndImageContext()
        }
        
        return image
    }
}

/* ###################################################################################################################################### */
// MARK: - Special Bar Button Item That Disappears, When Disabled -
/* ###################################################################################################################################### */
/**
 This will not turn grey. Instead, it will become clear.
 */
@IBDesignable
class RiValT_DisappearingBarButton: UIBarButtonItem {
    /* ################################################################## */
    /**
     If the control is disabled, we return clear.
     */
    override var isEnabled: Bool {
        get { super.isEnabled }
        set {
            super.tintColor = newValue ? .accent : .clear
            super.isEnabled = newValue
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Special Bar Button for Display Selection -
/* ###################################################################################################################################### */
/**
 A base class for the bar button items in the Group Editor Screen.
 */
class BaseCustomBarButtonItem: UIBarButtonItem { }

/* ###################################################################################################################################### */
// MARK: - Special Bar Button for Display Selection -
/* ###################################################################################################################################### */
/**
 This represents the bar button item for the display preferences popover.
 It changes its image to represent the currently selected timer display.
 */
class DisplayBarButtonItem: BaseCustomBarButtonItem {
    /* ############################################################## */
    /**
     The timer group associated with these settings.
     */
    weak var group: TimerGroup? {
        didSet {
            self.isEnabled = !self.isEnabled
            self.isEnabled = !self.isEnabled
        }
    }

    /* ################################################################## */
    /**
     The image to be displayed in the button.
     */
    override var image: UIImage? {
        get {
            super.image = super.image ?? self.group?.displayType.image?.resized(toNewHeight: 20)
            return super.image
        }
        set { super.image = newValue }
    }
}

/* ###################################################################################################################################### */
// MARK: - Special Bar Button for Sound Selection -
/* ###################################################################################################################################### */
/**
 This represents the bar button item for the sound preferences popover.
 It changes its image to represent the currently selected alarm sound.
 */
class SoundBarButtonItem: BaseCustomBarButtonItem {
    /* ############################################################## */
    /**
     The timer group associated with these settings.
     */
    weak var group: TimerGroup? {
        didSet {
            self.isEnabled = !self.isEnabled
            self.isEnabled = !self.isEnabled
        }
    }

    /* ################################################################## */
    /**
     The image to be displayed in the button.
     */
    override var image: UIImage? {
        get {
            super.image = super.image ?? self.group?.soundType.image?.resized(toNewHeight: 20)
            return super.image
        }
        set { super.image = newValue }
    }
}

/* ###################################################################################################################################### */
// MARK: Custom Group Border Decorator
/// A group-number label that exposes timer selection to VoiceOver.
private final class GroupNumberLabel: UILabel {
    /// The editor that handles selection within the numbered timer group.
    weak var controller: RiValT_GroupEditor_ViewController?

    /// Selects the next timer in the group when accessibility activates the label.
    override func accessibilityActivate() -> Bool {
        controller?.selectNextTimerInGroup() ?? false
    }
}

/* ###################################################################################################################################### */
/**
 This class draws a border around the currently selected group.
 */
class SectionBackgroundView: UICollectionReusableView {
    /* ################################################################## */
    /**
     Used to register this class with the collection view.
     */
    static let reuseIdentifier = "SectionBackgroundView"
    
    /* ############################################################## */
    /**
     The font to be used for the endcap button.
     */
    private static let _endcapFont = UIFont.systemFont(ofSize: 30)
    
    /* ############################################################## */
    /**
     The font to be used for the endcap button.
     */
    private static let _endcapFontButton = UIFont.boldSystemFont(ofSize: 40)

    /* ################################################################## */
    /**
     The width of the group endcap.
     */
    private static let _endcapWidthInDisplayUnits = CGFloat(40)
    
    /* ################################################################## */
    /**
     The radius of our rounded corners
     */
    static let rowCornerRadius = CGFloat(16)
    
    /* ################################################################## */
    /**
     The lightest light, when light.
     */
    private static let _lightModeMax = CGFloat(0.95)
    
    /* ################################################################## */
    /**
     The darkest dark, when light.
     */
    private static let _lightModeMin = CGFloat(0.58)
    
    /* ################################################################## */
    /**
     The lightest light, when dark.
     */
    private static let _darkModeMax = CGFloat(0.25)
    
    /* ################################################################## */
    /**
     The darkest dark, when dark.
     */
    private static let _darkModeMin = CGFloat(0.1)
    
    /* ################################################################## */
    /**
     This caches the last index path.
     */
    private var _lastIndexPath = IndexPath(item: -1, section: -1)
    
    /* ################################################################## */
    /**
     This caches the last selected group index.
     */
    private var _lastFrame = CGRect.zero { didSet { self.setNeedsLayout() } }
    
    /* ################################################################## */
    /**
     The controller that "owns" this instance.
     */
    var myController: RiValT_GroupEditor_ViewController? {
        RiValT_AppDelegate.appDelegateInstance?.groupEditorController
    }
    
    /* ################################################################## */
    /**
     The gesture recognizer that calls the handler.
     */
    weak var myTapRecognizer: UITapGestureRecognizer?

    /* ################################################################## */
    /**
     The group associated with this decorator.
     */
    weak var myGroup: TimerGroup?
    
    /* ################################################################## */
    /**
     The background gradient view.
     */
    weak private var _gradientImageView: UIImageView?
    
    /* ################################################################## */
    /**
     Required (and unsupported) coder init.
     */
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /* ################################################################## */
    /**
     */
    override init(frame inFrame: CGRect) {
        super.init(frame: inFrame)
        self._lastFrame = inFrame
        self.cornerRadius = Self.rowCornerRadius
    }
    
    /* ################################################################## */
    /**
     The background gradient view.
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        self._gradientImageView?.removeFromSuperview()
        if !self._lastFrame.isEmpty {
            createGradient(into: self._lastFrame)
        }
    }

    /* ################################################################## */
    /**
     The background gradient view.
     */
    func createGradient(into inFrame: CGRect) {
        var frame = inFrame
        guard let model = RiValT_AppDelegate.appDelegateInstance?.timerModel,
              let group = model.selectedTimer?.group else { return }
        if 1 < group.count || 1 < model.count {
            frame.size.width -= Self._endcapWidthInDisplayUnits
        }
        self._gradientImageView?.removeFromSuperview()
        let isDarkMode = myController?.isDarkMode ?? false
        let startColor = (!isDarkMode ? UIColor(white: Self._darkModeMax, alpha: 1.0) : UIColor(white: Self._lightModeMax, alpha: 1.0))
        let endColor = (!isDarkMode ? UIColor(white: Self._darkModeMin, alpha: 1.0) : UIColor(white: Self._lightModeMin, alpha: 1.0))
        let gradientImage = UIImage.gradientImage(from: startColor, to: endColor, with: frame)
        let gradientImageView = UIImageView(image: gradientImage)
        gradientImageView.frame = frame
        self.insertSubview(gradientImageView, at: 0)
        self._gradientImageView = gradientImageView
    }
    
    /* ################################################################## */
    /**
     Called when the actual layout attributes are applied to this instance.
     
     - parameter inLayoutAttributes: The new attributes.
     */
    override func preferredLayoutAttributesFitting(_ inLayoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        _ = super.preferredLayoutAttributesFitting(inLayoutAttributes)
        #if DEBUG
            print("Applying \(String(describing: inLayoutAttributes))")
        #endif
        
        self._lastFrame = .zero
        
        guard let group = RiValT_AppDelegate.appDelegateInstance?.timerModel.selectedTimer?.group else { return inLayoutAttributes }
        self._lastIndexPath = inLayoutAttributes.indexPath
        let isSelected = group.index == inLayoutAttributes.indexPath.section
        let isDarkMode = myController?.isDarkMode ?? false
        let isHighContrastMode = myController?.isHighContrastMode ?? false
        
        self._lastFrame =  isSelected ? CGRect(origin: .zero, size: inLayoutAttributes.frame.size) : .zero
        
        self.subviews.forEach { $0.removeFromSuperview() }

        guard (0..<(RiValT_AppDelegate.appDelegateInstance?.timerModel.count ?? 0)).contains(inLayoutAttributes.indexPath.section),
           let tempGroup = RiValT_AppDelegate.appDelegateInstance?.timerModel[inLayoutAttributes.indexPath.section]
        else {
            myGroup = nil
            self._gradientImageView?.isHidden = true
            return inLayoutAttributes
        }

        myGroup = tempGroup

        self._gradientImageView?.isHidden = isHighContrastMode || !isSelected
        self.backgroundColor = isSelected && isHighContrastMode ? .systemBackground.inverted : .clear

        // If we have more than one group, we add a number to the right end, identifying the group.
        if group.index == inLayoutAttributes.indexPath.section,
           (1 < group.model?.count ?? 0) || (1 < group.count) {
            let groupNumberLabel = GroupNumberLabel()
            groupNumberLabel.backgroundColor = isDarkMode ? UIColor(white: Self._lightModeMax, alpha: 1.0) : UIColor(white: Self._darkModeMax, alpha: 1.0)
            groupNumberLabel.textAlignment = .left
            groupNumberLabel.adjustsFontSizeToFitWidth = true
            groupNumberLabel.minimumScaleFactor = 0.5
            groupNumberLabel.text = " \(String(myController?.displayedGroupNumber(for: inLayoutAttributes.indexPath.section) ?? (inLayoutAttributes.indexPath.section + 1))) "
            self.addSubview(groupNumberLabel)
            groupNumberLabel.translatesAutoresizingMaskIntoConstraints = false
            groupNumberLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
            groupNumberLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -0).isActive = true
            groupNumberLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -0).isActive = true
            groupNumberLabel.widthAnchor.constraint(equalToConstant: Self._endcapWidthInDisplayUnits).isActive = true
            groupNumberLabel.cornerRadius = 0
            groupNumberLabel.clipsToBounds = true
            if 1 < group.count, !RiValT_Settings().combineTimers {
                groupNumberLabel.font = Self._endcapFontButton
                groupNumberLabel.isAccessibilityElement = true
                groupNumberLabel.accessibilityLabel = "SLUG-ACC-GROUP-BUTTON-LABEL".localizedVariant
                groupNumberLabel.accessibilityHint = "SLUG-ACC-GROUP-BUTTON-HINT".localizedVariant
                groupNumberLabel.accessibilityTraits = .button
                groupNumberLabel.controller = myController
                groupNumberLabel.textColor = UIColor(named: "Selected-Cell-Action-Color")
                groupNumberLabel.isUserInteractionEnabled = true
                let numberTapper = UITapGestureRecognizer(target: RiValT_AppDelegate.appDelegateInstance?.groupEditorController, action: #selector(RiValT_GroupEditor_ViewController.groupBackgroundNumberTapped))
                if let doubleTapper = myController?.rowDoubleTapRecognizer {
                    numberTapper.require(toFail: doubleTapper)
                }
                groupNumberLabel.addGestureRecognizer(numberTapper)
            } else {
                groupNumberLabel.font = Self._endcapFont
                groupNumberLabel.textColor = .label.inverted
                groupNumberLabel.isUserInteractionEnabled = false
                groupNumberLabel.isAccessibilityElement = false
                groupNumberLabel.accessibilityLabel = nil
                groupNumberLabel.accessibilityHint = nil
            }
        }

        // This allows us to select the group, when there's a tap, anywhere on the line.
        if nil != myGroup,
           nil == self.myTapRecognizer {
            let tapper = UITapGestureRecognizer(target: RiValT_AppDelegate.appDelegateInstance?.groupEditorController, action: #selector(RiValT_GroupEditor_ViewController.groupBackgroundTapped))
            if let doubleTapper = myController?.rowDoubleTapRecognizer {
                tapper.require(toFail: doubleTapper)
            }
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

/* ###################################################################################################################################### */
// MARK: - The Main Page View Controller for the Timer Editor Screens -
/* ###################################################################################################################################### */
/**
 This is a [UIPageViewController](https://developer.apple.com/documentation/uikit/uipageviewcontroller) subclass, that will manage individual presentations of the ``RiValT_EditTimer_ViewController`` class.
 
 It's main purpose, is to add "swipe to select" services, for groups containing multiple timers.
 
 This class is embedded into an instance of ``RiValT_TimerEditor_PageViewContainer``, and it is basically "invisible."
 */
class RiValT_TimerEditor_PageViewController: UIPageViewController {
    /* ############################################################## */
    /**
     This is the container instance that wraps this instance.
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
    var myController: RiValT_GroupEditor_ViewController?

    /* ############################################################## */
    /**
     Configure this cell item with its index path.
     
     - parameter inIndexPath: The index path for the cell being represented.
     - parameter inMyController: The controller that "owns" this cell.
     */
    func configure(indexPath inIndexPath: IndexPath, myController inMyController: RiValT_GroupEditor_ViewController?) {
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
    override func configure(indexPath inIndexPath: IndexPath, myController inMyController: RiValT_GroupEditor_ViewController?) {
        super.configure(indexPath: inIndexPath, myController: inMyController)
        self.contentView.subviews.forEach { $0.removeFromSuperview() }
        self.isAccessibilityElement = false
        guard let controller = inMyController, controller.canAddTimer(at: inIndexPath) else { return }

        let isNewGroup = inIndexPath.section == timerModel.count
        let symbol = UIImage.SymbolConfiguration(scale: isNewGroup ? .large : .small)
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: symbol), for: .normal)
        button.frame = self.contentView.bounds
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        button.isAccessibilityElement = true
        button.accessibilityLabel = (isNewGroup ? "SLUG-ACC-COLLECTION-GROUP-ADD-LABEL" : "SLUG-ACC-COLLECTION-TIMER-ADD-LABEL").localizedVariant
        button.accessibilityHint = (isNewGroup ? "SLUG-ACC-COLLECTION-GROUP-ADD-HINT" : "SLUG-ACC-COLLECTION-TIMER-ADD-HINT").localizedVariant
        button.addTarget(self, action: #selector(addButtonHit), for: .primaryActionTriggered)
        self.contentView.addSubview(button)
        if isNewGroup {
            self.overrideUserInterfaceStyle = .unspecified
        } else {
            self.overrideUserInterfaceStyle = controller.isDarkMode ? .light : .dark
        }
    }

    /// Asks the editor to add a timer at this cell when its button receives the primary action.
    @objc private func addButtonHit(_ button: UIButton) {
        guard button.superview === self.contentView else { return }
        self.myController?.addTimer(from: self)
    }
}

/* ###################################################################################################################################### */
// MARK: - One Display Cell for the Collection View -
/* ###################################################################################################################################### */
/**
 This describes each cell, representing a timer, in the collection view.
 */
class RiValT_TimerArray_IconCell: RiValT_BaseCollectionCell {
    /// The preset's starting phase and whether Warning continues to the end.
    private enum PresetPhase {
        case standard
        case warning
        case warningThenFinal
        case final

        init(timer: Timer) {
            let duration = timer.startingTimeInSeconds
            guard duration > 0 else {
                self = .standard
                return
            }
            let final = timer.finalRangeUpperBound
            if final >= duration {
                self = .final
            } else if timer.warningRangeUpperBound >= duration {
                self = final > 0 ? .warningThenFinal : .warning
            } else {
                self = .standard
            }
        }

        /// Selected cells have a black background in either appearance.
        private static let selectedColorTraits = UITraitCollection {
            $0.userInterfaceStyle = .dark
            $0.accessibilityContrast = .normal
        }

        var selectedColor: UIColor {
            let assetName: String
            switch self {
            case .standard: assetName = "Start-Color"
            case .warning, .warningThenFinal: assetName = "Warn-Color"
            case .final: assetName = "Final-Color"
            }
            return UIColor(named: assetName, in: nil, compatibleWith: Self.selectedColorTraits)?
                .resolvedColor(with: Self.selectedColorTraits) ?? .white
        }

        var selectedTextColor: UIColor {
            let color = selectedColor
            return UIColor { $0.accessibilityContrast == .high ? .white : color }
        }

        var unselectedBackgroundColor: UIColor? {
            switch self {
            case .standard: return UIColor(named: "Cell-Background")
            case .warning, .warningThenFinal: return UIColor(named: "Warning-Cell-Background")
            case .final: return UIColor(named: "Final-Cell-Background")
            }
        }

        var accessibilityDescription: String? {
            switch self {
            case .standard: return nil
            case .warning: return "SLUG-TIMER-ENTIRELY-IN-WARNING".localizedVariant
            case .warningThenFinal: return "SLUG-TIMER-STARTS-IN-WARNING".localizedVariant
            case .final: return "SLUG-TIMER-ENTIRELY-IN-FINAL".localizedVariant
            }
        }
    }

    /// Unselected cells use dark fills in light appearance and light fills in dark appearance.
    private static let _unselectedTextColor = UIColor { $0.userInterfaceStyle == .dark ? .black : .white }

    /// Describes whether activating this cell selects its group, edits the preset, or opens the timer.
    override var accessibilityHint: String? {
        get {
            guard item?.group?.isSelected == true else { return "SLUG-ACC-COLLECTION-SELECT-GROUP-HINT".localizedVariant }
            return (RiValT_Settings().oneTapEditing ? "SLUG-ACC-COLLECTION-EDIT-TIMER-HINT" : "SLUG-ACC-COLLECTION-TIMER-HINT").localizedVariant
        }
        set { super.accessibilityHint = newValue }
    }

    /* ############################################################## */
    /**
     The height of our display labels, if we have a tight squeeze.
     */
    private static let _tightFontHeightInDisplayUnits = CGFloat(18)
    
    /* ############################################################## */
    /**
     The width of a selected timer border.
     */
    static let borderWidthInDisplayUnits = CGFloat(3)
    
    /* ############################################################## */
    /**
     The large variant of the digital display font.
     */
    static let digitalDisplayFontBig = UIFont(name: "Let\'s go Digital", size: 60)
    
    /* ############################################################## */
    /**
     The large variant of the digital display font (unselected).
     */
    static let unselectedDisplayFontBig = UIFont.systemFont(ofSize: 60)

    /* ############################################################## */
    /**
     The smaller variant of the digital display font.
     */
    static let digitalDisplayFontSmall = UIFont(name: "Let\'s go Digital", size: 24)

    /* ############################################################## */
    /**
     The smaller variant of the digital display font (unselected).
     */
    static let unselectedDisplayFontSmall = UIFont.systemFont(ofSize: 20)

    /* ################################################################## */
    /**
     The radius of our rounded corners
     */
    private static let _cornerRadiusInDisplayUnits = CGFloat(12)

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
    func configure(with inItem: Timer, indexPath inIndexPath: IndexPath, myController inMyController: RiValT_GroupEditor_ViewController?) {
        let hasSetTime = 0 < inItem.startingTimeInSeconds
        let phase = PresetPhase(timer: inItem)
        // A shortcut threshold is already represented by the full duration in its starting phase.
        let hasWarning = hasSetTime && phase == .standard && 0 < inItem.warningTimeInSeconds
        let hasFinal = hasSetTime && phase != .final && 0 < inItem.finalTimeInSeconds
        let duration = inItem.setTimeDisplay

        self.contentView.backgroundColor = inItem.isSelected ? UIColor(named: "Selected-Cell-Background") : phase.unselectedBackgroundColor
        self.contentView.borderColor = inItem.isSelected ? phase.selectedColor : nil
        self.contentView.borderWidth = inItem.isSelected ? Self.borderWidthInDisplayUnits : 0
        self.contentView.cornerRadius = Self._cornerRadiusInDisplayUnits
        self.contentView.clipsToBounds = true
        super.configure(indexPath: inIndexPath, myController: inMyController)
        self.accessibilityValue = phase.accessibilityDescription.map { "\(duration). \($0)" } ?? duration
        
        self.item = inItem
        self.indexPath = inIndexPath
        self.contentView.subviews.forEach { $0.removeFromSuperview() }
        let startLabel = UILabel()
        startLabel.textColor = inItem.isSelected ? phase.selectedTextColor : Self._unselectedTextColor
        startLabel.font = hasSetTime ? inItem.isSelected ? Self.digitalDisplayFontSmall : Self.unselectedDisplayFontSmall : inItem.isSelected ? Self.digitalDisplayFontBig : Self.unselectedDisplayFontBig
        startLabel.text = duration
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
        if hasWarning || hasFinal {
            startLabel.heightAnchor.constraint(equalToConstant: Self._tightFontHeightInDisplayUnits).isActive = true
        }

        let warnLabel = UILabel()

        if hasWarning {
            warnLabel.textColor = inItem.isSelected ? PresetPhase.warning.selectedTextColor : Self._unselectedTextColor
            warnLabel.font = inItem.isSelected ? Self.digitalDisplayFontSmall : Self.unselectedDisplayFontSmall
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
            warnLabel.heightAnchor.constraint(equalToConstant: Self._tightFontHeightInDisplayUnits).isActive = true
        }
        
        if hasFinal {
            let finalLabel = UILabel()
            
            finalLabel.textColor = inItem.isSelected ? PresetPhase.final.selectedTextColor : Self._unselectedTextColor
            finalLabel.font = inItem.isSelected ? Self.digitalDisplayFontSmall : Self.unselectedDisplayFontSmall
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
            finalLabel.heightAnchor.constraint(equalToConstant: Self._tightFontHeightInDisplayUnits).isActive = true
        }
    }
}
