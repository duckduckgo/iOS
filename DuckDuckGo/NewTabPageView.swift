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

    @ObservedObject private var newTabPageModel: NewTabPageModel
    @ObservedObject private var messagesModel: NewTabPageMessagesModel
    @ObservedObject private var favoritesModel: FavoritesModelType
    @ObservedObject private var shortcutsModel: ShortcutsModel
    @ObservedObject private var shortcutsSettingsModel: NewTabPageShortcutsSettingsModel
    @ObservedObject private var sectionsSettingsModel: NewTabPageSectionsSettingsModel
    
    @State var isShowingTooltip: Bool = false
    @State private var isShowingSettings: Bool = false

    init(newTabPageModel: NewTabPageModel,
         messagesModel: NewTabPageMessagesModel,
         favoritesModel: FavoritesModelType,
         shortcutsModel: ShortcutsModel,
         shortcutsSettingsModel: NewTabPageShortcutsSettingsModel,
         sectionsSettingsModel: NewTabPageSectionsSettingsModel) {
        self.newTabPageModel = newTabPageModel
        self.messagesModel = messagesModel
        self.favoritesModel = favoritesModel
        self.shortcutsModel = shortcutsModel
        self.shortcutsSettingsModel = shortcutsSettingsModel
        self.sectionsSettingsModel = sectionsSettingsModel

        self.messagesModel.load()
    }

    private var messagesSectionView: some View {
        ForEach(messagesModel.homeMessageViewModels, id: \.messageId) { messageModel in
            HomeMessageView(viewModel: messageModel)
                .frame(maxWidth: horizontalSizeClass == .regular ? Constant.messageMaximumWidthPad : Constant.messageMaximumWidth)
                .padding(16)
        }
    }

    private var favoritesSectionView: some View {
        Group {
            if favoritesModel.isEmpty {
                FavoritesEmptyStateView(isShowingTooltip: $isShowingTooltip)
            } else {
                FavoritesView(model: favoritesModel)
            }
        }
        .sectionPadding()
    }

    @ViewBuilder
    private var shortcutsSectionView: some View {
        if isShortcutsSectionVisible {
            ShortcutsView(model: shortcutsModel, shortcuts: shortcutsSettingsModel.enabledItems)
                .sectionPadding()
        }
    }

    private var customizeButtonView: some View {
        HStack {
            Spacer()

            Button(action: {
                isShowingSettings = true
            }, label: {
                NewTabPageCustomizeButtonView()
                // Needed to reduce default button margins
                    .padding(EdgeInsets(top: 0, leading: -8, bottom: 0, trailing: -8))
            }).buttonStyle(SecondaryFillButtonStyle(compact: true, fullWidth: false))
                .padding(.top, 40)
        }.sectionPadding()
    }

    @ViewBuilder
    private var introMessageView: some View {
        if newTabPageModel.isIntroMessageVisible {
            NewTabPageIntroMessageView(onClose: {
                withAnimation {
                    newTabPageModel.dismissIntroMessage()
                }
            })
            .sectionPadding()
            .onFirstAppear {
                newTabPageModel.increaseIntroMessageCounter()
            }
        }
    }

    private var isAnySectionEnabled: Bool {
        !sectionsSettingsModel.enabledItems.isEmpty
    }

    private var isShortcutsSectionVisible: Bool {
        !shortcutsSettingsModel.enabledItems.isEmpty
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack {
                    introMessageView

                    messagesSectionView

                    if isAnySectionEnabled {
                        ForEach(sectionsSettingsModel.enabledItems, id: \.rawValue) { section in
                            switch section {
                            case .favorites:
                                favoritesSectionView
                            case .shortcuts:
                                shortcutsSectionView
                            }
                        }
                    } else {
                        // MARK: Dax Logo
                        Spacer()
                        NewTabPageDaxLogoView()
                    }

                    Spacer()

                    // MARK: Customize button
                    customizeButtonView
                }
                .frame(minHeight: proxy.frame(in: .local).size.height)
            }
        }
        .background(Color(designSystemColor: .background))
        .if(isShowingTooltip) {
            $0.highPriorityGesture(DragGesture(minimumDistance: 0, coordinateSpace: .global).onEnded { _ in
                isShowingTooltip = false
            })
        }
        .sheet(isPresented: $isShowingSettings, onDismiss: {
            shortcutsSettingsModel.save()
            sectionsSettingsModel.save()
        }, content: {
            NavigationView {
                NewTabPageSettingsView(shortcutsSettingsModel: shortcutsSettingsModel,
                                          sectionsSettingsModel: sectionsSettingsModel)
            }
        })
    }
}

private extension View {
        func sectionPadding() -> some View {
            self.padding(Constant.sectionPadding)
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
        newTabPageModel: NewTabPageModel(),
        messagesModel: NewTabPageMessagesModel(
            homePageMessagesConfiguration: PreviewMessagesConfiguration(
                homeMessages: []
            )
        ),
        favoritesModel: FavoritesPreviewModel(),
        shortcutsModel: ShortcutsModel(),
        shortcutsSettingsModel: NewTabPageShortcutsSettingsModel(),
        sectionsSettingsModel: NewTabPageSectionsSettingsModel()
    )
}

#Preview("With message") {
    NewTabPageView(
        newTabPageModel: NewTabPageModel(),
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
        favoritesModel: FavoritesPreviewModel(),
        shortcutsModel: ShortcutsModel(),
        shortcutsSettingsModel: NewTabPageShortcutsSettingsModel(),
        sectionsSettingsModel: NewTabPageSectionsSettingsModel()
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
