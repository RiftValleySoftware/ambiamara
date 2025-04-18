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
class RiValT_TimerArray_Placeholder: Identifiable, Hashable {
    /* ############################################################## */
    /**
     Equatable Conformance.
     
     - parameter lhs: The left-hand side of the comparison.
     - parameter rhs: The right-hand side of the comparison.
     - returns: True, if they are equal.
     */
    static func == (lhs: RiValT_TimerArray_Placeholder, rhs: RiValT_TimerArray_Placeholder) -> Bool { lhs.id == rhs.id }
    
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
     If we represent an existing timer, we use that UUID.
     */
    var id: UUID { timer?.id ?? self._id }
    
    /* ############################################################## */
    /**
     Initializer.
     
     - parameter inTimer: If this represents an existing timer, that is supplied here. It is optional. If not supplied, this is considered an "add item" placeholder.
     */
    init(timer inTimer: Timer? = nil) {
        self.timer = inTimer
    }
    
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
    static let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(80), heightDimension: .absolute(80))

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
     Configure this cell item with its index path.
     
     - parameter inIndexPath: The index path for the cell being represented.
     */
    func configure(indexPath inIndexPath: IndexPath) {
        self.indexPath = inIndexPath
    }
}

/* ###################################################################################################################################### */
// MARK: - One Display Cell for the Collection View -
/* ###################################################################################################################################### */
/**
 This describes each cell in the collection view.
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
     */
    override func configure(indexPath inIndexPath: IndexPath) {
        super.configure(indexPath: inIndexPath)
        self.contentView.subviews.forEach { $0.removeFromSuperview() }
        let newImage = UIImageView(image: UIImage(systemName: "plus.circle\(self.indexPath?.section == timerModel.count ? ".fill" : "")")?
            .applyingSymbolConfiguration(.init(scale: self.indexPath?.section == timerModel.count ? .large : .medium))
        )
        newImage.contentMode = .center
        newImage.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(newImage)
        newImage.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        newImage.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        newImage.leftAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
        newImage.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
    }
}

/* ###################################################################################################################################### */
// MARK: - One Display Cell for the Collection View -
/* ###################################################################################################################################### */
/**
 This describes each cell in the collection view.
 */
class RiValT_TimerArray_IconCell: RiValT_BaseCollectionCell {
    /* ############################################################## */
    /**
     The width of a selected timer border.
     */
    private static let _borderWidthInDisplayUnits = CGFloat(4)
    
    /* ############################################################## */
    /**
     The large variant of the digital display font.
     */
    static let digitalDisplayFontBig = UIFont(name: "Let\'s go Digital", size: 60)
    
    /* ############################################################## */
    /**
     The large variant of the digital display font.
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
     */
    func configure(with inItem: Timer, indexPath inIndexPath: IndexPath) {
        let cornerRadius = self.contentView.cornerRadius + (Self._borderWidthInDisplayUnits / 2)
        
        /* ########################################################## */
        /**
         This adds a thick dashed border around the cell.
         */
        func _addDashedBorder() {
            self.contentView.layer.sublayers?.removeAll()
            
            if self.item?.isSelected ?? false,
               let dashColor = self.contentView.tintColor?.cgColor {
                let frameSize = self.contentView.frame.size
                let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
                let shapeLayer:CAShapeLayer = CAShapeLayer()
                shapeLayer.bounds = shapeRect
                shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
                shapeLayer.fillColor = UIColor.clear.cgColor
                shapeLayer.strokeColor = dashColor
                // We cut the line in half, so the displayed width is smaller.
                shapeLayer.lineWidth = Self._borderWidthInDisplayUnits * 2
                shapeLayer.lineDashPattern = [5, 3]
                shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: cornerRadius).cgPath
                self.contentView.layer.addSublayer(shapeLayer)
            }
        }
        
        let hasSetTime = 0 < inItem.startingTimeInSeconds
        let hasWarning = hasSetTime && 0 < inItem.warningTimeInSeconds
        let hasFinal = hasSetTime && 0 < inItem.finalTimeInSeconds
        
        self.contentView.backgroundColor = UIColor(named: "\(inItem.isSelected ? "Selected-" : "")Cell-Background")

        super.configure(indexPath: inIndexPath)
        self.item = inItem
        self.indexPath = inIndexPath
        _addDashedBorder()
        self.contentView.subviews.forEach { $0.removeFromSuperview() }
        let startLabel = UILabel()
        startLabel.textColor = hasSetTime && inItem.isSelected ? UIColor(named: "Start-Color") : (hasSetTime ? (UIViewController().isDarkMode ? .black : .white) : .systemRed)
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
 */
class RiValT_MultiTimer_ViewController: RiValT_Base_ViewController {
    /* ############################################################## */
    /**
     The width of the "gutters" around each cell.
     */
    private static let _itemGuttersInDisplayUnits = CGFloat(4)
    
    /* ############################################################## */
    /**
     Used to track scrolling, and to prevent horizontal scroll.
     */
    private var _initialContentOffset: CGPoint = .zero

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
        let appearance = UIToolbarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.backgroundImage = nil
        self.toolbar?.standardAppearance = appearance
        self.toolbar?.scrollEdgeAppearance = appearance
        self.collectionView?.isDirectionalLockEnabled = true
    }
    
