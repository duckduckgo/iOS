//
// Created by Sean Reilly on 2017.01.25.
// Copyright (c) 2017 DuckDuckGo. All rights reserved.
//

import UIKit

class DDGImageActivityItemProvider: UIActivityItemProvider {
  
  init(imageURL: URL) {
    super.init(placeholderItem: DDGImageActivityItemProvider.placeholderImage())
    
    self.imageURL = imageURL
  }
  
  // MARK: UIActivityItemProvider
  override var item: Any { 
    get {
      if (self.activityType == .mail) {
        return UIImage()
      }
      do {
        let imageData = try Data(contentsOf: self.imageURL, options: [])
        return UIImage(data: imageData) ?? UIImage()
      } catch {
        return UIImage()
      }
    }
  }
  
  class func placeholderImage() -> UIImage {
    var placeholderImage: UIImage? = nil
    UIGraphicsBeginImageContextWithOptions(CGSize(width: CGFloat(1.0), height: CGFloat(1.0)), false, 0)
    placeholderImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return placeholderImage!
  }
  
  var imageURL: URL!
}
