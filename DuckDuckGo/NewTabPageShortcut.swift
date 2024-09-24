//
//  NewTabPageShortcut.swift
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

import UIKit

enum NewTabPageShortcut: CaseIterable, Equatable, Identifiable, Codable {
    var id: String { storageIdentifier }

    case bookmarks, aiChat, passwords, downloads, settings

    static var enabledByDefault: [NewTabPageShortcut] {
        NewTabPageShortcut.allCases.filter { $0 != .aiChat }
    }
}

extension NewTabPageShortcut {
    var storageIdentifier: String {
        switch self {
        case .bookmarks:
            "shortcut.storage.identifier.bookmarks"
        case .aiChat:
            "shortcut.storage.identifier.aichat"
        case .passwords:
            "shortcut.storage.identifier.passwords"
        case .downloads:
            "shortcut.storage.identifier.downloads"
        case .settings:
            "shortcut.storage.identifier.settings"
        }
    }

    var nameForPixel: String {
        switch self {
        case .bookmarks: return "bookmarks"
        case .aiChat: return "chat"
        case .passwords: return "passwords"
        case .downloads: return "downloads"
        case .settings: return "settings"
        }
    }
}
