/*
 © Copyright 2018-2025, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary code, and is not licensed for reuse.
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit

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
            red: CGFloat.random(in: 0.3...1.0),
            green: CGFloat.random(in: 0.3...1.0),
            blue: CGFloat.random(in: 0.3...1.0),
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
    private let squareView = UIView()

    /* ############################################################## */
    /**
     */
    override init(frame inFrame: CGRect) {
        super.init(frame: inFrame)
        contentView.addSubview(self.squareView)
        self.squareView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.squareView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            self.squareView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            self.squareView.topAnchor.constraint(equalTo: contentView.topAnchor),
            self.squareView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        self.squareView.layer.cornerRadius = 10
        self.squareView.clipsToBounds = true
    }
    
    /* ############################################################## */
    /**
     */
    func configure(with inItem: RiValT_TimerArray_IconItem) {
        self.squareView.backgroundColor = inItem.color
    }
    
    /* ############################################################## */
    /**
     */
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /* ############################################################## */
    /**
     */
    func setSelected(_ inIsSelected: Bool) {
        self.squareView.layer.borderColor = inIsSelected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
        self.squareView.layer.borderWidth = inIsSelected ? 3 : 0
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
    var collectionView: UICollectionView?
    
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
    var addButton: UIBarButtonItem?

    /* ############################################################## */
    /**
     */
    var deleteButton: UIBarButtonItem?
    
    /* ############################################################## */
    /**
     */
    var selectedIndexPath: IndexPath? {
        didSet {
            self.updateCellSelectionAppearance()
            self.updateToolbarButtons()
        }
    }

    /* ############################################################## */
    /**
     */
    @objc func addItem() {
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
    @objc func deleteItem() {
        guard let section = self.selectedIndexPath?.section,
              !self.rows[section].isEmpty
        else { return }
        
        self.rows[section].removeLast()
        self.updateSnapshot()
        self.updateToolbarButtons()
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
    
    /* ############################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.generateRandomRows()
        self.setupCollectionView()
        self.setupDataSource()
        self.title = "Icon Grid"
        self.navigationController?.navigationBar.prefersLargeTitles = true

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addItem))
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.deleteItem))

        self.navigationItem.rightBarButtonItems = [addButton]
        self.navigationItem.leftBarButtonItems = [deleteButton]

        self.addButton = addButton
        self.deleteButton = deleteButton
        
        self.updateToolbarButtons()
    }

    /* ############################################################## */
    /**
     */
    func generateRandomRows() {
        // Create 10 rows, each with 1 to 3 random items
        self.rows = (0..<5).map { _ in
            (0..<Int.random(in: 1...3)).map { _ in RiValT_TimerArray_IconItem(color: .random) }
        }
    }

    /* ############################################################## */
    /**
     */
    func setupCollectionView() {
        let layout = self.createLayout()
        guard let view = self.view else { return }
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        self.collectionView = collectionView
        view.addSubview(collectionView)
        
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.register(RiValT_TimerArray_IconCell.self, forCellWithReuseIdentifier: RiValT_TimerArray_IconCell.reuseIdentifier)
        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.delegate = self
    }

    /* ############################################################## */
    /**
     */
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(80), heightDimension: .absolute(80))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0)
        
        return UICollectionViewCompositionalLayout(section: section)
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
}

/* ###################################################################################################################################### */
// MARK: Drag and Drop Delegate Conformance
/* ###################################################################################################################################### */
extension RiValT_TimerArray_ViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate {
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

    /* ############################################################## */
    /**
     */
    func collectionView(_ inCollectionView: UICollectionView, performDropWith inCoordinator: UICollectionViewDropCoordinator) {
        /* ########################################################## */
        /**
         */
        func indexForNewRow(at inLocation: CGPoint) -> Int? {
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
        
        guard
            let item = inCoordinator.items.first,
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
                if let newSectionIndex = indexForNewRow(at: location) {
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
    
    /* ############################################################## */
    /**
     */
    func collectionView(_: UICollectionView, dropSessionDidUpdate: UIDropSession, withDestinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }

    /* ############################################################## */
    /**
     */
    func collectionView(_: UICollectionView, canHandle inSession: UIDropSession) -> Bool {
        nil != inSession.localDragSession
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
