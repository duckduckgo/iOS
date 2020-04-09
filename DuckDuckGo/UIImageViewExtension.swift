//
//  UIImageViewExtension.swift
//  DuckDuckGo
//
//  Created by Bartek on 09/04/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func crossOutImage() {
        let offset: CGFloat = 5.0
        let contentRect = CGRect(x: offset,
                                 y: (bounds.height - bounds.width) / 2 + offset,
                                 width: bounds.width - 2 * offset,
                                 height: bounds.width - 2 * offset)
        
        let backgroundShape = makeLineLayer(diagonalIn: contentRect)
        backgroundShape.strokeColor = UIColor.white.cgColor
        backgroundShape.lineCap = .round
        backgroundShape.lineWidth = 6
        backgroundShape.isOpaque = false
        layer.addSublayer(backgroundShape)
        
        let topShape = makeLineLayer(diagonalIn: contentRect)
        topShape.strokeColor = UIColor.black.cgColor
        topShape.lineCap = .round
        topShape.lineWidth = 2
        topShape.isOpaque = false
        layer.addSublayer(topShape)
        
        animateScaling(layer: backgroundShape)
        animateScaling(layer: topShape)
    }
    
    private func animateScaling(layer: CAShapeLayer) {
        let anim = CABasicAnimation(keyPath: "transform.scale.x")
        anim.duration = 0.3
        anim.timingFunction = CAMediaTimingFunction(name: .linear)
        anim.isRemovedOnCompletion = true
        anim.fromValue = 0.1
        anim.toValue = 1
        layer.add(anim, forKey: "scaleAnimation")
    }
    
    private func makeLineLayer(diagonalIn content: CGRect) -> CAShapeLayer {
        
        let diagonalLength = sqrt(content.size.width * content.size.width + content.size.height * content.size.height)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(x: 0, y: 0,
                                  width: bounds.width, height: bounds.height)
        
        let path = CGMutablePath()
        
        let startX = (bounds.width - diagonalLength) / 2
        path.move(to: CGPoint(x: startX,
                              y: bounds.midY))
        path.addLine(to: CGPoint(x: diagonalLength - startX,
                                 y: bounds.midY))
        shapeLayer.path = path
        
        let radians = CGFloat(45 * Double.pi / 180)
        shapeLayer.transform = CATransform3DMakeRotation(radians, 0.0, 0.0, 1.0)
        
        return shapeLayer
    }
    
}
