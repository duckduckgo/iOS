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
  weak var anchorView: UIView?
  weak var dimmedBackgroundView: UIView?
  weak var touchPassthroughView: UIView?
  
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
  
  override var isBeingPresented:Bool {
    get {
      return self.view.alpha != 0.0
    }
  }
  
  
  init(contentViewController viewController: UIViewController, andTouchPassthroughView touchPassthroughView: UIView) {
    self.contentViewController = viewController
    self.touchPassthroughView = touchPassthroughView
    self.intrusion = 6
    self.isShouldDismissUponOutsideTap = true
    
    super.init(nibName: nil, bundle: nil)
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
  
  
  override func loadView() {
    super.loadView()
    let backgroundView = DDGPopoverBackgroundView(frame: (self.touchPassthroughView ?? self.view).frame, popoverController: self)
    backgroundView.popoverViewController = self
    self.backgroundView = backgroundView
    self.view = backgroundView
    
    self.view.backgroundColor = UIColor.clear
    self.view.isOpaque = false
    self.addChildViewController(self.contentViewController)
    let contentView = self.contentViewController.view!
    // calls [childViewController willMoveToParentViewController:self]
    self.view.addSubview(contentView)
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    contentView.isOpaque = false
    contentView.layer.cornerRadius = 4.0
    //contentView.alpha = 1;
    self.contentViewController.didMove(toParentViewController: self)
    self.view.layer.shouldRasterize = true
    self.view.layer.rasterizationScale = UIScreen.main.scale
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let backgroundView = self.backgroundView {
      backgroundView.touchPassthroughView = self.touchPassthroughView
      backgroundView.backgroundImage! = UIImage(named: "popover-frame")!
      backgroundView.alpha = 0.0
    }
    let arrowImageName = self.isLargeMode ? "popover-indicator-large" : "popover-indicator"
    self.upArrowImage = UIImage(named: arrowImageName)
    if let upArrowImage = self.upArrowImage, let upCGImage = upArrowImage.cgImage {
      self.downArrowImage = UIImage(cgImage: upCGImage, scale: upArrowImage.scale, orientation: .downMirrored)
    }
    //[self.view addSubview:self.backgroundView];
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    if self.isShouldDismissUponOutsideTap {
      self.delegate?.popoverControllerDidDismissPopover(self)
      super.dismiss(animated: coordinator.isAnimated)
    } else {
      self.presentPopover(animated: coordinator.isAnimated)
    }
  }
  
  func presentPopover(animated: Bool) {
    var rootViewController = self.anchorView?.window!.rootViewController!
    if rootViewController == nil || self.popoverParentController != nil {
      rootViewController = self.popoverParentController
    }
    if let rootController = rootViewController {
      self.view.frame = rootController.view.frame
      // the containing frame should cover the entire root view
      rootController.view.window!.addSubview(self.view)
      rootController.addChildViewController(self)
      self.didMove(toParentViewController: rootViewController)
      self.view.addSubview(self.contentViewController.view)
      if let bgView = self.backgroundView {
        self.view.insertSubview(self.contentViewController.view, belowSubview: bgView)
      } else {
        self.view.addSubview(self.contentViewController.view)
      }
      self.addChildViewController(self.contentViewController)
      //    [self.contentViewController willMoveToParentViewController:self];
      //    [self.contentViewController removeFromParentViewController]; // calls [childViewController didMoveToParentViewController:nil]
      self.view.setNeedsLayout()
      self.view.layoutIfNeeded()
      let duration = animated ? 0.4 : 0.0
      UIView.animate(withDuration: duration, animations: { () -> Void in
        self.view.alpha = 1.0
      }, completion: { (_ finished: Bool) -> Void in
        self.view.layer.shouldRasterize = false
      })
    }
  }
  
  override func dismiss(animated: Bool, completion: ( (_: Void) -> Void)?) {
    var duration = animated ? 0.2 : 0.0
    self.view.layer.shouldRasterize = true
    self.view.layer.rasterizationScale = UIScreen.main.scale
    UIView.animate(withDuration: duration, animations: {() -> Void in
      self.view.alpha = 0.0
    }, completion: {(_ finished: Bool) -> Void in
      self.willMove(toParentViewController:nil)
      self.view.removeFromSuperview()
      self.removeFromParentViewController()
      self.contentViewController.willMove(toParentViewController:nil)
      self.contentViewController.view.removeFromSuperview()
      self.contentViewController.removeFromParentViewController()
      // calls [childViewController didMoveToParentViewController:nil]
      if finished {
        self.delegate?.popoverControllerDidDismissPopover(self)
      }
      completion?()
    })
  }
  
}



