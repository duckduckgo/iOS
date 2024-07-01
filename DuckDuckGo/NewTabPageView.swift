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

struct NewTabPageView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    @ObservedObject var messagesModel: NewTabPageMessagesModel
    @ObservedObject var favoritesModel: FavoritesModel

    init(messagesModel: NewTabPageMessagesModel, favoritesModel: FavoritesModel) {
        self.messagesModel = messagesModel
        self.favoritesModel = favoritesModel

        self.messagesModel.load()
    }

    var body: some View {
        ScrollView {
            VStack {
                // MARK: Messages
                ForEach(messagesModel.homeMessageViewModels, id: \.messageId) { messageModel in
                    HomeMessageView(viewModel: messageModel)
                        .frame(maxWidth: horizontalSizeClass == .regular ? Constant.messageMaximumWidthPad : Constant.messageMaximumWidth)
                        .padding()
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

                // MARK: Customize
                Button(action: {
                    // Temporary action for testing purposes
                    favoritesModel.toggleFavoritesPresence()
                }, label: {
                    NewTabPageCustomizeButtonView()
                }).buttonStyle(SecondaryFillButtonStyle(compact: true, fullWidth: false))
                    .padding(EdgeInsets(top: 88, leading: 0, bottom: 16, trailing: 0))
            }
        }
        .background(Color(designSystemColor: .background))
    }

    private struct Constant {
        static let sectionPadding = EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)

        static let messageMaximumWidth: CGFloat = 380
        static let messageMaximumWidthPad: CGFloat = 455
    }
}

// MARK: - Preview

#Preview("Regular") {
    NewTabPageView(messagesModel: NewTabPageMessagesModel(), favoritesModel: FavoritesModel())
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
                            exclusionRules: []
                        )
                    )
                ]
            )
        ),
        favoritesModel: FavoritesModel()
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
