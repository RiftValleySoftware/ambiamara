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
// MARK: - -
/* ###################################################################################################################################### */
/**
 
 */
class RiValT_TimerArray_IconCell: UICollectionViewCell {
    /* ############################################################## */
    /**
     */
    static let reuseIdentifier = "RiValT_TimerArray_IconCell"
    
    /* ############################################################## */
    /**
     */
    func configure(with inItem: RiValT_TimerContainer) {
        self.contentView.backgroundColor = UIViewController().isDarkMode ? .white : .black
        self.contentView.layer.cornerRadius = 12
        self.contentView.layer.masksToBounds = true
        self.contentView.subviews.forEach { $0.removeFromSuperview() }
        let newLabel = UILabel()
        newLabel.textColor = UIViewController().isDarkMode ? .black : .white
        newLabel.numberOfLines = 2
        newLabel.text = inItem.timerDisplay
        newLabel.textAlignment = .center
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(newLabel)
        newLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
        newLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
        newLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
    }
    
    /* ############################################################## */
    /**
     */
    func setSelected(_ inIsSelected: Bool) {
        self.contentView.borderColor = inIsSelected ? .systemBlue : .clear
        self.contentView.borderWidth = inIsSelected ? 3 : 0
    }
}

/* ###################################################################################################################################### */
// MARK: UICollectionViewDropProposal Special Class
/* ###################################################################################################################################### */
/**
 
 */
class RiValT_TimerArray_DropProposal: UICollectionViewDropProposal {
    /* ############################################################## */
    /**
     */
    weak var viewController: RiValT_TimerArray_ViewController?
    
    /* ############################################################## */
    /**
     */
    let session: UIDropSession
    
    /* ############################################################## */
    /**
     */
    let indexPath: IndexPath?

