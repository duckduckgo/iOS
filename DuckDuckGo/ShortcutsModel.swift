//
//  ShortcutsModel.swift
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

import Foundation

protocol ShortcutsPreferencesStorage {
    var enabledShortcuts: [NewTabPageShortcut] { get }
}

final class ShortcutsModel: ObservableObject {
    @Published private(set) var enabledShortcuts: [NewTabPageShortcut] = []

    private let shortcutsPreferencesStorage: ShortcutsPreferencesStorage

    init(shortcutsPreferencesStorage: ShortcutsPreferencesStorage) {
        self.shortcutsPreferencesStorage = shortcutsPreferencesStorage

        enabledShortcuts = shortcutsPreferencesStorage.enabledShortcuts
    }
}

final class InMemoryShortcutsPreferencesStorage: ShortcutsPreferencesStorage {
    private(set) var enabledShortcuts: [NewTabPageShortcut] = NewTabPageShortcut.allCases
}
