//
//  Markdown.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 14/05/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import UIKit

extension String {
    
    class FormattedString {
        var bold = false
        var string = ""
        
        init(bold: Bool, string: String) {
            self.bold = bold
            self.string = string
        }
        
        func attributedString(color: UIColor, lineHeightMultiple: CGFloat, fontSize: CGFloat) -> NSAttributedString {
            let boldModifier = bold ? "-Bold" : "-Regular"
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = lineHeightMultiple// 1.17

            return NSMutableAttributedString(string: string, attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.foregroundColor: color,
                NSAttributedString.Key.font: UIFont(name: "ProximaNova" + boldModifier, size: fontSize)!
            ])
        }
    }

    /// This is a super simple markdown that currently only supports `*` to make text bold.
    func attributedStringFromMarkdown(color: UIColor = UIColor.nearlyBlack,
                                      lineHeightMultiple: CGFloat = 1.17,
                                      fontSize: CGFloat = 16) -> NSAttributedString {
        
        var formattedStrings = [FormattedString]()
        
        let chars = Array(self)
        
        for i in 0 ..< chars.count {
            if chars[i].isMarkdownIndicator {
                let bold = chars[i] == "*" && !(formattedStrings.last?.bold ?? false)
                formattedStrings.append(FormattedString(bold: bold, string: ""))
                continue
            }

            var current = formattedStrings.last
            if current == nil {
                current = FormattedString(bold: false, string: "")
                formattedStrings.append(current!)
            }
            
            current?.string += "\(chars[i])"
        }
            
        let string = NSMutableAttributedString()

        formattedStrings.forEach {
            string.append($0.attributedString(color: color, lineHeightMultiple: lineHeightMultiple, fontSize: fontSize))
        }
        
        return string
    }
}

extension Character {
    
    var isMarkdownIndicator: Bool {
        return "*".contains(self)
    }
    
}
