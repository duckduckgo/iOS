//
//  UIColorExtension.swift
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

extension UIColor {

    public static var reallyBlack: UIColor {
        return UIColor(red: 25.0 / 255.0, green: 25.0 / 255.0, blue: 25.0 / 255.0, alpha: 1.0)
    }

    public static var nearlyBlackLight: UIColor {
        return UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
    }

    public static var nearlyBlack: UIColor {
        return UIColor(red: 34.0 / 255.0, green: 34.0 / 255.0, blue: 34.0 / 255.0, alpha: 1.0)
    }

    public static var charcoalGrey: UIColor {
        return UIColor(red: 68.0 / 255.0, green: 68.0 / 255.0, blue: 68.0 / 255.0, alpha: 1.0)
    }

    public static var greyishBrown: UIColor {
        return UIColor(red: 85.0 / 255.0, green: 85.0 / 255.0, blue: 85.0 / 255.0, alpha: 1.0)
    }

    public static var greyishBrown2: UIColor {
        return UIColor(red: 102.0 / 255.0, green: 102.0 / 255.0, blue: 102.0 / 255.0, alpha: 1.0)
    }

    public static var greyish: UIColor {
        return UIColor(red: 170.0 / 255.0, green: 170.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0)
    }

    public static var greyish2: UIColor {
        return UIColor(red: 153.0 / 255.0, green: 153.0 / 255.0, blue: 153.0 / 255.0, alpha: 1.0)
    }

    public static var greyish3: UIColor {
        return UIColor(red: 136.0 / 255.0, green: 136.0 / 255.0, blue: 136.0 / 255.0, alpha: 1.0)
    }

    public static var lightGreyish: UIColor {
        return UIColor(red: 234.0 / 255.0, green: 234.0 / 255.0, blue: 234.0 / 255.0, alpha: 1.0)
    }

    public static var gray20: UIColor {
        return UIColor(red: 238.0 / 255.0, green: 238.0 / 255.0, blue: 238.0 / 255.0, alpha: 1.0)
    }

    public static var gray50: UIColor {
        return UIColor(red: 171.0 / 255.0, green: 171.0 / 255.0, blue: 171.0 / 255.0, alpha: 1.0)
    }

    public static var darkGreyish: UIColor {
        return UIColor(red: 73.0 / 255.0, green: 73.0 / 255.0, blue: 73.0 / 255.0, alpha: 1.0)
    }

    public static var lightMercury: UIColor {
        return UIColor(red: 204.0 / 255.0, green: 204.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0)
    }

    public static var mercury: UIColor {
        return UIColor(red: 229.0 / 255.0, green: 229.0 / 255.0, blue: 229.0 / 255.0, alpha: 1.0)
    }

    public static var cornflowerBlue: UIColor {
        return UIColor(red: 103.0 / 255.0, green: 143.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }

    public static var cornflowerDark: UIColor {
        return UIColor(red: 80.0 / 255.0, green: 120.0 / 255.0, blue: 233.0 / 255.0, alpha: 1.0)
    }

    public static var skyBlue: UIColor {
        return UIColor(red: 66.0 / 255.0, green: 191.0 / 255.0, blue: 254.0 / 255.0, alpha: 1.0)
    }

    public static var skyBlueLight: UIColor {
        return UIColor(red: 120.0 / 255.0, green: 210.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }

    public static var midGreen: UIColor {
        return UIColor(red: 63.0 / 255.0, green: 161.0 / 255.0, blue: 64.0 / 255.0, alpha: 1.0)
    }

    public static var orange: UIColor {
        return UIColor(red: 222.0 / 255.0, green: 88.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
    }

    public static var orangeLight: UIColor {
        return UIColor(red: 255.0 / 255.0, green: 135.0 / 255.0, blue: 75.0 / 255.0, alpha: 1.0)
    }

    public static var nearlyWhiteLight: UIColor {
        return UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
    }

    public static var nearlyWhite: UIColor {
        return UIColor(red: 245.0 / 255.0, green: 245.0 / 255.0, blue: 245.0 / 255.0, alpha: 1.0)
    }

    public static var destructive: UIColor {
        return UIColor.systemRed
    }

    public static var yellow60: UIColor {
        return UIColor(hex: "F9BE1A")
    }

}

extension UIColor {

    convenience init(hex: String) {
        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    public func combine(withColor other: UIColor, ratio: CGFloat) -> UIColor {
        let otherRatio = 1 - ratio
        let red = (redComponent * ratio) + (other.redComponent * otherRatio)
        let green = (greenComponent * ratio) + (other.greenComponent * otherRatio)
        let blue = (blueComponent * ratio) + (other.blueComponent * otherRatio)
        let alpha = (alphaComponent * ratio) + (other.alphaComponent * otherRatio)
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    public var redComponent: CGFloat {
        var redComponent: CGFloat = 0
        getRed(&redComponent, green: nil, blue: nil, alpha: nil)
        return redComponent
    }

    public var greenComponent: CGFloat {
        var greenComponent: CGFloat = 0
        getRed(nil, green: &greenComponent, blue: nil, alpha: nil)
        return greenComponent
    }

    public var blueComponent: CGFloat {
        var blueComponent: CGFloat = 0
        getRed(nil, green: nil, blue: &blueComponent, alpha: nil)
        return blueComponent
    }

    public var alphaComponent: CGFloat {
        var alphaComponent: CGFloat = 0
        getRed(nil, green: nil, blue: nil, alpha: &alphaComponent)
        return alphaComponent
    }

}

extension UIColor {

    public static func forDomain(_ domain: String) -> UIColor {
        var consistentHash: Int {
            return domain.utf8
                .map { return $0 }
                .reduce(5381) { ($0 << 5) &+ $0 &+ Int($1) }
        }

        let palette = [
            UIColor(hex: "94B3AF"),
            UIColor(hex: "727998"),
            UIColor(hex: "645468"),
            UIColor(hex: "4D5F7F"),
            UIColor(hex: "855DB6"),
            UIColor(hex: "5E5ADB"),
            UIColor(hex: "678FFF"),
            UIColor(hex: "6BB4EF"),
            UIColor(hex: "4A9BAE"),
            UIColor(hex: "66C4C6"),
            UIColor(hex: "55D388"),
            UIColor(hex: "99DB7A"),
            UIColor(hex: "ECCC7B"),
            UIColor(hex: "E7A538"),
            UIColor(hex: "DD6B4C"),
            UIColor(hex: "D65D62")
        ]

        let hash = consistentHash
        let index = hash % palette.count
        return palette[abs(index)]
    }

}
