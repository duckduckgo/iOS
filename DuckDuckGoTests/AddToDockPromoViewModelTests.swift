//
//  AddToDockPromoViewModelTests.swift
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
import Lottie
@testable import DuckDuckGo

final class AddToDockPromoViewModelTests: XCTestCase {
    private var sut: AddToDockPromoViewModel!
    private var managerMock: AppIconManagerMock!

    override func setUpWithError() throws {
        try super.setUpWithError()

        managerMock = .init()
        sut = .init(appIconManager: managerMock)
    }

    override func tearDownWithError() throws {
        managerMock = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testWhenColorIsCalledThenReturnExpectedColor() {
        // GIVEN
        managerMock.appIcon = .red

        // WHEN
        var result = sut.color

        // THEN
        XCTAssertEqual(result, LottieColor(r: 0.87, g: 0.34, b: 0.2, a: 1.0))

        // GIVEN
        managerMock.appIcon = .yellow

        // WHEN
        result = sut.color

        // THEN
        XCTAssertEqual(result, LottieColor(r: 0.89, g: 0.64, b: 0.07, a: 1.0))

        // GIVEN
        managerMock.appIcon = .green

        // WHEN
        result = sut.color

        // THEN
        XCTAssertEqual(result, LottieColor(r: 0.22, g: 0.62, b: 0.16, a: 1.0))

        // GIVEN
        managerMock.appIcon = .blue

        // WHEN
        result = sut.color

        // THEN
        XCTAssertEqual(result, LottieColor(r: 0.22, g: 0.41, b: 0.94, a: 1.0))

        // GIVEN
        managerMock.appIcon = .purple

        // WHEN
        result = sut.color

        // THEN
        XCTAssertEqual(result, LottieColor(r: 0.42, g: 0.31, b: 0.73, a: 1.0))

        // GIVEN
        managerMock.appIcon = .black

        // WHEN
        result = sut.color

        // THEN
        XCTAssertEqual(result, LottieColor(r: 0, g: 0, b: 0, a: 1.0))
    }

}
