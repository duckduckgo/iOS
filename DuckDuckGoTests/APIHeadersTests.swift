//
//  APIHeadersTests.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//
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

import Foundation
import XCTest
@testable import Core

class APIHeadersTests: XCTestCase {

    func testWhenHeadersRequestedThenHeadersContainUserAgent() {
        let testee = APIHeaders(appVersion: appVersion())
        let expected = "ddg_ios/7.0.4.5 (com.duckduckgo.mobile.ios; iOS \(UIDevice.current.systemVersion))"
        let actual = testee.defaultHeaders[APIHeaders.Name.userAgent]
        XCTAssertEqual(expected, actual)
    }

    func testWhenProvidingEtagThenHeadersContainsIfNoneMatchHeader() {
        let testee = APIHeaders(appVersion: appVersion())
        let expected = "etag"
        let headers = testee.defaultHeaders(with: expected)
        XCTAssertEqual(expected, headers[APIHeaders.Name.ifNoneMatch])
    }

    func appVersion() -> AppVersion {
        let mockBundle = MockBundle()
        mockBundle.add(name: AppVersion.Keys.identifier, value: "com.duckduckgo.mobile.ios")
        mockBundle.add(name: AppVersion.Keys.versionNumber, value: "7.0.4")
        mockBundle.add(name: AppVersion.Keys.buildNumber, value: "5")
        return AppVersion(bundle: mockBundle)
    }

}
