//
//  SelectionViewViewModel.swift
//  RHMediaSelectionView
//
//  Created by Chung Han Hsin on 2024/4/1.
//

import UIKit
import PhotosUI

protocol SelectionViewViewModelDelegate: AnyObject {
    func selectionViewViewModel(_ selectionViewViewModel: SelectionViewViewModel, shouldPresentPikcer picker: PHPickerViewController)
    func selectionViewViewModel(_ selectionViewViewModel: SelectionViewViewModel, shouldReloadImageAtIndex index: Int)
    func selectionViewViewModel(_ selectionViewViewModel: SelectionViewViewModel, shouldShowActivityIndicator: Bool)
    func selectionViewViewModel(_ selectionViewViewModel: SelectionViewViewModel, shouldHideActivityIndicator: Bool)
    func selectionViewViewModel(_ selectionViewViewModel: SelectionViewViewModel, didFinishUploadingImageAt cellModelIndex: Int)
    
    func selectionViewViewModel(_ selectionViewViewModel: SelectionViewViewModel, isUploadingImageAt cellModelIndex: Int, withProgress progress: Float)
    
}

class SelectionViewViewModel {
    weak var delegate: SelectionViewViewModelDelegate?
    let concurrentQueue = DispatchQueue.global()
    let selectionModelQueue = DispatchQueue(label: "com.selectionModelQueue")
    
    var replacedIndex: Int? = nil
    var selectedImagesCount: Int {
        selectionCellModels.compactMap { $0.photo }.count
    }
    
    lazy var selectionCellModels = (1...maxSelectionLimit).map { SelectionViewCellModel(uid: "\($0 - 1)", photo: nil) }
    
    var allowedSelectionLimit: Int { maxSelectionLimit - selectedImagesCount }
    
    lazy var photoPickerManagerUseCase = makePhotoPickerManagerUseCase()
    let maxSelectionLimit: Int
    init(maxSelectionLimit: Int) {
        self.maxSelectionLimit = maxSelectionLimit
    }
}

// MARK: - Internal
extension SelectionViewViewModel {
    func selectPhoto(atIndex index: Int) {
        if selectionCellModels[index].isUploadingImage {
            return 
        }
        if index <= selectedImagesCount - 1 {
            replacePhoto(atIndex: index)
            return
        }
        addNewPhotos()
    }
    
    func moveCell(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath, completion: (IndexPath) -> Void) {
        let item = selectionCellModels.remove(at: sourceIndexPath.item)
        let nextContinuousIndex = selectedImagesCount
        let targetIndex = min(destinationIndexPath.row, nextContinuousIndex)
        selectionCellModels.insert(item, at: targetIndex)
        let shouldMoveCellToLastContinuousCellsIndex = destinationIndexPath.row >= targetIndex
        if shouldMoveCellToLastContinuousCellsIndex {
            let lastContunousImageCellIndexPath = IndexPath(item: targetIndex, section: destinationIndexPath.section)
            completion(lastContunousImageCellIndexPath)
        }
    }
    
    func removePhoto(at indexPath: IndexPath, willReloadCellAt: (IndexPath) -> Void, willMoveCellTo: (IndexPath) -> Void) {
        selectionCellModels[indexPath.row].photo = nil
        willReloadCellAt(indexPath)
        
        let destinationIndexPath = IndexPath.init(row: maxSelectionLimit - 1, section: 0)
        moveCell(at: indexPath, to: destinationIndexPath) { lastContunousImageCellIndexPath in
            willMoveCellTo(lastContunousImageCellIndexPath)
        }
    }
    
    func didFinishUploadingImage(with cellID: String) {
        guard let itemIndex = findCellModelIndex(with: cellID) else { return }
        self.selectionCellModels[itemIndex].isUploadingImage = false
        self.delegate?.selectionViewViewModel(self, didFinishUploadingImageAt: itemIndex)
    }
}

// MARK: - Helpers
private extension SelectionViewViewModel {
    func addNewPhotos() {
        if allowedSelectionLimit == 0 { return }
        photoPickerManagerUseCase.presentPhotoPicker(with: allowedSelectionLimit)
    }
    
    func replacePhoto(atIndex index: Int) {
        replacedIndex = index
        photoPickerManagerUseCase.presentPhotoPicker(with: 1)
    }
    
    func uploadImage(at cellModelIndex: Int) {
        let cellID = self.selectionCellModels[cellModelIndex].uid
        guard let image = self.selectionCellModels[cellModelIndex].photo else { return }
        concurrentQueue.async { [weak self] in
            guard let self else { return }
            guard let imageData = image.compress() else { return }
            let imgUrUploader = ImgUrUploader()
            imgUrUploader.uploadImageToImgur(imageData: imageData, taskID: cellID) { [weak self] progrss in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.isUploadingImage(with: cellID, progress: progrss)
                }
            }
        }
    }
    
    private func isUploadingImage(with cellID: String, progress: Float) {
        guard let itemIndex = findCellModelIndex(with: cellID) else { return }
        delegate?.selectionViewViewModel(self, isUploadingImageAt: itemIndex, withProgress: progress)
    }
    
    
    
    private func findCellModelIndex(with cellID: String) -> Int? {
        guard let itemIndex = self.selectionCellModels.firstIndex(where: { $0.uid == cellID }) else { return nil }
        return itemIndex
    }
}

extension SelectionViewViewModel {
    func makePhotoPickerManagerUseCase() -> PhotoPickerManagerUseCase {
        let usecase = PhotoPickerManagerUseCase()
        usecase.delegate = self
        return usecase
    }
}

extension SelectionViewViewModel: PhotoPickerManagerUseCaseDelegate {
    
    nonisolated func photoPickerManager(_ photoPickerManager: PhotoPickerManagerUseCase, shouldPresentPikcer picker: PHPickerViewController) {
        delegate?.selectionViewViewModel(self, shouldPresentPikcer: picker)
    }
    
    func photoPickerManager(_ photoPickerManager: PhotoPickerManagerUseCase, shouldShowActivityIndicator: Bool) {
        delegate?.selectionViewViewModel(self, shouldShowActivityIndicator: true)
    }
    
    private func makeReloadImageIndex() -> Int {
        var shouldReloadImageAtIndex: Int
        if let replacedIndex {
            shouldReloadImageAtIndex = replacedIndex
            self.replacedIndex = nil
        } else {
            shouldReloadImageAtIndex = max(selectedImagesCount, 0)
        }
        return shouldReloadImageAtIndex
    }
    
    func photoPickerManager(_ photoPickerManager: PhotoPickerManagerUseCase, didLoadImage image: UIImage, isFinishLoading: Bool) {
        let shouldReloadImageAtIndex = makeReloadImageIndex()
        selectionCellModels[shouldReloadImageAtIndex].photo = image
        selectionCellModels[shouldReloadImageAtIndex].isUploadingImage = true
        delegate?.selectionViewViewModel(self, shouldReloadImageAtIndex: shouldReloadImageAtIndex)
        
        uploadImage(at: shouldReloadImageAtIndex)
        
        if isFinishLoading {
            delegate?.selectionViewViewModel(self, shouldHideActivityIndicator: true)
        }
    }
    
    func photoPickerManager(_ photoPickerManager: PhotoPickerManagerUseCase, didOccurWithError error: PhotoPickerManagerUseCaseError) {}
}
