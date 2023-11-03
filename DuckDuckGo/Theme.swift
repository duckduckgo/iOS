//
//  Theme.swift
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

enum ThemeName: String {
    case systemDefault
    case light
    case dark
}

protocol Theme {
    var name: ThemeName { get }
    
    var currentImageSet: ThemeManager.ImageSet { get }
    var statusBarStyle: UIStatusBarStyle { get }
    var keyboardAppearance: UIKeyboardAppearance { get }

    var tabsBarBackgroundColor: UIColor { get }
    var tabsBarSeparatorColor: UIColor { get }
    
    var backgroundColor: UIColor { get }
    
    var mainViewBackgroundColor: UIColor { get }
    
    var omniBarBackgroundColor: UIColor { get }
    var barBackgroundColor: UIColor { get }
    var barTintColor: UIColor { get }
    
    var navigationBarTitleColor: UIColor { get }
    var navigationBarTintColor: UIColor { get }
    
    var searchBarBackgroundColor: UIColor { get }
    var searchBarTextColor: UIColor { get }
    var searchBarTextPlaceholderColor: UIColor { get }
    var searchBarTextDeemphasisColor: UIColor { get }

    var browsingMenuTextColor: UIColor { get }
    var browsingMenuIconsColor: UIColor { get }
    var browsingMenuBackgroundColor: UIColor { get }
    var browsingMenuSeparatorColor: UIColor { get }
    var browsingMenuHighlightColor: UIColor { get }
    
    var progressBarGradientDarkColor: UIColor { get }
    var progressBarGradientLightColor: UIColor { get }
    
    var autocompleteSuggestionTextColor: UIColor { get }
    var autocompleteCellAccessoryColor: UIColor { get }

    var tableCellBackgroundColor: UIColor { get }
    var tableCellSelectedColor: UIColor { get }
    var tableCellSeparatorColor: UIColor { get }
    var tableCellTextColor: UIColor { get }
    var tableCellAccessoryTextColor: UIColor { get }
    var tableCellAccessoryColor: UIColor { get }
    var tableCellHighlightedBackgroundColor: UIColor { get }
    var tableHeaderTextColor: UIColor { get }
    
    var tabSwitcherCellBackgroundColor: UIColor { get }
    var tabSwitcherCellBorderColor: UIColor { get }
    var tabSwitcherCellTextColor: UIColor { get }
    var tabSwitcherCellSecondaryTextColor: UIColor { get }
    
    var iconCellBorderColor: UIColor { get }
    
    var buttonTintColor: UIColor { get }
    var placeholderColor: UIColor { get }
    
    var textFieldBackgroundColor: UIColor { get }
    var textFieldFontColor: UIColor { get }
    
    var homeRowPrimaryTextColor: UIColor { get }
    var homeRowSecondaryTextColor: UIColor { get }
    var homeRowBackgroundColor: UIColor { get }
    
    var homePrivacyCellTextColor: UIColor { get }
    var homePrivacyCellSecondaryTextColor: UIColor { get }
    
    var aboutScreenTextColor: UIColor { get }
    var aboutScreenButtonColor: UIColor { get }

    var faviconBackgroundColor: UIColor { get }
    var favoriteTextColor: UIColor { get }
    
    var feedbackPrimaryTextColor: UIColor { get }
    var feedbackSecondaryTextColor: UIColor { get }
    var feedbackSentimentButtonBackgroundColor: UIColor { get }

    var activityStyle: UIActivityIndicatorView.Style { get }
    
    var destructiveColor: UIColor { get }
    
    var ddgTextTintColor: UIColor { get }
    
    var daxDialogBackgroundColor: UIColor { get }
    var daxDialogTextColor: UIColor { get }
 
    var autofillEmptySearchViewTextColor: UIColor { get }
    var autofillLockedViewTextColor: UIColor { get }

    var privacyDashboardWebviewBackgroundColor: UIColor { get }

}
