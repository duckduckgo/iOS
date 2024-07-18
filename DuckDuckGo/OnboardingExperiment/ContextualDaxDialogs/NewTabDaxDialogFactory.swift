//
//  NewTabDaxDialogFactory.swift
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

protocol NewTabDaxDialogProvider {
    associatedtype DaxDialog: View
    func createDaxDialog(for homeDialog: DaxDialogs.HomeScreenSpec, onDismiss: @escaping () -> Void) -> DaxDialog
}

class NewTabDaxDialogFactory: NewTabDaxDialogProvider {
    var delegate: OnboardingNavigationDelegate?

    init(delegate: OnboardingNavigationDelegate?) {
        self.delegate = delegate
    }

    @ViewBuilder
    func createDaxDialog(for homeDialog: DaxDialogs.HomeScreenSpec, onDismiss: @escaping () -> Void) -> some View {
        switch homeDialog {
        case .initial:
            createInitialDialog()
        case .addFavorite:
            createAddFavoriteDialog(message: homeDialog.message)
        case .subsequent:
            createSubsequentDialog()
        case .final:
            createFinalDialog(onDismiss: onDismiss)
        default:
            EmptyView()

        }
    }

    private func createInitialDialog() -> some View {
        let viewModel = OnboardingSearchSuggestionsViewModel(delegate: delegate)
        return FadeInView {
            OnboardingTrySearchDialog(viewModel: viewModel)
                .padding()
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
            DaxDialogView(logoPosition: .top) {
                ContextualDaxDialogContent(message: NSAttributedString(string: message))

            }
            .padding()
        }
    }

    private func createFinalDialog(onDismiss: @escaping () -> Void) -> some View {
        return ScrollView(.vertical) {
            FadeInView {
                OnboardingFinalDialog(highFiveAction: {
                    onDismiss()
                }).padding()
            }
        }
    }
}

struct FadeInView<Content: View>: View {
    var content: Content
    @State private var opacity: Double = 0

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.4)) {
                    opacity = 1.0
                }
            }
    }
}
