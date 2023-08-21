//
//  Button.swift
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

public struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme

    let disabled: Bool
    let compact: Bool

    public init(disabled: Bool = false, compact: Bool = false) {
        self.disabled = disabled
        self.compact = compact
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        let isLight = colorScheme == .light
        let standardBackgroundColor = isLight ? Color.blueBase : Color.blue30
        let disabledBackgroundColor = isLight ? Color.black.opacity(0.06) : Color.white.opacity(0.18)
        let standardForegroundColor = isLight ? Color.white : Color.black.opacity(0.84)
        let disabledForegroundColor = isLight ? Color.black.opacity(0.36) : Color.white.opacity(0.36)
        let backgroundColor = disabled ? disabledBackgroundColor : standardBackgroundColor
        let foregroundColor = disabled ? disabledForegroundColor : standardForegroundColor

        configuration.label
            .font(Font(UIFont.boldAppFont(ofSize: compact ? Consts.fontSize - 1 : Consts.fontSize)))
            .foregroundColor(configuration.isPressed ? standardForegroundColor.opacity(Consts.pressedOpacity) : foregroundColor)
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: compact ? Consts.height - 10 : Consts.height)
            .background(configuration.isPressed ? standardBackgroundColor.opacity(Consts.pressedOpacity) : backgroundColor)
            .cornerRadius(Consts.cornerRadius)
    }
}

public struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme

    let compact: Bool

    public init(compact: Bool = false) {
        self.compact = compact
    }
    
    private var backgoundColor: Color {
        colorScheme == .light ? Color.white : .gray70
    }

    private var foregroundColor: Color {
        colorScheme == .light ? .blueBase : .white
    }

    @ViewBuilder
    func compactPadding(view: some View) -> some View {
        if compact {
            view
        } else {
            view.padding()
        }
    }

    public func makeBody(configuration: Configuration) -> some View {
        compactPadding(view: configuration.label)
            .font(Font(UIFont.boldAppFont(ofSize: compact ? Consts.fontSize - 1 : Consts.fontSize)))
            .foregroundColor(configuration.isPressed ? foregroundColor.opacity(Consts.pressedOpacity) : foregroundColor.opacity(1))
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: compact ? Consts.height - 10 : Consts.height)
            .cornerRadius(Consts.cornerRadius)
    }
}

public struct GhostButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme

    public init() {}
    private var foregroundColor: Color {
        colorScheme == .light ? .blueBase : .white
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Font(UIFont.boldAppFont(ofSize: Consts.fontSize)))
            .foregroundColor(configuration.isPressed ? foregroundColor.opacity(Consts.pressedOpacity) : foregroundColor.opacity(1))
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: Consts.height)
            .background(Color.clear)
            .cornerRadius(Consts.cornerRadius)
    }
}

private enum Consts {
    static let cornerRadius: CGFloat = 12
    static let height: CGFloat = 50
    static let fontSize: CGFloat = 16
    static let pressedOpacity: CGFloat = 0.7
}
