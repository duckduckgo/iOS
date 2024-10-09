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

    /// Creates a new `NSAttributedString` initialized with the characters and attributes of the current attributed string plus the specified font.
    ///
    /// - Parameter font: The `UIFont` to apply to the text in the `NSAttributedString`.
    /// - Returns: A new `NSAttributedString`initialized with characters and attributes of the current attributed string plus the specified font.
    public func withFont(_ font: UIFont) -> NSAttributedString {
        with(attribute: .font, value: font)
    }

    /// Creates a new `NSAttributedString` initialized with the characters and attributes of the current attributed string plus the specified text color
    ///
    /// - Parameter color: The color to apply to the text
    /// - Returns: A new `NSAttributedString` initialized with characters and attributes of the current attributed string plus the text color
    public func withTextColor(_ color: UIColor) -> NSAttributedString {
        with(attribute: .foregroundColor, value: color)
    }

    /// Creates a new `NSAttributedString` initialized with the characters and attributes of the current attributed string plus the specified attribute
    ///
    /// - Parameters:
    ///   - key: The attribute key to apply. This should be one of the keys defined in `NSAttributedString.Key`.
    ///   - value: The value associated with the attribute key. This can be any object compatible with the attribute.
    ///   - range: An optional `NSRange` specifying the range within the `NSAttributedString` to apply the attribute.
    ///            If `nil`, the attribute is applied to the entire `NSAttributedString`.
    /// - Returns: A new `NSAttributedString` with the specified attribute applied.
    public func with(attribute key: NSAttributedString.Key, value: Any, in range: NSRange? = nil) -> NSAttributedString {
        with(attributes: [key: value], in: range)
    }

    /// Creates a new `NSAttributedString` initialized with the characters and attributes of the current attributed string plus the specified attributes
    ///
    /// - Parameters:
    ///   - attributes: A dictionary of attributes to apply, where the keys are of type `NSAttributedString.Key` and the values
    ///     are objects compatible with the attributes (e.g., `UIFont`, `UIColor`).
    ///   - range: An optional `NSRange` specifying the range within the `NSAttributedString` to apply the attributes.
    ///            If `nil`, the attributes are applied to the entire `NSAttributedString`.
    /// - Returns: A new `NSAttributedString` with the specified attributes applied.
    public func with(attributes: [NSAttributedString.Key: Any], in range: NSRange? = nil) -> NSAttributedString {
        let mutableString = NSMutableAttributedString(attributedString: self)
        mutableString.addAttributes(attributes, range: range ?? string.nsRange)
        return mutableString
    }
}

// MARK: - AttributedString Helper Extensions

public extension String {

    var attributed: NSAttributedString {
        NSAttributedString(string: self)
    }

    var nsRange: NSRange {
        NSRange(startIndex..., in: self)
    }

    func range(of string: String) -> NSRange {
        (self as NSString).range(of: string)
    }

}

// MARK: Helper Operators

/// Concatenates two `NSAttributedString` instances, returning a new `NSAttributedString`.
///
/// - Parameters:
///   - lhs: The left-hand side `NSAttributedString` to which the `rhs` `NSAttributedString` will be appended.
///   - rhs: The `NSAttributedString` to append to the `lhs` `NSAttributedString`.
/// - Returns: A new `NSAttributedString` that is the result of concatenating `lhs` and `rhs`.
public func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
    let mutable = NSMutableAttributedString(attributedString: lhs)
    mutable.append(rhs)
    return mutable
}

/// Concatenates an `NSAttributedString` with a `String`, returning a new `NSAttributedString`.
///
/// - Parameters:
///   - lhs: The left-hand side `NSAttributedString` to which the `String` will be appended.
///   - rhs: The `String` to append to the `lhs` `NSAttributedString`.
/// - Returns: A new `NSAttributedString` which is the result of concatenating `lhs` with `rhs`.
public func + (lhs: NSAttributedString, rhs: String) -> NSAttributedString {
    lhs + NSAttributedString(string: rhs)
}

/// Concatenates a `String` with an `NSAttributedString`, returning a new `NSAttributedString`.
///
/// - Parameters:
///   - lhs: The `String` to prepend to the `rhs` `NSAttributedString`.
///   - rhs: The right-hand side `NSAttributedString` that will be appended to the `lhs` `String`.
/// - Returns: A new `NSAttributedString` which is the result of concatenating `lhs` with `rhs`.
public func + (lhs: String, rhs: NSAttributedString) -> NSAttributedString {
    NSAttributedString(string: lhs) + rhs
}
