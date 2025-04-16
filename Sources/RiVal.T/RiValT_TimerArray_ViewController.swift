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
    static let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(80), heightDimension: .absolute(80))

    /* ############################################################## */
    /**
     The timer item associated with this cell.
     */
    var item: Timer?
    
    /* ############################################################## */
    /**
     */
    func configure(with inItem: Timer) {
        self.item = inItem
        self.contentView.backgroundColor = UIViewController().isDarkMode ? .white : .black
        self.contentView.layer.cornerRadius = 12
        self.contentView.layer.masksToBounds = true
        self.contentView.subviews.forEach { $0.removeFromSuperview() }
        let newLabel = UILabel()
        newLabel.textColor = UIViewController().isDarkMode ? .black : .white
        newLabel.numberOfLines = 2
        newLabel.font = .systemFont(ofSize: 30, weight: .bold)
        newLabel.text = item?.timerDisplay ?? ""
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
// MARK: - -
/* ###################################################################################################################################### */
/**
 
 */
class RiValT_TimerArray_ViewController: RiValT_Base_ViewController {
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
    static let itemsPerRow = TimerGroup.maxTimersInGroup

    /* ############################################################## */
    /**
     */
    @IBOutlet weak var collectionView: UICollectionView?

    /* ############################################################## */
    /**
     */
    var dataSource: UICollectionViewDiffableDataSource<Int, Timer>?
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
        for groupIndex in 0..<5 {
            for timerIndex in 0..<(1 == (groupIndex % 2) ? TimerGroup.maxTimersInGroup : TimerGroup.maxTimersInGroup - 1) {
                let timer = timerModel.createNewTimer(at: IndexPath(item: timerIndex, section: groupIndex))
                timer.startingTimeInSeconds = (groupIndex * TimerGroup.maxTimersInGroup) + timerIndex
            }
        }
    }
    
    /* ############################################################## */
    /**
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
extension RiValT_TimerArray_ViewController {
    /* ############################################################## */
    /**
     */
    func createLayout() {
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(RiValT_TimerArray_IconCell.itemSize.heightDimension.dimension))

        let item = NSCollectionLayoutItem(layoutSize: RiValT_TimerArray_IconCell.itemSize)

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
        self.dataSource = UICollectionViewDiffableDataSource<Int, Timer>(collectionView: collectionView) { (inCollectionView, inIndexPath, inTimer) -> UICollectionViewCell? in
            if let cell = inCollectionView.dequeueReusableCell(withReuseIdentifier: RiValT_TimerArray_IconCell.reuseIdentifier, for: inIndexPath) as? RiValT_TimerArray_IconCell {
                cell.configure(with: inTimer)
                cell.setSelected(inTimer.isSelected)
                return cell
            }
            
            return nil
        }

        self.updateSnapshot()
    }

    /* ############################################################## */
    /**
     */
    func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Timer>()
        for (sectionIndex, group) in self.timerModel.enumerated() {
            snapshot.appendSections([sectionIndex])
            snapshot.appendItems(group.allTimers, toSection: sectionIndex)
        }
        
        self.dataSource?.apply(snapshot, animatingDifferences: true)
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
    }

    /* ############################################################## */
    /**
     */
    @IBAction func deleteItem(_: Any) {
    }
}

/* ###################################################################################################################################### */
// MARK: UICollectionViewDragDelegate Conformance
/* ###################################################################################################################################### */
extension RiValT_TimerArray_ViewController: UICollectionViewDragDelegate {
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

    /* ############################################################## */
    /**
     */
    func collectionView(_: UICollectionView,
                        itemsForBeginning inSession: UIDragSession,
                        at inIndexPath: IndexPath
    ) -> [UIDragItem] {
        print("Starting drag at \(inIndexPath.debugDescription)")
        inSession.localContext = inIndexPath
        let timer = timerModel[indexPath: inIndexPath]
        let provider = NSItemProvider(object: timer.id.uuidString as NSString)
        let dragItem = UIDragItem(itemProvider: provider)
        dragItem.localObject = timer
        self.impactHaptic()

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
    func collectionView(_: UICollectionView,
                        dropSessionDidUpdate inSession: UIDropSession,
                        withDestinationIndexPath inIndexPath: IndexPath?
    ) -> UICollectionViewDropProposal {
        print("Vetting drag at \(inIndexPath.debugDescription)")
        guard let sourceIndexPath = inSession.localDragSession?.localContext as? IndexPath,
              let destinationIndexPath = inIndexPath,
              self.timerModel.canInsertTimer(at: destinationIndexPath, from: sourceIndexPath)
        else {
            print("Cancel: Cannot insert timer at \(inIndexPath.debugDescription)")
            return UICollectionViewDropProposal(operation: .cancel)
        }
        
        print("Can insert timer at \(inIndexPath.debugDescription)")
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }

    /* ############################################################## */
    /**
     */
    func collectionView(_ inCollectionView: UICollectionView,
                        performDropWith inCoordinator: UICollectionViewDropCoordinator
    ) {
        guard let sourceIndexPath = inCoordinator.session.localDragSession?.localContext as? IndexPath,
              let destinationIndexPath = inCoordinator.destinationIndexPath
        else { return }

        print("Moving timer from \(sourceIndexPath), to \(destinationIndexPath)")
        self.timerModel.moveTimer(from: sourceIndexPath, to: destinationIndexPath)
        self.updateSnapshot()
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
        self.timerModel.selectTimer(inIndexPath)
    }
}
