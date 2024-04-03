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
    let maxSelectionLimit = 15
    
    lazy var collectionView = makeCollectionView()
    lazy var longPressGestureRecognizer = makeLongPressGestureRecognizer()
    lazy var viewModel = SelectionViewViewModel.init(maxSelectionLimit: maxSelectionLimit)
    
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
        collectionView.register(SelectionViewCell.self, forCellWithReuseIdentifier: String(describing: SelectionViewCell.self))
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
            let rowsPerSection: CGFloat = 5
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
        return maxSelectionLimit
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: SelectionViewCell.self), for: indexPath) as! SelectionViewCell
        cell.setupImage(with: viewModel.selectionCellModels[indexPath.row].photo)
        cell.setupIsUploadingPhoto(with: viewModel.selectionCellModels[indexPath.row].isUploadingImage)
        cell.delegate = self
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension SelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.moveCell(at: sourceIndexPath, to: destinationIndexPath) { [weak self] lastContunousImageCellIndexPath in
            guard let self else { return }
            collectionView.moveItem(at: destinationIndexPath, to: lastContunousImageCellIndexPath)
            print(self.viewModel.selectionCellModels.map { $0.uid })
            print("====")
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
            // 只有 photo 不為 nil 的 cell 才可以拖動
            guard
                let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)),
                let _ = viewModel.selectionCellModels[selectedIndexPath.row].photo
            else {
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
    
    func selectionViewViewModel(_ selectionViewViewModel: SelectionViewViewModel, didUpdateCellModelImageAt itemIndex: Int) {
        let indexPath = IndexPath(row: itemIndex, section: 0)
        collectionView.reloadItems(at: [indexPath])
    }
    
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
        viewModel.removePhoto(at: indexPath) { [weak self] sourceIndexPath in
            guard let self else { return }
            self.collectionView.reloadItems(at: [sourceIndexPath])
        } willMoveCellTo: { [weak self] lastContunousImageCellIndexPath in
            guard let self else { return }
            self.collectionView.moveItem(at: indexPath, to: lastContunousImageCellIndexPath)
            print(viewModel.selectionCellModels.map { $0.uid })
            print("====")
        }
    }
}
