//
//  OnboardingAddressBarPositionPicker.swift
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

struct OnboardingAddressBarPositionPicker: View {
    @StateObject private var viewModel = OnboardingAddressBarPositionPickerViewModel()

    var body: some View {
        VStack(spacing: 16.0) {
            ForEach(viewModel.items, id: \.type) { item in
                AddressBarPositionButton(
                    icon: item.icon,
                    title: AttributedString(item.title),
                    message: item.message,
                    isSelected: item.isSelected,
                    action: {
                        viewModel.setAddressBar(position: item.type)
                    }
                )
            }
        }
    }
}

// MARK: - Views

private enum Metrics {
    enum Button {
        static let messageFont = Font.system(size: 15)
        static let overlayRadius: CGFloat = 13.0
        static let overlayStroke: CGFloat = 1
        static let itemSpacing: CGFloat = 16.0
        static let borderLightColor = Color.black.opacity(0.18)
        static let borderDarkColor = Color.white.opacity(0.18)
    }
    enum Checkbox {
        static let size: CGFloat = 24.0
        static let checkSize: CGSize = CGSize(width: 12, height: 10)
        static let strokeInset = 0.75
        static let strokeWidth = 1.5
    }
}

extension OnboardingAddressBarPositionPicker {
    
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
                    .stroke(strokeColor, lineWidth: Metrics.Button.overlayStroke)
            }
            .buttonStyle(AddressBarPostionButtonStyle(isSelected: isSelected))
        }

        private var strokeColor: Color {
            if isSelected {
                Color(designSystemColor: .accent)
            } else {
                colorScheme == .light ? Metrics.Button.borderLightColor : Metrics.Button.borderDarkColor
            }
        }

    }
    
}

extension OnboardingAddressBarPositionPicker.AddressBarPositionButton {

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
                Color(designSystemColor: .accent)
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

private struct AddressBarPostionButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme

    private let minHeight = 63.0

    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: minHeight)
            .background(backgroundColor(configuration.isPressed || isSelected))
            .cornerRadius(8)
            .contentShape(Rectangle()) // Makes whole button area tappable, when there's no background
    }

    private func backgroundColor(_ isHighlighted: Bool) -> Color {
        switch (colorScheme, isHighlighted) {
        case (.light, true):
            return .blueBase.opacity(0.2)
        case (.dark, true):
            return .blue30.opacity(0.2)
        default:
            return .clear
        }
    }
}
