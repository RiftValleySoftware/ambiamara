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
extension Array where Element: Hashable, Element: Comparable {
    /* ############################################################## */
    /**
     */
    var unique: [Element] { Array(Set(self)).sorted() }
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
typealias RiValT_TimerArray_IconRow = [RiValT_TimerArray_IconItem]

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
        self.contentView.cornerRadius = 10
    }
    
    /* ############################################################## */
    /**
     */
    func setSelected(_ inIsSelected: Bool) {
        self.contentView.layer.borderColor = inIsSelected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
        self.contentView.layer.borderWidth = inIsSelected ? 3 : 0
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
        super.viewDidLoad()
        self.createLayout()
        self.generateRandomRows()
        self.setupDataSource()
        self.updateToolbarButtons()
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RiValT_TimerArray_ViewController {
    /* ############################################################## */
    /**
     */
    func generateRandomRows() {
        self.rows = (0..<5).map { _ in (0..<Int.random(in: 1...3)).map { _ in RiValT_TimerArray_IconItem(color: .random) } }
    }

    /* ############################################################## */
    /**
     */
    func createLayout() {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(80), heightDimension: .absolute(80))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0)
        
        self.collectionView?.collectionViewLayout = UICollectionViewCompositionalLayout(section: section)
    }
    
    /* ############################################################## */
    /**
     */
    func setupDataSource() {
        guard let collectionView = self.collectionView else { return }
        self.dataSource = UICollectionViewDiffableDataSource<Int, RiValT_TimerArray_IconItem>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RiValT_TimerArray_IconCell.reuseIdentifier, for: indexPath) as! RiValT_TimerArray_IconCell
            cell.configure(with: item)
            let isSelected = indexPath == self.selectedIndexPath
            cell.setSelected(isSelected)
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
    func collectionView(_: UICollectionView, itemsForBeginning: UIDragSession, at inIndexPath: IndexPath) -> [UIDragItem] {
        let item = self.rows[inIndexPath.section][inIndexPath.item]
        let provider = NSItemProvider(object: item.id.uuidString as NSString)
        let dragItem = UIDragItem(itemProvider: provider)
        dragItem.localObject = item
        return [dragItem]
    }
}

/* ###################################################################################################################################### */
// MARK: UICollectionViewDropDelegate Conformance
/* ###################################################################################################################################### */
extension RiValT_TimerArray_ViewController: UICollectionViewDropDelegate {
    /* ############################################################## */
    /**
     */
    func collectionView(_: UICollectionView, canHandle inSession: UIDropSession) -> Bool {
        nil != inSession.localDragSession
    }
    
    /* ############################################################## */
    /**
     */
    func collectionView(_: UICollectionView, dropSessionDidUpdate: UIDropSession, withDestinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }

    /* ############################################################## */
    /**
     */
    func collectionView(_ inCollectionView: UICollectionView, performDropWith inCoordinator: UICollectionViewDropCoordinator) {
        /* ########################################################## */
        /**
         */
        func _indexForNewRow(at inLocation: CGPoint) -> Int? {
            let sortedFrames = collectionView?.visibleCells.compactMap { collectionView?.indexPath(for: $0)?.section }.unique ?? []

            for section in sortedFrames {
                let indexPath = IndexPath(item: 0, section: section)
                if let attributes = collectionView?.layoutAttributesForItem(at: indexPath),
                   inLocation.y < attributes.frame.minY {
                    return section
                }
            }

            return self.rows.count
        }
        
        guard let item = inCoordinator.items.first,
              let draggedItem = item.dragItem.localObject as? RiValT_TimerArray_IconItem
        else { return }

        let sourceIndexPath = item.sourceIndexPath
        let destinationIndexPath = inCoordinator.destinationIndexPath

        inCollectionView.performBatchUpdates {
            // Remove from source
            if let source = sourceIndexPath {
                self.rows[source.section].remove(at: source.item)
                // If that row is now empty, remove the row
                if self.rows[source.section].isEmpty {
                    self.rows.remove(at: source.section)
                }
            }

            if let destIndexPath = destinationIndexPath {
                // Drop into existing row
                self.rows[destIndexPath.section].insert(draggedItem, at: destIndexPath.item)
            } else {
                // Drop between sections: insert a new section
                let location = inCoordinator.session.location(in: inCollectionView)
                if let newSectionIndex = _indexForNewRow(at: location) {
                    self.rows.insert([draggedItem], at: newSectionIndex)
                } else {
                    // fallback: append at end
                    self.rows.append([draggedItem])
                }
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
    }
}

/* ###################################################################################################################################### */
// MARK: UICollectionViewDelegate Conformance
/* ###################################################################################################################################### */
extension RiValT_TimerArray_ViewController: UICollectionViewDelegate {
    /* ############################################################## */
    /**
     */
    func collectionView(_: UICollectionView, didSelectItemAt inIndexPath: IndexPath) {
        if self.selectedIndexPath == inIndexPath {
            self.selectedIndexPath = nil // toggle off if tapping again
        } else {
            self.selectedIndexPath = inIndexPath
        }
    }
}
