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
    private(set) var model: ShortcutsModel
    let shortcuts: [NewTabPageShortcut]
    let proxy: GeometryProxy?

    var body: some View {
        NewTabPageGridView(geometry: proxy, isUsingDynamicSpacing: true) { _ in
            ForEach(shortcuts) { shortcut in
                Button {
                    model.openShortcut(shortcut)
                } label: {
                    ShortcutItemView(shortcut: shortcut, accessoryType: nil)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    ScrollView {
        ShortcutsView(model: ShortcutsModel(), shortcuts: NewTabPageShortcut.allCases, proxy: nil)
    }
    .background(Color(designSystemColor: .background))
}
