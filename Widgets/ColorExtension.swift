//
//  ColorExtension.swift
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

import SwiftUI

extension Color {

    static let widgetBackground = Color("WidgetBackgroundColor")
    static let widgetFavoritesBackground = Color("WidgetFavoritesBackgroundColor")
    static let widgetSearchFieldBackground = Color("WidgetSearchFieldBackgroundColor")
    static let widgetSearchFieldText = Color("WidgetSearchFieldTextColor")
    static let widgetFavoriteLetter = Color("WidgetFavoriteLetterColor")

    static func forDomain(_ domain: String) -> Color {
        return Color(UIColor.forDomain(domain))
    }

}
