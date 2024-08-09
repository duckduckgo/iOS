//
//  NewTabPageModelTests.swift
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

final class NewTabPageModelTests: XCTestCase {

    let appSettings = AppSettingsMock()

    func testDoesNotShowIntroIfSettingUndefined() {
        let sut = NewTabPageModel(appSettings: appSettings)

        XCTAssertFalse(sut.isIntroMessageVisible)
    }

    func testShowsIntroMessage() {
        appSettings.newTabPageIntroMessageEnabled = true
        let sut = NewTabPageModel(appSettings: appSettings)

        XCTAssertTrue(sut.isIntroMessageVisible)
    }

    func testDisablesIntroMessageWhenDismissed() {
        appSettings.newTabPageIntroMessageEnabled = true
        let sut = NewTabPageModel(appSettings: appSettings)

        sut.dismissIntroMessage()

        XCTAssertFalse(sut.isIntroMessageVisible)
        XCTAssertEqual(appSettings.newTabPageIntroMessageEnabled, false)
    }

    func testDisablesIntroMessageAfterMultipleImpressions() {
        appSettings.newTabPageIntroMessageEnabled = true
        let sut = NewTabPageModel(appSettings: appSettings)

        for i in 1...3 {
            sut.increaseIntroMessageCounter()
        }

        XCTAssertTrue(sut.isIntroMessageVisible) // We want to keep the message visible on last occurence
        XCTAssertEqual(appSettings.newTabPageIntroMessageEnabled, false)
    }
}
