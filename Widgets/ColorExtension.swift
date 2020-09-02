//
//  ColorExtension.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 01/09/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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
