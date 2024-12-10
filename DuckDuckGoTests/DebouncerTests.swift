//
//  DebouncerTests.swift
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

final class DebouncerTests: XCTestCase {
    private var sut: Debouncer!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = Debouncer()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testWhenDebounceThenTriggerBlockAfterDueTime() {
        // GIVEN
        let expectation = expectation(description: #function)

        // WHEN
        sut.debounce(for: 0.05) {
            // THEN
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testWhenCancelThenCancelBlockExecution() {
        // GIVEN
        let expectation = expectation(description: #function)
        expectation.isInverted = true
        sut.debounce(for: 0.03) {
            // THEN
            expectation.fulfill()
        }

        // WHEN
        sut.cancel()

        wait(for: [expectation], timeout: 1.0)
    }

    func testWhenDebounceTwoBlocksThenCancelFirstTaskWhenSecondBlockIsScheduled() {
        // GIVEN
        let firstTaskExpectation = expectation(description: "FirstTask Completion")
        firstTaskExpectation.isInverted = true

        let secondTaskExpectation = expectation(description: "Second Task Completion")

        // WHEN
        sut.debounce(for: 0.05) {
            firstTaskExpectation.fulfill()
        }
        sut.debounce(for: 0.02) {
            secondTaskExpectation.fulfill()
        }

        wait(for: [firstTaskExpectation, secondTaskExpectation], timeout: 1.0)
    }
}
