//
//  DDGProgressBar.swift
//  Browser
//
//  Created by Sean Reilly on 2017.01.10.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

class DDGProgressBar: UIView {
  var percentCompleted:CGFloat = 0.0
  var noncompletedForeground: UIColor!
  var completedForeground: UIColor!
  
  override var bounds: CGRect{
    didSet {
      self.updateProgress()
    }
  }
  
  override var frame: CGRect{
    didSet {
      self.updateProgress()
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder)
    
    self.commonInit()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.commonInit()
  }
  
  func commonInit() {
    self.percentCompleted = 100
    self.backgroundColor = UIColor.duckProgressBarBackground
    self.completedForeground = UIColor.duckSearchBarBackground
    self.noncompletedForeground = UIColor.duckProgressBarForeground
    self.addSubview(self.completedView)
    self.updateProgress()
  }
  
  func updateProgress() {
    self.updateProgress(withDuration: 0.25)
  }
  
  func updateProgress(withDuration duration: TimeInterval) {
    let progress = min(max(0, percentCompleted), 100)
    var frame = self.frame
    frame.origin.x = 0
    frame.origin.y = 0
    frame.size.width = CGFloat(progress / 100) * frame.size.width
    if self.completedView == nil {
      self.completedView = UIView(frame: frame)
    }
    self.completedView.backgroundColor = progress >= 100 ? self.completedForeground : self.noncompletedForeground
    if duration != 0 {
      UIView.animate(withDuration: duration, animations: {() -> Void in
        self.completedView.frame = frame
      })
    } else {
      self.completedView.frame = frame
    }
    self.setNeedsDisplay()
  }
  
  
  var completedView: UIView!
}

