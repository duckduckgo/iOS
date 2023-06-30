//
//  ContentBlockerProtectionStoreTests.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

class ContentBlockerProtectionStoreTests: XCTestCase {

    func testWhenCheckingDomainsAreProtected_ThenUsesPersistedUnprotectedDomainList() {
        let configFile = makeConfigurationFile(domains: ["domain1.com", "domain2.com"])
        let privacyConfigurationManager = makePrivateConfigurationManager()

        privacyConfigurationManager.reload(etag: "new etag", data: configFile)
        let newConfig = privacyConfigurationManager.fetchedConfigData!
        let privacyConfig = privacyConfiguration(newConfig.data)

        XCTAssertEqual(newConfig.etag, "new etag")
        XCTAssertTrue(privacyConfig.isTempUnprotected(domain: "www.domain1.com"))
        XCTAssertTrue(privacyConfig.isTempUnprotected(domain: "www.domain2.com"))
        XCTAssertFalse(privacyConfig.isTempUnprotected(domain: "www.domain3.com"))
        XCTAssertTrue(privacyConfig.isTempUnprotected(domain: "domain1.com"))
        XCTAssertTrue(privacyConfig.isTempUnprotected(domain: "domain2.com"))
        XCTAssertFalse(privacyConfig.isTempUnprotected(domain: "domain3.com"))
    }

    // MARK: - Helpers

    private func makePrivateConfigurationManager() -> PrivacyConfigurationManager {
        // swiftlint:disable:next force_cast
        ContentBlocking.shared.privacyConfigurationManager as! PrivacyConfigurationManager
    }

    private func privacyConfiguration(_ data: PrivacyConfigurationData) -> AppPrivacyConfiguration {
        AppPrivacyConfiguration(data: data,
                                identifier: "",
                                localProtection: DomainsProtectionUserDefaultsStore(),
                                internalUserDecider: DefaultInternalUserDecider())
    }

    private func makeConfigurationFile(domains: [String]) -> Data {
        """
        {
            "features": {},
            "unprotectedTemporary": [
                    { "domain": "\(domains[0])" },
                    { "domain": "\(domains[1])" },
            ]
        }
        """.data(using: .utf8)!
    }
}