    /* ############################################################## */
    /**
     Called just before the view appears.
     
     - parameter inIsAnimated: True, if the appearance is animated.
     */
    override func viewWillAppear(_ inIsAnimated: Bool) {
        super.viewWillAppear(inIsAnimated)
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
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RiValT_MultiTimer_ViewController {
    /* ############################################################## */
    /**
     This establishes the display layout for our collection view.
     
     Each group of timers is a row, with up to 4 timers each.
     
     At the end of rows with less than 4 timers, or at the end of the collection view, we have "add" items.
     */
    func createLayout() {
        // The reason for the weird width, is to prevent the end "add" item from vertically flowing.
        // This only happens, if there are 3 items already there, and a new item is being dragged in from another group.
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.5),
                                               heightDimension: .absolute(RiValT_BaseCollectionCell.itemSize.heightDimension.dimension)
        )

        let item = NSCollectionLayoutItem(layoutSize: RiValT_TimerArray_IconCell.itemSize)

        item.contentInsets = NSDirectionalEdgeInsets(top: Self._itemGuttersInDisplayUnits,
                                                     leading: Self._itemGuttersInDisplayUnits,
                                                     bottom: Self._itemGuttersInDisplayUnits,
                                                     trailing: Self._itemGuttersInDisplayUnits
        )
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        self.collectionView?.collectionViewLayout = UICollectionViewCompositionalLayout(section: NSCollectionLayoutSection(group: group))
    }
    
    /* ############################################################## */
    /**
     This sets up the data source cells.
     */
    func setupDataSource() {
        guard let collectionView = self.collectionView else { return }
        self.dataSource = UICollectionViewDiffableDataSource<Int, RiValT_TimerArray_Placeholder>(collectionView: collectionView) { inCollectionView, inIndexPath, inTimer in
            var ret = UICollectionViewCell()
            
            // If this cell has a timer, we create a timer cell.
            if let timer = self.timerModel.getTimer(at: inIndexPath),
               let cell = inCollectionView.dequeueReusableCell(withReuseIdentifier: RiValT_TimerArray_IconCell.reuseIdentifier, for: inIndexPath) as? RiValT_TimerArray_IconCell {
                cell.configure(with: timer, indexPath: inIndexPath)
                ret = cell
            // Otherwise, we create an add cell.
            } else if let cell = inCollectionView.dequeueReusableCell(withReuseIdentifier: RiValT_TimerArray_AddCell.reuseIdentifier, for: inIndexPath) as? RiValT_TimerArray_AddCell {
                cell.configure(indexPath: inIndexPath)
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
        self.toolbarEditButton?.isEnabled = true
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
                  1 < self.timerModel.allTimers.count,
                  let nextTimerIndexPath = self.timerModel.allTimers[min(self.timerModel.count - 1, (self.timerModel.allTimers.firstIndex(of: timer) ?? 0) + 1)].indexPath,
                  let prevTimerIndexPath = self.timerModel.allTimers[max(0, (self.timerModel.allTimers.firstIndex(of: timer) ?? 0) - 1)].indexPath
            else { return }
            
            if self.timerModel.isValid(indexPath: nextTimerIndexPath),
               nextTimerIndexPath != indexPath {
                self.timerModel.selectTimer(nextTimerIndexPath)
            } else if self.timerModel.isValid(indexPath: prevTimerIndexPath),
                      prevTimerIndexPath != indexPath  {
                self.timerModel.selectTimer(prevTimerIndexPath)
            }
            
            self.timerModel.removeTimer(from: indexPath)
            
            if nil == self.timerModel.selectedTimer {
                self.timerModel.selectTimer(IndexPath(item: 0, section: 0))
            }
            
            self.updateSnapshot()
            self.collectionView?.reloadData()
            self.impactHaptic(1.0)
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
        
        alertController.addAction(okAction)

        let cancelAction = UIAlertAction(title: "SLUG-CANCEL-BUTTON-TEXT".localizedVariant, style: .cancel, handler: nil)

        alertController.addAction(cancelAction)

        self.impactHaptic(1.0)

        present(alertController, animated: true, completion: nil)
    }
    
    /* ############################################################## */
    /**
     */
    @IBAction func toolbarPlayButtonHit(_ inButton: UIBarButtonItem) {
        self.impactHaptic()
    }
    
    /* ############################################################## */
    /**
     */
    @IBAction func toolbarEditButtonHit(_ inButton: UIBarButtonItem) {
        self.impactHaptic()
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
        if nil == self.timerModel.getTimer(at: inIndexPath) {
            self.timerModel.createNewTimer(at: inIndexPath)
        }
        
        if !(self.timerModel.getTimer(at: inIndexPath)?.isSelected ?? false) {
            self.impactHaptic(1.0)
            self.timerModel.getTimer(at: inIndexPath)?.isSelected = true
        }
        
        self.updateSnapshot()
        inCollectionView.reloadData()
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
