//
//  LightTheme.swift
//  DuckDuckGo
//
//  Created by Bartek on 20/10/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit

struct LightTheme: Theme {
    
    var currentImageSet: ThemeManager.ImageSet = .light
    
    var statusBarStyle: UIStatusBarStyle = .default
    
    var backgroundColor = UIColor.nearlyWhite
    
    var barBackgroundColor = UIColor.nearlyWhiteLight
    var barTintColor = UIColor.darkGreyish
    var barTitleColor = UIColor.darkGreyish
    
    var tintOnBlurColor = UIColor.nearlyBlack
    
    var searchBarBackgroundColor = UIColor.lightGreyish
    var searchBarTextColor = UIColor.darkGreyish
    
    var tableCellBackgroundColor = UIColor.nearlyWhiteLight
    var tableCellTintColor = UIColor.darkGreyish
    var tableCellSeparatorColor = UIColor.lightGreyish
    var tableHeaderTextColor = UIColor.greyish4
    
    var toggleSwitchColor = UIColor.cornflowerBlue
    
    var homeRowPrimaryTextColor = UIColor.nearlyBlackLight
    var homeRowSecondaryTextColor = UIColor.greyishBrown2
    var homeRowBackgroundColor = UIColor.nearlyWhiteLight
    
    var aboutScreenTextColor = UIColor.charcoalGrey2
    var aboutScreenButtonColor = UIColor.cornflowerBlue
}
