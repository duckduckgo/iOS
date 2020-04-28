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
        static let moreButtonMargin: CGFloat = 2
    }
    
    static func iconImage(forNetworkName networkName: String, iconSize: CGSize) -> UIImage? {
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
        return iconImage(withString: networkSymbol, iconSize: iconSize)
    }
    
    static func iconImage(withString string: String, iconSize: CGSize) -> UIImage {
        
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
    
    // Stacked icon includes a border
    static func stackedIconImage(withBaseImage baseImage: UIImage,
                                 foregroundColor: UIColor,
                                 borderColor: UIColor,
                                 borderWidth: CGFloat) -> UIImage {
        
        let imageRect = CGRect(x: 0, y: 0, width: baseImage.size.width + borderWidth * 2, height: baseImage.size.height + borderWidth * 2)

        let renderer = UIGraphicsImageRenderer(size: imageRect.size)
        let icon = renderer.image { imageContext in
            let context = imageContext.cgContext
            context.setFillColor(borderColor.cgColor)
            context.fillEllipse(in: imageRect)
            
            context.setFillColor(foregroundColor.cgColor)
            let contentFrame = CGRect(origin: CGPoint(x: borderWidth, y: borderWidth),
                                      size: baseImage.size)
            baseImage.draw(in: contentFrame)
        }
        
        return icon
    }
    
    static func moreIconImage(withBaseImage baseImage: UIImage) -> UIImage {
    
        let imageRect = CGRect(x: 0, y: 0, width: baseImage.size.width * 2, height: baseImage.size.height)

        let renderer = UIGraphicsImageRenderer(size: imageRect.size)
        let icon = renderer.image { imageContext in
            let context = imageContext.cgContext
            context.setFillColor(UIColor.white.cgColor)
            
            let offsetPositions: [CGFloat] = [baseImage.size.width * 0.3,
                                              baseImage.size.width * 0.2,
                                              baseImage.size.width * 0.1].map { floor($0) }
            
            let lastOffset = offsetPositions.reduce(CGFloat(), +)
            
            var movingRect = CGRect(origin: CGPoint(x: lastOffset, y: 0), size: baseImage.size)
            var movingBorderRect = CGRect(origin: CGPoint(x: lastOffset - Constants.moreButtonMargin, y: -Constants.moreButtonMargin),
                                          size: CGSize(width: baseImage.size.width + Constants.moreButtonMargin * 2,
                                                       height: baseImage.size.height + Constants.moreButtonMargin * 2))
            for offset in offsetPositions.reversed() {
                print("-> \(movingRect)")
                
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
            baseImage.draw(in: movingRect)
        }
        
        return icon.withRenderingMode(.alwaysTemplate)
    }
}
