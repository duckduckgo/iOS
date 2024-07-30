//
//  NewTabPageSettingsPersistentStorage.swift
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

private struct NewTabPageItemSettings<Item: NewTabPageSettingsStorageItem>: Codable {
    let itemsOrder: [Item]
    let enabledItems: Set<Item>
}

final class NewTabPageSettingsPersistentStorage<Item: NewTabPageSettingsStorageItem>: NewTabPageSettingsStorage {
    private(set) var itemsOrder: [Item]
    private var enabledItems: Set<Item>

    private var appSettings: AppSettings
    private let keyPath: WritableKeyPath<AppSettings, Data?>

    init(appSettings: AppSettings = AppDependencyProvider.shared.appSettings,
         keyPath: WritableKeyPath<AppSettings, Data?>,
         defaultOrder: [Item],
         defaultEnabledItems: [Item]) {
        self.appSettings = appSettings
        self.keyPath = keyPath
        self.itemsOrder = defaultOrder
        self.enabledItems = Set(defaultEnabledItems)

        self.load()
    }

    func isEnabled(_ item: Item) -> Bool {
        enabledItems.contains(item)
    }

    func setItem(_ item: Item, enabled: Bool) {
        if enabled {
            enabledItems.insert(item)
        } else {
            enabledItems.remove(item)
        }
    }

    func moveItems(_ fromOffsets: IndexSet, toOffset: Int) {
        itemsOrder.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }

    func save() {
        let newSettings = NewTabPageItemSettings(itemsOrder: itemsOrder, enabledItems: enabledItems)
        if let data = try? JSONEncoder().encode(newSettings) {
            appSettings[keyPath: keyPath] = data
        }
    }

    private func load() {
        if let settingsData = appSettings[keyPath: keyPath],
           let settings = try? JSONDecoder().decode(NewTabPageItemSettings<Item>.self, from: settingsData) {
            itemsOrder = settings.itemsOrder
            enabledItems = settings.enabledItems
        }
    }
}
