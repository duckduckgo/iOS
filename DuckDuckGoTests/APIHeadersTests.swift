//
//  APIHeadersTests.swift
//  DuckDuckGo
//
//  Created by duckduckgo on 15/05/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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
    
    func appVersion() -> AppVersion {
        let mockBundle = MockBundle()
        mockBundle.add(name: AppVersion.Keys.identifier, value: "com.duckduckgo.mobile.ios")
        mockBundle.add(name: AppVersion.Keys.versionNumber, value: "7.0.4")
        mockBundle.add(name: AppVersion.Keys.buildNumber, value: "5")
        return AppVersion(bundle: mockBundle)
    }

}
