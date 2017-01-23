//
//  DDGPopoverViewController.swift
//  DuckDuckGo
//
//  Created by Sean Reilly on 2017.01.18.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import QuartzCore


protocol DDGPopoverViewControllerDelegate: NSObjectProtocol {
  func popoverControllerDidDismissPopover(_ popoverController: DDGPopoverViewController)
}

class DDGPopoverViewController: UIViewController {
  private(set) var contentViewController: UIViewController
  weak var delegate: DDGPopoverViewControllerDelegate?
  weak var popoverParentController: UIViewController?
  weak var touchPassthroughView: UIView?
  weak var anchorView: UIView?
  weak var dimmedBackgroundView: UIView?

  // the insets of the popover border
  var borderInsets = UIEdgeInsets()
  var intrusion: CGFloat = 0.0
  var isShouldDismissUponOutsideTap = false
  var isShouldAbsorbAndDismissUponDimmedViewTap = false
  var isHideArrow = false
  var isLargeMode = false
  var anchorRect = CGRect.zero
  var backgroundView: DDGPopoverBackgroundView?
  var upArrowImage: UIImage?
  var downArrowImage: UIImage?
  var arrowDirections:UIPopoverArrowDirection = .any
  
  init(contentViewController viewController: UIViewController, andTouchPassthroughView touchPassthroughView: UIView) {
    super.init(nibName: nil, bundle: nil)
    
    self.contentViewController = viewController
    self.touchPassthroughView = touchPassthroughView
    self.intrusion = 6
    self.isShouldDismissUponOutsideTap = true
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func presentPopover(from originView: UIView, permittedArrowDirections arrowDirections: UIPopoverArrowDirection, animated: Bool) {
    self.anchorRect = CGRect.zero
    // originRect
    self.anchorView = originView
    self.arrowDirections = arrowDirections
    self.presentPopover(animated: animated)
  }
  
  func present(from originRect: CGRect, in originView: UIView, permittedArrowDirections arrowDirections: UIPopoverArrowDirection, animated: Bool) {
    self.anchorRect = originRect
    self.anchorView = originView
    self.arrowDirections = arrowDirections
    self.presentPopover(animated: animated)
  }
  
  func dismiss(animated: Bool) {
    self.dismiss(animated: animated, completion: nil)
  }
  
  
  override func loadView() {
    super.loadView()
    self.backgroundView = DDGPopoverBackgroundView(frame: (self.touchPassthroughView ?? self.view).frame)
    self.backgroundView.popoverViewController = self
    self.view = self.backgroundView
    self.view.backgroundColor = UIColor.clear
    self.view.opaque = false
    var contentView = self.contentView.view
    self.addChildViewController(self.contentView)
    // calls [childViewController willMoveToParentViewController:self]
    self.view.addSubview(contentView)
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    contentView.opaque = false
    contentView.layer.cornerRadius = 4.0
    //contentView.alpha = 1;
    self.contentView.didMove(toParentViewController: self)
    self.view.layer.shouldRasterize = true
    self.view.layer.rasterizationScale = UIScreen.main.scale()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.backgroundView.touchPassthroughView = self.touchPassthroughView
    self.backgroundView.backgroundImage! = UIImage(named: "popover-frame")!
    self.backgroundView.alpha = 0.0
    var arrowImageName = self.isLargeMode ? "popover-indicator-large" : "popover-indicator"
    self.upArrowImage = UIImage(named: arrowImageName)!
    self.downArrowImage = UIImage(cgImage: self.upArrowImage.cgImage!, scale: self.upArrowImage.scale(), orientation: .downMirrored)
    //[self.view addSubview:self.backgroundView];
  }
  
  override func willRotate(toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
    super.willRotate(toInterfaceOrientation: toInterfaceOrientation, duration: duration)
    if self.isShouldDismissUponOutsideTap {
      self.delegate.popoverControllerDidDismissPopover(self)
      self.dismiss(animated: (duration > 0.0))
    }
  }
  
  override func didRotate(fromInterfaceOrientation fromOrientation: UIInterfaceOrientation) {
    super.didRotate(fromInterfaceOrientation: fromOrientation)
    if self.isShouldDismissUponOutsideTap {
      self.dismiss(animated: false)
    }
    else {
      self.presentPopover(animated: false)
    }
  }
  
  func presentPopover(animated: Bool) {
    var rootViewController = self.anchorView.window!.rootViewController!
    if rootViewController == nil || self.popoverParentController != nil {
      rootViewController = self.popoverParentController
    }
    self.view.frame = rootViewController.view.frame
    // the containing frame should cover the entire root view
    rootViewController.view.window!.addSubview(self.view)
    rootViewController.addChildViewController(self)
    self.didMove(toParentViewController: rootViewController)
    self.view.addSubview(self.contentView.view)
    self.view.insertSubview(self.contentView.view, belowSubview: self.backgroundView.arrowView)
    self.addChildViewController(self.contentView)
    //    [self.contentViewController willMoveToParentViewController:self];
    //    [self.contentViewController removeFromParentViewController]; // calls [childViewController didMoveToParentViewController:nil]
    self.view.setNeedsLayout()
    self.view.layoutIfNeeded()
    var duration = animated ? 0.4 : 0.0
    UIView.animate(withDuration: duration, animations: {() -> Void in
      self.view.alpha = 1.0
    }, completion: {(_ finished: Bool) -> Void in
      self.view.layer.shouldRasterize = false
    })
  }
  
  override func isBeingPresented() -> Bool {
    return self.view.alpha != 0.0
  }
  
  override func dismiss(animated: Bool, completion: @escaping (_: Void) -> Void) {
    var duration = animated ? 0.2 : 0.0
    self.view.layer.shouldRasterize = true
    self.view.layer.rasterizationScale = UIScreen.main.scale()
    UIView.animate(withDuration: duration, animations: {() -> Void in
      self.view.alpha = 0.0
    }, completion: {(_ finished: Bool) -> Void in
      self.willMove(toParentViewController: { _ in })
      self.view.removeFromSuperview()
      self.removeFromParent()
      self.contentView.willMove(toParentViewController: { _ in })
      self.contentView.view.removeFromSuperview()
      self.contentView.removeFromParent()
      // calls [childViewController didMoveToParentViewController:{ _ in }]
      if finished {
        self.delegate.popoverControllerDidDismissPopover(self)
      }
      if completion != { _ in } {
        completion()
      }
    })
  }
  
}



class DDGPopoverBackgroundView: UIView {
  var arrowView: UIImageView
  var popoverRect = CGRect.zero
  var debugRect = CGRect.zero
  var borderInsets = UIEdgeInsets()
  weak var popoverViewController: DDGPopoverViewController?
  
