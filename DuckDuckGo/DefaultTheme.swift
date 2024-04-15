//
//  DefaultTheme.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

// If you add a new colour here:
//  * and it uses the design system, please put it in Theme+DesignSystem instead
//  * and it doesn't use the design, please only do so with designer approval
struct DefaultTheme: Theme {
    let name = ThemeName.systemDefault

    let statusBarStyle: UIStatusBarStyle = .default

    let keyboardAppearance: UIKeyboardAppearance = .default

    let tabsBarBackgroundColor = UIColor(lightColor: .gray20, darkColor: .black)
    let tabsBarSeparatorColor = UIColor(lightColor: .greyish, darkColor: .darkGreyish)

    let navigationBarTintColor = UIColor(lightColor: .darkGreyish, darkColor: .lightMercury)

    let searchBarTextDeemphasisColor = UIColor(lightColor: .greyish3, darkColor: .lightMercury)

    let browsingMenuHighlightColor = UIColor(lightColor: .lightGreyish, darkColor: .darkGreyish)

    let tableCellSelectedColor = UIColor(lightColor: .mercury, darkColor: .charcoalGrey)
    let tableCellAccessoryColor = UIColor(lightColor: .greyish, darkColor: .greyish3)
    let tableCellHighlightedBackgroundColor = UIColor(lightColor: .mercury, darkColor: .greyishBrown)

    let tabSwitcherCellBorderColor = UIColor(lightColor: .nearlyBlackLight, darkColor: .white)
    let tabSwitcherCellTextColor = UIColor(lightColor: .black, darkColor: .white)
    let tabSwitcherCellSecondaryTextColor = UIColor(lightColor: .greyishBrown2, darkColor: .lightMercury)

    let homeRowPrimaryTextColor = UIColor(lightColor: .nearlyBlackLight, darkColor: .white)
    let homeRowSecondaryTextColor = UIColor(lightColor: .greyishBrown2, darkColor: .white)
    let homeRowBackgroundColor = UIColor(lightColor: .nearlyWhiteLight, darkColor: .nearlyBlackLight)

    let homePrivacyCellTextColor = UIColor(lightColor: .charcoalGrey, darkColor: .white)
    let homePrivacyCellSecondaryTextColor = UIColor.greyish3

    let favoritesPlusTintColor = UIColor.greyish3
    let favoritesPlusBackgroundColor = UIColor(lightColor: .lightMercury, darkColor: .greyishBrown2)

    let activityStyle: UIActivityIndicatorView.Style = .medium

    let destructiveColor = UIColor.destructive

    let searchBarBackgroundColor = UIColor(lightColor: .lightGreyish, darkColor: .charcoalGrey)
}

extension UIColor {
    convenience init(lightColor: UIColor, darkColor: UIColor) {
        self.init {
            switch $0.userInterfaceStyle {
            case .dark: return darkColor
            case .light: return lightColor
            case .unspecified: return lightColor
            @unknown default: return lightColor
            }
        }
    }
}
