//
//  CustomFontModifier.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

import SwiftUI

struct CustomFontModifier: ViewModifier {
    var style: Style
    var size: CGFloat
    
    enum Style: String {
        case regular = "ProximaNova-Regular"
        case light = "ProximaNova-Light"
        case semibold = "ProximaNova-Semibold"
        case bold = "ProximaNova-Bold"
    }
        
    func body(content: Content) -> some View {
        content
            .font(Font.custom(style.rawValue, size: size))
    }
}

extension View {
    func customFont(style: CustomFontModifier.Style = .regular, size: CGFloat = 16) -> some View {
        return self.modifier(CustomFontModifier(style: style, size: size))
    }
}