class DDGPopoverBackgroundView: UIView {
  var arrowView = UIImageView()
  var popoverRect = CGRect.zero
  var debugRect = CGRect.zero
  var borderInsets = UIEdgeInsets()
  var popoverViewController: DDGPopoverViewController
  weak var touchPassthroughView: UIView?
  
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
      return self.arrowImage
    }
    set(arrowImage) {
      self.arrowImage = arrowImage
      self.arrowView.image = arrowImage
    }
  }
  
  init(frame: CGRect, popoverController:DDGPopoverViewController) {
    self.borderInsets = UIEdgeInsetsMake(8, 8, 8, 8)
    self.arrowView = UIImageView()
    self.popoverViewController = popoverController
    
    super.init(frame:frame)
    
    self.addSubview(self.arrowView)
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
//    self.borderInsets = UIEdgeInsetsMake(8, 8, 8, 8)
//    self.arrowView = UIImageView()
//    self.addSubview(self.arrowView)
  }
  
  
  override func draw(_ rect: CGRect) {
    if let dimView = self.popoverViewController.dimmedBackgroundView {
      if let context = UIGraphicsGetCurrentContext() {
        context.setFillColor(UIColor.duckDimmedPopoverBackground.cgColor)
        context.fill(self.convert(dimView.frame, from: dimView.superview))
      }
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
  
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    // If the hitView is THIS view, return the view that you want to receive the touch instead:
    let hitView = super.hitTest(point, with: event)
    if hitView == self {
      if self.popoverViewController.isShouldDismissUponOutsideTap {
        // dismiss, but stil allow the hit to be passed through
        self.perform(#selector(self.goAwayNow), with: nil, afterDelay: 0.001)
      }
      if self.popoverViewController.contentViewController.view.frame.contains(point) {
        return hitView
      }
      // if we get here, we've gotten a tap outside of our own content area. Check to see
      // if it's within the dimmed view and if we're supposed to absorb those taps and dismiss
      if let dimView = self.popoverViewController.dimmedBackgroundView, self.popoverViewController.isShouldAbsorbAndDismissUponDimmedViewTap {
        if dimView.frame.contains(dimView.convert(point, from: self)) {
          // the tap was within the dimmed view.  dismiss and absorb the touch ourselves
          self.perform(#selector(self.goAwayNow), with: nil, afterDelay: 0.001)
        }
      }
      // this will pass any touches through to the passthroughview
      if let passthroughView = self.touchPassthroughView {
        return passthroughView.hitTest(passthroughView.convert(point, from: self), with: event)
      }
    }
    // Else return the hitView (as it could be one of this view's buttons):
    return hitView
  }
  
  func goAwayNow() {
    self.popoverViewController.dismiss(animated: true, completion: nil)
  }
  
  func originRect() -> CGRect {
    var originRect = self.popoverViewController.anchorRect
    let originView = self.popoverViewController.anchorView
    if originRect.origin.x == 0 && originRect.origin.y == 0 && originRect.size.width == 0 && originRect.size.height == 0 {
      // if the originRect is zeroed out then we should attach this popover to the originView itself
      originRect = self.convert(originView!.frame, from: originView!.superview!)
    } else {
      // the originRect is not zero and so translate its coordinates to this view's space
      originRect = self.convert(originRect, from: originView!.superview!)
    }
    return originRect
  }
  
  override func layoutSubviews() {
    // get the popover content size, either from preferredContentSize or from the actual size
    var contentSize = self.popoverViewController.contentViewController.preferredContentSize
    if contentSize.width <= 0 || contentSize.height <= 0 {
      contentSize = self.popoverViewController.contentViewController.view.frame.size
    }
    var insets = self.borderInsets
    let arrowSize = self.popoverViewController.upArrowImage!.size
    let originRect = self.originRect()
    // get a starting point for the outer popover frame
    let myFrame = self.frame
    let popoverWidth: CGFloat = min(insets.left + insets.right + contentSize.width, myFrame.size.width)
    let popoverHeight: CGFloat = min(insets.top + insets.bottom + contentSize.height, myFrame.size.height)
    var popoverX: CGFloat = max(0, originRect.origin.x + (originRect.size.width / 2.0) - (popoverWidth / 2.0))
    var popoverY: CGFloat = max(0, originRect.origin.y + originRect.size.height)
    // make sure the x isn't high enough to push the popover off the screen
    if popoverX + popoverWidth > myFrame.size.width {
      popoverX = max(0, myFrame.size.width - popoverWidth)
    }
    var arrowDir:UIPopoverArrowDirection = .up
    // if the popover thing is off of the screen and flipping the Y coordinates will
    // bring it fully back on-screen, then do so.
    if self.popoverViewController.arrowDirections.contains(.up) && popoverY + popoverHeight <= myFrame.size.height {
      // the arrow can point up and has enough room to do so... the current rect is acceptable
      arrowDir = .up
      popoverY -= self.popoverViewController.intrusion
      insets.top = max(insets.top, arrowSize.height)
    } else if self.popoverViewController.arrowDirections.contains(.down) {
      // backgroundRect.origin.y - originRect.size.height - backgroundRect.size.height > 0
      // the arrow can point down.  We may not have room for it to do so, but we'll do it anyway because there wasn't room or the option to point up
      popoverY -= originRect.size.height + popoverHeight - self.popoverViewController.intrusion
      arrowDir = .down
      insets.bottom = max(insets.top, arrowSize.height)
    }
    
    if arrowDir.contains(.down) {
      self.arrowImage = self.popoverViewController.downArrowImage
      self.arrowView.frame = CGRect(x: CGFloat(originRect.origin.x + (originRect.size.width / 2.0) - (arrowSize.width / 2.0)),
              y: CGFloat(popoverY + popoverHeight - arrowSize.height),
              width: CGFloat(arrowSize.width),
              height: CGFloat(arrowSize.height))
    } else {
      self.arrowImage = self.popoverViewController.upArrowImage
      self.arrowView.frame = CGRect(x: CGFloat(originRect.origin.x + (originRect.size.width / 2.0) - (arrowSize.width / 2.0)), 
              y: CGFloat(popoverY + 1), 
              width: CGFloat(arrowSize.width), 
              height: CGFloat(arrowSize.height))
      popoverY += arrowSize.height - self.borderInsets.top
    }
    
    self.arrowView.isHidden = self.popoverViewController.isHideArrow
    self.popoverRect = CGRect(x: popoverX, y: popoverY, width: popoverWidth, height: popoverHeight)
    // the popover frame image should be placed around the content
    self.popoverViewController.contentViewController.view.frame = UIEdgeInsetsInsetRect(self.popoverRect, self.borderInsets)
    super.layoutSubviews()
    self.setNeedsDisplay()
  }
}
