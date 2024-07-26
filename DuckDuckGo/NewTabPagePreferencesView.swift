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

    @State var listHeight: CGFloat?

    @State var lastListGlobalFrame: CGRect = .zero
    @State var lastSectionGlobalFrame: CGRect = .zero

    var body: some View {
        NavigationView {
            VStack {
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
                        } header: {
                            Text(UserText.newTabPagePreferencesShortcutsHeaderTitle)
                        } footer: {
                        }.overlay {
                            GeometryReader(content: { geometry in
                                Color.clear
                                    .preference(key: FrameKey.self, value: geometry.frame(in: .global))
                            })
                        }
                        .onPreferenceChange(FrameKey.self, perform: { value in
                            self.lastSectionGlobalFrame = value
                            updateListHeight()
                        })
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
                .overlay {
                    GeometryReader(content: { geometry in
                        Color.clear.preference(key: ListFrameKey.self, value: geometry.frame(in: .global))
                    })
                }
                .onPreferenceChange(ListFrameKey.self, perform: { value in
                    lastListGlobalFrame = value
                    updateListHeight()
                })
                .frame(height: listHeight)

                ShortcutsView(model: ShortcutsModel(shortcutsPreferencesStorage: InMemoryShortcutsPreferencesStorage()),
                              editingEnabled: true)
                .padding(.horizontal, 16)

                Spacer()
            }
            .applyBackground()
        }
    }

    private func updateListHeight() {
        guard lastListGlobalFrame != .zero, lastSectionGlobalFrame != .zero else { return }

        let newHeight = lastSectionGlobalFrame.maxY - lastListGlobalFrame.origin.y
//        if let listHeight {
//            self.listHeight = max(listHeight, newHeight)
//        } else {
            self.listHeight = max(0, newHeight)
//        }
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

private struct FrameKey: PreferenceKey {
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
    static var defaultValue: CGRect = .zero
}

private struct ListFrameKey: PreferenceKey {
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
    static var defaultValue: CGRect = .zero
}
