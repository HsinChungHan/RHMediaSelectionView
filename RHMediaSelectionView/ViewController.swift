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
    
    lazy var reloadButton = makeReloadButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(reloadButton)
        view.addSubview(selectionView)
        addChild(selectionViewController)
        reloadButton.constraint(bottom: view.safeAreaLayoutGuide.snp.bottom, leading: view.snp.leading, trailing: view.snp.trailing, size: .init(width: 0, height: 44))
        selectionView.constraint(top: view.safeAreaLayoutGuide.snp.top, bottom: reloadButton.snp.top, leading: view.snp.leading, trailing: view.snp.trailing, padding: .init(top: 16, left: 16, bottom: 16, right: 16))
        
     
    }
}
   

// MARK - Factory Mthods
extension ViewController {
    func makeReloadButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Reload CollectionView", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(didReloadButton), for: .touchUpInside)
        return button
    }
    
    @objc func didReloadButton() {
        selectionViewController.collectionView.reloadData()
    }
}
