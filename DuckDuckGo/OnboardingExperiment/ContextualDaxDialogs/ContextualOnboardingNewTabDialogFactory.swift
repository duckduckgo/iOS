//
//  ContextualOnboardingNewTabDialogFactory.swift
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

import Foundation
import SwiftUI

class ContextualOnboardingNewTabDialogFactory {
    var delegate: OnboardingNavigationDelegate?
    var onDismiss: () -> Void

    init(delegate: OnboardingNavigationDelegate?, onDismiss: @escaping () -> Void) {
        self.delegate = delegate
        self.onDismiss = onDismiss
    }

    @ViewBuilder
    func createDaxDialog(for homeDialog: DaxDialogs.HomeScreenSpec) -> some View {
        switch homeDialog {
        case .initial:
            createInitialDialog()
        case .addFavorite:
            createAddFavoriteDialog(message: homeDialog.message)
        case .subsequent:
            createSubsequentDialog()
        case .final:
            createFinalDialog()
        default:
            EmptyView()

        }
    }

    private func createInitialDialog() -> some View {
        let viewModel = OnboardingSearchSuggestionsViewModel(delegate: delegate)
        return ScrollView(.vertical) {
            FadeInView {
                OnboardingTrySearchDialog(viewModel: viewModel)
                    .padding()
            }
        }
        .background(
            OnboardingBackground()
        )
    }

    private func createSubsequentDialog() -> some View {
        let viewModel = OnboardingSiteSuggestionsViewModel(delegate: delegate)
        return ScrollView(.vertical) {
            FadeInView {
                OnboardingTryVisitingSiteDialog(logoPosition: .top, viewModel: viewModel)
                    .padding()
            }
        }
        .background(
            OnboardingBackground()
        )
    }

    private func createAddFavoriteDialog(message: String) -> some View {
        return FadeInView {
            ContextualDaxDialog(logoPosition: .top, message: NSAttributedString(string: message))
                .padding()
        }
    }

    private func createFinalDialog() -> some View {
        return ScrollView(.vertical) {
            FadeInView {
                OnboardingFinalDialog(highFiveAction: {
                    self.onDismiss()
                }).padding()
            }
        }
    }
}
