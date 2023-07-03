//
//  APIHeadersTests.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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
import Networking
@testable import Common
@testable import Core

class APIHeadersTests: XCTestCase {

    func testWhenHeadersRequestedThenHeadersContainUserAgent() {
        APIRequest.Headers.setUserAgent(DefaultUserAgentManager.duckduckGoUserAgent(for: makeAppVersion()))
        let testee = APIRequest.Headers()
        let expected = "ddg_ios/7.0.4.5 (com.duckduckgo.mobile.ios; iOS \(UIDevice.current.systemVersion))"
        let actual = testee.httpHeaders[APIRequest.HTTPHeaderField.userAgent]
        XCTAssertEqual(expected, actual)
    }

    func testWhenProvidingEtagThenHeadersContainsIfNoneMatchHeader() {
        APIRequest.Headers.setUserAgent(DefaultUserAgentManager.duckduckGoUserAgent(for: makeAppVersion()))
        let expected = "etag"
        let testee = APIRequest.Headers(etag: expected)
        XCTAssertEqual(expected, testee.httpHeaders[APIRequest.HTTPHeaderField.ifNoneMatch])
    }

    func makeAppVersion() -> AppVersion {
        let mockBundle = MockBundle()
        mockBundle.add(name: Bundle.Key.identifier, value: "com.duckduckgo.mobile.ios")
        mockBundle.add(name: Bundle.Key.versionNumber, value: "7.0.4")
        mockBundle.add(name: Bundle.Key.buildNumber, value: "5")
        return AppVersion(bundle: mockBundle)
    }

}
