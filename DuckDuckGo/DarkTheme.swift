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
//    var barLightTintColor = UIColor.darkGreyish
    
    var searchBarBackgroundColor = UIColor.grayishBrown
//    var searchBarPlaceholderTextColor = UIColor.greyish3
    var searchBarTextColor = UIColor.white
}