    /* ############################################################## */
    /**
     */
    init(_ inViewController: RiValT_TimerArray_ViewController,
         dropSessionDidUpdate inSession: UIDropSession,
         forIndexPath inIndexPath: IndexPath?
    ) {
        self.viewController = inViewController
        self.session = inSession
        self.indexPath = inIndexPath
        super.init(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    /* ############################################################## */
    /**
     */
    override var intent: UICollectionViewDropProposal.Intent {
        guard let indexPath = self.indexPath,
              let row = self.viewController?.rows[indexPath.section],
              !row.isEmpty,
              3 > row.count,
              indexPath.row < row.count
        else { return .unspecified }
        
        return .insertIntoDestinationIndexPath  // We use "into," in order to prevent reflowing.
    }
}

/* ###################################################################################################################################### */
// MARK: - -
/* ###################################################################################################################################### */
/**
 
 */
class RiValT_TimerArray_ViewController: RiValT_Base_ViewController {
    /* ############################################################## */
    /**
     */
    private static let _itemSize = NSCollectionLayoutSize(widthDimension: .absolute(80), heightDimension: .absolute(80))

    /* ############################################################## */
    /**
     */
    private static let _itemGuttersInDisplayUnits = CGFloat(8)

    /* ############################################################## */
    /**
     */
    private static let _dropLineWidthInDisplayUnits = CGFloat(4)

    /* ############################################################## */
    /**
     */
    private static let _itemsPerRow = 4

    /* ############################################################## */
    /**
     */
    private var _reorderIndicatorView: UIView {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.isHidden = true
        return view
    }

    /* ############################################################## */
    /**
     */
    @IBOutlet weak var collectionView: UICollectionView?

    /* ############################################################## */
    /**
     */
    @IBOutlet weak var addButton: UIBarButtonItem?

    /* ############################################################## */
    /**
     */
    @IBOutlet weak var deleteButton: UIBarButtonItem?

    /* ############################################################## */
    /**
     */
    var dataSource: UICollectionViewDiffableDataSource<Int, RiValT_TimerContainer>?

    /* ############################################################## */
    /**
     */
    var rows = [[RiValT_TimerContainer()]] {
        didSet {
            for (section, items) in rows.enumerated() {
                for (index, _) in items.enumerated() {
                    let newItem = RiValT_TimerContainer()
                    self.rows[section][index] = newItem
                }
            }
        }
    }
    
    /* ############################################################## */
    /**
     */
    var allTimers: [RiValT_TimerContainer] {
        var ret = [RiValT_TimerContainer]()
        
        rows.forEach {
            for (_, item) in $0.enumerated() {
                ret.append(item)
            }
        }
        
        return ret
    }

    /* ############################################################## */
    /**
     */
    var appendRow: Bool = false

    /* ############################################################## */
    /**
     */
    var appendItem: Bool = false

    /* ############################################################## */
    /**
     */
    private var _previousIndexPath: IndexPath?
    
    /* ############################################################## */
    /**
     */
    private var _selectedIndexPath: IndexPath? {
        didSet {
            self.updateCellSelectionAppearance()
            self.updateToolbarButtons()
        }
    }

    /* ############################################################## */
    /**
     */
    var selectedIndexPath: IndexPath? {
        get { self._selectedIndexPath ?? self.lastItemIndexPath }
        set { self._selectedIndexPath = newValue }
    }
    
    /* ############################################################## */
    /**
     */
    var lastItemIndexPath: IndexPath { IndexPath(item: 0, section: self.rows.count - 1) }
    
    /* ############################################################## */
    /**
     */
    var canReorder: Bool { 2 < self.allTimers.count }
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RiValT_TimerArray_ViewController {
    /* ############################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.addSubview(self._reorderIndicatorView)
    }
    
    /* ############################################################## */
    /**
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupDataSource()
        self.createLayout()
        self.updateToolbarButtons()
        self.updateSnapshot()
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RiValT_TimerArray_ViewController {
    /* ############################################################## */
    /**
     */
    func createLayout() {
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(Self._itemSize.heightDimension.dimension))

        let item = NSCollectionLayoutItem(layoutSize: Self._itemSize)

        item.contentInsets = NSDirectionalEdgeInsets(top: Self._itemGuttersInDisplayUnits, leading: Self._itemGuttersInDisplayUnits, bottom: Self._itemGuttersInDisplayUnits, trailing: Self._itemGuttersInDisplayUnits)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Self._itemGuttersInDisplayUnits, bottom: 0, trailing: Self._itemGuttersInDisplayUnits)
        self.collectionView?.collectionViewLayout = UICollectionViewCompositionalLayout(section: section)
    }
    
    /* ############################################################## */
    /**
     */
    func setupDataSource() {
        guard let collectionView = self.collectionView else { return }
        self.dataSource = UICollectionViewDiffableDataSource<Int, RiValT_TimerContainer>(collectionView: collectionView) { (inCollectionView, inIndexPath, inItem) -> UICollectionViewCell? in
            let cell = inCollectionView.dequeueReusableCell(withReuseIdentifier: RiValT_TimerArray_IconCell.reuseIdentifier, for: inIndexPath) as! RiValT_TimerArray_IconCell
            cell.configure(with: inItem)
            cell.setSelected(inIndexPath == self.selectedIndexPath)
            return cell
        }

        self.updateSnapshot()
    }

    /* ############################################################## */
    /**
     */
    func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, RiValT_TimerContainer>()
        for (sectionIndex, row) in self.rows.enumerated() {
            snapshot.appendSections([sectionIndex])
            snapshot.appendItems(row, toSection: sectionIndex)
        }
        
        self.dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    /* ############################################################## */
    /**
     */
    func updateCellSelectionAppearance() {
        for case let cell as RiValT_TimerArray_IconCell in collectionView?.visibleCells ?? [] {
            if let indexPath = self.collectionView?.indexPath(for: cell) {
                cell.setSelected(indexPath == self.selectedIndexPath)
            }
        }
    }
    
    /* ############################################################## */
    /**
     */
    func updateToolbarButtons() {
        guard let section = selectedIndexPath?.section else {
            self.addButton?.isEnabled = false
            self.deleteButton?.isEnabled = false
            return
        }
        self.addButton?.isEnabled = Self._itemsPerRow > self.rows[section].count
        self.deleteButton?.isEnabled = self.selectedIndexPath != self.lastItemIndexPath && !self.rows[section].isEmpty
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension RiValT_TimerArray_ViewController {
    /* ############################################################## */
    /**
     */
    @IBAction func addItem(_: Any) {
        /* ############################################################## */
        /**
         */
        guard let section = self.selectedIndexPath?.section,
              Self._itemsPerRow > self.rows[section].count
        else { return }
        
        var newRows = self.rows
        
        for (section, items) in newRows.enumerated() {
            for (index, _) in items.enumerated() {
                if self.lastItemIndexPath != IndexPath(item: index, section: section) {
                    newRows[section][index] = RiValT_TimerContainer()
                }
            }
        }

        var newIndexPath: IndexPath = IndexPath(item: 0, section: section)
        
        let item = RiValT_TimerContainer()
        
        if section < (newRows.count - 1) {
            newRows[section].append(item)
            newIndexPath.item = newRows[section].count - 1
        } else if 1 < newRows.count {
            newRows.insert([item], at: newRows.count - 1)
            newIndexPath.section = newRows.count - 2
        } else {
            newRows.insert([item], at: 0)
            newIndexPath.section = 0
        }
        
        self.impactHaptic(1.0)
        self.rows = newRows
        self.updateSnapshot()
        self.updateToolbarButtons()
        self.selectedIndexPath = newIndexPath
    }

    /* ############################################################## */
    /**
     */
    @IBAction func deleteItem(_: Any) {
        var newRows = self.rows
        
        for (section, items) in newRows.enumerated() {
            for (index, _) in items.enumerated() {
                if self.lastItemIndexPath != IndexPath(item: index, section: section) {
                    newRows[section][index] = RiValT_TimerContainer()
                }
            }
        }

        guard let section = self.selectedIndexPath?.section,
              let column = self.selectedIndexPath?.item,
              !newRows[section].isEmpty
        else { return }
        
        self.impactHaptic(1.0)
        newRows[section].remove(at: column)
        self.rows = newRows
        self.updateSnapshot()
        self.updateToolbarButtons()
        self.selectedIndexPath = self.lastItemIndexPath
    }
}

/* ###################################################################################################################################### */
// MARK: UICollectionViewDragDelegate Conformance
/* ###################################################################################################################################### */
extension RiValT_TimerArray_ViewController: UICollectionViewDragDelegate {
    /* ############################################################## */
    /**
     */
    func collectionView(_: UICollectionView,
                        itemsForBeginning inSession: UIDragSession,
                        at inIndexPath: IndexPath
    ) -> [UIDragItem] {
        self._previousIndexPath = nil
        self.appendRow = false
        self.appendItem = false

        if self.canReorder,
           inIndexPath != self.lastItemIndexPath {
            inSession.localContext = inIndexPath
            let item = self.rows[inIndexPath.section][inIndexPath.item]
            let provider = NSItemProvider(object: item.id.uuidString as NSString)
            let dragItem = UIDragItem(itemProvider: provider)
            self.selectedIndexPath = inIndexPath
            dragItem.localObject = item
            self.impactHaptic()
            return [dragItem]
        } else {
            return []
        }
    }
    
    /* ############################################################## */
    /**
     */
    func collectionView(_ inCollectionView: UICollectionView,
                        dragPreviewParametersForItemAt inIndexPath: IndexPath) -> UIDragPreviewParameters? {
        let parameters = UIDragPreviewParameters()
        parameters.backgroundColor = .clear
        if let cell = inCollectionView.cellForItem(at: inIndexPath) {
            parameters.visiblePath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.cornerRadius)
            parameters.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.cornerRadius)
        }
        return parameters
    }
}

/* ###################################################################################################################################### */
// MARK: UICollectionViewDropDelegate Conformance
/* ###################################################################################################################################### */
extension RiValT_TimerArray_ViewController: UICollectionViewDropDelegate {
    /* ############################################################## */
    /**
     */
    func collectionView(_: UICollectionView,
                        canHandle inSession: UIDropSession
    ) -> Bool {
        guard let sourceIndexPath = inSession.localDragSession?.localContext as? IndexPath,
              sourceIndexPath.section < rows.count - 1
        else { return false }
        
        return true
    }
    
