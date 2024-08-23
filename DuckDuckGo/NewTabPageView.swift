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

struct NewTabPageView<FavoritesModelType: FavoritesModel & FavoritesEmptyStateModel>: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    @ObservedObject private var newTabPageModel: NewTabPageModel
    @ObservedObject private var messagesModel: NewTabPageMessagesModel
    @ObservedObject private var favoritesModel: FavoritesModelType
    @ObservedObject private var shortcutsModel: ShortcutsModel
    @ObservedObject private var shortcutsSettingsModel: NewTabPageShortcutsSettingsModel
    @ObservedObject private var sectionsSettingsModel: NewTabPageSectionsSettingsModel

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
                .frame(maxWidth: horizontalSizeClass == .regular ? Metrics.messageMaximumWidthPad : Metrics.messageMaximumWidth)
                .padding(.horizontal, Metrics.regularPadding)
                .padding(.bottom, Metrics.regularPadding)
        }
    }

    private var favoritesSectionView: some View {
        Group {
            if favoritesModel.isEmpty {
                FavoritesEmptyStateView(model: favoritesModel)
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
                newTabPageModel.customizeNewTabPage()
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
                newTabPageModel.introMessageDisplayed()
            }
            .transition(.scale.combined(with: .opacity))
        }
    }

    @ViewBuilder
    private var emptyStateView: some View {
        VStack {
            introMessageView

            messagesSectionView

            Spacer()

            NewTabPageDaxLogoView()

            // MARK: Customize button
            Spacer()

            customizeButtonView
        }
        .padding(.top, Metrics.regularPadding)
    }

    @ViewBuilder
    private var sectionsView: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack {
                    introMessageView

                    messagesSectionView

                    ForEach(sectionsSettingsModel.enabledItems, id: \.rawValue) { section in
                        switch section {
                        case .favorites:
                            favoritesSectionView
                        case .shortcuts:
                            shortcutsSectionView
                        }
                    }

                    // MARK: Customize button
                    Spacer()

                    if customizeButtonShowedInline {
                        customizeButtonView
                            .transition(.move(edge: .bottom))
                            .animation(.easeInOut, value: customizeButtonShowedInline)
                    }
                }
                .padding(.top, Metrics.regularPadding)
                .anchorPreference(key: CustomizeButtonPrefKey.self, value: .bounds, transform: { vStackBoundsAnchor in
                    let verticalRoomForButton = Metrics.customizeButtonHeight + Metrics.sectionPadding.top + Metrics.sectionPadding.bottom
                    let contentSizeAdjustmentValue = customizeButtonShowedInline ? -verticalRoomForButton : 0
                    let adjustedContentSize = proxy[vStackBoundsAnchor].height + contentSizeAdjustmentValue

                    return proxy.size.height < adjustedContentSize
                })
                .onPreferenceChange(CustomizeButtonPrefKey.self, perform: { value in
                    customizeButtonShowedInline = isAnySectionEnabled ? value : false
                })
            }
            .withScrollKeyboardDismiss()
            .safeAreaInset(edge: .bottom, alignment: .trailing) {
                if !customizeButtonShowedInline {
                    customizeButtonView
                        .frame(maxWidth: .infinity)
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut, value: customizeButtonShowedInline)
                }
            }
        }
    }

    private var isAnySectionEnabled: Bool {
        !sectionsSettingsModel.enabledItems.isEmpty
    }

    private var isShortcutsSectionVisible: Bool {
        !shortcutsSettingsModel.enabledItems.isEmpty
    }

    @ViewBuilder
    private var mainView: some View {
        if !isAnySectionEnabled {
            emptyStateView
        } else {
            sectionsView
        }
    }

    var body: some View {
        if !newTabPageModel.isOnboarding {
            mainView
                .background(Color(designSystemColor: .background))
                .if(favoritesModel.isShowingTooltip) {
                    $0.highPriorityGesture(DragGesture(minimumDistance: 0, coordinateSpace: .global).onEnded { _ in
                        favoritesModel.toggleTooltip()
                    })
                }
                .sheet(isPresented: $newTabPageModel.isShowingSettings, onDismiss: {
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
}

private extension View {
    func sectionPadding() -> some View {
        self.padding(Metrics.sectionPadding)
    }

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

    static let regularPadding = 16.0
    static let largePadding = 24.0

    static let sectionPadding = EdgeInsets(
        top: Self.regularPadding,
        leading: Self.largePadding,
        bottom: Self.regularPadding,
        trailing: Self.largePadding
    )

    static let customizeButtonHeight: CGFloat = 40
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

#Preview("Empty state") {
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
        sectionsSettingsModel: NewTabPageSectionsSettingsModel(storage: .emptyStorage())
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

private extension NewTabPageSectionsSettingsStorage {
    static func emptyStorage() -> Self {
        Self.init(keyPath: \.newTabPageSectionsSettings, defaultOrder: [], defaultEnabledItems: [])
    }
}
