//
//  NSAttributedStringExtension.swift
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

import Foundation

extension NSAttributedString {
    public func withText(_ text: String) -> NSAttributedString {
        guard let mutableText = mutableCopy() as? NSMutableAttributedString else {
            return NSAttributedString(string: text)
        }
        mutableText.mutableString.setString(text)
        return mutableText
    }

    public var font: UIFont? {
        return attributes(at: 0, effectiveRange: nil)[.font] as? UIFont
    }

    public func stringWithFontSize(_ size: CGFloat) -> NSAttributedString? {
        guard let font = font else { return nil }
        let newFont = font.withSize(size)

        let newString = NSMutableAttributedString(attributedString: self)
        newString.setAttributes([.font: newFont], range: string.fullRange)
        return newString
    }
}
