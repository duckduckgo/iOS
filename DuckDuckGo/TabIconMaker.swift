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

    private struct Constants {
        static let fontSize: CGFloat = 10
        static let fontWeight: CGFloat = 5
        static let xTextOffset: CGFloat = 0
        static let yTextOffset: CGFloat = 6
        static let maxTextTabs = 100
    }

    func apply(count: Int, toImage image: UIImage) -> UIImage {
        let text = count < Constants.maxTextTabs ? "\(count)" : "🦆"

        UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
        text.draw(in: CGRect(origin: point(forText: text), size: image.size), withAttributes: attributes())
        image.draw(in: CGRect(origin: .zero, size: image.size), blendMode: CGBlendMode.xor, alpha: 1)

        let icon = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return icon
    }

    private func point(forText text: String) -> CGPoint {
        return CGPoint(x: Constants.xTextOffset, y: Constants.yTextOffset)
    }

    func attributes() -> [NSAttributedStringKey: Any] {

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center

        let font = UIFont.systemFont(ofSize: Constants.fontSize, weight: UIFont.Weight(Constants.fontWeight))
        return [ NSAttributedStringKey.font: font,
                 NSAttributedStringKey.foregroundColor: UIColor.nearlyBlackLight,
                 NSAttributedStringKey.paragraphStyle: paragraphStyle ]
    }

}
