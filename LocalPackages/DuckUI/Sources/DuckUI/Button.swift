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
    let fullWidth: Bool

    public init(disabled: Bool = false, compact: Bool = false, fullWidth: Bool = true) {
        self.disabled = disabled
        self.compact = compact
        self.fullWidth = fullWidth
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        let isDark = colorScheme == .dark
        let standardBackgroundColor = isDark ? Color.blue30 : Color.blueBase
        let pressedBackgroundColor = isDark ? Color.blueBase : Color.blue70
        let disabledBackgroundColor = isDark ? Color.white.opacity(0.18) : Color.black.opacity(0.06)
        let standardForegroundColor = isDark ? Color.black.opacity(0.84) : Color.white
        let pressedForegroundColor = isDark ? Color.black.opacity(0.84) : Color.white
        let disabledForegroundColor = isDark ? Color.white.opacity(0.36) : Color.black.opacity(0.36)
        let backgroundColor = disabled ? disabledBackgroundColor : standardBackgroundColor
        let foregroundColor = disabled ? disabledForegroundColor : standardForegroundColor

        configuration.label
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .font(Font(UIFont.boldAppFont(ofSize: Consts.fontSize)))
            .foregroundColor(configuration.isPressed ? pressedForegroundColor : foregroundColor)
            .padding(.vertical)
            .padding(.horizontal, fullWidth ? nil : 24)
            .frame(minWidth: 0, maxWidth: fullWidth ? .infinity : nil, maxHeight: compact ? Consts.height - 10 : Consts.height)
            .background(configuration.isPressed ? pressedBackgroundColor : backgroundColor)
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
            .font(Font(UIFont.boldAppFont(ofSize: Consts.fontSize)))
            .foregroundColor(configuration.isPressed ? foregroundColor.opacity(Consts.pressedOpacity) : foregroundColor.opacity(1))
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: compact ? Consts.height - 10 : Consts.height)
            .cornerRadius(Consts.cornerRadius)
    }
}

public struct SecondaryFillButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme

    let disabled: Bool
    let compact: Bool
    let fullWidth: Bool
    let isFreeform: Bool

    public init(disabled: Bool = false, compact: Bool = false, fullWidth: Bool = true, isFreeform: Bool = false) {
        self.disabled = disabled
        self.compact = compact
        self.fullWidth = fullWidth
        self.isFreeform = isFreeform
    }

    public func makeBody(configuration: Configuration) -> some View {
        let isDark = colorScheme == .dark
        let standardBackgroundColor = isDark ? Color.white.opacity(0.18) : Color.black.opacity(0.06)
        let pressedBackgroundColor = isDark ? Color.white.opacity(0.3) : Color.black.opacity(0.18)
        let disabledBackgroundColor = isDark ? Color.white.opacity(0.06) : Color.black.opacity(0.06)
        let defaultForegroundColor = isDark ? Color.white : Color.black.opacity(0.84)
        let disabledForegroundColor = isDark ? Color.white.opacity(0.36) : Color.black.opacity(0.36)
        let backgroundColor = disabled ? disabledBackgroundColor : standardBackgroundColor
        let foregroundColor = disabled ? disabledForegroundColor : defaultForegroundColor

        configuration.label
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .font(Font(UIFont.boldAppFont(ofSize: Consts.fontSize)))
            .foregroundColor(configuration.isPressed ? defaultForegroundColor : foregroundColor)
            .if(!isFreeform) { view in
                view
                    .padding(.vertical)
                    .padding(.horizontal, fullWidth ? nil : 24)
                    .frame(minWidth: 0, maxWidth: fullWidth ? .infinity : nil, maxHeight: compact ? Consts.height - 10 : Consts.height)
            }
            .background(configuration.isPressed ? pressedBackgroundColor : backgroundColor)
            .cornerRadius(Consts.cornerRadius)
    }
}

public struct GhostButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Font(UIFont.boldAppFont(ofSize: Consts.fontSize)))
            .foregroundColor(foregroundColor(configuration.isPressed))
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: Consts.height)
            .background(backgroundColor(configuration.isPressed))
            .cornerRadius(Consts.cornerRadius)
            .contentShape(Rectangle()) // Makes whole button area tappable, when there's no background
    }
    
    private func foregroundColor(_ isPressed: Bool) -> Color {
        switch (colorScheme, isPressed) {
        case (.dark, false):
            return .blue30
        case (.dark, true):
            return .blue20
        case (_, false):
            return .blueBase
        case (_, true):
            return .blue70
        }
    }
    
    private func backgroundColor(_ isPressed: Bool) -> Color {
        switch (colorScheme, isPressed) {
        case (.light, true):
            return .blueBase.opacity(0.2)
        case (.dark, true):
            return .blue30.opacity(0.2)
        default:
            return .clear
        }
    }
}

private enum Consts {
    static let cornerRadius: CGFloat = 8
    static let height: CGFloat = 50
    static let fontSize: CGFloat = 15
    static let pressedOpacity: CGFloat = 0.7
}
