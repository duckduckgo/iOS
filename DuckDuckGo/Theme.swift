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
    case light
    case dark
}

protocol Theme {
    var name: ThemeName { get }
    
    var currentImageSet: ThemeManager.ImageSet { get }
    var statusBarStyle: UIStatusBarStyle { get }
    var keyboardAppearance: UIKeyboardAppearance { get }
    
    var backgroundColor: UIColor { get }
    
    var barBackgroundColor: UIColor { get }
    var barTintColor: UIColor { get }
    var barTitleColor: UIColor { get }
    
    // Color of the content that is directly placed over blurred background
    var tintOnBlurColor: UIColor { get }
    
    var searchBarBackgroundColor: UIColor { get }
    var searchBarTextColor: UIColor { get }
    
    var tableCellBackgroundColor: UIColor { get }
    var tableCellSelectedColor: UIColor { get }
    var tableCellTintColor: UIColor { get }
    var tableCellSeparatorColor: UIColor { get }
    var tableCellAccessoryTextColor: UIColor { get }
    var tableHeaderTextColor: UIColor { get }
    
    var toggleSwitchColor: UIColor { get }
    
    var homeRowPrimaryTextColor: UIColor { get }
    var homeRowSecondaryTextColor: UIColor { get }
    var homeRowBackgroundColor: UIColor { get }
    
    var aboutScreenTextColor: UIColor { get }
    var aboutScreenButtonColor: UIColor { get }

    var favoritesPlusTintColor: UIColor { get }
    var favoritesPlusBackgroundColor: UIColor { get }
    var faviconBackgroundColor: UIColor { get }
    var favoriteTextColor: UIColor { get }
    
}
