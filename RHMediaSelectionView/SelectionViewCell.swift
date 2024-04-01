//
//  SelectionViewCell.swift
//  RHMediaSelectionView
//
//  Created by Chung Han Hsin on 2024/4/1.
//

import Foundation
import UIKit

class SelectionViewCell: UICollectionViewCell {
    lazy var imageView = makeImageView()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setupLayout()
    }
}

extension SelectionViewCell {
    private func setupLayout() {
        contentView.addSubview(imageView)
        imageView.fillSuperView()
    }
}

// MARK: - Factory Methods
private extension SelectionViewCell {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }
}
