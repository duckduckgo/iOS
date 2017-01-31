//
// Created by Sean Reilly on 2017.01.25.
// Copyright (c) 2017 DuckDuckGo. All rights reserved.
//

import Foundation
import UIKit

class DDGConstraintHelper: NSObject {
  class func pinView(_ viewToPin: UIView, to viewToPinTo: UIView, inViewContainer viewContainer: UIView) {
    viewContainer.addConstraint(NSLayoutConstraint(item: viewToPin, attribute: .top, relatedBy: .equal, toItem: viewToPinTo, attribute: .top, multiplier: 1, constant: 0))
    viewContainer.addConstraint(NSLayoutConstraint(item: viewToPin, attribute: .bottom, relatedBy: .equal, toItem: viewToPinTo, attribute: .bottom, multiplier: 1, constant: 0))
    viewContainer.addConstraint(NSLayoutConstraint(item: viewToPin, attribute: .leading, relatedBy: .equal, toItem: viewToPinTo, attribute: .leading, multiplier: 1, constant: 0))
    viewContainer.addConstraint(NSLayoutConstraint(item: viewToPin, attribute: .trailing, relatedBy: .equal, toItem: viewToPinTo, attribute: .trailing, multiplier: 1, constant: 0))
  }
  
  class func setHeight(_ height: CGFloat, of viewToAddHeight: UIView, inViewContainer viewContainer: UIView) {
    viewContainer.addConstraint(NSLayoutConstraint(item: viewToAddHeight, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height))
  }
  
  class func pinView(_ viewToPin: UIView, toEdgeOf viewToPinEdgesTo: UIView, inViewContainer viewContainer: UIView) {
    viewContainer.addConstraint(NSLayoutConstraint(item: viewToPin, attribute: .leading, relatedBy: .equal, toItem: viewToPinEdgesTo, attribute: .leading, multiplier: 1, constant: 0))
    viewContainer.addConstraint(NSLayoutConstraint(item: viewToPin, attribute: .trailing, relatedBy: .equal, toItem: viewToPinEdgesTo, attribute: .trailing, multiplier: 1, constant: 0))
  }
  
  class func pinView(_ viewToPin: UIView, underView viewToPinUnder: UIView, inViewContainer viewContainer: UIView) {
    viewContainer.addConstraint(NSLayoutConstraint(item: viewToPin, attribute: .top, relatedBy: .equal, toItem: viewToPinUnder, attribute: .bottom, multiplier: 1, constant: 0))
  }
  
  class func pinView(_ viewToPin: UIView, into viewToPinInto: UIView) {
    viewToPinInto.addConstraint(NSLayoutConstraint(item: viewToPin, attribute: .top, relatedBy: .equal, toItem: viewToPinInto, attribute: .top, multiplier: 1, constant: 0))
    viewToPinInto.addConstraint(NSLayoutConstraint(item: viewToPin, attribute: .bottom, relatedBy: .equal, toItem: viewToPinInto, attribute: .bottom, multiplier: 1, constant: 0))
    viewToPinInto.addConstraint(NSLayoutConstraint(item: viewToPin, attribute: .leading, relatedBy: .equal, toItem: viewToPinInto, attribute: .leading, multiplier: 1, constant: 0))
    viewToPinInto.addConstraint(NSLayoutConstraint(item: viewToPin, attribute: .trailing, relatedBy: .equal, toItem: viewToPinInto, attribute: .trailing, multiplier: 1, constant: 0))
  }
  
  class func pinView(_ viewToPin: UIView, toBottomOf viewToPinBottomTo: UIView, inViewController viewContainer: UIView) {
    viewContainer.addConstraint(NSLayoutConstraint(item: viewToPin, attribute: .bottom, relatedBy: .equal, toItem: viewToPinBottomTo, attribute: .bottom, multiplier: 1, constant: 0))
  }
  
  // Method to quickly add constraints to pin a view to another view that are both subviews of another view, so that a view can change and the viewToPin will change acordingly
  // Pin View Inside of another view so all the edges are inside
}