    /* ############################################################## */
    /**
     */
    func collectionView(_: UICollectionView,
                        dropSessionDidUpdate inSession: UIDropSession,
                        withDestinationIndexPath inIndexPath: IndexPath?
    ) -> UICollectionViewDropProposal {
        let lastItemIndex = IndexPath(row: rows[rows.count - 1].count - 1, section: rows.count - 2)
        guard self.canReorder,
              let collectionView = self.collectionView,
              let destinationIndexPath = inIndexPath,
              destinationIndexPath.section <= lastItemIndex.section,
              let lastItemAttributes = collectionView.layoutAttributesForItem(at: lastItemIndex),
              let sourceIndexPath = inSession.localDragSession?.localContext as? IndexPath
        else {
            self._reorderIndicatorView.isHidden = true
            return UICollectionViewDropProposal(operation: .cancel)
        }
        
        let lastItemSlopInDisplayUnits = Self._itemGuttersInDisplayUnits * 2
        
        self._reorderIndicatorView.isHidden = true
        let location = inSession.location(in: collectionView)
        
        let row = self.rows[destinationIndexPath.section]
        
        guard let lastRowItemAttributes = collectionView.layoutAttributesForItem(at: IndexPath(item: row.count - 1, section: destinationIndexPath.section))
        else { return UICollectionViewDropProposal(operation: .cancel) }
        
        let noFlyZone = (lastRowItemAttributes.frame.minX - (Self._itemGuttersInDisplayUnits * 2))...(lastRowItemAttributes.frame.maxX - lastItemSlopInDisplayUnits)
        if noFlyZone.contains(location.x),
           sourceIndexPath.section == destinationIndexPath.section {
            return UICollectionViewDropProposal(operation: .cancel)
        }

        if location.y > lastItemAttributes.frame.maxY - (Self._itemGuttersInDisplayUnits * 2),
           sourceIndexPath.section < (self.rows.count - 2) || 1 < self.rows[sourceIndexPath.section].count {
            if !self.appendRow {
                self.impactHaptic()
            }
            self.appendRow = true
            self.appendItem = false
            self._previousIndexPath = nil
            self._reorderIndicatorView.frame = CGRect(x: collectionView.frame.minX,
                                                      y: (lastItemAttributes.frame.maxY + Self._itemGuttersInDisplayUnits) - (Self._dropLineWidthInDisplayUnits / 2),
                                                      width: collectionView.frame.width,
                                                      height: Self._dropLineWidthInDisplayUnits)
            self._reorderIndicatorView.isHidden = false
            return RiValT_TimerArray_DropProposal(self, dropSessionDidUpdate: inSession, forIndexPath: sourceIndexPath)
        } else {
            self.appendRow = false
            if destinationIndexPath != sourceIndexPath,
               Self._itemsPerRow > row.count || sourceIndexPath.section == destinationIndexPath.section {
                if location.x > (lastRowItemAttributes.frame.maxX - lastItemSlopInDisplayUnits) {
                    if !self.appendItem {
                        self.impactHaptic()
                    }
                    self.appendItem = true
                    self._previousIndexPath = nil
                    self._reorderIndicatorView.frame = CGRect(x: lastRowItemAttributes.frame.maxX + Self._itemGuttersInDisplayUnits - (Self._dropLineWidthInDisplayUnits / 2),
                                                              y: lastRowItemAttributes.frame.minY,
                                                              width: Self._dropLineWidthInDisplayUnits,
                                                              height: lastRowItemAttributes.frame.height)
                    self._reorderIndicatorView.isHidden = false
                    return RiValT_TimerArray_DropProposal(self, dropSessionDidUpdate: inSession, forIndexPath: destinationIndexPath)
                }
                
                if let indexPath = collectionView.indexPathForItem(at: location),
                   let layoutAttributes = collectionView.layoutAttributesForItem(at: indexPath) {
                    if destinationIndexPath != self._previousIndexPath {
                        self.impactHaptic()
                    }
                    
                    self.appendItem = false
                    self._previousIndexPath = destinationIndexPath

                    let frame = layoutAttributes.frame
                    var xPos = max(0, frame.maxX + (Self._itemGuttersInDisplayUnits - (Self._dropLineWidthInDisplayUnits / 2)))
                    if 0 == destinationIndexPath.item || destinationIndexPath.item < sourceIndexPath.item || sourceIndexPath.section != destinationIndexPath.section {
                        xPos = max(0, frame.minX - (Self._itemGuttersInDisplayUnits + (Self._dropLineWidthInDisplayUnits / 2)))
                    }
                    self._reorderIndicatorView.frame = CGRect(x: xPos,
                                                              y: frame.minY, width: Self._dropLineWidthInDisplayUnits, height: frame.height)
                    self._reorderIndicatorView.isHidden = false
                    return RiValT_TimerArray_DropProposal(self, dropSessionDidUpdate: inSession, forIndexPath: indexPath)
                }
            }
        }
        
        return UICollectionViewDropProposal(operation: .cancel)
    }

