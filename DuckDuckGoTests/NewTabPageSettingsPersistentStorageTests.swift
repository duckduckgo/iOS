//
//  NewTabPageSettingsPersistentStorageTests.swift
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

final class NewTabPageSettingsPersistentStorageTests: XCTestCase {

    private var settingsPersistentStore = NewTabPageSettingsPersistentStoreMock()

    func testLoadsInitialStateFromDefaults() {
        let sut = createSUT()

        XCTAssertEqual(sut.itemsOrder, Constant.defaultItems)
        XCTAssertEqual(sut.enabledItems, Constant.defaultItems)
    }

    func testUsesDefaultsIfDataCorrupted() {
        let sut = createSUT()

        settingsPersistentStore.data = "Random data".data(using: .utf8)

        XCTAssertEqual(sut.itemsOrder, Constant.defaultItems)
        XCTAssertEqual(sut.enabledItems, Constant.defaultItems)
    }

    func testDisableItem() {
        let sut = createSUT()

        sut.setItem(.one, enabled: false)

        XCTAssertFalse(sut.isEnabled(.one))
        XCTAssertFalse(sut.enabledItems.contains(.one))
    }

    func testEnableItem() {
        let sut = createSUT(defaultEnabledItems: [])

        sut.setItem(.one, enabled: true)

        XCTAssertTrue(sut.isEnabled(.one))
        XCTAssertTrue(sut.enabledItems.contains(.one))
    }

    func testSaveAndRestore() {
        var sut = createSUT(defaultOrder: [.three, .two, .one], defaultEnabledItems: [.two])

        sut.save()

        sut = createSUT()

        XCTAssertEqual(sut.enabledItems, [.two])
        XCTAssertEqual(sut.itemsOrder, [.three, .two, .one])
    }

    func testMove() {
        let sut = createSUT()

        sut.moveItems(IndexSet(integer: 0), toOffset: 2)

        XCTAssertEqual(sut.itemsOrder, [.two, .one, .three])
    }

    func testEnabledItemsPreserveOrder() {
        let order = [StorageItem.one, .three, .two]
        let sut = createSUT(defaultOrder: order)

        XCTAssertEqual(sut.enabledItems, order)

        sut.moveItems(IndexSet(integer: 0), toOffset: 2)

        XCTAssertEqual(sut.enabledItems, [.three, .one, .two])
    }

    private func createSUT(defaultOrder: [StorageItem] = Constant.defaultItems, defaultEnabledItems: [StorageItem] = Constant.defaultItems) -> NewTabPageSettingsPersistentStorage<StorageItem> {
        NewTabPageSettingsPersistentStorage<StorageItem>(persistentStore: settingsPersistentStore,
                                                         defaultOrder: defaultOrder,
                                                         defaultEnabledItems: defaultEnabledItems)
    }

    private enum Constant {
        static let defaultItems = [StorageItem.one, .two, .three]
    }
}

private enum StorageItem: NewTabPageSettingsStorageItem, CaseIterable {
    case one
    case two
    case three
}
