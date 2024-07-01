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

enum Shortcut: Int, CaseIterable, Equatable, Identifiable {
    var id: Int { rawValue }

    case bookmarks, aiChat, vpn, passwords

    var name: String {
        switch self {
        case .bookmarks:
            UserText.homeTabShortcutBookmarks
        case .aiChat:
            UserText.homeTabShortcutAIChat
        case .vpn:
            UserText.homeTabShortcutVPN
        case .passwords:
            UserText.homeTabShortcutPasswords
        }
    }
}

struct ShortcutsView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State var enabledShortcuts: [Shortcut] = Array(Shortcut.allCases.prefix(upTo: 3))

    var body: some View {
        NewTabPageGridView { _ in
            ForEach(enabledShortcuts) { shortcut in
                ShortcutItemView(name: shortcut.name)
            }
        }
    }
}

#Preview {
    ShortcutsView()
}
