//
//  UIImage+Extension.swift
//  RHMediaSelectionView
//
//  Created by Chung Han Hsin on 2024/4/1.
//

import UIKit

extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage? {
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // 選擇寬高比例中較小的一個作為縮放比例，確保圖片不會變形
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // 繪製新的圖片
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    
    func compressImage(quality: CGFloat) -> Data? {
        return jpegData(compressionQuality: quality)
    }
    
    var fileSize: CGFloat? {
        if let imageData = self.jpegData(compressionQuality: 1.0) {
            let fileSize = CGFloat(CGFloat(imageData.count) / (1024.0 * 1024.0))
            return fileSize
        }
        return nil
    }
    
    func toData() -> Data? {
        if let imageData = jpegData(compressionQuality: 1.0) {
            return imageData
        }
        
        if let imageData = pngData() {
            return imageData
        }
        
        return nil
    }
    
    // 預設縮小為 1 MB 以下
    func compress(lessThan sizeInMB: CGFloat = 1) -> Data? {
        let sizeInBytes = sizeInMB * 1024 * 1024
        var compressionQuality: CGFloat = 1.0
        guard var imageData = self.jpegData(compressionQuality: compressionQuality) else { return nil }
        
        // Check if the current size is already under the desired size
        if CGFloat(imageData.count) <= sizeInBytes {
            return imageData
        }
        
        // Adjust the compressionQuality to reduce the image size
        while CGFloat(imageData.count) > sizeInBytes && compressionQuality > 0 {
            compressionQuality -= 0.1
            if let compressedImageData = self.jpegData(compressionQuality: compressionQuality) {
                imageData = compressedImageData
            } else {
                break
            }
        }
        
        return imageData
    }
}
