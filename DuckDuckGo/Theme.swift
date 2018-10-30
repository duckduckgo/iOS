//
//  ThemeTmp.swift
//  DuckDuckGo
//
//  Created by Bartek on 20/10/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit

protocol Theme {
    
    var currentImageSet: ThemeManager.ImageSet { get }
    var statusBarStyle: UIStatusBarStyle { get }
    
    var backgroundColor: UIColor { get }
    
    var barBackgroundColor: UIColor { get }
    var barTintColor: UIColor { get }
    var barTitleColor: UIColor { get }
    
    // Color of the content that is directly placed over blurred background
    var tintOnBlurColor: UIColor { get }
    
    var searchBarBackgroundColor: UIColor { get }
    var searchBarTextColor: UIColor { get }
    
    var tableCellBackgroundColor: UIColor { get }
    var tableCellTintColor: UIColor { get }
    var tableCellSeparatorColor: UIColor { get }
    var tableHeaderTextColor: UIColor { get }
    
    var toggleSwitchColor: UIColor { get }
    
    var homeRowPrimaryTextColor: UIColor { get }
    var homeRowSecondaryTextColor: UIColor { get }
    var homeRowBackgroundColor: UIColor { get }
    
    var aboutScreenTextColor: UIColor { get }
    var aboutScreenButtonColor: UIColor { get }
}
