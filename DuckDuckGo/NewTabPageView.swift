//
//  NewTabPageView.swift
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

struct NewTabPageView<FavoritesModelType: FavoritesModel>: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    @ObservedObject var messagesModel: NewTabPageMessagesModel
    @ObservedObject var favoritesModel: FavoritesModelType

    init(messagesModel: NewTabPageMessagesModel, favoritesModel: FavoritesModelType) {
        self.messagesModel = messagesModel
        self.favoritesModel = favoritesModel

        self.messagesModel.load()
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack {
                    // MARK: Messages
                    ForEach(messagesModel.homeMessageViewModels, id: \.messageId) { messageModel in
                        HomeMessageView(viewModel: messageModel)
                            .frame(maxWidth: horizontalSizeClass == .regular ? Constant.messageMaximumWidthPad : Constant.messageMaximumWidth)
                            .padding(16)
                    }

                    // MARK: Favorites
                    if favoritesModel.isEmpty {
                        FavoritesEmptyStateView()
                            .padding(Constant.sectionPadding)
                    } else {
                        FavoritesView(model: favoritesModel)
                            .padding(Constant.sectionPadding)
                    }

                    // MARK: Shortcuts
                    ShortcutsView()
                        .padding(Constant.sectionPadding)

                    Spacer()

                    // MARK: Customize button
                    HStack {
                        Spacer()

                        Button(action: {
                        }, label: {
                            NewTabPageCustomizeButtonView()
                            // Needed to reduce default button margins
                                .padding(EdgeInsets(top: 0, leading: -8, bottom: 0, trailing: -8))
                        }).buttonStyle(SecondaryFillButtonStyle(compact: true, fullWidth: false))
                            .padding(Constant.sectionPadding)
                            .padding(.top, 40)
                    }
                }
                .frame(minHeight: proxy.frame(in: .local).size.height)
            }
            .background(Color(designSystemColor: .background))
        }
    }
}

private struct Constant {
    static let sectionPadding = EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)

    static let messageMaximumWidth: CGFloat = 380
    static let messageMaximumWidthPad: CGFloat = 455
}

// MARK: - Preview

#Preview("Regular") {
    NewTabPageView(
        messagesModel: NewTabPageMessagesModel(
            homePageMessagesConfiguration: PreviewMessagesConfiguration(
                homeMessages: []
            )
        ),
        favoritesModel: FavoritesPreviewModel()
    )
}

#Preview("With message") {
    NewTabPageView(
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
        favoritesModel: FavoritesPreviewModel()
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
