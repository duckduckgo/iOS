//
//  ShortcutsView.swift
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
import UniformTypeIdentifiers

struct ShortcutsView: View {
    @ObservedObject private(set) var model: ShortcutsModel

    let editingEnabled: Bool

    var body: some View {
        NewTabPageGridView { _ in
            ReorderableForEach(model.enabledShortcuts, isReorderingEnabled: editingEnabled) { shortcut in
                Button {
                    model.openShortcut(shortcut)
                } label: {
                    ShortcutItemView(shortcut: shortcut, accessoryType: nil)
                }
                .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 8))
            } preview: { shortcut in
                ShortcutIconView(shortcut: shortcut).contentShape(.dragPreview, RoundedRectangle(cornerRadius: 8))
            } onMove: { indices, newOffset in
                withAnimation {
                    model.moveShortcuts(from: indices, to: newOffset)
                }
            }
        }
    }
}

extension NewTabPageShortcut: Reorderable {
    var dropItemProvider: NSItemProvider {
        NSItemProvider(object: id as NSString)
    }

    var dropType: UTType { .text }
}

#Preview {
    ScrollView {
        ShortcutsView(model: ShortcutsModel(shortcutsPreferencesStorage: InMemoryShortcutsPreferencesStorage()), editingEnabled: false)
    }
    .background(Color(designSystemColor: .background))
}
