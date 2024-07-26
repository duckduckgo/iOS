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
    @ObservedObject var shortcutsModel: ShortcutsModel

    // Arbitrary high value is required to acomodate for the content size
    @State var listHeight: CGFloat = 5000

    @State var firstSectionFrame: CGRect = .zero
    @State var lastSectionFrame: CGRect = .zero

    var body: some View {
        mainView
        .applyBackground()
        .tintIfAvailable(Color(designSystemColor: .accent))
        .navigationTitle(UserText.newTabPagePreferencesTitle)
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
        if model.visibleSections.contains(.shortcuts) {
            ScrollView {
                VStack {
                    sectionsList(withFrameUpdates: true)
                        .withoutScroll()
                        .frame(height: listHeight)
                    
                    ShortcutsView(model: shortcutsModel, editingEnabled: true)
                        .padding(.horizontal, Metrics.horizontalPadding)
                }
            }
            .coordinateSpace(name: Constant.scrollCoordinateSpace)
        } else {
            sectionsList(withFrameUpdates: false)
        }
    }

    @ViewBuilder
    private func sectionsList(withFrameUpdates: Bool) -> some View {
        List {
            Section {
                sectionsPreferenceSectionContentView
            } header: {
                Text(UserText.newTabPagePreferencesSectionsSettingsHeaderTitle)
                    .if(withFrameUpdates) {
                        $0.onFrameUpdate(in: Constant.scrollCoordinateSpace, using: FirstSectionFrameKey.self) { frame in
                            self.firstSectionFrame = frame
                            updateListHeight()
                        }
                    }
            } footer: {
                Text(UserText.newTabPagePreferencesSectionsSettingsDescription)
            }

            if model.visibleSections.contains(.shortcuts) {
                Section {
                } header: {
                    Text(UserText.newTabPagePreferencesShortcutsHeaderTitle)
                        .if(withFrameUpdates) {
                            $0.onFrameUpdate(in: Constant.scrollCoordinateSpace, using: LastSectionFrameKey.self) { frame in
                                self.lastSectionFrame = frame
                                updateListHeight()
                            }
                        }
                }
            }
        }
        .applyInsetGroupedListStyle()
        .environment(\.editMode, .constant(.active))
    }

    @ViewBuilder
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

    // MARK: -

    private func updateListHeight() {
        guard firstSectionFrame != .zero, lastSectionFrame != .zero else { return }

        let newHeight = lastSectionFrame.maxY - firstSectionFrame.minY + Metrics.defaultListTopPadding
        self.listHeight = max(0, newHeight)
    }

    private struct Constant {
        static let scrollCoordinateSpaceName = "Scroll"
        static let scrollCoordinateSpace = CoordinateSpace.named(scrollCoordinateSpaceName)
    }

    private struct Metrics {
        static let defaultListTopPadding = 24.0
        static let horizontalPadding = 16.0
    }
}

#Preview {
    NavigationView {
        NewTabPagePreferencesView(
            model: NewTabPagePreferencesModel(
                newTabPagePreferencesStorage: InMemoryNewTabPageSectionsPreferencesStorage()
            ),
            shortcutsModel: ShortcutsModel(shortcutsPreferencesStorage: InMemoryShortcutsPreferencesStorage())
        )
    }
}

private struct FirstSectionFrameKey: PreferenceKey {
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
    static var defaultValue: CGRect = .zero
}

private struct LastSectionFrameKey: PreferenceKey {
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
    static var defaultValue: CGRect = .zero
}
