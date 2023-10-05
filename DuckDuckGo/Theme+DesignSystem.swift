//
//  Theme+DesignSystem.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import DesignResourcesKit

// Once all colours are from the design system we can consider removing having multiple themes.
extension Theme {

    var omniBarBackgroundColor: UIColor { UIColor(designSystemColor: .panel) }
    var backgroundColor: UIColor { UIColor(designSystemColor: .background) }
    var mainViewBackgroundColor: UIColor { UIColor(designSystemColor: .base) }
    var barBackgroundColor: UIColor { UIColor(designSystemColor: .panel) }
    var barTintColor: UIColor { UIColor(designSystemColor: .icons) }
    var browsingMenuBackgroundColor: UIColor { UIColor(designSystemColor: .surface) }
    var tableCellBackgroundColor: UIColor { UIColor(designSystemColor: .surface) }
    var tabSwitcherCellBackgroundColor: UIColor { UIColor(designSystemColor: .surface) }
    var searchBarTextPlaceholderColor: UIColor { UIColor(designSystemColor: .textSecondary) }

}
