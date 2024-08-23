//
//  NewTabPageShortcutsSettingsStorageTests.swift
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

import XCTest
@testable import DuckDuckGo

final class NewTabPageSettingsModelTests: XCTestCase {

    private let storage = StorageMock(itemsOrder: SettingsItemMock.allCases)

    func testFiltersSettingsUsingProvidedFilter() {
        let sut = createSUT { item in
            item != .two
        }

        XCTAssertFalse(sut.enabledItems.contains(.two))
    }

    func testMovingReordersFullSet() {
        let sut = createSUT { item in
            item != .two
        }

        sut.moveItems(from: IndexSet(integer: 0), to: 1)

        XCTAssertEqual(storage.itemsOrder, [.two, .one, .three])
    }

    func testMovingItemToEndWhenNoFilter() {
        let sut = createSUT()

        sut.moveItems(from: IndexSet(integer: 0), to: 3)

        XCTAssertEqual(storage.itemsOrder, [.two, .three, .one])
    }

    func testMovingItemToEndWhenFiltered() {
        let sut = createSUT { item in
            item != .two
        }

        sut.moveItems(from: IndexSet(integer: 0), to: 2)

        XCTAssertEqual(storage.itemsOrder, [.two, .three, .one])
    }

    func testMovingToStartWhenFiltered() {
        let sut = createSUT { item in
            item != .one
        }

        sut.moveItems(from: IndexSet(integer: 1), to: 0)

        XCTAssertEqual(storage.itemsOrder, [.one, .three, .two])
    }

    func testItemsSettingsAreFiltered() {
        let sut = createSUT { item in
            item != .one
        }

        XCTAssertEqual(sut.itemsSettings.map(\.item), [.two, .three])
    }

    func testEnabledItemsAreFiltered() {
        let sut = createSUT { item in
            item != .one
        }

        XCTAssertEqual(sut.enabledItems, [.two, .three])
    }

    private func createSUT(filter: @escaping (SettingsItemMock) -> Bool = { _ in true }) -> NewTabPageSettingsModel<SettingsItemMock, StorageMock> {
        NewTabPageSettingsModel(settingsStorage: storage, visibilityFilter: filter)
    }
}

private final class StorageMock: NewTabPageSettingsStorage {
    var itemsOrder: [SettingsItemMock]

    init(itemsOrder: [SettingsItemMock]) {
        self.itemsOrder = itemsOrder
    }

    func isEnabled(_ item: SettingsItemMock) -> Bool {
        return true
    }

    func setItem(_ item: SettingsItemMock, enabled: Bool) {

    }

    func moveItems(_ fromOffsets: IndexSet, toOffset: Int) {
        itemsOrder.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }

    func save() {
    }
}

private enum SettingsItemMock: CaseIterable, NewTabPageSettingsStorageItem {
    case one
    case two
    case three
}
