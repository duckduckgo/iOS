//
//  ProgressView.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

@IBDesignable
class ProgressView: UIView, CAAnimationDelegate {
    
    private struct Constants {
        static let gradientAnimationKey = "animateGradient"
        static let progressAnimationKey = "animateProgress"
        static let fadeOutAnimationKey = "animateFadeOut"
    }
    
    private var progressLayer = CAGradientLayer()
    private var progressMask = CALayer()
    
    // Actual progress
    private var currentProgress: CGFloat = 0.0
    // Progress used to calculate last animation
    private var visibleProgress: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configureLayers()
    }
    
    func configureLayers() {
        backgroundColor = .clear
        
        var progressFrame = bounds
        progressFrame.size.width = 0
        
        progressMask.anchorPoint = .zero
        progressMask.frame = progressFrame
        if #available(iOS 11.0, *) {
            progressMask.cornerRadius = 2
            progressMask.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        }
        progressMask.backgroundColor = UIColor.white.cgColor
        
        progressLayer.frame = bounds
        progressLayer.anchorPoint = .zero
        progressLayer.mask = progressMask
        
        var colors = [CGColor]()
        for _ in 0...6 {
            colors.append(UIColor.cornflowerBlue.cgColor)
            colors.append(UIColor.skyBlueLight.cgColor)
        }
        
        progressLayer.colors = colors
        progressLayer.locations = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 1.1, 1.2, 1.3]
        progressLayer.startPoint = CGPoint(x: 0, y: 0.5)
        progressLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(progressLayer, at: 0)
    }
    
    func show() {
        currentProgress = 0
        visibleProgress = 0
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        var frame = progressMask.frame
        frame.origin.x = 0
        frame.size.width = 0
        progressMask.frame = frame
        progressMask.opacity = 1
        CATransaction.commit()
        CATransaction.flush()
        
        startGradientAnimation()
    }
    
    func increaseProgress(to progress: CGFloat, animated: Bool = false) {
        currentProgress = progress
        updateProgressMask(animated: animated)
    }
    
    func finishAndHide() {
        increaseProgress(to: 1, animated: true)
    }
    
    private func calculateProgressMaskRect() -> CGRect {
        guard currentProgress < 1  else {
            return bounds
        }
        var progressRect = bounds
        progressRect.size.width *= currentProgress * 0.5
        return progressRect
    }
    
    private func updateProgressMask(animated: Bool) {
        guard progressMask.animation(forKey: Constants.progressAnimationKey) == nil,
            currentProgress > visibleProgress else {
            return
        }
        
        let progressFrame = calculateProgressMaskRect()
        visibleProgress = currentProgress
        
        let duration: TimeInterval
        if animated == false {
            duration = 0
        } else if currentProgress > 1 - CGFloat.ulpOfOne {
            duration = 0.2
        } else {
            duration = 0.6
        }
        
        let animation = CABasicAnimation(keyPath: "bounds")
        animation.fromValue = progressMask.bounds
        animation.toValue = progressFrame
        animation.duration = duration
        animation.isRemovedOnCompletion = true
        animation.delegate = self
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressMask.bounds = progressFrame
        CATransaction.commit()
        
        progressMask.add(animation, forKey: Constants.progressAnimationKey)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if visibleProgress > 1 - CGFloat.ulpOfOne {
            hideAndReset()
        } else {
            updateProgressMask(animated: true)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        progressLayer.frame = bounds
        progressMask.frame = calculateProgressMaskRect()
        progressMask.removeAnimation(forKey: Constants.progressAnimationKey)
    }
    
    private func startGradientAnimation() {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.toValue = [-0.2, -0.1, 0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 1.1]
        animation.duration = 0.4
        animation.repeatCount = .greatestFiniteMagnitude
        progressLayer.add(animation, forKey: Constants.gradientAnimationKey)
    }
    
    private func stopGradientAnimation() {
        progressLayer.removeAnimation(forKey: Constants.gradientAnimationKey)
    }
    
    private func hideAndReset() {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1
        animation.toValue = 0
        animation.duration = 0.4
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressMask.opacity = 0
        CATransaction.commit()
        
        progressMask.add(animation, forKey: Constants.fadeOutAnimationKey)
        
        visibleProgress = 0
        currentProgress = 0
    }
    
    // MARK: IB
    override func prepareForInterfaceBuilder() {
        var progressFrame = bounds
        progressFrame.size.width = 0
        
        progressMask.frame = progressFrame
    }
}
