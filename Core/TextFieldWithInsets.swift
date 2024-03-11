//
//  TextFieldWithInsets.swift
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

@IBDesignable
class TextFieldWithInsets: UITextField {

    var onCopyAction: ((UITextField) -> Void)?

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

    override func copy(_ sender: Any?) {
        if let action = onCopyAction {
            action(self)
        } else {
            super.copy(sender)
        }
    }
}
