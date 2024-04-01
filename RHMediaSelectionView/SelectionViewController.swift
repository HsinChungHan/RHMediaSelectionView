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
    
    // 活動指示器
    private var activityIndicator: UIActivityIndicatorView?
    
    // 儲存加載的照片
    private var selectedImages: [UIImage] = []
    
    // 加載完成的計數器
    private var loadCompletedCounter: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        collectionView.fillSuperView()
        collectionView.register(SelectionViewCell.self, forCellWithReuseIdentifier: "CellID")
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
    
    func presentPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = MAX_SELECTED_PHOTOS - selectedImages.count // 可以自訂選擇的數量
        configuration.filter = .images // 只選擇圖片
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    private func handleLoadedImage(_ image: AnyObject?, from itemProvider: NSItemProvider, totalImagesCount: Int) {
        if let image = image as? UIImage {
            selectedImages.append(image)
        }
        
        loadCompletedCounter += 1
        
        // 檢查是否所有圖片都已加載完成
        if loadCompletedCounter == totalImagesCount {
            hideActivityIndicator()
            // 這裡可以更新UI顯示照片，例如刷新一個collectionView
            collectionView.reloadData()
        }
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
        cell.backgroundColor = Color.Blue.v500
        if selectedImages.count - 1 >= indexPath.row {
            cell.imageView.image = selectedImages[indexPath.row]
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension SelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // 開始更新數據模型
        let item = selectedImages.remove(at: sourceIndexPath.item)
        selectedImages.insert(item, at: destinationIndexPath.item)
        // 這裡你也可以更新後台數據或是持久層的數據
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presentPhotoPicker()
    }
}

// MARK: - PHPickerViewControllerDelegate
extension SelectionViewController: 
    PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        if results.isEmpty {
            // 沒有選擇任何照片
            return
        }
        
        // 重置計數器和照片數組
        loadCompletedCounter = 0
        selectedImages.removeAll()
        
        // 顯示加載指示器
        showActivityIndicator()
        
        // 处理多个选取结果
        for result in results {
            let itemProvider = result.itemProvider
            
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                    DispatchQueue.main.async {
                        self?.handleLoadedImage(image, from: itemProvider, totalImagesCount: results.count)
                    }
                }
            }
        }
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
