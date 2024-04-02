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
}

class SelectionViewViewModel {
    weak var delegate: SelectionViewViewModelDelegate?
    
    var replacedIndex: Int? = nil
    var selectedImagesCount: Int {
        selectionCellModels.compactMap { $0.photo }.count
    }
    lazy var selectionCellModels = (1...maxSelectionLimit).map { SelectionViewCellModel(uid: "\($0)", photo: nil) }
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
        let shouldMoveCellToLastContinuousCellsIndex = destinationIndexPath.row > targetIndex
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
}

extension SelectionViewViewModel {
    func makePhotoPickerManagerUseCase() -> PhotoPickerManagerUseCase {
        let usecase = PhotoPickerManagerUseCase()
        usecase.delegate = self
        return usecase
    }
}

extension SelectionViewViewModel: PhotoPickerManagerUseCaseDelegate {
    func photoPickerManager(_ photoPickerManager: PhotoPickerManagerUseCase, shouldPresentPikcer picker: PHPickerViewController) {
        delegate?.selectionViewViewModel(self, shouldPresentPikcer: picker)
    }
    
    func photoPickerManager(_ photoPickerManager: PhotoPickerManagerUseCase, shouldShowActivityIndicator: Bool) {
        delegate?.selectionViewViewModel(self, shouldShowActivityIndicator: true)
    }
    
    func photoPickerManager(_ photoPickerManager: PhotoPickerManagerUseCase, didLoadImage image: UIImage, isFinishLoading: Bool) {
        var shouldReloadImageAtIndex: Int
        if let replacedIndex {
            shouldReloadImageAtIndex = replacedIndex
            selectionCellModels[replacedIndex].photo = image
            self.replacedIndex = nil
        } else {
            selectionCellModels[selectedImagesCount].photo = image
            shouldReloadImageAtIndex = selectedImagesCount - 1
        }
        delegate?.selectionViewViewModel(self, shouldReloadImageAtIndex: shouldReloadImageAtIndex)
        
        if isFinishLoading {
            delegate?.selectionViewViewModel(self, shouldHideActivityIndicator: true)
        }
    }
    
    func photoPickerManager(_ photoPickerManager: PhotoPickerManagerUseCase, didOccurWithError error: PhotoPickerManagerUseCaseError) {}
}
