//
//  Text.swift
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

import SwiftUI

public struct Label3AltStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    public init() {}
    
    public func body(content: Content) -> some View {
        content
            .font(Font(uiFont: UIFont.semiBoldAppFont(ofSize: 16)))
            .foregroundColor(colorScheme == .light ? .black : .white)
    }
}

public struct Label3Style: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    private let design: Font.Design
    
    public init(design: Font.Design = .default) {
        self.design = design
    }
    
    public func body(content: Content) -> some View {
        content
            .font(.system(size: 17, design: design))
            .foregroundColor(colorScheme == .light ? .gray50 : .gray20)
    }
}

public struct Label4Style: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    private let design: Font.Design
    private let foregroundColorLight: Color
    private let foregroundColorDark: Color

    public init(design: Font.Design = .default, foregroundColorLight: Color = .gray90, foregroundColorDark: Color = .white) {
        self.design = design
        self.foregroundColorLight = foregroundColorLight
        self.foregroundColorDark = foregroundColorDark
    }

    public func body(content: Content) -> some View {
        content
            .font(.system(.callout, design: design))
            .foregroundColor(colorScheme == .light ? foregroundColorLight : foregroundColorDark)
    }
}

public struct Label4SubtitleStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    private let design: Font.Design

    public init(design: Font.Design = .default) {
        self.design = design
    }

    public func body(content: Content) -> some View {
        content
            .font(.system(.callout, design: design))
            .foregroundColor(colorScheme == .light ? .gray50 : .gray30)
    }
}

public struct SecondaryTextStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    public init() {}
    public func body(content: Content) -> some View {
        content
            .foregroundColor(colorScheme == .light ? .gray70 : .gray20)
    }
}

public extension View {
    func secondaryTextStyle() -> some View {
        modifier(SecondaryTextStyle())
    }
    
    func label3AltStyle() -> some View {
        modifier(Label3AltStyle())
    }
    
    func label3Style(design: Font.Design = .default) -> some View {
        modifier(Label3Style(design: design))
    }

    func label4Style(design: Font.Design = .default, foregroundColorLight: Color = .gray90, foregroundColorDark: Color = .white) -> some View {
        modifier(Label4Style(design: design, foregroundColorLight: foregroundColorLight, foregroundColorDark: foregroundColorDark))
    }
}

extension Font {
    init(uiFont: UIFont) {
        self = Font(uiFont as CTFont)
    }
}
