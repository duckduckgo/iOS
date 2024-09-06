//
//  AppIconPickerViewModelTests.swift
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

final class AppIconPickerViewModelTests: XCTestCase {
    private var sut: AppIconPickerViewModel!
    private var appIconManagerMock: AppIconManagerMock!

    @MainActor
    override func setUpWithError() throws {
        try super.setUpWithError()

        appIconManagerMock = AppIconManagerMock()
        sut = AppIconPickerViewModel(appIconManager: appIconManagerMock)
    }

    override func tearDownWithError() throws {
        appIconManagerMock = nil
        sut = nil
        try super.tearDownWithError()
    }

    @MainActor
    func testWhenItemsIsCalledThenIconsAreReturned() {
        // GIVEN
        let expectedIcons: [AppIcon] = [.red, .yellow, .green, .blue, .purple, .black]

        // WHEN
        let result = sut.items

        // THEN
        XCTAssertEqual(result.map(\.icon), expectedIcons)
    }

    @MainActor
    func testWhenInitThenSelectedAppIconIsReturned() {
        // GIVEN
        appIconManagerMock.appIcon = .purple
        sut = AppIconPickerViewModel(appIconManager: appIconManagerMock)

        // WHEN
        let result = sut.items

        // THEN
        XCTAssertEqual(result.count, AppIcon.allCases.count)
        assertSelected(.purple, items: result)
    }

    @MainActor
    func testWhenChangeAppIconIsCalledAndManagerFailsThenSelectedAppIconIsNotUpdated() {
        // GIVEN
        appIconManagerMock.appIcon = .red
        appIconManagerMock.changeAppIconError = NSError(domain: #function, code: 0)
        assertSelected(.red, items: sut.items)

        // WHEN
        sut.changeApp(icon: .purple)

        // THEN
        assertSelected(.red, items: sut.items)
    }

    @MainActor
    func testWhenChangeAppIconIsCalledThenShouldAskAppIconManagerToChangeAppIcon() {
        // GIVEN
        XCTAssertFalse(appIconManagerMock.didCallChangeAppIcon)
        XCTAssertNil(appIconManagerMock.capturedAppIcon)

        // WHEN
        sut.changeApp(icon: .purple)

        // THEN
        XCTAssertTrue(appIconManagerMock.didCallChangeAppIcon)
        XCTAssertEqual(appIconManagerMock.capturedAppIcon, .purple)
    }

    private func assertSelected(_ appIcon: AppIcon, items: [AppIconPickerViewModel.DisplayModel]) {
        items.forEach { model in
            if model.icon == appIcon {
                XCTAssertTrue(model.isSelected)
            } else {
                XCTAssertFalse(model.isSelected)
            }
        }
    }
}

final class AppIconManagerMock: AppIconManaging {
    private(set) var didCallChangeAppIcon = false
    private(set) var capturedAppIcon: AppIcon?

    var appIcon: DuckDuckGo.AppIcon = .red

    var changeAppIconError: Error?

    func changeAppIcon(_ appIcon: AppIcon, completionHandler: (((any Error)?) -> Void)?) {
        didCallChangeAppIcon = true
        capturedAppIcon = appIcon

        if let changeAppIconError {
            completionHandler?(changeAppIconError)
        } else {
            completionHandler?(nil)
        }
    }

}
