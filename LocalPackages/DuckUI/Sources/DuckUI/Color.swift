//
//  Color.swift
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

#if !os(macOS)

import SwiftUI

public extension Color {
    static let red100 = Color.init(0x330B01)
    static let red90 = Color.init(0x551605)
    static let red80 = Color.init(0x77230C)
    static let red70 = Color.init(0x9A3216)
    static let red60 = Color.init(0xBC4423)
    static let redBase = Color.init(0xDE5833)
    static let red40 = Color.init(0xE46F4F)
    static let red30 = Color.init(0xEB876C)
    static let red20 = Color.init(0xF2A18A)
    static let red10 = Color.init(0xF8BBAA)
    static let red0 = Color.init(0xFFD7CC)
    
    static let blue100 = Color.init(0x051133)
    static let blue90 = Color.init(0x0B2059)
    static let blue80 = Color.init(0x14307E)
    static let blue70 = Color.init(0x1E42A4)
    static let blue60 = Color.init(0x1E42A4)
    static let blueBase = Color.init(0x3969EF)
    static let blue40 = Color.init(0x557FF3)
    static let blue30 = Color.init(0x7295F6)
    static let blue20 = Color.init(0x8FABF9)
    static let blue10 = Color.init(0xADC2FC)
    static let blue0 = Color.init(0xCCDAFF)

    static let gray95 = Color.init(0x111111)
    static let gray90 = Color.init(0x222222)
    static let gray85 = Color.init(0x333333)
    static let gray80 = Color.init(0x444444)
    static let gray70 = Color.init(0x666666)
    static let gray60 = Color.init(0x888888)
    static let gray55 = Color.init(0x999999)
    static let gray50 = Color.init(0xAAAAAA)
    static let gray40 = Color.init(0xCCCCCC)
    static let gray30 = Color.init(0xDDDDDD)
    static let gray25 = Color.init(0xE5E5E5)
    static let gray20 = Color.init(0xEEEEEE)
    static let gray10 = Color.init(0xF5F5F5)
    static let gray0 = Color.init(0xFAFAFA)

    static let deprecatedBlue =  Color.init(0x678FFF)
}

public extension UIColor {
    static let red100 = UIColor(.red100)
    static let red90 = UIColor(.red90)
    static let red80 = UIColor(.red80)
    static let red70 = UIColor(.red70)
    static let red60 = UIColor(.red60)
    static let redBase = UIColor(.redBase)
    static let red40 = UIColor(.red40)
    static let red30 = UIColor(.red30)
    static let red20 = UIColor(.red20)
    static let red10 = UIColor(.red10)
    static let red0 = UIColor(.red0)
    
    static let blue100 = UIColor(.blue100)
    static let blue90 = UIColor(.blue90)
    static let blue80 = UIColor(.blue80)
    static let blue70 = UIColor(.blue70)
    static let blue60 = UIColor(.blue60)
    static let blueBase = UIColor(.blueBase)
    static let blue40 = UIColor(.blue40)
    static let blue30 = UIColor(.blue30)
    static let blue20 = UIColor(.blue20)
    static let blue10 = UIColor(.blue10)
    static let blue0 = UIColor(.blue0)
    
    static let black = UIColor(.black)
    static let gray95 = UIColor(.gray95)
    static let gray90 = UIColor(.gray90)
    static let gray85 = UIColor(.gray85)
    static let gray80 = UIColor(.gray80)
    static let gray70 = UIColor(.gray70)
    static let gray60 = UIColor(.gray60)
    static let gray55 = UIColor(.gray55)
    static let gray50 = UIColor(.gray50)
    static let gray40 = UIColor(.gray40)
    static let gray30 = UIColor(.gray30)
    static let gray25 = UIColor(.gray25)
    static let gray20 = UIColor(.gray20)
    static let gray10 = UIColor(.gray10)
    static let gray0 =  UIColor(.gray0)
    static let white =  UIColor(.white)
    
}

public extension Color {
    init(_ hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

public extension Color {
    static func shade(_ percent: Double) -> Color {
        Self.black.opacity(percent)
    }

    static func tint(_ percent: Double) -> Color {
        Self.white.opacity(percent)
    }
}

public extension UIColor {
    static func shade(_ percent: Double) -> UIColor {
        UIColor(.shade(percent))
    }

    static func tint(_ percent: Double) -> UIColor {
        UIColor(.tint(percent))
    }
}

#endif
