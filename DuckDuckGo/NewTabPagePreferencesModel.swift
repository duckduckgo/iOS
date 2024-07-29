//
//  NewTabPagePreferencesModel.swift
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

final class NewTabPagePreferencesModel<SettingItem: NewTabPageSettingsStorageItem, Storage: NewTabPageSettingsStorage>: ObservableObject where Storage.SettingItem == SettingItem {

    /// Preferences page settings collection with bindings
    @Published private(set) var itemsSettings: [NTPSetting<SettingItem>] = []

    /// Enabled items, ordered.
    @Published private(set) var enabledItems: [SettingItem] = []

    private let preferencesStorage: Storage

    init(preferencesStorage: Storage) {
        self.preferencesStorage = preferencesStorage

        updatePublishedValues()
    }

    func moveItems(from: IndexSet, to: Int) {
        preferencesStorage.moveItems(from, toOffset: to)
        updatePublishedValues()
    }

    func save() {
        preferencesStorage.save()
    }

    private func updatePublishedValues() {
        populateSettings()
        populateEnabledItems()
    }

    private func populateEnabledItems() {
        enabledItems = preferencesStorage.enabledItems
    }

    private func populateSettings() {
        itemsSettings = preferencesStorage.itemsOrder.map { item in
            NTPSetting(item: item, isEnabled: Binding(get: {
                self.preferencesStorage.isEnabled(item)
            }, set: { newValue in
                self.preferencesStorage.setItem(item, enabled: newValue)
                self.updatePublishedValues()
            }))
        }
    }
}

extension NewTabPagePreferencesModel {
    struct NTPSetting<Item> {
        let item: Item
        let isEnabled: Binding<Bool>
    }
}
