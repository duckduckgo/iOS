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

    var padBackgroundColor = UIColor.charcoalGrey
    var tabsBarSeparatorColor = UIColor.greyish2
    
    var backgroundColor = UIColor.nearlyBlack
    
    var barBackgroundColor = UIColor.nearlyBlackLight
    var barTintColor = UIColor.lightMercury
    
    var navigationBarTitleColor = UIColor.white
    var navigationBarTintColor = UIColor.lightMercury
    
    var tintOnBlurColor = UIColor.white
    
    var searchBarBackgroundColor = UIColor.charcoalGrey
    var centeredSearchBarBackgroundColor = UIColor.nearlyBlackLight
    var searchBarTextColor = UIColor.white
    var searchBarTextPlaceholderColor = UIColor.lightMercury
    var searchBarTextDeemphasisColor = UIColor.lightMercury
    var searchBarBorderColor = UIColor.darkGreyish
    var searchBarClearTextIconColor = UIColor.greyish2
    
    var progressBarGradientDarkColor = UIColor.orange
    var progressBarGradientLightColor = UIColor.orangeLight
    
    var autocompleteCellAccessoryColor = UIColor.lightMercury

    var tableCellBackgroundColor = UIColor.nearlyBlackLight
    var tableCellSelectedColor = UIColor.charcoalGrey
    var tableCellSeparatorColor = UIColor.charcoalGrey
    var tableCellTextColor = UIColor.lightGreyish
    var tableCellAccessoryTextColor = UIColor.greyish
    var tableCellAccessoryColor = UIColor.greyish3
    var tableCellHighlightedBackgroundColor = UIColor.greyishBrown
    var tableHeaderTextColor = UIColor.greyish3
    
    var tabSwitcherCellBackgroundColor = UIColor.nearlyBlackLight
    var tabSwitcherCellBorderColor = UIColor.white
    var tabSwitcherCellTextColor = UIColor.white
    var tabSwitcherCellSecondaryTextColor = UIColor.lightMercury
    
    var iconCellBorderColor = UIColor.lightGreyish

    var buttonTintColor = UIColor.cornflowerBlue
    var placeholderColor = UIColor.greyish
    
    var textFieldBackgroundColor = UIColor.nearlyBlackLight
    var textFieldFontColor = UIColor.white
    
    var homeRowPrimaryTextColor = UIColor.white
    var homeRowSecondaryTextColor = UIColor.lightMercury
    var homeRowBackgroundColor = UIColor.nearlyBlackLight
    
    var homePrivacyCellTextColor = UIColor.white
    var homePrivacyCellSecondaryTextColor = UIColor.greyish3
    
    var aboutScreenTextColor = UIColor.white
    var aboutScreenButtonColor = UIColor.cornflowerBlue
    
    var favoritesPlusTintColor = UIColor.greyish3
    var favoritesPlusBackgroundColor = UIColor.greyishBrown2

    var faviconBackgroundColor = UIColor.charcoalGrey
    var favoriteTextColor = UIColor.greyish
    
    var feedbackPrimaryTextColor = UIColor.white
    var feedbackSecondaryTextColor = UIColor.lightGreyish
    var feedbackSentimentButtonBackgroundColor = UIColor.charcoalGrey
    
    var privacyReportCellBackgroundColor = UIColor.nearlyBlackLight
    
    var activityStyle: UIActivityIndicatorView.Style = .white
    
    var destructiveColor: UIColor = UIColor.destructive
    
    var ddgTextTintColor: UIColor = .white

    var daxDialogBackgroundColor: UIColor = .nearlyBlackLight
    var daxDialogTextColor: UIColor = UIColor.nearlyWhite

}
