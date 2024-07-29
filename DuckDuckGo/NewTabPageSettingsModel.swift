//
//  NewTabPageSettingsModel.swift
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
import SwiftUI

final class NewTabPageSettingsModel<SettingItem: NewTabPageSettingsStorageItem, Storage: NewTabPageSettingsStorage>: ObservableObject where Storage.SettingItem == SettingItem {

    /// Settings page settings collection with bindings
    @Published private(set) var itemsSettings: [NTPSetting<SettingItem>] = []

    /// Enabled items, ordered.
    @Published private(set) var enabledItems: [SettingItem] = []

    private let settingsStorage: Storage

    init(settingsStorage: Storage) {
        self.settingsStorage = settingsStorage

        updatePublishedValues()
    }

    func moveItems(from: IndexSet, to: Int) {
        settingsStorage.moveItems(from, toOffset: to)
        updatePublishedValues()
    }

    func save() {
        settingsStorage.save()
    }

    private func updatePublishedValues() {
        populateSettings()
        populateEnabledItems()
    }

    private func populateEnabledItems() {
        enabledItems = settingsStorage.enabledItems
    }

    private func populateSettings() {
        itemsSettings = settingsStorage.itemsOrder.map { item in
            NTPSetting(item: item, isEnabled: Binding(get: {
                self.settingsStorage.isEnabled(item)
            }, set: { newValue in
                self.settingsStorage.setItem(item, enabled: newValue)
                self.updatePublishedValues()
            }))
        }
    }
}

extension NewTabPageSettingsModel {
    struct NTPSetting<Item> {
        let item: Item
        let isEnabled: Binding<Bool>
    }
}
