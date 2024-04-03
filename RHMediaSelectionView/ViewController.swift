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
    lazy var circularProgressBar = makeCircularProgrssBar()
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.addSubview(reloadButton)
//        view.addSubview(selectionView)
//        addChild(selectionViewController)
//        reloadButton.constraint(bottom: view.safeAreaLayoutGuide.snp.bottom, leading: view.snp.leading, trailing: view.snp.trailing, size: .init(width: 0, height: 44))
//        selectionView.constraint(top: view.safeAreaLayoutGuide.snp.top, bottom: reloadButton.snp.top, leading: view.snp.leading, trailing: view.snp.trailing, padding: .init(top: 16, left: 16, bottom: 16, right: 16))
        
        view.addSubview(circularProgressBar)
        circularProgressBar.constraint(centerX: view.snp.centerX, centerY: view.snp.centerY, size: .init(width: 100, height: 100))
        
        testCircularBarFromCurrentValue()
//        testCircularBar()
        
    }
}

extension ViewController {
    func testCircularBar() {
        circularProgressBar.setProgressWithAnimation(duration: 3, value: 0.9)
    }
    
    func testCircularBarFromCurrentValue() {
        // 在第一秒時設置進度到 0.15
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.circularProgressBar.setProgressWithAnimationFromCurrentValue(duration: 1, value: 0.15)
        }
        
        // 在第二秒時設置進度到 0.55
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.circularProgressBar.setProgressWithAnimationFromCurrentValue(duration: 1, value: 0.55)
        }
        
        // 在第三秒時設置進度到 0.89
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            self.circularProgressBar.setProgressWithAnimationFromCurrentValue(duration: 1, value: 0.89)
        }
        
        // 在第四秒時設置進度到 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
            self.circularProgressBar.setProgressWithAnimationFromCurrentValue(duration: 1, value: 1.0)
        }
    }
        
}

// MARK - Factory Mthods
extension ViewController {
    func makeReloadButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Reload buttons", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(didReloadButton), for: .touchUpInside)
        return button
    }
    
    @objc func didReloadButton() {
        selectionViewController.collectionView.reloadData()
    }
    
    func makeCircularProgrssBar() -> CircularProgressBar {
        let view = CircularProgressBar()
        return view
    }
}
