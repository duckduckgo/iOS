//
//  UIImageExtension.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

extension UIImage {
    
    struct Constants {
        static let buttonBorderWidth: CGFloat = 2
    }
    
    /// Based on iconImage create image that has a border around it.
    /// Result can be used to create stack of images that overlap each other.
    static func stackedIconImage(withIconImage iconImage: UIImage,
                                 borderWidth: CGFloat = Constants.buttonBorderWidth,
                                 foregroundColor: UIColor,
                                 borderColor: UIColor) -> UIImage {
        
        let imageRect = CGRect(x: 0,
                               y: 0,
                               width: iconImage.size.width + borderWidth * 2,
                               height: iconImage.size.height + borderWidth * 2)

        let renderer = UIGraphicsImageRenderer(size: imageRect.size)
        let icon = renderer.image { imageContext in
            let context = imageContext.cgContext
            context.setFillColor(borderColor.cgColor)
            context.fillEllipse(in: imageRect)
            
            context.setFillColor(foregroundColor.cgColor)
            let contentFrame = CGRect(origin: CGPoint(x: borderWidth,
                                                      y: borderWidth),
                                      size: iconImage.size)
            iconImage.draw(in: contentFrame)
        }
        
        return icon
    }
    
}