  var backgroundImage: UIImage? {
    get {
      return self.backgroundImage
    }
    set(backgroundImage) {
      self.backgroundImage = backgroundImage?.resizableImage(withCapInsets: UIEdgeInsetsMake(12, 12, 12, 12))
    }
  }
  
  var arrowImage: UIImage? {
    get {
      // TODO: add getter implementation
    }
    set(arrowImage) {
      self.arrowImage = arrowImage
      self.arrowView.image = arrowImage
    }
  }
  
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.borderInsets = UIEdgeInsetsMake(8, 8, 8, 8)
    self.arrowView = UIImageView()
    self.addSubview(self.arrowView)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    self.borderInsets = UIEdgeInsetsMake(8, 8, 8, 8)
    self.arrowView = UIImageView()
    self.addSubview(self.arrowView)
  }
  
  
  override func draw(_ rect: CGRect) {
    if let dimView = self.popoverViewController?.dimmedBackgroundView {
      var context = UIGraphicsGetCurrentContext()!
      context.setFillColor(UIColor.duckDimmedPopoverBackground().cgColor)
      context.fill(self.convert(dimView.frame, from: dimView.superview))
    }
    super.draw(rect)
    self.backgroundImage!.draw(in: self.popoverRect)
    //    CGContextRef context = UIGraphicsGetCurrentContext();
    //    CGContextSetFillColorWithColor(context, [[UIColor greenColor] colorWithAlphaComponent:0.3].CGColor);
    //    CGContextFillRect(context, self.originRect);
    //
    //    CGContextSetFillColorWithColor(context, [[UIColor blueColor] colorWithAlphaComponent:0.3].CGColor);
    //    CGContextFillRect(context, self.arrowView.frame);
    //
    //    CGContextSetFillColorWithColor(context, [[UIColor redColor] colorWithAlphaComponent:0.3].CGColor);
    //    CGContextFillRect(context, self.popoverRect);
  }
  
