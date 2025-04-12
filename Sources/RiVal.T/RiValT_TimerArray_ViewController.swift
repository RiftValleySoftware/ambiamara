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
extension UIColor {
    /* ############################################################## */
    /**
     */
    static var random: UIColor {
        return UIColor(
            red: CGFloat.random(in: 0.3...0.9),
            green: CGFloat.random(in: 0.3...0.9),
            blue: CGFloat.random(in: 0.3...0.9),
            alpha: 1.0
        )
    }
}

/* ###################################################################################################################################### */
// MARK: - -
/* ###################################################################################################################################### */
/**
 
 */
struct RiValT_TimerArray_IconItem: Hashable {
    /* ############################################################## */
    /**
     */
    let id = UUID()
    
    /* ############################################################## */
    /**
     */
    let color: UIColor
}

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
    func configure(with inItem: RiValT_TimerArray_IconItem) {
        self.contentView.backgroundColor = inItem.color
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
    private static let _itemGuttersInDisplayUnits = CGFloat(4)

    /* ############################################################## */
    /**
     */
    private var reorderIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.isHidden = true
        return view
    }()

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
    var dataSource: UICollectionViewDiffableDataSource<Int, RiValT_TimerArray_IconItem>?

    /* ############################################################## */
    /**
     */
    var rows: [[RiValT_TimerArray_IconItem]] = []
    
    /* ############################################################## */
    /**
     */
    var selectedIndexPath: IndexPath? {
        didSet {
            self.updateCellSelectionAppearance()
            self.updateToolbarButtons()
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RiValT_TimerArray_ViewController {
    /* ############################################################## */
    /**
     */
    override func viewDidLoad() {
        /* ########################################################## */
        /**
         */
        func _generateRandomRows() {
            self.rows = (0..<5).map { _ in (0..<Int.random(in: 1...3)).map { _ in RiValT_TimerArray_IconItem(color: .random) } }
        }

        super.viewDidLoad()
        
        _generateRandomRows()
        
        self.setupDataSource()
        self.createLayout()
        self.updateToolbarButtons()
        self.collectionView?.addSubview(self.reorderIndicatorView)
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
        
        self.collectionView?.collectionViewLayout = UICollectionViewCompositionalLayout(section: section)
    }
    
    /* ############################################################## */
    /**
     */
    func setupDataSource() {
        guard let collectionView = self.collectionView else { return }
        self.dataSource = UICollectionViewDiffableDataSource<Int, RiValT_TimerArray_IconItem>(collectionView: collectionView) { (inCollectionView, inIndexPath, inItem) -> UICollectionViewCell? in
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
        var snapshot = NSDiffableDataSourceSnapshot<Int, RiValT_TimerArray_IconItem>()
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
        self.addButton?.isEnabled = 3 > self.rows[section].count
        self.deleteButton?.isEnabled = !self.rows[section].isEmpty
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
        guard let section = self.selectedIndexPath?.section,
              3 > self.rows[section].count
        else { return }
        
        self.rows[section].append(RiValT_TimerArray_IconItem(color: .random))
        self.updateSnapshot()
        self.updateToolbarButtons()
    }

    /* ############################################################## */
    /**
     */
    @IBAction func deleteItem(_: Any) {
        guard let section = self.selectedIndexPath?.section,
              !self.rows[section].isEmpty
        else { return }
        
        self.rows[section].removeLast()
        self.updateSnapshot()
        self.updateToolbarButtons()
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
        inSession.localContext = inIndexPath
        let item = self.rows[inIndexPath.section][inIndexPath.item]
        let provider = NSItemProvider(object: item.id.uuidString as NSString)
        let dragItem = UIDragItem(itemProvider: provider)
        dragItem.localObject = item
        return [dragItem]
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
        nil != inSession.localDragSession
    }
    
    /* ############################################################## */
    /**
     */
    func collectionView(_: UICollectionView,
                        dropSessionDidUpdate inSession: UIDropSession,
                        withDestinationIndexPath inIndexPath: IndexPath?
    ) -> UICollectionViewDropProposal {
        guard let collectionView = self.collectionView,
              let indexPath = inIndexPath,
              let sourceIndexPath = inSession.localDragSession?.localContext as? IndexPath
        else {
            self.reorderIndicatorView.isHidden = true
            return UICollectionViewDropProposal(operation: .cancel)
        }
        
        let row = self.rows[indexPath.section]
        let location = inSession.location(in: collectionView)

        if (row.count < 3 || sourceIndexPath.section == indexPath.section),
           (sourceIndexPath.section != indexPath.section || (sourceIndexPath.row != indexPath.row && sourceIndexPath.row + 1 != indexPath.row)) {
            // Get layout attributes for last item in the section. We use this, to see if we will be appending.
            if let lastItemIndex = row.indices.last,
               let lastAttributes = collectionView.layoutAttributesForItem(at: IndexPath(item: lastItemIndex, section: indexPath.section)) {
                
                // If we are more than halfway across the last item in the row, we append at the end.
                if location.x > (lastAttributes.frame.midX + Self._itemGuttersInDisplayUnits) {
                    self.reorderIndicatorView.frame = CGRect(x: lastAttributes.frame.maxX + Self._itemGuttersInDisplayUnits,
                                                             y: lastAttributes.frame.minY,
                                                             width: 4,
                                                             height: lastAttributes.frame.height)
                    self.reorderIndicatorView.isHidden = false
                    return RiValT_TimerArray_DropProposal(self, dropSessionDidUpdate: inSession, forIndexPath: indexPath)
                }
            }
            
            if let indexPath = collectionView.indexPathForItem(at: location),
               let layoutAttributes = collectionView.layoutAttributesForItem(at: indexPath) {
                let frame = layoutAttributes.frame
                let lineThickness = 3.0
                self.reorderIndicatorView.frame = CGRect(x: max(0, frame.minX - ((lineThickness / 2) + Self._itemGuttersInDisplayUnits)), y: frame.minY, width: lineThickness, height: frame.height)
                self.reorderIndicatorView.isHidden = false
                return RiValT_TimerArray_DropProposal(self, dropSessionDidUpdate: inSession, forIndexPath: indexPath)
            }
        }
        
        self.reorderIndicatorView.isHidden = true
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
        
        guard let item = inCoordinator.items.first,
              let draggedItem = item.dragItem.localObject as? RiValT_TimerArray_IconItem
        else { return }

        if let sourceIndexPath = item.sourceIndexPath,
           let destinationIndexPath = inCoordinator.destinationIndexPath {
            var newRows = self.rows
            
            inCollectionView.performBatchUpdates {
                newRows[sourceIndexPath.section].remove(at: sourceIndexPath.item)

                if destinationIndexPath.row < (self.rows[destinationIndexPath.section].count - 1) {
                    newRows[destinationIndexPath.section].insert(draggedItem, at: destinationIndexPath.row)
                } else {
                    newRows[destinationIndexPath.section].append(draggedItem)
                }
                
                for section in stride(from: self.rows.count - 1, to: 0, by: -1) {
                    if newRows[section].isEmpty {
                        newRows.remove(at: section)
                    }
                }
                
                self.rows = newRows
            }
            
            updateSnapshot()
        }

        if let destIndexPath = inCoordinator.destinationIndexPath {
            inCoordinator.drop(item.dragItem, toItemAt: destIndexPath)
        } else {
            inCoordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(
                insertionIndexPath: IndexPath(item: 0, section: self.rows.count - 1),
                reuseIdentifier: RiValT_TimerArray_IconCell.reuseIdentifier)
            )
        }
        
        self.reorderIndicatorView.isHidden = true
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
