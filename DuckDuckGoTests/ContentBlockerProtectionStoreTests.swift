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
@testable import DuckDuckGo

class ContentBlockerProtectionStoreTests: XCTestCase {

    func testWhenCheckingDomainsAreProtected_ThenUsesPersistedUnprotectedDomainList() throws {
        let configFile =
        """
        {
            "features": {},
            "unprotectedTemporary": [
                    { "domain": "domain1.com" },
                    { "domain": "domain2.com" },
                    { "domain": "domain3.com" },
            ]
        }
        """.data(using: .utf8)!
        try FileStore().persist(configFile, for: .privacyConfiguration)
        // swiftlint:disable:next force_cast
        let privacyConfigurationManager = ContentBlocking.shared.privacyConfigurationManager as! PrivacyConfigurationManager
        XCTAssertEqual(privacyConfigurationManager.embeddedConfigData.etag,
                       AppPrivacyConfigurationDataProvider.Constants.embeddedDataETag)
        XCTAssertEqual(privacyConfigurationManager.reload(etag: "new etag", data: configFile), .downloaded)

        let newConfig = privacyConfigurationManager.fetchedConfigData
        XCTAssertNotNil(newConfig)

        if let newConfig = newConfig {
            XCTAssertEqual(newConfig.etag, "new etag")
            let config = AppPrivacyConfiguration(data: newConfig.data,
                                                 identifier: "",
                                                 localProtection: DomainsProtectionUserDefaultsStore(),
                                                 internalUserDecider: DefaultInternalUserDecider())

            XCTAssertFalse(config.isTempUnprotected(domain: "main1.com"))
            XCTAssertFalse(config.isTempUnprotected(domain: "notdomain1.com"))
            XCTAssertTrue(config.isTempUnprotected(domain: "domain1.com"))

            XCTAssertTrue(config.isTempUnprotected(domain: "www.domain1.com"))
        }
    }

}
