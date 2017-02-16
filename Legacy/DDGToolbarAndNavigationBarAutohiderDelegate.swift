//
// Created by Sean Reilly on 2017.01.23.
// Copyright (c) 2017 DuckDuckGo. All rights reserved.
//

import UIKit

protocol DDGToolbarAndNavigationBarAutohiderDelegate: NSObjectProtocol {
  func setHideToolbarAndNavigationBar(_ shouldHide: Bool, forScrollview scrollView: UIScrollView)
}

class DDGToolbarAndNavigationBarAutohider: NSObject, UIScrollViewDelegate {
  weak var barHiderDelegate: DDGToolbarAndNavigationBarAutohiderDelegate?
  
  var lastOffset = CGPoint.zero
  var lastUpwardsScrollDistance: CGFloat = 0.0
  var previousContentHeight: CGFloat = 0.0
  var containerView: UIView
  var scrollView: UIScrollView
  var topToolbarBottomConstraint: NSLayoutConstraint!
  var bottomToolbarTopConstraint: NSLayoutConstraint!
  
  init(containerView: UIView, scrollView: UIScrollView, delegate: DDGToolbarAndNavigationBarAutohiderDelegate) {
    self.barHiderDelegate = delegate
    self.containerView = containerView
    self.scrollView = scrollView
    
    super.init()
    
    lastOffset = scrollView.contentOffset
    lastUpwardsScrollDistance = 0
    self.scrollView.delegate = self
    // Register the notificaiton
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  func autoHideOrShowToolbarBased(onScrolling scrollView: UIScrollView) {
    let offset = scrollView.contentOffset
    var shouldStoreLastOffset = true
    if offset.y == 0 {
      // we're at the top... show the toolbar
      lastUpwardsScrollDistance = 0
      self.barHiderDelegate?.setHideToolbarAndNavigationBar(false, forScrollview: scrollView)
    } else if offset.y > lastOffset.y {
      // we're scrolling down... hide the toolbar, unless we're already very close to the bottom
      let contentHeight: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
      var atBottom = false
      let distanceToTheBottom: CGFloat = contentHeight - offset.y
      if distanceToTheBottom < 100 {
        atBottom = true
      }
      lastUpwardsScrollDistance = 0
      self.barHiderDelegate?.setHideToolbarAndNavigationBar(!atBottom, forScrollview: scrollView)
    } else if offset.y > 0 && offset.y <= scrollView.contentSize.height + scrollView.frame.size.height + 50 {
      // we're scrolling up... show the toolbar if we've gone past a certain threshold
      lastUpwardsScrollDistance += (lastOffset.y - offset.y)
      if lastUpwardsScrollDistance > 50 {
        lastUpwardsScrollDistance = 0
        self.barHiderDelegate?.setHideToolbarAndNavigationBar(false, forScrollview: scrollView)
      }
    } else {
      shouldStoreLastOffset = false
    }
    
    // This fixes the issue of pulling up (think pull to refresh) causing an issue with the bar coming in an out... Make's it a whole lot more polished
    if shouldStoreLastOffset {
      lastOffset = offset
    }
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.autoHideOrShowToolbarBased(onScrolling: scrollView)
  }
  // Expanded
  
  func goBackToExpandedNavigationBarState() {
    self.barHiderDelegate?.setHideToolbarAndNavigationBar(false, forScrollview: self.scrollView)
  }
}
