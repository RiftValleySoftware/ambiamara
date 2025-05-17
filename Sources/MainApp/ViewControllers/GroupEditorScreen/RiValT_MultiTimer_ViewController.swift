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
// MARK: - UIImage Extension to Create Gradients -
/* ###################################################################################################################################### */
extension UIImage {
    /**
     Create a simple gradient image from inStartColor on left and inEndColor on right (if horizontal), or inStartColor on top, and inEndColor on bottom (if vertical)
     
     - parameter inStartColor: left side or top
     - parameter inEndColor: right side or bottom
     - parameter inFrame: frame to be filled (Cannot be empty)
     - parameter isVertical: True, if the gradient is top to bottom (default is false)
     
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
            if (self.indexPath?.section ?? 0) < timerModel.count {
                self.overrideUserInterfaceStyle = myController?.isDarkMode ?? false ? .light : .dark
            } else {
                self.overrideUserInterfaceStyle = myController?.isDarkMode ?? false ? .dark : .light
            }
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
     The height of our display labels, if we have a tight squeeze.
     */
    private static let _tightFontHeightInDisplayUnits = CGFloat(18)
    
    /* ############################################################## */
    /**
     The width of a selected timer border.
     */
    static let borderWidthInDisplayUnits = CGFloat(1)
    
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
    func configure(with inItem: Timer, indexPath inIndexPath: IndexPath, myController inMyController: RiValT_MultiTimer_ViewController?) {
        let hasSetTime = 0 < inItem.startingTimeInSeconds
        let hasWarning = hasSetTime && 0 < inItem.warningTimeInSeconds
        let hasFinal = hasSetTime && 0 < inItem.finalTimeInSeconds

        self.contentView.backgroundColor = UIColor(named: "\(inItem.isSelected ? "Selected-" : "")Cell-Background")
        self.contentView.borderColor = inItem.isSelected ? .white : .clear
        self.contentView.borderWidth = inItem.isSelected ? Self.borderWidthInDisplayUnits : 0
        self.contentView.cornerRadius = Self._cornerRadiusInDisplayUnits
        self.contentView.clipsToBounds = true
        super.configure(indexPath: inIndexPath, myController: inMyController)
        
        self.item = inItem
        self.indexPath = inIndexPath
        self.contentView.subviews.forEach { $0.removeFromSuperview() }
        let startLabel = UILabel()
        startLabel.textColor = hasSetTime && inItem.isSelected ? UIColor(named: "Start-Color") : (hasSetTime || !inItem.isSelected ? (UIViewController().isDarkMode ? .black : .white) : .systemRed)
        startLabel.font = hasSetTime ? inItem.isSelected ? Self.digitalDisplayFontSmall : Self.unselectedDisplayFontSmall : inItem.isSelected ? Self.digitalDisplayFontBig : Self.unselectedDisplayFontBig
        startLabel.text = hasSetTime ? inItem.setTimeDisplay : ""
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
            warnLabel.textColor = inItem.isSelected ? UIColor(named: "Warn-Color") : UIViewController().isDarkMode ? .black : .white
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
            
            finalLabel.textColor = inItem.isSelected ? UIColor(named: "Final-Color") : UIViewController().isDarkMode ? .black : .white
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
        private static let _cornerRadiusInDisplayUnits = CGFloat(16)
        
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
         The background gradient view.
         */
        weak private var _gradientImageView: UIImageView?
        
        /* ########################################################## */
        /**
         Required (and unsupported) coder init.
         */
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        /* ########################################################## */
        /**
         */
        override init(frame inFrame: CGRect) {
            super.init(frame: inFrame)
            self._lastFrame = inFrame
            self.cornerRadius = Self._cornerRadiusInDisplayUnits
        }
        
        /* ########################################################## */
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

        /* ########################################################## */
        /**
         The background gradient view.
         */
        func createGradient(into inFrame: CGRect) {
            var frame = inFrame
            if 1 < (self.myGroup?.model?.count ?? 0) {
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
        
        /* ########################################################## */
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
                let groupNumberLabel = UILabel()
                groupNumberLabel.backgroundColor = isDarkMode ? UIColor(white: Self._lightModeMax, alpha: 1.0) : UIColor(white: Self._darkModeMax, alpha: 1.0)
                groupNumberLabel.textAlignment = .left
                groupNumberLabel.adjustsFontSizeToFitWidth = true
                groupNumberLabel.minimumScaleFactor = 0.5
                groupNumberLabel.text = " \(String(inLayoutAttributes.indexPath.section + 1)) "
                self.addSubview(groupNumberLabel)
                groupNumberLabel.translatesAutoresizingMaskIntoConstraints = false
                groupNumberLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
                groupNumberLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -0).isActive = true
                groupNumberLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -0).isActive = true
                groupNumberLabel.widthAnchor.constraint(equalToConstant: Self._endcapWidthInDisplayUnits).isActive = true
                groupNumberLabel.cornerRadius = 0
                groupNumberLabel.clipsToBounds = true
                if 1 < group.count {
                    groupNumberLabel.font = Self._endcapFontButton
                    groupNumberLabel.isAccessibilityElement = true
                    groupNumberLabel.accessibilityLabel = "SLUG-ACC-GROUP-BUTTON-LABEL".localizedVariant
                    groupNumberLabel.accessibilityHint = "SLUG-ACC-GROUP-BUTTON-HINT".localizedVariant
                    groupNumberLabel.textColor = UIColor(named: "Selected-Cell-Action-Color")
                    groupNumberLabel.isUserInteractionEnabled = true
                    groupNumberLabel.addGestureRecognizer(UITapGestureRecognizer(target: RiValT_AppDelegate.appDelegateInstance?.groupEditorController, action: #selector(groupBackgroundNumberTapped)))
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
        if let backgroundView = inTapGesture.view as? _SectionBackgroundView,
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
//        } else {
//            inCollectionView.setContentOffset(self._lastScrollPos, animated: true)
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
        self._lastScrollPos = inScrollView.contentOffset
    }
}
