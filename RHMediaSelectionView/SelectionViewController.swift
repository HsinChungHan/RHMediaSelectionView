//
//  SelectionViewController.swift
//  RHMediaSelectionView
//
//  Created by Chung Han Hsin on 2024/4/1.
//

import Foundation
import UIKit
import PhotosUI
import RHUIComponent

class SelectionViewController: UIViewController {
    let MAX_SELECTED_PHOTOS = 9
    
    lazy var collectionView = makeCollectionView()
    lazy var longPressGestureRecognizer = makeLongPressGestureRecognizer()
    let viewModel = SelectionViewViewModel()
    
    private var activityIndicator: UIActivityIndicatorView?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        collectionView.fillSuperView()
        collectionView.register(SelectionViewCell.self, forCellWithReuseIdentifier: "CellID")
        collectionView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.delegate = self
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
            print()
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
    
    private func showActivityIndicator() {
        if activityIndicator == nil {
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.center = self.view.center
            self.view.addSubview(indicator)
            activityIndicator = indicator
        }
        activityIndicator?.startAnimating()
    }
    
    private func hideActivityIndicator() {
        activityIndicator?.stopAnimating()
    }
}

// MARK: - UICollectionViewDataSource
extension SelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellID", for: indexPath) as! SelectionViewCell
        cell.setupImage(with: viewModel.selectionCellModels[indexPath.row].photo)
        cell.delegate = self
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension SelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // 開始更新數據模型
        let item = viewModel.selectionCellModels.remove(at: sourceIndexPath.item)
        let targetIndex = min(destinationIndexPath.row, viewModel.selectedImagesCount - 1)
        viewModel.selectionCellModels.insert(item, at: targetIndex)
        let shouldMoveCellToLastContinuousCellsIndex = destinationIndexPath.row > viewModel.selectedImagesCount - 1
        if shouldMoveCellToLastContinuousCellsIndex {
            let visualDestinationIndexPath = IndexPath(item: viewModel.selectedImagesCount - 1, section: destinationIndexPath.section)
            collectionView.moveItem(at: destinationIndexPath, to: visualDestinationIndexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectPhoto(atIndex: indexPath.row)
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
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressGestureRecognizer))
        return longPressGesture
    }
    
    @objc func didLongPressGestureRecognizer(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
            
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            let cell = collectionView.cellForItem(at: selectedIndexPath)
            cell?.layer.add(shakeAnimation(), forKey: "shake")
//            for cell in collectionView.visibleCells {
//                if collectionView.indexPath(for: cell) != selectedIndexPath {
//                    cell.layer.add(shakeAnimation(), forKey: "shake")
//                }
//            }
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

extension SelectionViewController: SelectionViewViewModelDelegate {
    func selectionViewViewModel(_ selectionViewViewModel: SelectionViewViewModel, shouldHideActivityIndicator: Bool) {
        hideActivityIndicator()
    }
    
    func selectionViewViewModel(_ selectionViewViewModel: SelectionViewViewModel, shouldShowActivityIndicator: Bool) {
        showActivityIndicator()
    }
    
    func selectionViewViewModel(_ selectionViewViewModel: SelectionViewViewModel, shouldPresentPikcer picker: PHPickerViewController) {
        present(picker, animated: true)
    }
    
    func selectionViewViewModel(_ selectionViewViewModel: SelectionViewViewModel, shouldReloadImageAtIndex index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        collectionView.reloadItems(at: [indexPath])
    }
}

extension SelectionViewController: SelectionViewCellDelegate {
    func selectionViewCell(_ selectionViewCell: SelectionViewCell, didTapRemoveButton button: UIButton) {
        guard let indexPath = collectionView.indexPath(for: selectionViewCell) else { return }
        viewModel.selectionCellModels[indexPath.row].photo = nil
        collectionView.reloadItems(at: [indexPath])
        
        let item = viewModel.selectionCellModels.remove(at: indexPath.row)
        viewModel.selectionCellModels.append(item)
//        viewModel.selectionCellModels.insert(item, at: viewModel.selectionCellModels.count - 1)
        collectionView.moveItem(at: indexPath, to: IndexPath.init(row: viewModel.selectionCellModels.count - 1, section: 0))
    }
}
