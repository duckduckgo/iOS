//
//  UIViewController+DDGSearchController.m
//  DuckDuckGo
//
//  Created by Johnnie Walker on 05/04/2013.
//
//

import UIKit

extension UIViewController {
  
  func searchDDG() -> DDGSearchController? {
    var viewController:UIViewController? = self
    while viewController != nil {
      if let duckController = viewController as? DDGSearchController {
        return duckController
      } else {
        viewController = viewController?.parent
      }
    }
    return nil
  }
  
  func searchBackButtonIconDDG() -> UIImage? {
    return nil
  }
  
  // the view that should be dimmed if a DDGPopoverViewController is shown from this VC
  func dimmableContentView() -> UIView? {
    return self.view
  }
  
  func duckPopoverIntrusionAdjustment() -> CGFloat {
    return 0.0
  }
  
}
