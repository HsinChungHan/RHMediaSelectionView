//
//  SelectionViewController.swift
//  RHMediaSelectionView
//
//  Created by Chung Han Hsin on 2024/4/1.
//

import Foundation
import UIKit
import RHUIComponent

class SelectionViewController: UIViewController {
    var backgroundColors: [UIColor] = [
        Color.Blue.v100,
        Color.Blue.v200,
        Color.Blue.v300,
        Color.Blue.v400,
        Color.Blue.v500,
        Color.Blue.v600,
        Color.Blue.v700,
        Color.Blue.v800,
        Color.Blue.v900,
    ]
    
    lazy var collectionView = makeCollectionView()
    lazy var longPressGestureRecognizer = makeLongPressGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        collectionView.fillSuperView()
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CellID")
        collectionView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setCollectionViewLayout()
        
    }
}

// MARK: - Helpers
private extension SelectionViewController {
    func setCollectionViewLayout() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let itemsPerRow: CGFloat = 3
            let rowsPerSection: CGFloat = 3
            let minimumItemSpacing: CGFloat = layout.minimumInteritemSpacing
            let paddingSpace = minimumItemSpacing * (itemsPerRow - 1)
            let availableWidth = collectionView.bounds.width - paddingSpace - layout.sectionInset.left - layout.sectionInset.right
            let widthPerItem = availableWidth / itemsPerRow
            
            let availableHeight = collectionView.bounds.height - paddingSpace - layout.sectionInset.top - layout.sectionInset.bottom
            let heightPerItem = availableHeight / rowsPerSection
            layout.itemSize = CGSize(width: widthPerItem, height: heightPerItem)
            layout.invalidateLayout()
        }
    }
    
    func shakeAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
        animation.values = [-0.02, 0.02]
        animation.autoreverses = true
        animation.duration = 0.1
        animation.repeatCount = Float.infinity
        return animation
    }
}

// MARK: - UICollectionViewDataSource
extension SelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellID", for: indexPath)
        let color = backgroundColors[indexPath.row]
        cell.backgroundColor = color
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension SelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // 開始更新數據模型
        let item = backgroundColors.remove(at: sourceIndexPath.item)
        backgroundColors.insert(item, at: destinationIndexPath.item)
        // 這裡你也可以更新後台數據或是持久層的數據
    }
}


// MARK: - Factory Methods
private extension SelectionViewController {
    func makeCollectionView() -> UICollectionView {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.dataSource = self
        view.delegate = self
        return view
    }
    
    func makeLongPressGestureRecognizer() -> UILongPressGestureRecognizer {
        let penGensture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressGestureRecognizer))
        return penGensture
    }
    
    @objc func didLongPressGestureRecognizer(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
            
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            for cell in collectionView.visibleCells {
                if collectionView.indexPath(for: cell) != selectedIndexPath {
                    cell.layer.add(shakeAnimation(), forKey: "shake")
                }
            }
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionView.endInteractiveMovement()
            for cell in collectionView.visibleCells {
                cell.layer.removeAnimation(forKey: "shake")
            }
        default:
            collectionView.cancelInteractiveMovement()
            for cell in collectionView.visibleCells {
                cell.layer.removeAnimation(forKey: "shake")
            }
        }
    }
    
}
