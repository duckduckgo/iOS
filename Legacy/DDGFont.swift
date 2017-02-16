//
//  DDGFont.swift
//  DuckDuckGo
//
//  Created by Sean Reilly on 2017.01.18.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

extension UIFont {
  
  static func duckFont(ofSize size:CGFloat) -> UIFont { return UIFont.systemFont(ofSize: size) }
  
  static let duckStoryTitle = duckFont(ofSize: 16)
  
  static let duckStoryTitleLarge = duckFont(ofSize: 24)
  
  static let duckStoryTitleSmall = duckFont(ofSize: 14)
  
  static let duckStoryCategory = duckFont(ofSize: 12)
  
  static let duckStoryCategorySmall = duckFont(ofSize: 12)
  
  static let duckGeneral = duckFont(ofSize: 12)
  
}

