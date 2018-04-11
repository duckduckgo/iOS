//
//  TabViewController.swift
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
import CoreGraphics
import CoreText

class TabIconMaker {
    
    func icon(forTabs count: Int) -> UIImage {
        let image = #imageLiteral(resourceName: "Tabs")
        let text = count < 100 ? "\(count)" : "~"

        UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
        text.draw(in: CGRect(origin: point(forText: text), size: image.size), withAttributes: attributes(forText: text))
        image.draw(in: CGRect(origin: .zero, size: image.size), blendMode: CGBlendMode.xor, alpha: 1)
        
        let icon = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return icon
    }
    
    private func point(forText text: String) -> CGPoint {
        if isSingleChar(text) {
            return CGPoint(x: 5.5, y: 7.5)
        }
        return CGPoint(x: 2.7, y: 7.5)
    }
    
    private func attributes(forText text: String) -> [NSAttributedStringKey : Any] {
        let size: CGFloat = 10
        let weight: CGFloat = 5
        let font = UIFont.systemFont(ofSize: size, weight: UIFont.Weight(weight))
        return [ NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor : UIColor.white ]
    }
    
    private func isSingleChar(_ text: String) -> Bool {
        return text.count == 1
    }
}
