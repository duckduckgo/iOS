//
//  NewTabPageSectionsSettingsModelTests.swift
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
@testable import Core
@testable import DuckDuckGo

final class NewTabPageSectionsSettingsModelTests: XCTestCase {

    override func tearDown() {
        PixelFiringMock.tearDown()
    }

    func testFiresPixelWhenItemEnabled() {
        let sut = createSUT()

        let setting = sut.itemsSettings.first { setting in
            setting.item == .favorites
        }

        setting?.isEnabled.wrappedValue = true

        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.newTabPageCustomizeSectionOn("favorites").name)
    }

    func testFiresPixelWhenItemDisabled() {
        let sut = createSUT()

        let setting = sut.itemsSettings.first { setting in
            setting.item == .favorites
        }

        setting?.isEnabled.wrappedValue = false

        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.newTabPageCustomizeSectionOff("favorites").name)
    }

    func testFiresPixelWhenItemReordered() {
        let sut = createSUT()

        sut.moveItems(from: IndexSet(integer: 0), to: 1)

        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.newTabPageSectionReordered.name)
    }

    private func createSUT() -> NewTabPageSectionsSettingsModel {
        let storage = NewTabPageSectionsSettingsStorage(
            persistentStore: NewTabPageSettingsPersistentStoreMock(),
            defaultOrder: NewTabPageSection.allCases,
            defaultEnabledItems: NewTabPageSection.allCases
        )

        return NewTabPageSectionsSettingsModel(storage: storage, pixelFiring: PixelFiringMock.self)
    }
}

final class NewTabPageSettingsPersistentStoreMock: NewTabPageSettingsPersistentStore {
    var data: Data?
}
