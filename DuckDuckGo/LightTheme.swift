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
//    var barLightTintColor = UIColor.darkGreyish
    
    var searchBarBackgroundColor = UIColor.lightGreyish
//    var searchBarPlaceholderTextColor = UIColor.greyish2
    var searchBarTextColor = UIColor.darkGreyish
    
    var tableCellBackgrundColor = UIColor.nearlyWhiteLight
    var tableCellTintColor = UIColor.darkGreyish
    var tableCellSeparatorColor = UIColor.lightGreyish
}
