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
        
        static let completionThreshold = 1 - CGFloat.ulpOfOne
    }
    
    private var progressLayer = CAGradientLayer()
    private var progressMask = CALayer()
    
    // Actual progress, as reported by WKWebView.
    private var currentProgress: CGFloat = 0.0
    // Currently displayed progress, used to prepare next animation.
    private var visibleProgress: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        decorate()
        configureLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        decorate()
        configureLayers()
    }
    
    func configureLayers() {
        backgroundColor = .clear
        
        var progressFrame = bounds
        progressFrame.size.width = 0
        
        progressMask.anchorPoint = .zero
        progressMask.frame = progressFrame
        progressMask.backgroundColor = UIColor.white.cgColor
        
        progressLayer.frame = bounds
        progressLayer.anchorPoint = .zero
        progressLayer.mask = progressMask
        
        progressLayer.locations = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 1.1, 1.2, 1.3]
        progressLayer.startPoint = CGPoint(x: 0, y: 0.5)
        progressLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(progressLayer, at: 0)
    }
    
    func show(initialProgress: CGFloat = 0) {
        currentProgress = initialProgress
        visibleProgress = initialProgress
        
        progressMask.removeAllAnimations()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressMask.bounds = calculateProgressMaskRect()
        progressMask.opacity = 1
        CATransaction.commit()
        
        startGradientAnimation()
    }
    
    func increaseProgress(to progress: CGFloat, animated: Bool = false) {
        guard progress > currentProgress else { return }
        currentProgress = progress
        
        // Workaround for the issue, when iOS removes all animations automatically (e.g. when putting app to the background)
        startGradientAnimation()
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
        let runningAnimations = progressMask.animationKeys() ?? []
        let progressRelatedAnimations = runningAnimations.filter({ $0 == Constants.progressAnimationKey || $0 == Constants.fadeOutAnimationKey })
        
        guard progressRelatedAnimations.isEmpty,
            currentProgress > visibleProgress else {
                return
        }
        
        let progressFrame = calculateProgressMaskRect()
        visibleProgress = currentProgress
        
        let duration: TimeInterval
        if !animated {
            duration = 0
        } else if currentProgress > Constants.completionThreshold {
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
        progressMask.add(animation, forKey: Constants.progressAnimationKey)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressMask.bounds = progressFrame
        CATransaction.commit()
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if visibleProgress > Constants.completionThreshold {
            hide(animated: true)
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
        guard progressLayer.animation(forKey: Constants.gradientAnimationKey) == nil else { return }
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.toValue = [-0.2, -0.1, 0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 1.1]
        animation.duration = 0.4
        animation.repeatCount = .greatestFiniteMagnitude
        progressLayer.add(animation, forKey: Constants.gradientAnimationKey)
    }
    
    private func stopGradientAnimation() {
        progressLayer.removeAnimation(forKey: Constants.gradientAnimationKey)
    }
    
    func hide(animated: Bool = false) {
        if animated {
            CATransaction.begin()
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 1
            animation.toValue = 0
            animation.duration = 0.4
            progressMask.add(animation, forKey: Constants.fadeOutAnimationKey)
            CATransaction.setCompletionBlock(stopGradientAnimation)
            CATransaction.commit()
        } else {
            progressMask.removeAllAnimations()
            stopGradientAnimation()
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressMask.opacity = 0
        CATransaction.commit()
    }
    
    // MARK: IB
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        backgroundColor = .cornflowerBlue
    }
}

extension ProgressView {
    
    private func decorate() {
        let theme = ThemeManager.shared.currentTheme
        var colors = [CGColor]()
        for _ in 0...6 {
            colors.append(theme.progressBarGradientDarkColor.cgColor)
            colors.append(theme.progressBarGradientLightColor.cgColor)
        }
        
        progressLayer.colors = colors
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            decorate()
        }
    }
}
