//
//  UILabelExtension.swift
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
