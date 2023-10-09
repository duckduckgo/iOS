//
//  UserAgentTests.swift
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

import WebKit
import XCTest
import BrowserServicesKit
@testable import Core

// swiftlint:disable file_length type_body_length
final class UserAgentTests: XCTestCase {
    
    private struct DefaultAgent {

        // swiftlint:disable line_length
        static let mobile = "Mozilla/5.0 (iPhone; CPU iPhone OS 12_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
        static let tablet = "Mozilla/5.0 (iPad; CPU OS 12_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
        static let oldWebkitVersionMobile = "Mozilla/5.0 (iPhone; CPU iPhone OS 12_4 like Mac OS X) AppleWebKit/605.1.14 (KHTML, like Gecko) Mobile/15E148"
        static let newWebkitVersionMobile = "Mozilla/5.0 (iPhone; CPU iPhone OS 12_4 like Mac OS X) AppleWebKit/605.1.16 (KHTML, like Gecko) Mobile/15E148"
        static let sameWebkitVersionMobile = "Mozilla/5.0 (iPhone; CPU iPhone OS 12_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"

    }
    
    private struct ExpectedAgent {

        // Based on DefaultAgent values
        static let mobile = "Mozilla/5.0 (iPhone; CPU iPhone OS 12_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.4 Mobile/15E148 DuckDuckGo/7 Safari/605.1.15"
        static let tablet = "Mozilla/5.0 (iPad; CPU OS 12_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.4 Mobile/15E148 DuckDuckGo/7 Safari/605.1.15"
        static let desktop = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.4 DuckDuckGo/7 Safari/605.1.15"
        static let oldWebkitVersionMobile = "Mozilla/5.0 (iPhone; CPU iPhone OS 12_4 like Mac OS X) AppleWebKit/605.1.14 (KHTML, like Gecko) Version/12.4 Mobile/15E148 DuckDuckGo/7 Safari/605.1.14"
        static let newWebkitVersionMobile = "Mozilla/5.0 (iPhone; CPU iPhone OS 12_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Mobile/15E148 DuckDuckGo/7 Safari/604.1"
        static let sameWebkitVersionMobile = "Mozilla/5.0 (iPhone; CPU iPhone OS 12_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Mobile/15E148 DuckDuckGo/7 Safari/604.1"

        static let mobileNoApplication = "Mozilla/5.0 (iPhone; CPU iPhone OS 12_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.4 Mobile/15E148 Safari/605.1.15"
        
        // Based on fallback constants in UserAgent
        static let mobileFallback = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.5 Mobile/15E148 DuckDuckGo/7 Safari/605.1.15"
        static let desktopFallback = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.5 DuckDuckGo/7 Safari/605.1.15"

        static let mobileFixed = "Mozilla/5.0 (iPhone; CPU iPhone OS 12_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Mobile/15E148 DuckDuckGo/7 Safari/604.1"
        static let tabletFixed = "Mozilla/5.0 (iPad; CPU OS 12_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Mobile/15E148 DuckDuckGo/7 Safari/604.1"
        static let desktopFixed = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 DuckDuckGo/7 Safari/605.1.15"

        static let mobileClosest = "Mozilla/5.0 (iPhone; CPU iPhone OS 12_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Mobile/15E148 Safari/604.1"
        static let tabletClosest = "Mozilla/5.0 (iPad; CPU OS 12_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Mobile/15E148 Safari/604.1"
        static let desktopClosest = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Safari/605.1.15"
        // swiftlint:enable line_length
        
    }
    
    private struct Constants {
        static let url = URL(string: "http://example.com/index.html")
        static let noAppUrl = URL(string: "http://cvs.com/index.html")
        static let noAppSubdomainUrl = URL(string: "http://subdomain.cvs.com/index.html")
        static let ddgFixedUrl = URL(string: "http://test2.com/index.html")
        static let ddgDefaultUrl = URL(string: "http://test3.com/index.html")
    }
    
    let testConfig = """
    {
        "features": {
            "customUserAgent": {
                "state": "enabled",
                "settings": {
                    "omitApplicationSites": [
                        {
                            "domain": "cvs.com",
                            "reason": "Site reports browser not supported"
                        }
                    ]
                },
                "exceptions": []
            }
        },
        "unprotectedTemporary": []
    }
    """.data(using: .utf8)!
    
    private var privacyConfig: PrivacyConfiguration!

