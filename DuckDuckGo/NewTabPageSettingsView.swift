//
//  NewTabPageSettingsView.swift
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
import Common

struct NewTabPageSettingsView: View {
    @Environment(\.dismiss) var dismiss

    @ObservedObject var shortcutsSettingsModel: NewTabPageShortcutsSettingsModel
    @ObservedObject var sectionsSettingsModel: NewTabPageSectionsSettingsModel

    @State var listHeight: CGFloat = Metrics.initialListHeight

    var body: some View {
        mainView
            .applyBackground()
            .tintIfAvailable(Color(designSystemColor: .accent))
            .navigationTitle(UserText.newTabPageSettingsTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(UserText.navigationTitleDone) {
                        dismiss()
                    }
                    .tint(Color(designSystemColor: .textPrimary))
                }
            }
    }

    // MARK: Views

    @ViewBuilder
    private var mainView: some View {
        if sectionsSettingsModel.enabledItems.contains(.shortcuts) {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        sectionsList(withFrameUpdates: true, geometry: geometry)
                            .withoutScroll()
                            .frame(height: listHeight)

                        EditableShortcutsView(model: shortcutsSettingsModel, geometry: geometry)
                            .padding(.horizontal, Metrics.horizontalPadding)
                    }
                }
            }
        } else {
            sectionsList(withFrameUpdates: false)
        }
    }

    @ViewBuilder
    private func sectionsList(withFrameUpdates: Bool, geometry: GeometryProxy? = nil) -> some View {
            List {
                Section {
                    sectionsSettingsContentView
                } header: {
                    Text(UserText.newTabPageSettingsSectionsHeaderTitle)
                } footer: {
                    Text(UserText.newTabPageSettingsSectionsDescription)
                }

                if sectionsSettingsModel.enabledItems.contains(.shortcuts) {
                    Section {
                    } header: {
                        Text(UserText.newTabPageSettingsShortcutsHeaderTitle)
                    } footer: {
                        Rectangle().fill(.clear).frame(minHeight: 0.1)
                    }
                    .anchorPreference(key: ListBottomKey.self, value: .bottom, transform: { anchor in
                        let y = geometry?[anchor].y ?? 0
                        return y
                    })
                }
            }
            .onPreferenceChange(ListBottomKey.self, perform: { position in
                guard self.listHeight == Metrics.initialListHeight else { return }

                self.listHeight = max(0, position)
            })
            .applyInsetGroupedListStyle()
            .environment(\.editMode, .constant(.active))
    }

    @ViewBuilder
    private var sectionsSettingsContentView: some View {
        ForEach(sectionsSettingsModel.itemsSettings, id: \.item) { setting in
            switch setting.item {
            case .favorites:
                NewTabPageSettingsSectionItemView(title: UserText.newTabPageSettingsSectionNameFavorites,
                                                  iconResource: .favorite24,
                                                  isEnabled: setting.isEnabled)
            case .shortcuts:
                NewTabPageSettingsSectionItemView(title: UserText.newTabPageSettingsSectionNameShortcuts,
                                                  iconResource: .shortcut24,
                                                  isEnabled: setting.isEnabled)
            }
        }.onMove(perform: { indices, newOffset in
            sectionsSettingsModel.moveItems(from: indices, to: newOffset)
        })
    }
}

private struct Metrics {
    static let horizontalPadding = 24.0
    static let initialListHeight = 5000.0
}

private struct ListBottomKey: PreferenceKey {
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
    static var defaultValue: CGFloat = Metrics.initialListHeight
}

#Preview {
    NavigationView {
        NewTabPageSettingsView(
            shortcutsSettingsModel: NewTabPageShortcutsSettingsModel(),
            sectionsSettingsModel: NewTabPageSectionsSettingsModel()
        )
    }
}
