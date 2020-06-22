//
//  PrivacyProtectionIconSource.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

class PrivacyProtectionIconSource {
    
    struct Constants {
        static let buttonBorderWidth: CGFloat = 2
    }
    
    /// Load or generate tracker network logo for given tracker network name.
    static func iconImageTemplate(forNetworkName networkName: String, iconSize: CGSize) -> UIImage {
        if let image = UIImage(named: "PP Network Icon \(networkName.lowercased())") {
            if image.size != iconSize {
                let renderer = UIGraphicsImageRenderer(size: iconSize)
                let icon = renderer.image { imageContext in
                    let context = imageContext.cgContext
                    context.setFillColor(UIColor.white.cgColor)
                    
                    let frame = CGRect(origin: .zero, size: iconSize)
                    image.draw(in: frame)
                }
                
                return icon.withRenderingMode(.alwaysTemplate)
            }
            return image
        }
        
        let networkSymbol: String
        let networkName = networkName.uppercased().dropPrefix(prefix: "THE ")
        if let firstCharacter = networkName.first {
            networkSymbol = String(firstCharacter)
        } else {
            networkSymbol = "?"
        }
        
        return iconImageTemplate(withString: networkSymbol, iconSize: iconSize)
    }
    
    /// Create icon template image: circle with text of zero opaciy inside.
    ///
    /// Notes:
    ///    - Text is not scaled, typically you'd use it to present one or two characters.
    static func iconImageTemplate(withString string: String, iconSize: CGSize) -> UIImage {
        
        let imageRect = CGRect(x: 0, y: 0, width: iconSize.width, height: iconSize.height)

        let renderer = UIGraphicsImageRenderer(size: imageRect.size)
        let icon = renderer.image { imageContext in
            let context = imageContext.cgContext
            
            context.setFillColor(UIColor.white.cgColor)
            context.fillEllipse(in: imageRect)
            
            let label = UILabel(frame: imageRect)
            label.font = UIFont.boldAppFont(ofSize: 17)
            label.textColor = UIColor.black
            label.textAlignment = .center
            label.text = string
            label.sizeToFit()
            
            context.translateBy(x: (imageRect.width - label.bounds.width) / 2,
                                y: (imageRect.height - label.font.ascender) / 2 - (label.font.ascender - label.font.capHeight) / 2)
            
            context.setBlendMode(.destinationOut)
            label.layer.draw(in: context)
        }
        
        return icon.withRenderingMode(.alwaysTemplate)
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
    
    /// Based on iconImage create image template that represents "more image".
    static func moreIconImageTemplate(withIconImage iconImage: UIImage) -> UIImage {
    
        let imageRect = CGRect(x: 0, y: 0, width: iconImage.size.width * 2, height: iconImage.size.height)

        let renderer = UIGraphicsImageRenderer(size: imageRect.size)
        let icon = renderer.image { imageContext in
            let context = imageContext.cgContext
            context.setFillColor(UIColor.white.cgColor)
            
            // Position of "stack" elements, add/remove elements to tweak how many are visible.
            let offsetPositions: [CGFloat] = [iconImage.size.width * 0.3].map { floor($0) }
            
            let lastOffset = offsetPositions.reduce(CGFloat(), +)
            
            var movingRect = CGRect(origin: CGPoint(x: lastOffset, y: 0), size: iconImage.size)
            var movingBorderRect = CGRect(origin: CGPoint(x: lastOffset - Constants.buttonBorderWidth,
                                                          y: -Constants.buttonBorderWidth),
                                          size: CGSize(width: iconImage.size.width + Constants.buttonBorderWidth * 2,
                                                       height: iconImage.size.height + Constants.buttonBorderWidth * 2))
            for offset in offsetPositions.reversed() {
                context.setBlendMode(.destinationOut)
                context.fillEllipse(in: movingBorderRect)
                
                context.setBlendMode(.normal)
                context.fillEllipse(in: movingRect)
            
                movingRect.origin.x -= offset
                movingBorderRect.origin.x -= offset
            }
            
            context.setBlendMode(.destinationOut)
            context.fillEllipse(in: movingBorderRect)
            
            movingRect.origin.x = 0
            iconImage.draw(in: movingRect)
        }
        
        return icon.withRenderingMode(.alwaysTemplate)
    }
}
