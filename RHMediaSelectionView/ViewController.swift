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
        addChild(selectionViewController)
        selectionView.constraint(top: view.safeAreaLayoutGuide.snp.top, bottom: view.layoutMarginsGuide.snp.bottom, leading: view.snp.leading, trailing: view.snp.trailing, padding: .init(top: 16, left: 16, bottom: 16, right: 16))
    }
}

