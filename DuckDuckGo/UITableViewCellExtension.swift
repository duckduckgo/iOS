//
//  UITableViewCellExtension.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

extension UITableViewCell {
    
    /// Even if `selectedBackgroundView` exists, setting its background color does not work. Hence, this workaround.
    func setHighlightedStateBackgroundColor(_ color: UIColor) {
        let view = UIView()
        view.backgroundColor = color
        selectedBackgroundView = view
    }
    
    func decorate(with theme: Theme) {
        backgroundColor = theme.tableCellBackgroundColor
        textLabel?.textColor = theme.tableCellTextColor
        tintColor = theme.buttonTintColor
        setHighlightedStateBackgroundColor(theme.tableCellHighlightedBackgroundColor)
    }
    
}
