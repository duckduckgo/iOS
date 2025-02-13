//
//  QuerySubmittedTests.swift
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
import Suggestions

@testable import DuckDuckGo

class QuerySubmittedTests: XCTestCase {
    let mock = MockOmniBarDelegate()
    let sut = OmniBar.loadFromXib(dependencies: MockOmnibarDependency(voiceSearchHelper: MockVoiceSearchHelper(isSpeechRecognizerAvailable: true, voiceSearchEnabled: true)))

    override func setUp() {
        super.setUp()
        sut.omniDelegate = mock
    }

    override func tearDown() {
        mock.clear()
        super.tearDown()
    }

    func testValidAddressSubmissions() {
        let validQueries = [
            ("www.test.com", "http://www.test.com"),
            ("http://example.com/path?query=123", "http://example.com/path?query=123"),
            (" www.test.com ", "http://www.test.com")
        ]

        for (query, expected) in validQueries {
            assertQuerySubmission(query: query, expected: expected)
        }
    }

    func testInvalidAddressSubmissions() {
        let invalidQueries = [
            "16385-12228.75",
            "invalid-url",
            "http://[::1]:80",
            "12345"
        ]

        for query in invalidQueries {
            assertQuerySubmission(query: query, expected: query)
        }
    }

    func testSuggestionSelectionCallsDelegate() {
        mock.suggestion = .website(url: URL(string: "www.testing.com")!)

        sut.onQuerySubmitted()

        XCTAssertTrue(mock.wasOnOmniSuggestionSelectedCalled)
        XCTAssertFalse(mock.wasOnOmniQuerySubmittedCalled)
    }

    func testEmptyQueryDoesNotCallDelegate() {
        sut.textField.text = ""
        sut.onQuerySubmitted()

        XCTAssertFalse(mock.wasOnOmniQuerySubmittedCalled)
        XCTAssertFalse(mock.wasOnOmniSuggestionSelectedCalled)
    }

    func testBlankQueryDoesNotCallDelegate() {
        sut.textField.text = "   "
        sut.onQuerySubmitted()

        XCTAssertFalse(mock.wasOnOmniQuerySubmittedCalled)
        XCTAssertFalse(mock.wasOnOmniSuggestionSelectedCalled)
    }

    // MARK: - Helper Methods

    private func assertQuerySubmission(query: String, expected: String) {
        sut.textField.text = query
        sut.onQuerySubmitted()

        XCTAssertEqual(mock.query, expected)
        XCTAssertFalse(mock.wasOnOmniSuggestionSelectedCalled)
    }
}

final class MockOmniBarDelegate: OmniBarDelegate {
    var query: String = ""
    var suggestion: Suggestion?
    var wasOnOmniQuerySubmittedCalled = false
    var wasOnOmniSuggestionSelectedCalled = false

    func onOmniQuerySubmitted(_ query: String) {
        wasOnOmniQuerySubmittedCalled = true
        self.query = query
    }

    func onOmniSuggestionSelected(_ suggestion: Suggestion) {
        wasOnOmniSuggestionSelectedCalled = true
    }

    func clear() {
        query = ""
        suggestion = nil
        wasOnOmniQuerySubmittedCalled = false
        wasOnOmniSuggestionSelectedCalled = false
    }

    func selectedSuggestion() -> Suggestion? {
        return suggestion
    }

    // MARK: - Unused methods

    func onAbortPressed() {
    }

    func onEditingEnd() -> OmniBarEditingEndResult {
        return .dismissed
    }

    func onClearPressed() {
    }

    func onEnterPressed() {
    }

    func onVoiceSearchPressed() {
    }

    func onTextFieldWillBeginEditing(_ omniBar: DuckDuckGo.OmniBar, tapped: Bool) {
    }

    func onTextFieldDidBeginEditing(_ omniBar: DuckDuckGo.OmniBar) -> Bool {
        return false
    }
    func onBackPressed() {
    }

    func onForwardPressed() {
    }

    func onDidBeginEditing() { }

    func onDidEndEditing() { }
}
