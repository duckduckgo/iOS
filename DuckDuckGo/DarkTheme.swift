//
//  DarkTheme.swift
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
struct DarkTheme: Theme {
    var name = ThemeName.dark
    
    var currentImageSet: ThemeManager.ImageSet = .dark
    var statusBarStyle: UIStatusBarStyle = .lightContent
    var keyboardAppearance: UIKeyboardAppearance = .dark

    var tabsBarBackgroundColor = UIColor.black
    var tabsBarSeparatorColor = UIColor.darkGreyish

    var navigationBarTintColor = UIColor.lightMercury

    var centeredSearchBarBackgroundColor = UIColor.nearlyBlackLight
    var searchBarTextDeemphasisColor = UIColor.lightMercury

    var browsingMenuHighlightColor = UIColor.darkGreyish
  
    var tableCellSelectedColor = UIColor.charcoalGrey
    var tableCellAccessoryColor = UIColor.greyish3
    var tableCellHighlightedBackgroundColor = UIColor.greyishBrown
    
    var tabSwitcherCellBorderColor = UIColor.white
    var tabSwitcherCellTextColor = UIColor.white
    var tabSwitcherCellSecondaryTextColor = UIColor.lightMercury
 
    var homeRowPrimaryTextColor = UIColor.white
    var homeRowSecondaryTextColor = UIColor.lightMercury
    var homeRowBackgroundColor = UIColor.nearlyBlackLight
    
    var homePrivacyCellTextColor = UIColor.white
    var homePrivacyCellSecondaryTextColor = UIColor.greyish3
     
    var favoritesPlusTintColor = UIColor.greyish3
    var favoritesPlusBackgroundColor = UIColor.greyishBrown2

    var activityStyle: UIActivityIndicatorView.Style = .medium
    
    var destructiveColor: UIColor = UIColor.destructive

    var searchBarBackgroundColor: UIColor = UIColor.charcoalGrey
}
