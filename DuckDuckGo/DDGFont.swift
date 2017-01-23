//
//  DDGFont.swift
//  DuckDuckGo
//
//  Created by Sean Reilly on 2017.01.18.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

extension UIFont {
  
  class func duckStoryTitle() -> UIFont { return duckFont(ofSize: 16) }
  
  class func duckStoryTitleLarge() -> UIFont { return duckFont(ofSize: 24) }
  
  class func duckStoryTitleSmall() -> UIFont { return duckFont(ofSize: 14) }
  
  class func duckStoryCategory() -> UIFont { return duckFont(ofSize: 12) }
  
  class func duckStoryCategorySmall() -> UIFont { return duckFont(ofSize: 12) }
  
  class func duckGeneral() -> UIFont { return duckFont(ofSize: 12) }
  
  class func duckFont(ofSize size:CGFloat) -> UIFont { return UIFont.systemFont(ofSize: size) }
  
}

