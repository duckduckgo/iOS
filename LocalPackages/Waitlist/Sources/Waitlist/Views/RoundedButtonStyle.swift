//
//  RoundedButtonStyle.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

public struct RoundedButtonStyle: ButtonStyle {

    public enum Style {
        case solid
        case bordered
    }

    public let enabled: Bool
    private let style: Style

    public init(enabled: Bool, style: Style = .solid) {
        self.enabled = enabled
        self.style = style
    }

    public func makeBody(configuration: Self.Configuration) -> some View {
        let backgroundColor: Color
        let foregroundColor: Color
        let borderColor: Color
        let borderWidth: CGFloat

        switch style {
        case .solid:
            backgroundColor = enabled ? Color.waitlistBlue : Color.waitlistBlue.opacity(0.2)
            foregroundColor = Color.waitlistButtonText
            borderColor = Color.clear
            borderWidth = 0
        case .bordered:
            backgroundColor = Color.clear
            foregroundColor = Color.waitlistBlue
            borderColor = Color.waitlistBlue
            borderWidth = 2
        }

        return configuration.label
            .daxHeadline()
            .frame(maxWidth: .infinity)
            .padding([.top, .bottom], 16)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(borderColor, lineWidth: borderWidth))
    }

}
