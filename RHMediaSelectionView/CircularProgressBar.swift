//
//  CircularProgressBar.swift
//  RHMediaSelectionView
//
//  Created by Chung Han Hsin on 2024/4/3.
//

import UIKit
import RHUIComponent

protocol CircularProgressBarDelegate: AnyObject {
    func progressBar(_ progressBar: CircularProgressBar, didFinishProgress: Bool)
}

class CircularProgressBar: UIView {
    weak var delegate: CircularProgressBarDelegate?
    
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    private lazy var progressLabel = makeProgressLabel()
    private var displayLink: CADisplayLink?
    
    private var progress: Float = 0
    private var isFinishProgress: Bool {
        progress == 1.0
    }
    
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
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = Color.Red.v100.withAlphaComponent(0.5).cgColor
        trackLayer.lineWidth = 10.0
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)
        
        // progress layer
        progressLayer.lineCap = .round
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
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
        progressLabel.text = "\(Int(min(currentValue * 100 + 1, 100))) %"
    }
    
    func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
}

// MARK: Internal Methods
extension CircularProgressBar {
    func setProgressWithAnimation(duration: TimeInterval, value: Float) {
        progress = value
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
    
    func setProgressWithAnimationFromCurrentValue(duration: TimeInterval=0.1, value: Float) {
        progress = value
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
    
    func reset() {
        // 停止 displayLink 和动画
        stopDisplayLink()
        progressLayer.removeAllAnimations()
        
        // 重置 progressLayer 和 label
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.strokeEnd = 0.0
        CATransaction.commit()
        
        progressLabel.text = "0 %"
        progress = 0.0
    }
}

extension CircularProgressBar: CAAnimationDelegate {
    func animationDidStart(_ anim: CAAnimation) {
        startDisplayLink()
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        stopDisplayLink()
        if flag {
            delegate?.progressBar(self, didFinishProgress: isFinishProgress)
        }
    }
}


