//
//  AppConfigurationURLProviderTests.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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
import BrowserServicesKit
import Configuration
@testable import DuckDuckGo

final class AppConfigurationURLProviderTests: XCTestCase {
    private var urlProvider: AppConfigurationURLProvider!
    private var mockTdsURLProvider: MockTrackerDataURLProvider!
    let controlURL = "control/url.json"
    let treatmentURL = "treatment/url.json"

    override func setUp() {
        super.setUp()
        mockTdsURLProvider = MockTrackerDataURLProvider()
        urlProvider = AppConfigurationURLProvider(trackerDataUrlProvider: mockTdsURLProvider)
    }

    override func tearDown() {
        urlProvider = nil
        mockTdsURLProvider = nil
        super.tearDown()
    }

    func testUrlForTrackerDataIsDefaultWhenTdsUrlProviderUrlIsNil() {
        // GIVEN
        mockTdsURLProvider.trackerDataURL = nil

        // WHEN
        let url = urlProvider.url(for: .trackerDataSet)

        // THEN
        XCTAssertEqual(url, URL.trackerDataSet)
    }

    func testUrlForTrackerDataIsTheOneProvidedByTdsUrlProvider() {
        // GIVEN
        let expectedURL = URL(string: "https://someurl.com")!
        mockTdsURLProvider.trackerDataURL = expectedURL

        // WHEN
        let url = urlProvider.url(for: .trackerDataSet)

        // THEN
        XCTAssertEqual(url, expectedURL)
    }

}

class MockTrackerDataURLProvider: TrackerDataURLProviding {
    var trackerDataURL: URL?
}
