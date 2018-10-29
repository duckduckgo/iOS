//
//  DarkTheme.swift
//  DuckDuckGo
//
//  Created by Bartek on 20/10/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit

struct DarkTheme: Theme {
    
    var currentImageSet: ThemeManager.ImageSet = .dark
    
    var statusBarStyle: UIStatusBarStyle = .lightContent
    
    var backgroundColor = UIColor.nearlyBlack
    
    var barBackgroundColor = UIColor.nearlyBlackLight
    var barTintColor = UIColor.grayish
    var barTitleColor = UIColor.white
    
    var tintOnBlurColor = UIColor.white
    
    var searchBarBackgroundColor = UIColor.grayishBrown
    var searchBarTextColor = UIColor.white
    
    var tableCellBackgroundColor = UIColor.nearlyBlackLight
    var tableCellTintColor = UIColor.grayish
    var tableCellSeparatorColor = UIColor.charcoalGrey2
    var tableHeaderTextColor = UIColor.lightGreyish
    
    var toggleSwitchColor = UIColor.cornflowerBlue
    
    var homeRowPrimaryTextColor = UIColor.white
    var homeRowSecondaryTextColor = UIColor.lightMercury
    var homeRowBackgroundColor = UIColor.nearlyBlackLight
    
    var aboutScreenTextColor = UIColor.white
    var aboutScreenButtonColor = UIColor.cornflowerBlue
}
