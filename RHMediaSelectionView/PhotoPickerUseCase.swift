//
//  PhotoPickerUseCase.swift
//  RHMediaSelectionView
//
//  Created by Chung Han Hsin on 2024/4/1.
//

import UIKit
import PhotosUI

protocol PhotoPickerManagerUseCaseDelegate: AnyObject {
    func photoPickerManager(_ photoPickerManager: PhotoPickerManagerUseCase, shouldPresentPikcer picker: PHPickerViewController)
    func photoPickerManager(_ photoPickerManager: PhotoPickerManagerUseCase, shouldShowActivityIndicator: Bool)
    func photoPickerManager(_ photoPickerManager: PhotoPickerManagerUseCase, didLoadImage image: UIImage, isFinishLoading: Bool)
    func photoPickerManager(_ photoPickerManager: PhotoPickerManagerUseCase, didOccurWithError error: PhotoPickerManagerUseCaseError)
}

enum PhotoPickerManagerUseCaseError {
    case failedLoadPhoto
}

class PhotoPickerManagerUseCase {
    weak var delegate: PhotoPickerManagerUseCaseDelegate?
    
    func presentPhotoPicker(with selectionLimit: Int) {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = selectionLimit
        configuration.filter = .images // 只選擇圖片
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        delegate?.photoPickerManager(self, shouldPresentPikcer: picker)
    }
}

// MARK: - PHPickerViewControllerDelegate
extension PhotoPickerManagerUseCase:
    PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        var loadCompletedCounter = 0
        picker.dismiss(animated: true, completion: nil)
        
        if results.isEmpty {
            return
        }
        
        // 顯示加載指示器
        delegate?.photoPickerManager(self, shouldShowActivityIndicator: true)
        
        for result in results {
            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (imageObj, error) in
                    guard let self else { return }
                    loadCompletedCounter += 1
                    DispatchQueue.main.async {
                        
                        if let _ = error {
                            self.delegate?.photoPickerManager(self, didOccurWithError: .failedLoadPhoto)
                            return
                        }
                        guard let image = imageObj as? UIImage else {
                            self.delegate?.photoPickerManager(self, didOccurWithError: .failedLoadPhoto)
                            return
                        }
                        
                        let isFinishLoading = results.count == loadCompletedCounter
                        self.delegate?.photoPickerManager(self, didLoadImage: image, isFinishLoading: isFinishLoading)
                    }
                }
            }
        }
    }
}
