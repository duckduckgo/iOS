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
    @State private var customizeButtonShowedInline = false

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

    private var mainView: some View {
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

                    // MARK: Customize button
                    Spacer()

                    if customizeButtonShowedInline {
                        customizeButtonView
                            .animation(.easeInOut, value: customizeButtonShowedInline)
                    }
                }
                .anchorPreference(key: CustomizeButtonPrefKey.self, value: .bounds, transform: { vStackBoundsAnchor in
                    let verticalRoomForButton = 40 + Constant.sectionPadding
                    let contentSizeAdjustmentValue = customizeButtonShowedInline ? -verticalRoomForButton : 0
                    let adjustedContentSize = proxy[vStackBoundsAnchor].height + contentSizeAdjustmentValue

                    return proxy.size.height < adjustedContentSize
                })
                .onPreferenceChange(CustomizeButtonPrefKey.self, perform: { value in
                    customizeButtonShowedInline = value
                })
            }
            .safeAreaInset(edge: .bottom, alignment: .trailing) {
                if !customizeButtonShowedInline {
                    customizeButtonView
                        .animation(.easeInOut, value: customizeButtonShowedInline)
                }
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

    var body: some View {
        if !newTabPageModel.isOnboarding {
            mainView
        }
    }
}

private extension View {
        func sectionPadding() -> some View {
            self.padding(Constant.sectionPadding)
        }
    }

private struct Constant {
    static let sectionPadding = 24.0

    static let messageMaximumWidth: CGFloat = 380
    static let messageMaximumWidthPad: CGFloat = 455
}

private struct CustomizeButtonPrefKey: PreferenceKey {
    static var defaultValue: Bool = true

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
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
