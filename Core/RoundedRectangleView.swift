//
//  RoundedRectangleView.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 03/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

@IBDesignable
public class RoundedRectangleView: UIView {
    
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
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var dropShadow: Bool = false
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        configureDropShadow()
    }
    
    private func configureDropShadow() {
        if dropShadow {
            displayDropShadow()
        }
    }
}
