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

struct DarkTheme: Theme {
    var name = ThemeName.dark
    
    var currentImageSet: ThemeManager.ImageSet = .dark
    var statusBarStyle: UIStatusBarStyle = .lightContent
    var keyboardAppearance: UIKeyboardAppearance = .dark
    
    var backgroundColor = UIColor.nearlyBlack
    
    var barBackgroundColor = UIColor.nearlyBlackLight
    var barTintColor = UIColor.greyish
    var barTitleColor = UIColor.white
    
    var tintOnBlurColor = UIColor.white
    
    var searchBarBackgroundColor = UIColor.charcoalGrey
    var searchBarTextColor = UIColor.white
    var searchBarTextDeemphasisColor = UIColor.lightMercury
    var searchBarBorderColor = UIColor.darkGreyish
    var searchBarClearTextIconColor = UIColor.greyishBrown2

    var tableCellBackgroundColor = UIColor.nearlyBlackLight
    var tableCellSelectedColor = UIColor.charcoalGrey
    var tableCellTintColor = UIColor.greyish
    var tableCellSeparatorColor = UIColor.charcoalGrey
    var tableCellTextColor = UIColor.lightGreyish
    var tableCellAccessoryTextColor = UIColor.greyish
    var tableHeaderTextColor = UIColor.greyish3
    
    var buttonTintColor = UIColor.cornflowerBlue
    var placeholderColor = UIColor.greyish
    
    var textFieldBackgroundColor = UIColor.nearlyBlackLight
    var textFieldFontColor = UIColor.white
    
    var homeRowPrimaryTextColor = UIColor.white
    var homeRowSecondaryTextColor = UIColor.lightMercury
    var homeRowBackgroundColor = UIColor.nearlyBlackLight
    
    var aboutScreenTextColor = UIColor.white
    var aboutScreenButtonColor = UIColor.cornflowerBlue
    
    var favoritesPlusTintColor = UIColor.greyish3
    var favoritesPlusBackgroundColor = UIColor.greyishBrown2

    var faviconBackgroundColor = UIColor.charcoalGrey
    var favoriteTextColor = UIColor.greyish
    
    var feedbackPrimaryTextColor = UIColor.white
    var feedbackSecondaryTextColor = UIColor.lightGreyish
    var feedbackSentimentButtonBackgroundColor = UIColor.charcoalGrey
    
    var activityStyle: UIActivityIndicatorView.Style = .white
}
