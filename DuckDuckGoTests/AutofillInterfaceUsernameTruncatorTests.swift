//
//  AutofillInterfaceUsernameTruncatorTests.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

class AutofillInterfaceUsernameTruncatorTests: XCTestCase {

    func testWhenUsernameIsShorterThanMaxLengthThenNotTruncated() {
        let username = "daxTheDuck"
        let expectedUsername = "daxTheDuck"

        let result = AutofillInterfaceUsernameTruncator.truncateUsername(username, maxLength: 20)
        XCTAssertEqual(expectedUsername, result, "usernames should match")
    }

    func testWhenUsernameIsTheSameLengthAsMaxLengthThenNotTruncated() {
        let username = "daxTheDuck"
        let expectedUsername = "daxTheDuck"

        let result = AutofillInterfaceUsernameTruncator.truncateUsername(username, maxLength: 10)
        XCTAssertEqual(expectedUsername, result, "usernames should match")
    }

    func testWhenUsernameIsLongerThanMaxLengthThenTruncated() {
        let username = "daxTheDuckTheBestDuckYouCouldEverMeet"
        let expectedUsername = "daxTheDuckTheBest..."

        let result = AutofillInterfaceUsernameTruncator.truncateUsername(username, maxLength: 20)
        XCTAssertEqual(expectedUsername, result, "usernames should match")
    }

    func testWhenUsernameIsOneCharacterLongerThanMaxLengthThenTruncated() {
        let username = "daxTheDuck1"
        let expectedUsername = "daxTheD..."

        let result = AutofillInterfaceUsernameTruncator.truncateUsername(username, maxLength: 10)
        XCTAssertEqual(expectedUsername, result, "usernames should match")
    }

    func testWhenUsernameIsEmptyThenNotTruncated() {
        let username = ""
        let expectedUsername = ""

        let result = AutofillInterfaceUsernameTruncator.truncateUsername(username, maxLength: 20)
        XCTAssertEqual(expectedUsername, result, "usernames should match")
    }
}
