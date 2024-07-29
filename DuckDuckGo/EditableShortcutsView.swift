//
//  EditableShortcutsView.swift
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

struct EditableShortcutsView: View {

    @ObservedObject private(set) var model: NewTabPageShortcutsSettingsModel

    var body: some View {
        NewTabPageGridView { _ in
            ReorderableForEach(model.itemsSettings, id: \.item.id, isReorderingEnabled: true) { setting in
                let isEnabled = model.enabledItems.contains(setting.item)
                Button {
                    setting.isEnabled.wrappedValue.toggle()
                } label: {
                    ShortcutItemView(shortcut: setting.item, accessoryType: isEnabled ? .selected : .add)
                }
            } preview: { setting in
                ShortcutIconView(shortcut: setting.item).previewShape()
            } onMove: { indices, newOffset in
                withAnimation {
                    model.moveItems(from: indices, to: newOffset)
                }
            }
        }
    }
}

private extension View {
    func previewShape() -> some View {
        contentShape(.dragPreview, RoundedRectangle(cornerRadius: 8))
    }
}

extension NewTabPageSettingsModel.NTPSetting<NewTabPageShortcut>: Reorderable, Hashable, Equatable {

    var dropItemProvider: NSItemProvider {
        NSItemProvider(object: item.id as NSString)
    }

    var dropType: UTType { .text }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.item == rhs.item
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(item.hashValue)
    }
}

#Preview {
    ScrollView {
        EditableShortcutsView(model: NewTabPageShortcutsSettingsModel())
    }
    .background(Color(designSystemColor: .background))
}
