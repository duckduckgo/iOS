//
//  SearchBarExtension.swift
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