    override func setUp() {
        super.setUp()
        
        let mockEmbeddedData = MockEmbeddedDataProvider(data: testConfig, etag: "test")
        let mockProtectionStore = MockDomainsProtectionStore()

        let manager = PrivacyConfigurationManager(fetchedETag: nil,
                                                  fetchedData: nil,
                                                  embeddedDataProvider: mockEmbeddedData,
                                                  localProtection: mockProtectionStore,
                                                  internalUserDecider: DefaultInternalUserDecider())

        privacyConfig = manager.privacyConfig
    }
    
    func testWhenMobileUaAndDektopFalseThenMobileAgentCreatedWithApplicationAndSafariSuffix() {
        let testee = UserAgent(defaultAgent: DefaultAgent.mobile)
        XCTAssertEqual(ExpectedAgent.mobile, testee.agent(forUrl: Constants.url, isDesktop: false, privacyConfig: privacyConfig))
    }
    
    func testWhenMobileUaAndDektopTrueThenDesktopAgentCreatedWithApplicationAndSafariSuffix() {
        let testee = UserAgent(defaultAgent: DefaultAgent.mobile)
        XCTAssertEqual(ExpectedAgent.desktop, testee.agent(forUrl: Constants.url, isDesktop: true, privacyConfig: privacyConfig))
    }
    
    func testWhenTabletUaAndDektopFalseThenTabletAgentCreatedWithApplicationAndSafariSuffix() {
        let testee = UserAgent(defaultAgent: DefaultAgent.tablet)
        XCTAssertEqual(ExpectedAgent.tablet, testee.agent(forUrl: Constants.url, isDesktop: false, privacyConfig: privacyConfig))
    }
    
    func testWhenTabletUaAndDektopTrueThenDesktopAgentCreatedWithApplicationAndSafariSuffix() {
        let testee = UserAgent(defaultAgent: DefaultAgent.tablet)
        XCTAssertEqual(ExpectedAgent.desktop, testee.agent(forUrl: Constants.url, isDesktop: true, privacyConfig: privacyConfig))
    }
    
    func testWhenNoUaAndDesktopFalseThenFallbackMobileAgentIsUsed() {
        let testee = UserAgent()
        XCTAssertEqual(ExpectedAgent.mobileFallback, testee.agent(forUrl: Constants.url, isDesktop: false, privacyConfig: privacyConfig))
    }
    
    func testWhenNoUaAndDesktopTrueThenFallbackDesktopAgentIsUsed() {
        let testee = UserAgent()
        XCTAssertEqual(ExpectedAgent.desktopFallback, testee.agent(forUrl: Constants.url, isDesktop: true, privacyConfig: privacyConfig))
    }
    
    func testWhenDomainDoesNotSupportApplicationComponentThenApplicationIsOmittedFromUa() {
        let testee = UserAgent(defaultAgent: DefaultAgent.mobile)
        XCTAssertEqual(ExpectedAgent.mobileNoApplication, testee.agent(forUrl: Constants.noAppUrl, isDesktop: false, privacyConfig: privacyConfig))
    }
    
    func testWhenSubdomainDoesNotSupportApplicationComponentThenApplicationIsOmittedFromUa() {
        let testee = UserAgent(defaultAgent: DefaultAgent.mobile)
        XCTAssertEqual(ExpectedAgent.mobileNoApplication,
                       testee.agent(forUrl: Constants.noAppSubdomainUrl, isDesktop: false, privacyConfig: privacyConfig))
    }
    
