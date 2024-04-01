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
        case uploadSelectionPhoto
    }
    
    weak var delegate: SelectionViewCellDelegate?
    lazy var imageView = makeImageView()
    lazy var removeButton = makeRemoveButton()
    var status = Status.noSelectionPhoto {
        didSet {
            switch status {
            case .haveSelectionPhoto, .uploadSelectionPhoto:
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
        contentView.addSubview(removeButton)
        imageView.fillSuperView()
        removeButton.constraint(bottom: snp.bottom, trailing: snp.trailing, padding: .init(top: 0, left: 0, bottom: 4, right: 4), size: .init(width: 24, height: 24))
        removeButton.layer.cornerRadius = 24 / 2
        removeButton.clipsToBounds = true
    }
}

extension SelectionViewCell {
    func setupImage(with image: UIImage?) {
        guard let image else {
            status = .noSelectionPhoto
            imageView.image = nil
            return
        }
        status = .haveSelectionPhoto
        imageView.image = image
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
    
    func makeRemoveButton() -> UIButton {
        let view = UIButton(type: .system)
        view.setImage(UIImage(named: "cancel")!, for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        view.backgroundColor = Color.Red.v500
        view.addTarget(self, action: #selector(didTapSelectionButton), for: .touchUpInside)
        return view
    }
    
    @objc func didTapSelectionButton(sender: UIButton) {
        delegate?.selectionViewCell(self, didTapRemoveButton: sender)
    }
}