  override func hitTest(_ point: CGPoint, with event: UIEvent) -> UIView? {
    var hitView = super.hitTest(point, with: event)!
    // If the hitView is THIS view, return the view that you want to receive the touch instead:
    if hitView == self {
      if self.popoverViewController?.isShouldDismissUponOutsideTap {
        // dismiss, but stil allow the hit to be passed through
        self.performSelector(#selector(self.goAwayNow), withObject: nil, afterDelay: 0.001)
        // Check the popoverViewController if the content view is of type DDGStoryMenu
        if (self.popoverViewController.contentView is DDGStoryMenu) {
          // Check the cell and see if the hit point falls in the cell, then dont pass the hit view
          var menu = (self.popoverViewController.contentView as! DDGStoryMenu)
          var locationInView = menu.storyCell.convertPoint(point, from: menu.storyCell.window!)
          if menu.storyCell.bounds.contains(locationInView) {
            menu.storyCell.shouldGoToDetail = false
          }
        }
      }
      var isWithinContent = self.popoverViewController.contentView.view.frame.contains(point)
      if isWithinContent {
        return hitView
      }
      // if we get here, we've gotten a tap outside of our own content area. Check to see
      // if it's within the dimmed view and if we're supposed to absorb those taps and dismiss
      var dimView = self.popoverViewController.dimmedBackgroundView
      if dimView && self.popoverViewController.isShouldAbsorbAndDismissUponDimmedViewTap {
        if dimView.frame.contains(dimView.convertPoint(point, from: self)) {
          // the tap was within the dimmed view.  dismiss and absorb the touch ourselves
          self.performSelector(#selector(self.goAwayNow), withObject: nil, afterDelay: 0.001)
        }
      }
      // this will pass any touches through to the passthroughview
      return self.touchPassthroughView.hitTest(self.touchPassthroughView.convertPoint(point, from: self), withEvent: event)!
    }
    // Else return the hitView (as it could be one of this view's buttons):
    return hitView
  }
  
  func goAwayNow() {
    self.popoverViewController.dismiss(animated: true)
  }
  
  func originRect() -> CGRect {
    var originRect = self.popoverViewController.anchorRect
    var originView = self.popoverViewController.anchorView
    if originRect.origin.x == 0 && originRect.origin.y == 0 && originRect.size.width == 0 && originRect.size.height == 0 {
      // if the originRect is zeroed out then we should attach this popover to the originView itself
      originRect = self.convertRect(originView.frame, from: originView.superview!)
    }
    else {
      // the originRect is not zero and so translate its coordinates to this view's space
      originRect = self.convertRect(originRect, from: originView.superview!)
    }
    return originRect
  }
  
  override func layoutSubviews() {
    // get the popover content size, either from preferredContentSize or from the actual size
    var contentSize = self.popoverViewController.contentView.preferredContentSize
    if contentSize.width <= 0 || contentSize.height <= 0 {
      contentSize = self.popoverViewController.contentView.view.frame.size
    }
    var insets = self.borderInsets
    var arrowSize = self.popoverViewController.upArrowImage.size
    var originRect = self.originRect()
    // get a starting point for the outer popover frame
    var myFrame = self.frame
    var popoverWidth: CGFloat = min(insets.left + insets.right + contentSize.width, myFrame.size.width)
    var popoverHeight: CGFloat = min(insets.top + insets.bottom + contentSize.height, myFrame.size.height)
    var popoverX: CGFloat = max(0, originRect.origin.x + (originRect.size.width / 2.0) - (popoverWidth / 2.0))
    var popoverY: CGFloat = max(0, originRect.origin.y + originRect.size.height)
    // make sure the x isn't high enough to push the popover off the screen
    if popoverX + popoverWidth > myFrame.size.width {
      popoverX = max(0, myFrame.size.width - popoverWidth)
    }
    var arrowDir = .up
    // if the popover thing is off of the screen and flipping the Y coordinates will
    // bring it fully back on-screen, then do so.
    if self.popoverViewController.arrowDirections & .up && popoverY + popoverHeight <= myFrame.size.height {
      // the arrow can point up and has enough room to do so... the current rect is acceptable
      arrowDir = .up
      popoverY -= self.popoverViewController.intrusion
      insets.top = max(insets.top, arrowSize.height)
    }
    else if self.popoverViewController.arrowDirections & .down {
      // backgroundRect.origin.y - originRect.size.height - backgroundRect.size.height > 0
      // the arrow can point down.  We may not have room for it to do so, but we'll do it anyway because there wasn't room or the option to point up
      popoverY -= originRect.size.height + popoverHeight - self.popoverViewController.intrusion
      arrowDir = .down
      insets.bottom = max(insets.top, arrowSize.height)
    }
    
    switch arrowDir {
    case .down:
      self.arrowImage = self.popoverViewController.downArrowImage
      self.arrowView.frame = CGRect(x: CGFloat(originRect.origin.x + (originRect.size.width / 2.0) - (arrowSize.width / 2.0)), y: CGFloat(popoverY + popoverHeight - arrowSize.height), width: CGFloat(arrowSize.width), height: CGFloat(arrowSize.height))
    default:
      self.arrowImage = self.popoverViewController.upArrowImage
      self.arrowView.frame = CGRect(x: CGFloat(originRect.origin.x + (originRect.size.width / 2.0) - (arrowSize.width / 2.0)), y: CGFloat(popoverY + 1), width: CGFloat(arrowSize.width), height: CGFloat(arrowSize.height))
      popoverY += arrowSize.height - self.borderInsets.top
    }
    
    self.arrowView.isHidden = self.popoverViewController.isHideArrow
    self.popoverRect = CGRect(x: popoverX, y: popoverY, width: popoverWidth, height: popoverHeight)
    // the popover frame image should be placed around the content
    self.popoverViewController.contentView.view.frame = UIEdgeInsetsInsetRect(self.popoverRect, self.borderInsets)
    super.layoutSubviews()
    self.setNeedsDisplay()
  }
}
