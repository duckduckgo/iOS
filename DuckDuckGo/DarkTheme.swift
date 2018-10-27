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
//    var barLightTintColor = UIColor.darkGreyish
    
    var searchBarBackgroundColor = UIColor.grayishBrown
//    var searchBarPlaceholderTextColor = UIColor.greyish3
    var searchBarTextColor = UIColor.white
    
    var tableCellBackgrundColor = UIColor.nearlyBlackLight
    var tableCellTintColor = UIColor.grayish
    var tableCellSeparatorColor = UIColor.charcoalGrey2
    
    var tableHeaderTextColor = UIColor.lightGreyish
    var toggleSwitchColor: UIColor?
}
