//
//  ViewController.swift
//  RHMediaSelectionView
//
//  Created by Chung Han Hsin on 2024/4/1.
//

import UIKit

class ViewController: UIViewController {
    let selectionViewController = SelectionViewController()
    var selectionView: UIView { selectionViewController.view }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(selectionView)
        selectionView.constraint(top: view.safeAreaLayoutGuide.snp.top, bottom: view.safeAreaLayoutGuide.snp.bottom, leading: view.snp.leading, trailing: view.snp.trailing, padding: .init(top: 0, left: 16, bottom: 0, right: 16))
    }
}

