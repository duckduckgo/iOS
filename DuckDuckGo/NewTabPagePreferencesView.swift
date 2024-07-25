//
//  NewTabPagePreferencesView.swift
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

struct NewTabPagePreferencesView: View {
    @Environment(\.dismiss) var dismiss

    @ObservedObject var model: NewTabPagePreferencesModel

    var body: some View {
        NavigationView {
            List {
                Section {
                    sectionsPreferenceSectionContentView
                } header: {
                    Text(UserText.newTabPagePreferencesSectionsSettingsHeaderTitle)
                } footer: {
                    Text(UserText.newTabPagePreferencesSectionsSettingsDescription)
                }

                if model.visibleSections.contains(.shortcuts) {
                    Section {
                        EmptyView()
                    } header: {
                        Text(UserText.newTabPagePreferencesShortcutsHeaderTitle)
                    } footer: {
                        // Placed in footer since Section adds a group layer, which we don't want here.
                        ShortcutsView(model: ShortcutsModel(shortcutsPreferencesStorage: InMemoryShortcutsPreferencesStorage()))
                            .padding(.horizontal, -24) // Required to adjust for the group inset
                    }
                }
            }
            .environment(\.editMode, .constant(.active))
            .applyInsetGroupedListStyle()
            .tintIfAvailable(Color(designSystemColor: .accent))
            .navigationTitle(UserText.newTabPagePreferencesTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .tint(Color(designSystemColor: .textPrimary))
                }
            }
        }
    }

    private var sectionsPreferenceSectionContentView: some View {
        ForEach(model.sectionsSettings, id: \.section) { item in
            switch item.section {
            case .favorites:
                NTPPreferencesSectionItemView(title: "Favorites",
                                              iconResource: .favorite24,
                                              isEnabled: item.isEnabled)
            case .shortcuts:
                NTPPreferencesSectionItemView(title: "Shortcuts",
                                              iconResource: .shortcut24,
                                              isEnabled: item.isEnabled)
            }
        }.onMove(perform: { indices, newOffset in
            model.moveSections(from: indices, to: newOffset)
        })
    }
}

#Preview {
    return NewTabPagePreferencesView(
        model: NewTabPagePreferencesModel(
            newTabPagePreferencesStorage: InMemoryNewTabPageSectionsPreferencesStorage()
        )
    )
}
