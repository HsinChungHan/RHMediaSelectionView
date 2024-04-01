//
//  SelectionViewCellModel.swift
//  RHMediaSelectionView
//
//  Created by Chung Han Hsin on 2024/4/1.
//

import UIKit

struct SelectionViewCellModel {
    enum State {
        case noSelectionPhoto
        case haveSelectionPhoto
        case uploadSelectionPhoto
    }
    
    var photo: UIImage?
//    var state: State
}
