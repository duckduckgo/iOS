//
//  TextFieldWithInsets.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 02/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

@IBDesignable
class TextFieldWithInsets: UITextField {
    
    @IBInspectable var leftInset: CGFloat = 0
    @IBInspectable var rightInset: CGFloat = 0
    @IBInspectable var topInset: CGFloat = 0
    @IBInspectable var bottomInset: CGFloat = 0
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return boundsWithInsets(forBounds: bounds)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return boundsWithInsets(forBounds: bounds)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return boundsWithInsets(forBounds: bounds)
    }
    
    override func borderRect(forBounds bounds: CGRect) -> CGRect {
        return boundsWithInsets(forBounds: bounds)
    }
    
    private func boundsWithInsets(forBounds bounds: CGRect) -> CGRect {
        let x = bounds.origin.x + leftInset
        let y = bounds.origin.y + topInset
        let width = bounds.size.width - leftInset - rightInset
        let height = bounds.size.height - topInset - bottomInset
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
