//
//  SearchBarExtension.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 26/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

extension UISearchBar {
    
    public var textColor: UIColor? {
        get {
            return textField()?.textColor
        }
        set(newColor) {
            updateTextColor(newColor: newColor)
        }
    }
    
    private func updateTextColor(newColor: UIColor?) {
        guard let textColor = newColor, let textField = textField() else {
            return
        }
        textField.textColor = textColor
    }
    
    private func textField() -> UITextField? {
        for subview: UIView in subviews {
            for subSubview: UIView in subview.subviews {
                if let textField = subSubview as? UITextField {
                    return textField
                }
            }
        }
        return nil
    }
}