    func testWhenCustomUserAgentIsDisabledThenApplicationIsOmittedFromUa() {
        let disabledConfig = """
        {
            "features": {
                "customUserAgent": {
                    "state": "disabled",
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
        
        let mockEmbeddedData = MockEmbeddedDataProvider(data: disabledConfig, etag: "test")
        let mockProtectionStore = MockDomainsProtectionStore()

        let manager = PrivacyConfigurationManager(fetchedETag: nil,
                                                  fetchedData: nil,
                                                  embeddedDataProvider: mockEmbeddedData,
                                                  localProtection: mockProtectionStore,
                                                  internalUserDecider: DefaultInternalUserDecider())
        
        let testee = UserAgent(defaultAgent: DefaultAgent.mobile)
        XCTAssertEqual(ExpectedAgent.mobileNoApplication, testee.agent(forUrl: Constants.url, isDesktop: false,
                                                                       privacyConfig: manager.privacyConfig))
    }

    /// Experimental config

    func makePrivacyConfig(from rawConfig: Data) -> PrivacyConfiguration {
        let mockEmbeddedData = MockEmbeddedDataProvider(data: rawConfig, etag: "test")
        let mockProtectionStore = MockDomainsProtectionStore()

        let manager = PrivacyConfigurationManager(fetchedETag: nil,
                                                  fetchedData: nil,
                                                  embeddedDataProvider: mockEmbeddedData,
                                                  localProtection: mockProtectionStore,
                                                  internalUserDecider: DefaultInternalUserDecider())
        return manager.privacyConfig
    }

    let ddgConfig = """
    {
        "features": {
            "customUserAgent": {
                "defaultPolicy": "ddg",
                "state": "enabled",
                "settings": {
                    "omitApplicationSites": [
                        {
                            "domain": "cvs.com",
                            "reason": "Site reports browser not supported"
                        }
                    ],
                    "ddgFixedSites": [
                        {
                            "domain": "test2.com"
                        }
                    ]
                },
                "exceptions": []
            }
        },
        "unprotectedTemporary": []
    }
    """.data(using: .utf8)!

    func testWhenMobileUaAndDesktopFalseAndDomainSupportsFixedUAThenFixedMobileAgentUsed() {
        let testee = UserAgent(defaultAgent: DefaultAgent.mobile)
        let config = makePrivacyConfig(from: ddgConfig)
        XCTAssertEqual(ExpectedAgent.mobileFixed, testee.agent(forUrl: Constants.ddgFixedUrl, isDesktop: false, privacyConfig: config))
    }

    func testWhenMobileUaAndDesktopTrueAndDomainSupportsFixedUAThenFixedMobileAgentUsed() {
        let testee = UserAgent(defaultAgent: DefaultAgent.mobile)
        let config = makePrivacyConfig(from: ddgConfig)
        XCTAssertEqual(ExpectedAgent.desktopFixed, testee.agent(forUrl: Constants.ddgFixedUrl, isDesktop: true, privacyConfig: config))
    }

    func testWhenTabletUaAndDesktopFalseAndDomainSupportsFixedUAThenFixedMobileAgentUsed() {
        let testee = UserAgent(defaultAgent: DefaultAgent.tablet)
        let config = makePrivacyConfig(from: ddgConfig)
        XCTAssertEqual(ExpectedAgent.tabletFixed, testee.agent(forUrl: Constants.ddgFixedUrl, isDesktop: false, privacyConfig: config))
    }

    func testWhenTabletUaAndDesktopTrueAndDomainSupportsFixedUAThenFixedMobileAgentUsed() {
        let testee = UserAgent(defaultAgent: DefaultAgent.tablet)
        let config = makePrivacyConfig(from: ddgConfig)
        XCTAssertEqual(ExpectedAgent.desktopFixed, testee.agent(forUrl: Constants.ddgFixedUrl, isDesktop: true, privacyConfig: config))
    }

    let ddgFixedConfig = """
    {
        "features": {
            "customUserAgent": {
                "state": "enabled",
                "settings": {
                    "defaultPolicy": "ddgFixed",
                    "omitApplicationSites": [
                        {
                            "domain": "cvs.com",
                            "reason": "Site reports browser not supported"
                        }
                    ],
                    "ddgDefaultSites": [
                        {
                            "domain": "test3.com"
                        }
                    ]
                },
                "exceptions": []
            }
        },
        "unprotectedTemporary": []
    }
    """.data(using: .utf8)!

    func testWhenMobileUaAndDesktopFalseAndDefaultPolicyFixedThenFixedMobileAgentUsed() {
        let testee = UserAgent(defaultAgent: DefaultAgent.mobile)
        let config = makePrivacyConfig(from: ddgFixedConfig)
        XCTAssertEqual(ExpectedAgent.mobileFixed, testee.agent(forUrl: Constants.url, isDesktop: false, privacyConfig: config))
    }

    func testWhenMobileUaAndDesktopTrueAndDefaultPolicyFixedThenFixedMobileAgentUsed() {
        let testee = UserAgent(defaultAgent: DefaultAgent.mobile)
        let config = makePrivacyConfig(from: ddgFixedConfig)
        XCTAssertEqual(ExpectedAgent.desktopFixed, testee.agent(forUrl: Constants.url, isDesktop: true, privacyConfig: config))
    }

    func testWhenTabletUaAndDesktopFalseAndDefaultPolicyFixedThenFixedMobileAgentUsed() {
        let testee = UserAgent(defaultAgent: DefaultAgent.tablet)
        let config = makePrivacyConfig(from: ddgFixedConfig)
        XCTAssertEqual(ExpectedAgent.tabletFixed, testee.agent(forUrl: Constants.url, isDesktop: false, privacyConfig: config))
    }

    func testWhenTabletUaAndDesktopTrueAndDefaultPolicyFixedThenFixedMobileAgentUsed() {
        let testee = UserAgent(defaultAgent: DefaultAgent.tablet)
        let config = makePrivacyConfig(from: ddgFixedConfig)
        XCTAssertEqual(ExpectedAgent.desktopFixed, testee.agent(forUrl: Constants.url, isDesktop: true, privacyConfig: config))
    }

    func testWhenDefaultPolicyFixedAndDomainIsOnDefaultListThenDefaultAgentUsed() {
        let testee = UserAgent(defaultAgent: DefaultAgent.mobile)
        let config = makePrivacyConfig(from: ddgFixedConfig)
        XCTAssertEqual(ExpectedAgent.mobile, testee.agent(forUrl: Constants.ddgDefaultUrl, isDesktop: false, privacyConfig: config))
    }

    let closestConfig = """
    {
        "features": {
            "customUserAgent": {
                "state": "enabled",
                "settings": {
                    "defaultPolicy": "closest",
                    "omitApplicationSites": [
                        {
                            "domain": "cvs.com",
                            "reason": "Site reports browser not supported"
                        }
                    ],
                    "ddgFixedSites": [
                        {
                            "domain": "test2.com"
                        }
                    ],
                    "ddgDefaultSites": [
                        {
                            "domain": "test3.com"
                        }
                    ]
                },
                "exceptions": []
            }
        },
        "unprotectedTemporary": []
    }
    """.data(using: .utf8)!

    func testWhenMobileUaAndDesktopFalseAndDefaultPolicyClosestThenClosestMobileAgentUsed() {
        let testee = UserAgent(defaultAgent: DefaultAgent.mobile)
        let config = makePrivacyConfig(from: closestConfig)
        XCTAssertEqual(ExpectedAgent.mobileClosest, testee.agent(forUrl: Constants.url, isDesktop: false, privacyConfig: config))
    }

    func testWhenMobileUaAndDesktopTrueAndDefaultPolicyClosestThenFixedMobileAgentUsed() {
        let testee = UserAgent(defaultAgent: DefaultAgent.mobile)
        let config = makePrivacyConfig(from: closestConfig)
        XCTAssertEqual(ExpectedAgent.desktopClosest, testee.agent(forUrl: Constants.url, isDesktop: true, privacyConfig: config))
    }

    func testWhenTabletUaAndDesktopFalseAndDefaultPolicyClosestThenFixedMobileAgentUsed() {
        let testee = UserAgent(defaultAgent: DefaultAgent.tablet)
        let config = makePrivacyConfig(from: closestConfig)
        XCTAssertEqual(ExpectedAgent.tabletClosest, testee.agent(forUrl: Constants.url, isDesktop: false, privacyConfig: config))
    }

    func testWhenTabletUaAndDesktopTrueAndDefaultPolicyClosestThenFixedMobileAgentUsed() {
        let testee = UserAgent(defaultAgent: DefaultAgent.tablet)
        let config = makePrivacyConfig(from: closestConfig)
        XCTAssertEqual(ExpectedAgent.desktopClosest, testee.agent(forUrl: Constants.url, isDesktop: true, privacyConfig: config))
    }

    func testWhenDefaultPolicyClosestAndDomainIsOnDefaultListThenDefaultAgentUsed() {
        let testee = UserAgent(defaultAgent: DefaultAgent.mobile)
        let config = makePrivacyConfig(from: closestConfig)
        XCTAssertEqual(ExpectedAgent.mobile, testee.agent(forUrl: Constants.ddgDefaultUrl, isDesktop: false, privacyConfig: config))
    }

    func testWhenDefaultPolicyClosestAndDomainIsOnFixedListThenFixedAgentUsed() {
        let testee = UserAgent(defaultAgent: DefaultAgent.mobile)
        let config = makePrivacyConfig(from: closestConfig)
        XCTAssertEqual(ExpectedAgent.mobileFixed, testee.agent(forUrl: Constants.ddgFixedUrl, isDesktop: false, privacyConfig: config))
    }

    let configWithVersions = """
    {
        "features": {
            "customUserAgent": {
                "state": "enabled",
                "settings": {
                    "defaultPolicy": "ddg",
                    "omitApplicationSites": [
                        {
                            "domain": "cvs.com",
                            "reason": "Site reports browser not supported"
                        }
                    ],
                    "closestUserAgent": {
                        "versions": ["350", "360"]
                    },
                    "ddgFixedUserAgent": {
                        "versions": ["351", "361"]
                    }
                },
                "exceptions": []
            }
        },
        "unprotectedTemporary": []
    }
    """.data(using: .utf8)!

    func testWhenAtbDoesNotMatchVersionFromConfigThenDefaultUAIsUsed() {
        let statisticsStore = MockStatisticsStore()
        statisticsStore.atb = "v300-1"
        let testee = UserAgent(defaultAgent: DefaultAgent.mobile, statistics: statisticsStore)
        let config = makePrivacyConfig(from: configWithVersions)
        XCTAssertEqual(ExpectedAgent.mobile, testee.agent(forUrl: Constants.url, isDesktop: false, privacyConfig: config))
    }

    func testWhenAtbMatchesVersionInClosestUserAgentThenClosestUAIsUsed() {
        let statisticsStore = MockStatisticsStore()
        statisticsStore.atb = "v360-1"
        let testee = UserAgent(defaultAgent: DefaultAgent.mobile, statistics: statisticsStore)
        let config = makePrivacyConfig(from: configWithVersions)
        XCTAssertEqual(ExpectedAgent.mobileClosest, testee.agent(forUrl: Constants.url, isDesktop: false, privacyConfig: config))
    }

    func testWhenAtbMatchesVersionInDDGFixedUserAgentThenDDGFixedUAIsUsed() {
        let statisticsStore = MockStatisticsStore()
        statisticsStore.atb = "v361-1"
        let testee = UserAgent(defaultAgent: DefaultAgent.mobile, statistics: statisticsStore)
        let config = makePrivacyConfig(from: configWithVersions)
        XCTAssertEqual(ExpectedAgent.mobileFixed, testee.agent(forUrl: Constants.url, isDesktop: false, privacyConfig: config))
    }

    func testWhenAtbWithoutDayComponentMatchesVersionInDDGFixedUserAgentThenDDGFixedUAIsUsed() {
        let statisticsStore = MockStatisticsStore()
        statisticsStore.atb = "v361"
        let testee = UserAgent(defaultAgent: DefaultAgent.mobile, statistics: statisticsStore)
        let config = makePrivacyConfig(from: configWithVersions)
        XCTAssertEqual(ExpectedAgent.mobileFixed, testee.agent(forUrl: Constants.url, isDesktop: false, privacyConfig: config))
    }

    func testWhenOldWebKitVersionThenDefaultMobileAgentUsed() {
        let testee = UserAgent(defaultAgent: DefaultAgent.oldWebkitVersionMobile)
        let config = makePrivacyConfig(from: ddgFixedConfig)
        XCTAssertEqual(ExpectedAgent.oldWebkitVersionMobile, testee.agent(forUrl: Constants.url, isDesktop: false, privacyConfig: config))
    }

    func testWhenNewerWebKitVersionThenFixedAgentUsed() {
        let testee = UserAgent(defaultAgent: DefaultAgent.newWebkitVersionMobile)
        let config = makePrivacyConfig(from: ddgFixedConfig)
        XCTAssertEqual(ExpectedAgent.newWebkitVersionMobile, testee.agent(forUrl: Constants.url, isDesktop: false, privacyConfig: config))
    }

    func testWhenSameWebKitVersionThenFixedAgentUsed() {
        let testee = UserAgent(defaultAgent: DefaultAgent.sameWebkitVersionMobile)
        let config = makePrivacyConfig(from: ddgFixedConfig)
        XCTAssertEqual(ExpectedAgent.sameWebkitVersionMobile, testee.agent(forUrl: Constants.url, isDesktop: false, privacyConfig: config))
    }

}
// swiftlint:enable file_length type_body_length