    /* ############################################################## */
    /**
     */
    func collectionView(_ inCollectionView: UICollectionView,
                        performDropWith inCoordinator: UICollectionViewDropCoordinator
    ) {
        /* ########################################################## */
        /**
         */
        func _indexForNewRow(at inLocation: CGPoint) -> Int? {
            let frames: [Int] = self.collectionView?.visibleCells.compactMap {
                let ret = self.collectionView?.indexPath(for: $0)?.section
                return ret
            } ?? []
            let sortedFrames = Array(Set(frames)).sorted()
            for section in sortedFrames {
                let indexPath = IndexPath(item: 0, section: section)
                if let attributes = self.collectionView?.layoutAttributesForItem(at: indexPath),
                   inLocation.y < attributes.frame.minY {
                    return section
                }
            }

            return self.rows.count
        }
        
        self._reorderIndicatorView.isHidden = true

        guard let item = inCoordinator.items.first else { return }

        self.impactHaptic(1.0)

        var deferringSelection: IndexPath?
        
        if let sourceIndexPath = item.sourceIndexPath,
           var destinationIndexPath = inCoordinator.destinationIndexPath {
            if self.appendRow {
                self.appendRow = false
                var newRows = self.rows
                inCollectionView.performBatchUpdates {
                    newRows[sourceIndexPath.section].remove(at: sourceIndexPath.item)
                    let newItem = RiValT_TimerContainer()
                    newRows.insert([newItem], at: newRows.count - 1)

                    for section in stride(from: self.rows.count - 1, to: 0, by: -1) {
                        if newRows[section].isEmpty {
                            newRows.remove(at: section)
                        }
                    }
                    
                    self.rows = newRows
                    
                    deferringSelection = IndexPath(row: 0, section: newRows.count - 2)
                }
            } else {
                var newRows = self.rows
                
                inCollectionView.performBatchUpdates {
                    newRows[sourceIndexPath.section].remove(at: sourceIndexPath.item)
                    
                    let newItem = RiValT_TimerContainer()

                    if self.appendItem {
                        self.appendItem = false
                        newRows[destinationIndexPath.section].append(newItem)
                        destinationIndexPath.item += 1
                    } else if destinationIndexPath.item < newRows[destinationIndexPath.section].count {
                        newRows[destinationIndexPath.section].insert(newItem, at: destinationIndexPath.item)
                    }
                    
                    for section in stride(from: self.rows.count - 1, to: 0, by: -1) {
                        if newRows[section].isEmpty {
                            newRows.remove(at: section)
                            if section <= destinationIndexPath.section {
                                destinationIndexPath.section -= 1
                            }
                        }
                    }

                    self.rows = newRows
                    
                    deferringSelection = IndexPath(row: min(newRows[destinationIndexPath.section].count - 1, destinationIndexPath.item), section: destinationIndexPath.section)
                }
            }
            
            updateSnapshot()
            
            if let deferringSelection {
                self.selectedIndexPath = deferringSelection
            }
        }

        if let destIndexPath = inCoordinator.destinationIndexPath {
            inCoordinator.drop(item.dragItem, toItemAt: destIndexPath)
        } else {
            inCoordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(
                insertionIndexPath: IndexPath(item: 0, section: self.rows.count - 1),
                reuseIdentifier: RiValT_TimerArray_IconCell.reuseIdentifier)
            )
        }
        
        self._reorderIndicatorView.isHidden = true
    }
}

/* ###################################################################################################################################### */
// MARK: UICollectionViewDelegate Conformance
/* ###################################################################################################################################### */
extension RiValT_TimerArray_ViewController: UICollectionViewDelegate {
    /* ############################################################## */
    /**
     */
    func collectionView(_: UICollectionView,
                        didSelectItemAt inIndexPath: IndexPath
    ) {
        self.selectedIndexPath = self.selectedIndexPath == inIndexPath ? nil : inIndexPath
    }
}
