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
        static let iconWidth: CGFloat = 22
        static let iconHeight: CGFloat = 22
    }
    
    static func iconImage(for networkName: String) -> UIImage? {
        if let image = UIImage(named: "PP Network Icon \(networkName.lowercased())") {
            return image
        }
        
        let imageRect = CGRect(x: 0, y: 0, width: Constants.iconWidth, height: Constants.iconHeight)
        
        UIGraphicsBeginImageContextWithOptions(imageRect.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        let networkSymbol: String
        if let firstCharacter = networkName.first {
            networkSymbol = String(firstCharacter).uppercased()
        } else {
            networkSymbol = "?"
        }
        
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: imageRect)
        
        let label = UILabel(frame: imageRect)
        label.font = UIFont.semiBoldAppFont(ofSize: 17)
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.text = networkSymbol
        label.sizeToFit()
        
        context.translateBy(x: (imageRect.width - label.bounds.width) / 2,
                             y: (imageRect.height - label.font.ascender) / 2 - (label.font.ascender - label.font.capHeight) / 2)
        
        context.setBlendMode(.destinationOut)
        label.layer.draw(in: context)
        
        let icon = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return icon?.withRenderingMode(.alwaysTemplate)
    }
}
