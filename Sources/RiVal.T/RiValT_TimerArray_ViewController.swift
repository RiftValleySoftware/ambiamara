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

class RiValT_TimerArray_Placeholder: Identifiable, Hashable {
    static func == (lhs: RiValT_TimerArray_Placeholder, rhs: RiValT_TimerArray_Placeholder) -> Bool { lhs.id == rhs.id }
    
    /* ############################################################## */
    /**
     */
    var timer: Timer?
    
    /* ############################################################## */
    /**
     */
    var _id: UUID = UUID()
    
    /* ############################################################## */
    /**
     */
    var id: UUID { timer?.id ?? self._id }
    
    /* ############################################################## */
    /**
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
// MARK: - One Display Cell for the Collection View -
/* ###################################################################################################################################### */
/**
 This describes each cell in the collection view.
 */
class RiValT_TimerArray_AddCell: UICollectionViewCell {
    /* ############################################################## */
    /**
     */
    static let reuseIdentifier = "RiValT_TimerArray_AddCell"
    
    /* ############################################################## */
    /**
     */
    func configure() {
        self.contentView.backgroundColor = UIColor(named: "Accent Color")
        self.contentView.layer.cornerRadius = RiValT_TimerArray_IconCell.itemSize.widthDimension.dimension / 2
        self.contentView.subviews.forEach { $0.removeFromSuperview() }
        let newImage = UIImageView(image: UIImage(systemName: "plus"))
        newImage.contentMode = .scaleAspectFit
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
        newLabel.font = UIFont(name: "Let\'s go Digital", size: 60)
        newLabel.text = inItem.timerDisplay
        newLabel.adjustsFontSizeToFitWidth = true
        newLabel.minimumScaleFactor = 0.25
        newLabel.textAlignment = .center
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(newLabel)
        newLabel.centerYAnchor.constraint(greaterThanOrEqualTo: self.contentView.centerYAnchor).isActive = true
        newLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 4).isActive = true
        newLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -4).isActive = true
        self.contentView.borderColor = inItem.isSelected ? .systemBlue : .clear
        self.contentView.borderWidth = inItem.isSelected ? 3 : 0
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
    var dataSource: UICollectionViewDiffableDataSource<Int, RiValT_TimerArray_Placeholder>?

    /* ############################################################## */
    /**
     */
    var lastIndexPath: IndexPath?
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
        for groupIndex in 0..<15 {
            for timerIndex in 0..<(Int.random(in: 1...TimerGroup.maxTimersInGroup)) {
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
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(RiValT_TimerArray_IconCell.itemSize.heightDimension.dimension)
        )

        let item = NSCollectionLayoutItem(layoutSize: RiValT_TimerArray_IconCell.itemSize)

        item.contentInsets = NSDirectionalEdgeInsets(top: Self._itemGuttersInDisplayUnits,
                                                     leading: Self._itemGuttersInDisplayUnits,
                                                     bottom: Self._itemGuttersInDisplayUnits,
                                                     trailing: Self._itemGuttersInDisplayUnits
        )
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                        leading: Self._itemGuttersInDisplayUnits,
                                                        bottom: 0,
                                                        trailing: Self._itemGuttersInDisplayUnits
        )
        
        self.collectionView?.collectionViewLayout = UICollectionViewCompositionalLayout(section: section)
    }
    
    /* ############################################################## */
    /**
     */
    func setupDataSource() {
        guard let collectionView = self.collectionView else { return }
        self.dataSource = UICollectionViewDiffableDataSource<Int, RiValT_TimerArray_Placeholder>(collectionView: collectionView) { inCollectionView, inIndexPath, inTimer in
            var ret = UICollectionViewCell()
            
            if inIndexPath.item == self.timerModel[inIndexPath.section].count,
               nil == inTimer.timer,
                let cell = inCollectionView.dequeueReusableCell(withReuseIdentifier: RiValT_TimerArray_AddCell.reuseIdentifier, for: inIndexPath) as? RiValT_TimerArray_AddCell {
                cell.configure()
                ret = cell
            } else if let cell = inCollectionView.dequeueReusableCell(withReuseIdentifier: RiValT_TimerArray_IconCell.reuseIdentifier, for: inIndexPath) as? RiValT_TimerArray_IconCell,
                      let timer = inTimer.timer {
                cell.configure(with: timer)
                ret = cell
            }
            
            return ret
        }
        
        collectionView.dataSource = self.dataSource
    }

    /* ############################################################## */
    /**
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
        
        self.dataSource?.apply(snapshot, animatingDifferences: false)
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
            parameters.backgroundColor = .clear
            parameters.visiblePath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.cornerRadius)
            parameters.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.cornerRadius)
        }
        return parameters
    }

    /* ############################################################## */
    /**
     */
    func collectionView(_ inCollectionView: UICollectionView,
                        itemsForBeginning inSession: UIDragSession,
                        at inIndexPath: IndexPath
    ) -> [UIDragItem] {
        guard self.timerModel.isValid(indexPath: inIndexPath) else { return [] }
        self.lastIndexPath = inIndexPath
        inSession.localContext = inIndexPath
        self.timerModel.selectTimer(inIndexPath)
        inCollectionView.reloadData()
        let timer = self.timerModel[indexPath: inIndexPath]
        let provider = NSItemProvider(object: timer.id.uuidString as NSString)
        let dragItem = UIDragItem(itemProvider: provider)
        dragItem.localObject = timer
        self.impactHaptic(1.0)

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
extension RiValT_TimerArray_ViewController: UICollectionViewDelegate {
    /* ############################################################## */
    /**
     */
    func collectionView(_ inCollectionView: UICollectionView,
                        didSelectItemAt inIndexPath: IndexPath
    ) {
        self.timerModel.selectTimer(inIndexPath)
        inCollectionView.reloadData()
    }
}
