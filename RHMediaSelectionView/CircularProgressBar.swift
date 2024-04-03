//
//  CircularProgressBar.swift
//  RHMediaSelectionView
//
//  Created by Chung Han Hsin on 2024/4/3.
//

import UIKit
import RHUIComponent

class CircularProgressBar: UIView {
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    private lazy var progressLabel = makeProgressLabel()
    private var displayLink: CADisplayLink?

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        makeCircularPath()
        setupLayout()
    }
}

extension CircularProgressBar {
    func makeCircularPath() {
        self.backgroundColor = .clear
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * CGFloat.pi
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: (frame.size.width) / 2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        // track layer
        trackLayer.path = circlePath.cgPath
        trackLayer.fillColor = Color.Neutral.v700.withAlphaComponent(0.3).cgColor
        trackLayer.strokeColor = Color.Red.v100.cgColor
        trackLayer.lineWidth = 10.0
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)
        
        // progress layer
        progressLayer.lineCap = .round
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = Color.Neutral.v700.withAlphaComponent(0.3).cgColor
        progressLayer.strokeColor = Color.Red.v500.cgColor
        progressLayer.lineWidth = 10.0
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = 0.0
        layer.addSublayer(progressLayer)
    }
    
    func makeProgressLabel() -> UILabel {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .white
        return label
    }
    
    func setupLayout() {
        addSubview(progressLabel)
        progressLabel.constraint(centerX: snp.centerX, centerY: snp.centerY)
    }
}

// MARK: - Helpers
private extension CircularProgressBar {
    func startDisplayLink() {
        // 若之前有 displayLink 的話，需要先結束
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateProgressLabel))
        displayLink?.add(to: .main, forMode: .default)
    }

    @objc func updateProgressLabel() {
        let currentValue = progressLayer.presentation()?.strokeEnd ?? 0
        progressLabel.text = "\(Int(currentValue * 100)) %"
    }
    
    func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
}

// MARK: Internal Methods
extension CircularProgressBar {
    func setProgressWithAnimation(duration: TimeInterval, value: Float) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.delegate = self
        animation.duration = duration
        animation.fromValue = 0
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        progressLayer.strokeEnd = CGFloat(value)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        progressLayer.add(animation, forKey: "animateprogress")
    }
    
    func setProgressWithAnimationFromCurrentValue(duration: TimeInterval=1.0, value: Float) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.delegate = self
        animation.duration = duration
        // 使用當前進度作為動畫起始值
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        progressLayer.strokeEnd = CGFloat(value)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        progressLayer.add(animation, forKey: "animateprogress")
    }
}

extension CircularProgressBar: CAAnimationDelegate {
    func animationDidStart(_ anim: CAAnimation) {
        startDisplayLink()
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        stopDisplayLink()
        // 確保結束時顯示正確的結束值
//        progressLabel.text = "\(Int((progressLayer.strokeEnd) * 100)) %"
    }
}
