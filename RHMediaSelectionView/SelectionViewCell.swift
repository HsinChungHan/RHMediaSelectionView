//
//  SelectionViewCell.swift
//  RHMediaSelectionView
//
//  Created by Chung Han Hsin on 2024/4/1.
//

import Foundation
import RHUIComponent
import UIKit

protocol SelectionViewCellDelegate: AnyObject {
    func selectionViewCell(_ selectionViewCell: SelectionViewCell, didTapRemoveButton button: UIButton)
}

class SelectionViewCell: UICollectionViewCell {
    enum Status {
        case noSelectionPhoto
        case haveSelectionPhoto
    }
    
    weak var delegate: SelectionViewCellDelegate?
    lazy var imageView = makeImageView()
    lazy var removeButton = makeRemoveButton()
    lazy var lightGrayMaskView = makeMaskView()
    var status = Status.noSelectionPhoto
    
    var isUploadingPhoto: Bool = false {
        didSet {
            if isUploadingPhoto {
                lightGrayMaskView.isHidden = false
                removeButton.isHidden = true
                return
            }
            lightGrayMaskView.isHidden = true
            switch status {
            case .haveSelectionPhoto:
                removeButton.isHidden = false
            case .noSelectionPhoto:
                removeButton.isHidden = true
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setupLayout()
    }
}

extension SelectionViewCell {
    private func setupLayout() {
        contentView.addSubview(imageView)
        contentView.addSubview(lightGrayMaskView)
        contentView.addSubview(removeButton)
        imageView.fillSuperView(inset: .init(top: 6, left: 6, bottom: 6, right: 6))
        removeButton.constraint(bottom: snp.bottom, trailing: snp.trailing, size: .init(width: 24, height: 24))
        removeButton.layer.cornerRadius = 24 / 2
        removeButton.clipsToBounds = true
        lightGrayMaskView.fillSuperView()
        
    }
}

extension SelectionViewCell {
    func setupImage(with image: UIImage?) {
        guard let image else {
            status = .noSelectionPhoto
            imageView.image = UIImage(named: "photo")
            return
        }
        status = .haveSelectionPhoto
        imageView.image = image
    }
    
    func setupIsUploadingPhoto(with isUploadingPhoto: Bool) {
        self.isUploadingPhoto = isUploadingPhoto
    }
}

// MARK: - Factory Methods
private extension SelectionViewCell {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = UIImage(named: "photo")
        view.clipsToBounds = true
        return view
    }
    
    func makeRemoveButton() -> UIButton {
        let view = UIButton(type: .system)
        view.setImage(UIImage(named: "cancel")!.withRenderingMode(.alwaysOriginal), for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        view.backgroundColor = Color.Red.v500
        view.addTarget(self, action: #selector(didTapSelectionButton), for: .touchUpInside)
        view.isHidden = true
        return view
    }
    
    @objc func didTapSelectionButton(sender: UIButton) {
        delegate?.selectionViewCell(self, didTapRemoveButton: sender)
    }
    
    func makeMaskView() -> UIView {
        let view = UIView()
        view.backgroundColor = .lightGray.withAlphaComponent(0.5)
        view.isHidden = true
        return view
    }
}
