//
//  DDGSearchBar.swift
//  Browser
//
//  Created by Sean Reilly on 2017.01.03.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit


class DDGSearchBar : UIView {
  @IBOutlet var bangButton: UIButton?
  @IBOutlet var leftButton: UIButton?
  @IBOutlet var cancelButton: UIButton?
  @IBOutlet var searchField: DDGAddressBarTextField?
  @IBOutlet var progressView: DDGProgressBar?
  
  @IBOutlet var cancelButtonXConstraint: NSLayoutConstraint?
  @IBOutlet var leftButtonXConstraint: NSLayoutConstraint?
  
  @IBOutlet var compactedLabel: UILabel?
  @IBOutlet var goBackToExpandedStateButton: UIButton?
  
  private var isShowsCancelButton: Bool = false
  private var isShowsLeftButton: Bool = false
  private var isShowsBangButton: Bool = false
  
  var isCompactMode: Bool = false {
    didSet {
      let compact = isCompactMode
      self.compactedLabel?.text = DDGSearchBar.getTextFromSearchBarText(self.searchField?.text)
      self.leftButton?.alpha = compact ? 0 : 1
      self.searchField?.alpha = compact ? 0 : 1
      self.compactedLabel?.alpha = compact ? 1 : 0;
      self.goBackToExpandedStateButton?.isHidden = !compact
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
    self.setNeedsLayout()
  }
  
  func showBangButton(show:Bool=true, animated:Bool) {
    self.isShowsBangButton = show
    self.showsBangButtonUpdated(animated: animated)
  }
  
  func showsBangButtonUpdated(animated: Bool) {
    if let searchField=self.searchField {
      let show = self.isShowsBangButton
      searchField.additionalLeftSideInset = show ? 39 : 0
      self.isShowsBangButton = show
      self.setNeedsLayout()
      self.layoutIfNeeded(animated ? 0.2 : 0)
    }
  }
  
  
  func showCancelButton(show:Bool=true, animated:Bool=true) {
    self.isShowsCancelButton = show
    self.showsCancelButtonUpdated(animated: animated)
  }
  
  func showsCancelButtonUpdated(animated: Bool) {
    let show = self.isShowsCancelButton
    
    let makeChanges: (() -> Void) = {() -> Void in
      guard let cancelButton=self.cancelButton, let cancelConstraint = self.cancelButtonXConstraint else {
        return
      }
      if show {
        cancelConstraint.constant = -(cancelButton.frame.size.width + 12)
        cancelButton.alpha = 1
      } else {
        cancelConstraint.constant = 4
        cancelButton.alpha = 0
      }
      if animated {
        self.layoutIfNeeded()
      } else {
        self.setNeedsLayout()
      }
    }
    if animated {
      UIView.animate(withDuration: 0.2, animations: makeChanges)
    } else {
      makeChanges()
    }
  }
  
  func showLeftButton(show:Bool=true, animated:Bool=true) {
    self.isShowsLeftButton = show
    self.showsLeftButtonUpdated(animated: animated)
  }
  
  func showsLeftButtonUpdated(animated: Bool) {
    guard let leftButton=self.leftButton, let leftConstraint = self.leftButtonXConstraint else {
      return
    }
    
    if self.isShowsLeftButton {
      leftConstraint.constant = leftButton.frame.size.width + 10
      leftButton.alpha = 1
    } else {
      leftConstraint.constant = 0
      leftButton.alpha = 0
    }
    self.layoutIfNeeded(((animated) ? 0.2 : 0.0))
  }
  
  func layoutIfNeeded(_ animationDuration: TimeInterval) {
    if animationDuration <= 0 {
      self.layoutIfNeeded()
    } else {
      UIView.animate(withDuration: animationDuration, animations: {() -> Void in
        self.layoutIfNeeded()
      })
    }
  }
  
  
  
  
  override func layoutSubviews() {
    self.leftButton?.isHidden = !self.isShowsLeftButton
    //self.bangButton?.hidden = !self.showsBangButton;
    self.bangButton?.alpha = self.isShowsBangButton ? 1 : 0
    self.cancelButton?.isHidden = !self.isShowsCancelButton
    self.setNeedsDisplay()
    self.setNeedsUpdateConstraints()
    super.layoutSubviews()
  }
  
  override func updateConstraints() {
    super.updateConstraints()
    self.searchField?.updateConstraints()
  }
  
  func cancel() {
    self.progressView?.percentCompleted = 100
  }
  
  func finish() {
    self.progressView?.percentCompleted = 100
  }
  
  
  func setProgress(_ newProgress: Double) {
    self.progressView?.percentCompleted = max(0, min(ceil(newProgress * 100), 100))
  }
  
  func setProgress(_ newProgress: Double, animationDuration duration: CGFloat) {
    UIView.animate(withDuration: TimeInterval(duration), delay: 0.0, options: [.beginFromCurrentState, .curveEaseOut], animations: {() -> Void in
      self.setProgress(newProgress)
    }, completion: {(_ finished: Bool) -> Void in
      if finished {
        self.setProgress(newProgress + 0.1, animationDuration: duration * 4)
      }
    })
  }

  class func getTextFromSearchBarText(_ searchText: String?) -> String {
    if let searchText = searchText {
      if searchText.hasPrefix("http") {
        return URL(string: searchText)?.host ?? searchText
      } else {
        return searchText
      }
    } else {
      return ""
    }
  }

}


