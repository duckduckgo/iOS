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
import Core
import SwiftUI

typealias SettingItemEnabledFunction<I> = (_ item: I, _ isEnabled: Bool) -> Void

final class NewTabPageSettingsModel<SettingItem: NewTabPageSettingsStorageItem, Storage: NewTabPageSettingsStorage>: ObservableObject where Storage.SettingItem == SettingItem {

    /// Settings page settings collection with bindings
    @Published private(set) var itemsSettings: [NTPSetting<SettingItem>] = []

    private var filteredItemsOrder: [SettingItem] = []

    /// Enabled items, ordered.
    @Published private(set) var enabledItems: [SettingItem] = []

    private var indexMapping: [Int: Int] = [:]

    private let settingsStorage: Storage
    private let visibilityFilter: ((SettingItem) -> Bool)
    private let onItemEnabled: SettingItemEnabledFunction<SettingItem>?
    private let onItemReordered: (() -> Void)?

    init(settingsStorage: Storage,
         onItemEnabled: SettingItemEnabledFunction<SettingItem>? = nil,
         onItemReordered: (() -> Void)? = nil,
         visibilityFilter: @escaping ((SettingItem) -> Bool) = { _ in true }) {
        self.settingsStorage = settingsStorage
        self.visibilityFilter = visibilityFilter
        self.onItemEnabled = onItemEnabled
        self.onItemReordered = onItemReordered

        updatePublishedValues()
    }

    func moveItems(from: IndexSet, to: Int) {
        let from = mapIndexSet(from)

        // If index is not found it means we're moving to the end.
        // Guard index range in case there's no filtering.
        let to = indexMapping[to] ?? min(settingsStorage.itemsOrder.count, to + 1)

        settingsStorage.moveItems(from, toOffset: to)
        updatePublishedValues()

        onItemReordered?()
    }

    func save() {
        settingsStorage.save()
    }

    private func updatePublishedValues() {
        populateSettings()
        populateEnabledItems()
    }

    private func populateEnabledItems() {
        enabledItems = filteredItemsOrder.filter(settingsStorage.isEnabled(_:))
    }

    private func populateSettings() {
        let allItemsOrder = settingsStorage.itemsOrder
        filteredItemsOrder = allItemsOrder.filter(visibilityFilter)
        
        itemsSettings = filteredItemsOrder.compactMap { item in
            return NTPSetting(item: item,
                              isEnabled: Binding(get: { [weak self] in
                self?.settingsStorage.isEnabled(item) ?? false
            }, set: { [weak self] newValue in
                self?.onItemEnabled?(item, newValue)
                self?.settingsStorage.setItem(item, enabled: newValue)
                self?.updatePublishedValues()
            }))
        }

        for (index, item) in allItemsOrder.enumerated() {
            if let filteredIndex = filteredItemsOrder.firstIndex(of: item) {
                 indexMapping[filteredIndex] = index
             }
        }
    }

    private func mapIndexSet(_ indexSet: IndexSet) -> IndexSet {
        let mappedIndices = indexSet.compactMap { index in
            indexMapping[index]
        }

        return IndexSet(mappedIndices)
    }
}

extension NewTabPageSettingsModel {
    struct NTPSetting<Item> {
        let item: Item
        let isEnabled: Binding<Bool>
    }
}
