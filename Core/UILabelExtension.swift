//
//  UILabelExtension.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 09/04/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

extension UILabel {
    
    public func adjustPlainTextLineHeight(_ height: CGFloat) {
        let attributes = attributesForLineHeight(height)
        attributedText = NSAttributedString(string: text ?? "", attributes: attributes)
    }
    
    private func attributesForLineHeight(_ height: CGFloat) -> [String: Any] {
        let paragaphStyle = NSMutableParagraphStyle()
        paragaphStyle.lineHeightMultiple = height
        paragaphStyle.alignment = textAlignment
        
        return [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: textColor,
            NSParagraphStyleAttributeName: paragaphStyle
        ]
    }
}
