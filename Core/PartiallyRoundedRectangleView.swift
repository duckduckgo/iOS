//
//  PartiallyRoundedRectangleView.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
