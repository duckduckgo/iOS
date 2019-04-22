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

class ProgressView: UIView {
    
    private struct Constants {
        static let gradientAnimationKey = "animateGradient"
    }
    
    private var progressLayer = CAGradientLayer()
    private var progressMask = CALayer()
    
    private var currentProgress: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configureLayers()
    }
    
    func configureLayers() {
        var progressFrame = bounds
        progressFrame.size.width *= 0.5
        
        progressMask.frame = progressFrame
        
        if #available(iOS 11.0, *) {
            progressMask.cornerRadius = 2
            progressMask.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        }
        
        progressMask.backgroundColor = UIColor.white.cgColor
        
        progressLayer.anchorPoint = .zero
        progressLayer.frame = bounds
        progressLayer.mask = progressMask
        
        var colors = [CGColor]()
        var locations = [NSNumber]()
        for i in 0...6 {
            colors.append(UIColor.cornflowerBlue.cgColor)
            colors.append(UIColor.skyBlueLight.cgColor)
            
            let location = 0.2 * Double(i)
            locations.append(NSNumber(value: location - 0.1))
            locations.append(NSNumber(value: location))
        }
        
        progressLayer.colors = colors
        progressLayer.locations = locations
        progressLayer.startPoint = CGPoint(x: 0, y: 0.5)
        progressLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(progressLayer, at: 0)
    }
    
    override func awakeFromNib() {
        self.backgroundColor = .clear
    }
    
    func updateProgress(_ progress: CGFloat, animated: Bool = false) {
        print("---> p: \(progress)")
        
        currentProgress = progress
        updateProgressMask(animated: animated)
    }
    
    private func updateProgressMask(animated: Bool) {
        var progressFrame = bounds
        progressFrame.size.width *= currentProgress
        
        let duration: TimeInterval
        if animated == false {
            duration = 0
        } else if currentProgress > 1 - CGFloat.ulpOfOne {
            duration = 0.3
        } else {
            duration = 1
            progressFrame.size.width *= 0.5
        }
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        self.progressMask.frame = progressFrame
        CATransaction.commit()
        CATransaction.flush()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        progressLayer.frame = bounds
        updateProgressMask(animated: false)
    }
    
    private func startGradientAnimation() {
        
        let animation = CABasicAnimation(keyPath: "locations")
        
        var fromLocations = [NSNumber]()
        var toLocations: [NSNumber] = [-0.2, -0.1]
        for i in 0...6 {
            let location = 0.2 * Double(i)
            fromLocations.append(NSNumber(value: location - 0.1))
            fromLocations.append(NSNumber(value: location))
            
            toLocations.append(NSNumber(value: location - 0.1))
            toLocations.append(NSNumber(value: location))
        }
        toLocations = toLocations.dropLast(2)
        
//        animation.fromValue =  fromLocations
        animation.toValue = toLocations
        animation.duration = 0.4
        animation.isRemovedOnCompletion = true
        animation.repeatCount = .greatestFiniteMagnitude
        self.progressLayer.add(animation, forKey: Constants.gradientAnimationKey)
    }
    
    private func stopGradientAnimation() {
        self.progressLayer.removeAnimation(forKey: Constants.gradientAnimationKey)
    }
    
    func hide() {
        stopGradientAnimation()
        currentProgress = 0
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.4)
        var frame = progressMask.frame
        frame.origin.x += frame.size.width
        progressMask.frame = frame
        CATransaction.commit()
    }
    
    func show() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        var frame = progressMask.frame
        frame.origin.x = 0
        frame.size.width = 0
        progressMask.frame = frame
        CATransaction.commit()
        CATransaction.flush()
        startGradientAnimation()
    }
    
    var isVisible: Bool {
        return alpha > 0
    }
}
