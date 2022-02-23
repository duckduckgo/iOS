//
//  SmarterEncryptionTests.swift
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

import Foundation
import XCTest
import BrowserServicesKit // to remove in BSK
import os.log
@testable import Core

struct HTTPSUpgradesRefTests: Decodable {
    struct HTTPSUpgradesTests: Decodable {
        let name: String
        let desc: String
        let tests: [HTTPSUpgradesTest]
    }
    
    struct HTTPSUpgradesTest: Decodable {
        let name: String
        let siteURL: String
        let requestURL: String
        let requestType: String
        let expectURL: String
        let exceptPlatforms: [String]
        
        var shouldSkip: Bool { exceptPlatforms.contains("ios-browser") }
    }
    
    let navigations: HTTPSUpgradesTests
    let subrequests: HTTPSUpgradesTests
}

// swiftlint:disable force_try
// swiftlint:disable force_cast
@available(iOS 14.0, *)
final class SmarterEncryptionTests: XCTestCase {
    
    private enum Resource {
        static let config = "privacy-reference-tests/https-upgrades/config_reference.json"
        static let tests = "privacy-reference-tests/https-upgrades/tests.json"
        static let allowList = "privacy-reference-tests/https-upgrades/https_allowlist_reference.json"
        static let bloomFilterSpec = "privacy-reference-tests/https-upgrades/https_bloomfilter_spec_reference.json"
        static let bloomFilter = "privacy-reference-tests/https-upgrades/https_bloomfilter_reference"
    }
    
    private let data = JsonTestDataLoader()
    
    private lazy var appConfig: PrivacyConfiguration = {
        let localProtection = MockDomainsProtectionStore()
        localProtection.unprotectedDomains = []
        
        let configJSON = data.fromJsonFile(Resource.config)
        let configDict = try! JSONSerialization.jsonObject(with: configJSON, options: []) as! [String: Any]
        let configData = PrivacyConfigurationData(json: configDict)
        return AppPrivacyConfiguration(data: configData, identifier: "", localProtection: localProtection)
    }()
    
    private lazy var httpsUpgradesTestSuite: HTTPSUpgradesRefTests = {
        let tests = data.fromJsonFile(Resource.tests)
        return try! JSONDecoder().decode(HTTPSUpgradesRefTests.self, from: tests)
    }()
    
    private lazy var excludedDomains: [String] = {
        let allowListData = data.fromJsonFile(Resource.allowList)
        return try! HTTPSUpgradeParser.convertExcludedDomainsData(allowListData)
    }()
    
    private lazy var bloomFilterSpecification: HTTPSBloomFilterSpecification = {
        let data = data.fromJsonFile(Resource.bloomFilterSpec)
        return try! HTTPSUpgradeParser.convertBloomFilterSpecification(fromJSONData: data)
    }()
    
    private lazy var bloomFilter: BloomFilterWrapper? = {
        let path = Bundle(for: type(of: self)).path(forResource: Resource.bloomFilter, ofType: "bin")!
        return BloomFilterWrapper(fromPath: path,
                                  withBitCount: Int32(bloomFilterSpecification.bitCount),
                                  andTotalItems: Int32(bloomFilterSpecification.totalEntries))
    }()
    
    private lazy var mockStore: HTTPSUpgradeStore = {
        MockHTTPSUpgradeStore(bloomFilter: bloomFilter, bloomFilterSpecification: bloomFilterSpecification, excludedDomains: excludedDomains)
    }()
    
    func testHTTPSUpgradesNavigations() async {
        let tests = httpsUpgradesTestSuite.navigations.tests
        let httpsUpgrade = HTTPSUpgrade(store: mockStore, privacyConfig: appConfig)
        httpsUpgrade.loadData() // do we like this api?
        
        for test in tests {
            os_log("TEST: %s", test.name)

            guard !test.shouldSkip else {
                os_log("SKIPPING TEST: \(test.name)")
                return
            }
            
            guard let url = URL(string: test.requestURL) else {
                XCTFail("BROKEN INPUT: \(Resource.tests)")
                return
            }
             
            var resultUrl = url
            let result = await httpsUpgrade.upgrade(url: url)
            if case let .success(upgradedUrl) = result {
                resultUrl = upgradedUrl
            }

            XCTAssertEqual(resultUrl.absoluteString, test.expectURL, "FAILED: \(test.name)")
        }
    }
    
}

private struct MockHTTPSUpgradeStore: HTTPSUpgradeStore {
    
    var bloomFilter: BloomFilterWrapper?
    var bloomFilterSpecification: HTTPSBloomFilterSpecification?
    var excludedDomains: [String]
    
    func hasExcludedDomain(_ domain: String) -> Bool {
        excludedDomains.contains(domain)
    }
    
    func persistBloomFilter(specification: HTTPSBloomFilterSpecification, data: Data) -> Bool { return true }
    func persistExcludedDomains(_ domains: [String]) -> Bool { return true }

}
