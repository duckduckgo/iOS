//
//  NSAttributedStringExtension.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 05/04/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

extension NSAttributedString {
    public func withText(_ text: String) -> NSAttributedString {
        let mutableText = mutableCopy() as! NSMutableAttributedString
        mutableText.mutableString.setString(text)
        return mutableText
    }
}
