//
//  SupportedExternalUrlSchemeTests.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

class ExternalUrlSchemeTests: XCTestCase {

    func testThatEmailIsSupported() {
        let url = URL(string: "mailto://someurl")!
        XCTAssertEqual(ExternalSchemeHandler.schemeType(for: url),
                       ExternalSchemeHandler.SchemeType.external(.askForConfirmation))
    }

    func testThatSmsIsSupported() {
        let url = URL(string: "sms://someurl")!
        XCTAssertEqual(ExternalSchemeHandler.schemeType(for: url),
        ExternalSchemeHandler.SchemeType.external(.askForConfirmation))
    }

    func testThatMapsAreSupported() {
        let url = URL(string: "maps://someurl")!
        XCTAssertEqual(ExternalSchemeHandler.schemeType(for: url),
                       ExternalSchemeHandler.SchemeType.external(.open))
    }

    func testThatCallsAreSupported() {
        let url = URL(string: "tel://someurl")!
        XCTAssertEqual(ExternalSchemeHandler.schemeType(for: url),
                       ExternalSchemeHandler.SchemeType.external(.open))
    }

    func testThatUrlsWithNoSchemeAreNotSupported() {
        let url = URL(string: "telzzz")!
        XCTAssertEqual(ExternalSchemeHandler.schemeType(for: url),
                       ExternalSchemeHandler.SchemeType.other)
    }

    func testThatUnknownSchemesAreNotSupported() {
        let url = URL(string: "other://")!
        XCTAssertEqual(ExternalSchemeHandler.schemeType(for: url),
                       ExternalSchemeHandler.SchemeType.other)
    }
    
    func testThatAboutSchemesAreAllowed() {
        let url = URL(string: "about:blank")!
        XCTAssertNotEqual(ExternalSchemeHandler.schemeType(for: url),
                       ExternalSchemeHandler.SchemeType.external(.cancel))
    }
}
