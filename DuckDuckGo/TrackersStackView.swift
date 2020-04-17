//
//  TrackersStackView.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

class TrackersStackView: UIStackView {
    
    struct Constants {
        static let crossOutOffset: CGFloat = 1.0
        
        static let crossOutBackgroundLayerKey = "crossOutBackground"
        static let crossOutForegroundLayerKey = "crossOutForeground"
    }
    
    @IBOutlet var trackerIcons: [UIImageView]!
    
    var crossOutBackgroundColor: UIColor = .clear
    
    func crossOutTrackerIcons(duration: TimeInterval) {
        trackerIcons.forEach { imageView in
            animateCrossOut(for: imageView, duration: duration)
        }
    }
    
    func resetTrackerIcons() {
        trackerIcons.forEach { imageView in
            resetCrossOut(for: imageView)
        }
    }
    
    private func animateCrossOut(for imageView: UIImageView, duration: TimeInterval) {
        
        let contentRect = CGRect(x: Constants.crossOutOffset,
                                 y: (imageView.bounds.height - imageView.bounds.width) / 2 + Constants.crossOutOffset,
                                 width: imageView.bounds.width - 2 * Constants.crossOutOffset,
                                 height: imageView.bounds.width - 2 * Constants.crossOutOffset)
        
        let backgroundShape = makeLineLayer(bounds: imageView.bounds, diagonalIn: contentRect)
        backgroundShape.strokeColor = crossOutBackgroundColor.cgColor
        backgroundShape.lineCap = .round
        backgroundShape.lineWidth = 6
        backgroundShape.isOpaque = false
        backgroundShape.name = Constants.crossOutBackgroundLayerKey
        imageView.layer.addSublayer(backgroundShape)
        
        let foregroundShape = makeLineLayer(bounds: imageView.bounds, diagonalIn: contentRect)
        foregroundShape.strokeColor = tintColor.cgColor
        foregroundShape.lineCap = .round
        foregroundShape.lineWidth = 2
        foregroundShape.isOpaque = false
        foregroundShape.name = Constants.crossOutForegroundLayerKey
        imageView.layer.addSublayer(foregroundShape)
        
        animateScaling(layer: backgroundShape, duration: duration)
        animateScaling(layer: foregroundShape, duration: duration)
    }
    
    private func resetCrossOut(for imageView: UIImageView) {
        let animationLayers = imageView.layer.sublayers?.filter {
            $0.name == Constants.crossOutBackgroundLayerKey || $0.name == Constants.crossOutForegroundLayerKey
        }
        animationLayers?.forEach {
            $0.removeAllAnimations()
            $0.removeFromSuperlayer()
        }
    }
    
    private func animateScaling(layer: CAShapeLayer, duration: TimeInterval) {
        let anim = CABasicAnimation(keyPath: "transform.scale.x")
        anim.duration = duration
        anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
        anim.isRemovedOnCompletion = true
        anim.fromValue = 0
        anim.toValue = 1
        layer.add(anim, forKey: "scaleAnimation")
    }
    
    private func makeLineLayer(bounds: CGRect, diagonalIn content: CGRect) -> CAShapeLayer {
        
        let diagonalLength = sqrt(content.size.width * content.size.width + content.size.height * content.size.height)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        
        let path = CGMutablePath()
        let startX = (bounds.width - diagonalLength) / 2
        path.move(to: CGPoint(x: startX,
                              y: bounds.midY))
        path.addLine(to: CGPoint(x: diagonalLength + startX,
                                 y: bounds.midY))
        shapeLayer.path = path
        
        let radians = CGFloat(45 * Double.pi / 180)
        shapeLayer.transform = CATransform3DMakeRotation(radians, 0.0, 0.0, 1.0)
        
        return shapeLayer
    }
}
