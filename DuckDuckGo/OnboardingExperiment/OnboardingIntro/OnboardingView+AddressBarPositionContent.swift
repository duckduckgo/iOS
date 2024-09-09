//
//  OnboardingView+AddressBarPositionContent.swift
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
import DuckUI
import Onboarding

private enum Metrics {
    static let titleFont = Font.system(size: 20, weight: .semibold)
    static let messageFont = Font.system(size: 16)
}

extension OnboardingView {

    struct AddressBarPositionContentState {
        var animateTitle = true
        var showContent = false
    }

    struct AddressBarPositionContent: View {
        
        @StateObject private var viewModel = AddressBarPositionContentViewModel()

        private var animateTitle: Binding<Bool>
        private var showContent: Binding<Bool>
        private let action: () -> Void

        init(
            animateTitle: Binding<Bool> = .constant(true),
            showContent: Binding<Bool> = .constant(true),
            action: @escaping () -> Void
        ) {
            self.animateTitle = animateTitle
            self.showContent = showContent
            self.action = action
        }

        var body: some View {
            VStack(spacing: 16.0) {
                AnimatableTypingText(UserText.HighlightsOnboardingExperiment.AddressBarPosition.title, startAnimating: animateTitle) {
                    showContent.wrappedValue = true
                }
                .foregroundColor(.primary)
                .font(Metrics.titleFont)

                VStack(spacing: 24) {
                    addressBarPositionButtons

                    Button(action: action) {
                        Text(verbatim: UserText.HighlightsOnboardingExperiment.AddressBarPosition.cta)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .visibility(showContent.wrappedValue ? .visible : .invisible)
            }
        }

        private var addressBarPositionButtons: some View {
            VStack(spacing: 16.0) {
                ForEach(viewModel.items, id: \.type) { item in
                    AddressBarPositionButton(
                        icon: item.icon,
                        title: item.title,
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

}

// MARK: - ViewModel

final class AddressBarPositionContentViewModel: ObservableObject {

    struct AddressBarPositionDisplayModel {
        let type: AddressBarPosition
        let icon: ImageResource
        let title: AttributedString
        let message: String
        let isSelected: Bool
    }

    @Published private(set) var items: [AddressBarPositionDisplayModel] = []

    private let addressBarPositionManager: AddressBarPositionManaging

    init(addressBarPositionManager: AddressBarPositionManaging = AppUserDefaults()) {
        self.addressBarPositionManager = addressBarPositionManager
        makeDisplayModels()
    }

    func setAddressBar(position: AddressBarPosition) {
        addressBarPositionManager.currentAddressBarPosition = position
        makeDisplayModels()
    }

    private func makeDisplayModels() {
        items = AddressBarPosition.allCases.map { addressBarPosition in
            let info = addressBarPosition.titleAndMessage

            return AddressBarPositionDisplayModel(
                type: addressBarPosition,
                icon: addressBarPosition.image,
                title: info.title,
                message: info.message,
                isSelected: addressBarPositionManager.currentAddressBarPosition == addressBarPosition
            )
        }
    }
}

// MARK: - AddressBarPositionManaging

protocol AddressBarPositionManaging: AnyObject {
    var currentAddressBarPosition: AddressBarPosition { get set }
}

extension AppUserDefaults: AddressBarPositionManaging {}

private extension AddressBarPosition {

    var titleAndMessage: (title: AttributedString, message: String) {
        switch self {
        case .top:
            (
                AttributedString(UserText.HighlightsOnboardingExperiment.AddressBarPosition.topTitle),
                UserText.HighlightsOnboardingExperiment.AddressBarPosition.topMessage
            )
        case .bottom:
            (
                AttributedString(UserText.HighlightsOnboardingExperiment.AddressBarPosition.bottomTitle),
                UserText.HighlightsOnboardingExperiment.AddressBarPosition.bottomMessage
            )
        }
    }

    var image: ImageResource {
        switch self {
        case .top: .addressBarTop
        case .bottom: .addressBarBottom
        }
    }

}

// MARK: - Preview

#Preview {
    OnboardingView.AddressBarPositionContent(action: {})
}
