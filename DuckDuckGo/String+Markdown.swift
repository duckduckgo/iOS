//
//  String+Markdown.swift
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

extension String {
    
    class FormattedString {
        var bold = false
        var string = ""
        
        init(bold: Bool, string: String) {
            self.bold = bold
            self.string = string
        }
        
        func attributedString(color: UIColor, lineHeightMultiple: CGFloat, fontSize: CGFloat) -> NSAttributedString {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = lineHeightMultiple

            return NSMutableAttributedString(string: string, attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.foregroundColor: color,
                NSAttributedString.Key.font: bold ? UIFont.boldAppFont(ofSize: fontSize) : UIFont.appFont(ofSize: fontSize)
            ])
        }
    }

    /// This is a super simple markdown that currently only supports `*` to make text bold.
    func attributedStringFromMarkdown(color: UIColor,
                                      lineHeightMultiple: CGFloat = 1.37,
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
