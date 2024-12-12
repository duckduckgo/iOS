//
//  SimpleNewTabPageView.swift
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
import RemoteMessaging

struct SimpleNewTabPageView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    @ObservedObject private var viewModel: NewTabPageViewModel
    @ObservedObject private var messagesModel: NewTabPageMessagesModel
    @ObservedObject private var favoritesViewModel: FavoritesViewModel

    init(viewModel: NewTabPageViewModel,
         messagesModel: NewTabPageMessagesModel,
         favoritesViewModel: FavoritesViewModel) {
        self.viewModel = viewModel
        self.messagesModel = messagesModel
        self.favoritesViewModel = favoritesViewModel

        self.messagesModel.load()
    }

    private var isShowingSections: Bool {
        !favoritesViewModel.allFavorites.isEmpty
    }

    var body: some View {
        if !viewModel.isOnboarding {
            mainView
                .background(Color(designSystemColor: .background))
                .simultaneousGesture(
                    DragGesture()
                        .onChanged({ value in
                            if value.translation.height != 0.0 {
                                viewModel.beginDragging()
                            }
                        })
                        .onEnded({ _ in viewModel.endDragging() })
                )
        }
    }

    @ViewBuilder
    private var mainView: some View {
        if isShowingSections {
            sectionsView
        } else {
            emptyStateView
        }
    }
}

private extension SimpleNewTabPageView {
    // MARK: - Views
    @ViewBuilder
    private var sectionsView: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: Metrics.sectionSpacing) {

                    messagesSectionView
                        .padding(.top, Metrics.nonGridSectionTopPadding)

                    favoritesSectionView(proxy: proxy)
                }
                .padding(sectionsViewPadding(in: proxy))
            }
            .withScrollKeyboardDismiss()
        }
        // Prevent recreating geomery reader when keyboard is shown/hidden.
        .ignoresSafeArea(.keyboard)
    }

    @ViewBuilder
    private var emptyStateView: some View {
        ZStack {
            NewTabPageDaxLogoView()

            VStack(spacing: Metrics.sectionSpacing) {
                messagesSectionView
                    .padding(.top, Metrics.nonGridSectionTopPadding)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .padding(Metrics.regularPadding)
    }

    private var messagesSectionView: some View {
        ForEach(messagesModel.homeMessageViewModels, id: \.messageId) { messageModel in
            HomeMessageView(viewModel: messageModel)
                .frame(maxWidth: horizontalSizeClass == .regular ? Metrics.messageMaximumWidthPad : Metrics.messageMaximumWidth)
                .transition(.scale.combined(with: .opacity))
        }
    }

    private func favoritesSectionView(proxy: GeometryProxy) -> some View {
        FavoritesView(model: favoritesViewModel,
                      isAddingFavorite: .constant(false),
                      geometry: proxy)
    }

    private func sectionsViewPadding(in geometry: GeometryProxy) -> CGFloat {
        geometry.frame(in: .local).width > Metrics.verySmallScreenWidth ? Metrics.regularPadding : Metrics.smallPadding
    }
}

private extension View {
    @ViewBuilder
    func withScrollKeyboardDismiss() -> some View {
        if #available(iOS 16, *) {
            scrollDismissesKeyboard(.immediately)
        } else {
            self
        }
    }
}

private struct Metrics {

    static let smallPadding = 12.0
    static let regularPadding = 24.0
    static let sectionSpacing = 32.0
    static let nonGridSectionTopPadding = -8.0

    static let messageMaximumWidth: CGFloat = 380
    static let messageMaximumWidthPad: CGFloat = 455

    static let verySmallScreenWidth: CGFloat = 320
}

// MARK: - Preview

#Preview("Regular") {
    SimpleNewTabPageView(
        viewModel: NewTabPageViewModel(),
        messagesModel: NewTabPageMessagesModel(
            homePageMessagesConfiguration: PreviewMessagesConfiguration(
                homeMessages: []
            )
        ),
        favoritesViewModel: FavoritesPreviewModel()
    )
}

#Preview("With message") {
    SimpleNewTabPageView(
        viewModel: NewTabPageViewModel(),
        messagesModel: NewTabPageMessagesModel(
            homePageMessagesConfiguration: PreviewMessagesConfiguration(
                homeMessages: [
                    HomeMessage.remoteMessage(
                        remoteMessage: RemoteMessageModel(
                            id: "0",
                            content: .small(titleText: "Title", descriptionText: "Description"),
                            matchingRules: [],
                            exclusionRules: [],
                            isMetricsEnabled: false
                        )
                    )
                ]
            )
        ),
        favoritesViewModel: FavoritesPreviewModel()
    )
}

#Preview("No favorites") {
    SimpleNewTabPageView(
        viewModel: NewTabPageViewModel(),
        messagesModel: NewTabPageMessagesModel(
            homePageMessagesConfiguration: PreviewMessagesConfiguration(
                homeMessages: []
            )
        ),
        favoritesViewModel: FavoritesPreviewModel(favorites: [])
    )
}

#Preview("Empty") {
    SimpleNewTabPageView(
        viewModel: NewTabPageViewModel(),
        messagesModel: NewTabPageMessagesModel(
            homePageMessagesConfiguration: PreviewMessagesConfiguration(
                homeMessages: []
            )
        ),
        favoritesViewModel: FavoritesPreviewModel()
    )
}

private final class PreviewMessagesConfiguration: HomePageMessagesConfiguration {
    private(set) var homeMessages: [HomeMessage]

    init(homeMessages: [HomeMessage]) {
        self.homeMessages = homeMessages
    }

    func refresh() {

    }

    func didAppear(_ homeMessage: HomeMessage) {
        // no-op
    }

    func dismissHomeMessage(_ homeMessage: HomeMessage) {
        homeMessages = homeMessages.dropLast()
    }
}
