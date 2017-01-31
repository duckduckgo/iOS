//
//  Colour.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 26/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

extension UIColor {
  static let darkGrey = UIColor.darkGray

  static func colorWithRedValue(redValue: CGFloat, greenValue: CGFloat, blueValue: CGFloat, alpha: CGFloat) -> UIColor {
    return UIColor(red: redValue/255.0, green: greenValue/255.0, blue: blueValue/255.0, alpha: alpha)
  }
  
  static func duckFont(ofSize size:CGFloat) -> UIFont { return UIFont.systemFont(ofSize: size) }
  
  static let duckStoryTitle = duckFont(ofSize: 16)
  
  static let duckStoryTitleLarge = duckFont(ofSize: 24)
  
  static let duckStoryTitleSmall = duckFont(ofSize: 14)
  
  static let duckStoryCategory = duckFont(ofSize: 12)
  
  static let duckStoryCategorySmall = duckFont(ofSize: 12)
  
  static let duckGeneral = duckFont(ofSize: 12)

  
  
  static let duckBlack = UIColor(red:41.0, green:41.0, blue:41.0, alpha:1.0)
  
  static let duckGray = UIColor(red:86.0/255.0, green:86.0/255.0, blue:86.0/255.0, alpha:1.0)
  
  static let duckLightBlue = UIColor(red:191.0/255.0, green:223.0/255.0, blue:255.0/255.0, alpha:1.0)
  
  static let duckLightGray = UIColor(red:240.0/255.0, green:240.0/255.0, blue:240.0/255.0, alpha:1.0)
  
  static let duckSegmentedForeground = UIColor.white
  
  static let duckSegmentedBackground = duckSearchBarBackground
  
  static let duckTabBarBackground = UIColor.white
  
  static let duckTabBarForeground = UIColor(red:0.678, green:0.678, blue:0.678, alpha:1)
  
  static let duckTabBarForegroundSelected = UIColor(red:0.874, green:0.345, blue:0.2, alpha:1)
  
  static let duckTabBarBorder = UIColor(red:0, green:0, blue:0, alpha:0.15)
  
  static let duckProgressBarForeground = UIColor(red:0.266, green:0.584, blue:0.831, alpha:1)
  
  static let duckProgressBarBackground = UIColor(red:0.596, green:0.772, blue:0.905, alpha:1)
  
  static let duckStoriesBackground = UIColor(red:0.933, green:0.933, blue:0.933, alpha:1)
  
  static let duckRefreshColor = UIColor(red:0.666, green:0.666, blue:0.666, alpha:1)
  
  static let duckSegmentBarBackground = duckSearchBarBackground
  static let duckSegmentBarForeground = UIColor.white
  static let duckSegmentBarBackgroundSelected = UIColor.white
  static let duckSegmentBarForegroundSelected = duckSearchBarBackground
  static let duckSegmentBarBorder = UIColor.white
  
  static let duckStoryMenuButtonBackground = UIColor.black.withAlphaComponent(0.5)
  
  static let duckNoContentColor = UIColor(red:0.933, green:0.933, blue:0.933, alpha:1)
  
  static let duckRed = UIColor(red:0.87, green:0.345, blue:0.2, alpha:1)
  
  static let duckStoryReadColor = UIColor(red:158.0, green:158.0, blue:158.0, alpha:1)
  
  static let duckStoryTitleBackground = UIColor.white
  
  static let duckStoryDropShadowColor = UIColor(red:0.854, green:0.854, blue:0.854, alpha:1)
  
  static let duckTableSeparator = UIColor(red:0.866, green:0.866, blue:0.866, alpha:1)
  
  static let duckSearchFieldBackground = UIColor(red:0.741, green:0.29, blue:0.168, alpha:1)
  
  static let duckSearchBarBackground = UIColor(red:0.87, green:0.345, blue:0.2, alpha:1)
  
  static let duckSearchFieldForeground = UIColor.white
  
  static let duckSearchFieldPlaceholderForeground = UIColor.white
  
  static let duckPopoverBackground = UIColor.clear
  
  static let duckDimmedPopoverBackground = UIColor.black.withAlphaComponent(0.35)
  
  static let autocompleteHeaderColor = UIColor.clear
  
  static let duckListItemTextForeground = UIColor(red:0.133, green:0.133, blue:0.133, alpha:1)
  
  static let duckListItemDetailForeground = UIColor(red:137.0/255.0, green:137.0/255.0, blue:137.0/255.0, alpha:1.0)
  
  static let autocompleteTitleColor = UIColor(red:89.0, green:95.0, blue:102.0, alpha:1.0)
  
  
}
