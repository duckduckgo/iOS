//
//  NewTabPageViewModelTests.swift
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

final class NewTabPageViewModelTests: XCTestCase {

    let introDataStorage = NewTabPageIntroDataStoringMock()

    override func tearDown() {
        PixelFiringMock.tearDown()
    }

    func testDoesNotShowIntroIfSettingUndefined() {
        let sut = NewTabPageViewModel(introDataStorage: introDataStorage)

        XCTAssertFalse(sut.isIntroMessageVisible)
    }

    func testShowsIntroMessage() {
        introDataStorage.newTabPageIntroMessageEnabled = true
        let sut = NewTabPageViewModel(introDataStorage: introDataStorage)

        XCTAssertTrue(sut.isIntroMessageVisible)
    }

    func testDisablesIntroMessageWhenDismissed() {
        introDataStorage.newTabPageIntroMessageEnabled = true
        let sut = NewTabPageViewModel(introDataStorage: introDataStorage)

        sut.dismissIntroMessage()

        XCTAssertFalse(sut.isIntroMessageVisible)
        XCTAssertEqual(introDataStorage.newTabPageIntroMessageEnabled, false)
    }

    func testDisablesIntroMessageAfterMultipleImpressions() {
        introDataStorage.newTabPageIntroMessageEnabled = true
        let sut = NewTabPageViewModel(introDataStorage: introDataStorage)

        for _ in 1...3 {
            sut.introMessageDisplayed()
        }

        XCTAssertTrue(sut.isIntroMessageVisible) // We want to keep the message visible on last occurence
        XCTAssertEqual(introDataStorage.newTabPageIntroMessageEnabled, false)
    }

    func testFiresPixelWhenIntroMessageDismissed() {
        let sut = NewTabPageViewModel(pixelFiring: PixelFiringMock.self)

        sut.dismissIntroMessage()

        XCTAssertEqual(Pixel.Event.newTabPageMessageDismissed.name, PixelFiringMock.lastPixelName)
    }

    func testFiresPixelWhenIntroMessageDisplayed() {
        let sut = NewTabPageViewModel(pixelFiring: PixelFiringMock.self)

        sut.introMessageDisplayed()

        XCTAssertEqual(Pixel.Event.newTabPageMessageDisplayed.name, PixelFiringMock.lastPixelName)
    }

    func testFiresPixelOnNewTabPageCustomize() {
        let sut = NewTabPageViewModel(pixelFiring: PixelFiringMock.self)

        sut.customizeNewTabPage()

        XCTAssertEqual(Pixel.Event.newTabPageCustomize.name, PixelFiringMock.lastPixelName)
    }
}
