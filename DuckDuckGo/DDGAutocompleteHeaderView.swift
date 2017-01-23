//
// Created by Sean Reilly on 2017.01.23.
// Copyright (c) 2017 DuckDuckGo. All rights reserved.
//

import UIKit
class DDGAutocompleteHeaderView: UIView {
  var textLabel: UILabel?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = UIColor.duckStoriesBackground()
    let label = UILabel(frame: UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(0, 8.0, 0, 0)))
    label.backgroundColor = UIColor.clear
    label.isOpaque = false
    label.textColor = UIColor.autocompleteHeaderColor()
    label.font = UIFont.duckFont(ofSize: 13.0)
    label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.addSubview(label)
    self.textLabel = label
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder)
  }
  
  
}