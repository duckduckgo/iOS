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
    static let blue0 = Color.init(0xADC2FC)
    
    static let deprecatedBlue =  Color.init(0x678FFF)
    
    static let gray70 =  Color.init(0x666666)
    
    static let fontDark =  Color.init(0x494949)
}

private extension Color {
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

#endif
