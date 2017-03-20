//
//  PartiallyRoundedRectangleView.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 15/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

@IBDesignable
public class PartiallyRoundedRectangleView: UIView {
    
    @IBInspectable var borderColor: UIColor = UIColor.white {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 2.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0
    
    @IBInspectable var topLeftCorner: Bool = true
    
    @IBInspectable var topRightCorner: Bool = true
    
    @IBInspectable var bottomLeftCorner: Bool = true
    
    @IBInspectable var bottomRightCorner: Bool = true
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        var corners = UIRectCorner()
        if topLeftCorner     { corners.insert(.topLeft)     }
        if topRightCorner    { corners.insert(.topRight)    }
        if bottomLeftCorner  { corners.insert(.bottomLeft)  }
        if bottomRightCorner { corners.insert(.bottomRight) }
        round(corners: corners, radius: cornerRadius)
    }
}
