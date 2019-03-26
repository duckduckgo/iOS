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

struct LightTheme: Theme {
    var name = ThemeName.light
    
    var currentImageSet: ThemeManager.ImageSet = .light
    var statusBarStyle: UIStatusBarStyle = .default
    var keyboardAppearance: UIKeyboardAppearance = .light
    
    var backgroundColor = UIColor.nearlyWhite
    
    var barBackgroundColor = UIColor.nearlyWhiteLight
    var barTintColor = UIColor.darkGreyish
    var barTitleColor = UIColor.darkGreyish
    
    var tintOnBlurColor = UIColor.white
    
    var searchBarBackgroundColor = UIColor.mercury
    var searchBarTextColor = UIColor.darkGreyish
    var searchBarTextDeemphasisColor = UIColor.greyish3
    var searchBarBorderColor = UIColor.lightGreyish
    var searchBarClearTextIconColor = UIColor.greyish

    var tableCellBackgroundColor = UIColor.nearlyWhiteLight
    var tableCellSelectedColor = UIColor.mercury
    var tableCellTintColor = UIColor.darkGreyish
    var tableCellSeparatorColor = UIColor.mercury
    var tableCellAccessoryTextColor = UIColor.greyish3
    var tableHeaderTextColor = UIColor.greyish3
    
    var toggleSwitchColor = UIColor.cornflowerBlue
    
    var homeRowPrimaryTextColor = UIColor.nearlyBlackLight
    var homeRowSecondaryTextColor = UIColor.greyishBrown2
    var homeRowBackgroundColor = UIColor.nearlyWhiteLight
    
    var aboutScreenTextColor = UIColor.charcoalGrey
    var aboutScreenButtonColor = UIColor.cornflowerBlue
    
    var favoritesPlusTintColor = UIColor.greyish3
    var favoritesPlusBackgroundColor = UIColor.lightMercury
    
    var faviconBackgroundColor = UIColor.white
    var favoriteTextColor = UIColor.darkGreyish
    
    var activityStyle: UIActivityIndicatorView.Style = .gray
}
