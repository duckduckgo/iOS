//
//  AddressBarPositionViews.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import DesignResourcesKit

private enum Metrics {
    enum Button {
        static let titleFont = Font.system(size: 16, weight: .semibold)
        static let messageFont = Font.system(size: 15)
        static let overlayRadius: CGFloat = 13.0
        static let overlayStroke: CGFloat = 1
        static let itemSpacing: CGFloat = 16.0
    }
    enum Checkbox {
        static let size: CGFloat = 24.0
        static let checkSize: CGSize = CGSize(width: 12, height: 10)
        static let strokeInset = 0.75
        static let strokeWidth = 1.5
    }
}

struct AddressBarPositionButton: View {
    @Environment(\.colorScheme) private var colorScheme

    let icon: ImageResource
    let title: AttributedString
    let message: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Metrics.Button.itemSpacing) {
                Image(icon)

                VStack(alignment: .leading) {
                    Text(title)
                        .font(Metrics.Button.titleFont)
                        .foregroundStyle(Color.primary)
                    Text(message)
                        .font(Metrics.Button.messageFont)
                        .foregroundStyle(Color.secondary)
                }

                Spacer()

                Checkbox(isSelected: isSelected)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: Metrics.Button.overlayRadius)
                .stroke(.blue, lineWidth: Metrics.Button.overlayStroke)
        }
        .buttonStyle(AddressBarPostionButtonStyle())
    }

}

private extension AddressBarPositionButton {

    struct Checkbox: View {
        @Environment(\.colorScheme) private var colorScheme

        let isSelected: Bool

        var body: some View {
            Circle()
                .frame(width: Metrics.Checkbox.size, height: Metrics.Checkbox.size)
                .foregroundColor(foregroundColor)
                .overlay {
                    selectionOverlay
                }
        }

        @ViewBuilder
        private var selectionOverlay: some View {
            if isSelected {
                Image(.checkShape)
                    .resizable()
                    .frame(width: Metrics.Checkbox.checkSize.width, height: Metrics.Checkbox.checkSize.height)
                    .foregroundColor(.white)
            } else {
                Circle()
                    .inset(by: Metrics.Checkbox.strokeInset)
                    .stroke(.secondary, lineWidth: Metrics.Checkbox.strokeWidth)
            }
        }

        private var foregroundColor: Color {
            switch (colorScheme, isSelected) {
            case (.light, true), (.dark, true):
                    Color.init(designSystemColor: .accent)
            case (.light, false):
                    .black.opacity(0.03)
            case (.dark, false):
                    .white.opacity(0.06)
            default:
                    .clear
            }
        }
    }

}

// MARK: - Style

struct AddressBarPostionButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme

    private let minHeight = 63.0

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: minHeight)
            .background(backgroundColor(configuration.isPressed))
            .cornerRadius(8)
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

#Preview("Top - Unselected - Light Mode") {
    AddressBarPositionButton(
        icon: .addressBarTop,
        title: .init(UserText.HighlightsOnboardingExperiment.AddressBarPosition.topTitle),
        message: UserText.HighlightsOnboardingExperiment.AddressBarPosition.topMessage,
        isSelected: false,
        action: {}
    )
    .preferredColorScheme(.light)
}

#Preview("Top - Unselected - Dark Mode") {
    AddressBarPositionButton(
        icon: .addressBarTop,
        title: .init(UserText.HighlightsOnboardingExperiment.AddressBarPosition.topTitle),
        message: UserText.HighlightsOnboardingExperiment.AddressBarPosition.topMessage,
        isSelected: false,
        action: {}
    )
    .preferredColorScheme(.dark)
}

#Preview("Top - Selected - Light Mode") {
    AddressBarPositionButton(
        icon: .addressBarTop,
        title: .init(UserText.HighlightsOnboardingExperiment.AddressBarPosition.topTitle),
        message: UserText.HighlightsOnboardingExperiment.AddressBarPosition.topMessage,
        isSelected: true,
        action: {}
    )
    .preferredColorScheme(.light)
}


#Preview("Top - Selected - Dark Mode") {
    AddressBarPositionButton(
        icon: .addressBarTop,
        title: .init(UserText.HighlightsOnboardingExperiment.AddressBarPosition.topTitle),
        message: UserText.HighlightsOnboardingExperiment.AddressBarPosition.topMessage,
        isSelected: true,
        action: {}
    )
    .preferredColorScheme(.dark)
}

#Preview("Bottom - Unselected - Light Mode") {
    AddressBarPositionButton(
        icon: .addressBarTop,
        title: .init(UserText.HighlightsOnboardingExperiment.AddressBarPosition.topTitle),
        message: UserText.HighlightsOnboardingExperiment.AddressBarPosition.topMessage,
        isSelected: false,
        action: {}
    )
    .preferredColorScheme(.light)
}

#Preview("Bottom - Unselected - Dark Mode") {
    AddressBarPositionButton(
        icon: .addressBarTop,
        title: .init(UserText.HighlightsOnboardingExperiment.AddressBarPosition.topTitle),
        message: UserText.HighlightsOnboardingExperiment.AddressBarPosition.topMessage,
        isSelected: false,
        action: {}
    )
    .preferredColorScheme(.dark)
}

#Preview("Bottom - Selected - Light Mode") {
    AddressBarPositionButton(
        icon: .addressBarBottom,
        title: .init(UserText.HighlightsOnboardingExperiment.AddressBarPosition.bottomTitle),
        message: UserText.HighlightsOnboardingExperiment.AddressBarPosition.bottomMessage,
        isSelected: true,
        action: {}
    )
    .preferredColorScheme(.light)
}

#Preview("Bottom - Selected - Dark Mode") {
    AddressBarPositionButton(
        icon: .addressBarBottom,
        title: .init(UserText.HighlightsOnboardingExperiment.AddressBarPosition.bottomTitle),
        message: UserText.HighlightsOnboardingExperiment.AddressBarPosition.bottomMessage,
        isSelected: true,
        action: {}
    )
    .preferredColorScheme(.dark)
}
