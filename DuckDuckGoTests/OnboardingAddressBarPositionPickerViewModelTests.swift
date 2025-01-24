//
//  OnboardingAddressBarPositionPickerViewModelTests.swift
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

final class OnboardingAddressBarPositionPickerViewModelTests: XCTestCase {
    private var addressBarPositionManagerMock: AddressBarPositionManagerMock!

    override func setUpWithError() throws {
        addressBarPositionManagerMock = AddressBarPositionManagerMock()
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        addressBarPositionManagerMock = nil
        try super.tearDownWithError()
    }

    func testWhenInitThenDisplayModelsAreCorrect() throws {
        // GIVEN
        addressBarPositionManagerMock.currentAddressBarPosition = .top
        let sut = OnboardingAddressBarPositionPickerViewModel(addressBarPositionManager: addressBarPositionManagerMock)

        // WHEN
        let items = sut.items

        // THEN
        let firstItem = try XCTUnwrap(items.first)
        XCTAssertEqual(firstItem.type, .top)
        XCTAssertEqual(firstItem.title.string, UserText.Onboarding.AddressBarPosition.topTitle + " " + UserText.Onboarding.AddressBarPosition.defaultOption)
        XCTAssertEqual(firstItem.message, UserText.Onboarding.AddressBarPosition.topMessage)
        XCTAssertEqual(firstItem.icon, .addressBarTop)
        XCTAssertTrue(firstItem.isSelected)

        let secondItem = try XCTUnwrap(items.last)
        XCTAssertEqual(secondItem.type, .bottom)
        XCTAssertEqual(secondItem.title.string, UserText.Onboarding.AddressBarPosition.bottomTitle)
        XCTAssertEqual(secondItem.message, UserText.Onboarding.AddressBarPosition.bottomMessage)
        XCTAssertEqual(secondItem.icon, .addressBarBottom)
        XCTAssertFalse(secondItem.isSelected)
    }

    func testWhenUpdateAddressBarThenDisplayModelsAreUpdated() throws {
        // GIVEN
        addressBarPositionManagerMock.currentAddressBarPosition = .top
        let sut = OnboardingAddressBarPositionPickerViewModel(addressBarPositionManager: addressBarPositionManagerMock)
        XCTAssertEqual(sut.items.first?.type, .top)
        XCTAssertTrue(sut.items.first?.isSelected ?? false)

        // WHEN
        sut.setAddressBar(position: .bottom)

        // THEN
        XCTAssertEqual(addressBarPositionManagerMock.currentAddressBarPosition, .bottom)
        
        let items = sut.items
        let firstItem = try XCTUnwrap(items.first)
        XCTAssertEqual(firstItem.type, .top)
        XCTAssertEqual(firstItem.title.string, UserText.Onboarding.AddressBarPosition.topTitle + " " + UserText.Onboarding.AddressBarPosition.defaultOption)
        XCTAssertEqual(firstItem.message, UserText.Onboarding.AddressBarPosition.topMessage)
        XCTAssertEqual(firstItem.icon, .addressBarTop)
        XCTAssertFalse(firstItem.isSelected)

        let secondItem = try XCTUnwrap(items.last)
        XCTAssertEqual(secondItem.type, .bottom)
        XCTAssertEqual(secondItem.title.string, UserText.Onboarding.AddressBarPosition.bottomTitle)
        XCTAssertEqual(secondItem.message, UserText.Onboarding.AddressBarPosition.bottomMessage)
        XCTAssertEqual(secondItem.icon, .addressBarBottom)
        XCTAssertTrue(secondItem.isSelected)
    }

}

private class AddressBarPositionManagerMock: AddressBarPositionManaging {
    var currentAddressBarPosition: AddressBarPosition = .top
}
