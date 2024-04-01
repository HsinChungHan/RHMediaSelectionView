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
    let MAX_SELECTION_LIMIT = 9
    var replacedIndex: Int? = nil
    var selectedImages = [UIImage]()
    var allowedSelectionLimit: Int {
        MAX_SELECTION_LIMIT - selectedImages.count
    }
    
    lazy var photoPickerManagerUseCase = makePhotoPickerManagerUseCase()
    
}

// MARK: - Internal
extension SelectionViewViewModel {
    func selectPhoto(atIndex index: Int) {
        if index <= selectedImages.count - 1 {
            replacePhoto(atIndex: index)
            return
        }
        addNewPhotos()
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
            selectedImages[replacedIndex] = image
            self.replacedIndex = nil
        } else {
            selectedImages.append(image)
            shouldReloadImageAtIndex = selectedImages.firstIndex(of: image)!
        }
        delegate?.selectionViewViewModel(self, shouldReloadImageAtIndex: shouldReloadImageAtIndex)
        
        if isFinishLoading {
            delegate?.selectionViewViewModel(self, shouldHideActivityIndicator: true)
        }
    }
    
    func photoPickerManager(_ photoPickerManager: PhotoPickerManagerUseCase, didOccurWithError error: PhotoPickerManagerUseCaseError) {}
}
