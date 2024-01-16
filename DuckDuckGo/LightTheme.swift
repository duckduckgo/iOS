//
//  LightTheme.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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
struct LightTheme: Theme {
    var name = ThemeName.light
    
    var currentImageSet: ThemeManager.ImageSet = .light
    var statusBarStyle: UIStatusBarStyle = .darkContent
    
    var keyboardAppearance: UIKeyboardAppearance = .light

    var tabsBarBackgroundColor = UIColor.gray20
    var tabsBarSeparatorColor = UIColor.greyish
    
    var navigationBarTintColor = UIColor.darkGreyish
    
    var searchBarTextDeemphasisColor = UIColor.greyish3

    var browsingMenuHighlightColor = UIColor.lightGreyish
    
    var tableCellSelectedColor = UIColor.mercury
    var tableCellAccessoryColor = UIColor.greyish
    var tableCellHighlightedBackgroundColor = UIColor.mercury
    
    var tabSwitcherCellBorderColor = UIColor.nearlyBlackLight
    var tabSwitcherCellTextColor = UIColor.black
    var tabSwitcherCellSecondaryTextColor = UIColor.greyishBrown2

    var homeRowPrimaryTextColor = UIColor.nearlyBlackLight
    var homeRowSecondaryTextColor = UIColor.greyishBrown2
    var homeRowBackgroundColor = UIColor.nearlyWhiteLight
    
    var homePrivacyCellTextColor = UIColor.charcoalGrey
    var homePrivacyCellSecondaryTextColor = UIColor.greyish3
       
    var favoritesPlusTintColor = UIColor.greyish3
    var favoritesPlusBackgroundColor = UIColor.lightMercury

    var activityStyle: UIActivityIndicatorView.Style = .medium
    
    var destructiveColor: UIColor = UIColor.destructive

    var searchBarBackgroundColor: UIColor = UIColor.lightGreyish
}
