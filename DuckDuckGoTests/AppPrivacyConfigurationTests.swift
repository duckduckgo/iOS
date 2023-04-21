//
//  AppPrivacyConfigurationTests.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import BrowserServicesKit

class AppPrivacyConfigurationTests: XCTestCase {

    func testWhenEmbeddedDataIsUpdatedThenUpdateSHAAndEtag() {

        let data = AppPrivacyConfigurationDataProvider.loadEmbeddedAsData()

        XCTAssertEqual(data.sha256,
                       AppPrivacyConfigurationDataProvider.Constants.embeddedDataSHA,
                       "Error: please update SHA and ETag when changing embedded config")
    }
    
    func testWhenEmbeddedDataIsUsedThenItCanBeParsed() throws {
        
        let provider = AppPrivacyConfigurationDataProvider()
        
        let jsonData = provider.embeddedData
        let configData = try PrivacyConfigurationData(data: jsonData)

        let config = AppPrivacyConfiguration(data: configData,
                                             identifier: "",
                                             localProtection: MockDomainsProtectionStore(),
                                             internalUserDecider: DefaultInternalUserDecider(store: InternalUserStore()))
        
        XCTAssert(config.isEnabled(featureKey: .contentBlocking))
        
    }

}
