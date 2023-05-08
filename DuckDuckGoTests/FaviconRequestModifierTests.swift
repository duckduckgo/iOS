//
//  FaviconRequestModifierTests.swift
//  UnitTests
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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
@testable import Core

class MockEmbeddedDataProvider: EmbeddedDataProvider {
    var embeddedDataEtag: String

    var embeddedData: Data

    init(data: Data, etag: String) {
        embeddedData = data
        embeddedDataEtag = etag
    }
}

class FaviconRequestModifierTests: XCTestCase {
    
    let testConfig = """
    {
        "features": {
            "customUserAgent": {
                "state": "enabled",
                "settings": {
                    "omitApplicationSites": [
                        {
                            "domain": "cvs.com",
                            "reason": "Site breakage"
                        }
                    ]
                },
                "exceptions": []
            }
        },
        "unprotectedTemporary": []
    }
    """.data(using: .utf8)!
    
    private var userAgentManager: UserAgentManager!
    
    override func setUp() {
        super.setUp()
        
        let mockEmbeddedData = MockEmbeddedDataProvider(data: testConfig, etag: "test")
        let mockProtectionStore = MockDomainsProtectionStore()

        let manager = PrivacyConfigurationManager(fetchedETag: nil,
                                                  fetchedData: nil,
                                                  embeddedDataProvider: mockEmbeddedData,
                                                  localProtection: mockProtectionStore,
                                                  internalUserDecider: DefaultInternalUserDecider())

        let config = manager.privacyConfig
        
        userAgentManager = MockUserAgentManager(privacyConfig: config)
    }
    
    func test() {
        let request = URLRequest(url: URL(string: "https://www.example.com")!)
        let result = FaviconRequestModifier(userAgentManager: userAgentManager).modified(for: request)
        XCTAssertTrue(result?.allHTTPHeaderFields?["User-Agent"]?.contains("DuckDuckGo") ?? false)
    }
    
}
