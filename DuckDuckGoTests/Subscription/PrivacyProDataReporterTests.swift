//
//  PrivacyProDataReporterTests.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
@testable import DuckDuckGo
@testable import Core
@testable import BrowserServicesKit
@testable import DDGSync
@testable import SecureStorage

final class PrivacyProDataReporterTests: XCTestCase {
    let testConfig = """
    {
        "readme": "https://github.com/duckduckgo/privacy-configuration",
        "version": 1,
        "features": {
            "additionalCampaignPixelParams": {
                "exceptions": [],
                "state": "enabled",
                "settings": {
                    "origins": [
                      "test_origin"
                    ]
                },
                "minSupportedVersion": 52080000,
                "hash": "12345"
            }
        }
    }
    """.data(using: .utf8)!
    lazy var configManager = PrivacyConfigurationManager(fetchedETag: nil,
                                                         fetchedData: nil,
                                                         embeddedDataProvider: MockEmbeddedDataProvider(data: testConfig, etag: "etag"),
                                                         localProtection: MockDomainsProtectionStore(),
                                                         internalUserDecider: DefaultInternalUserDecider())

    let testSuiteName = "PrivacyProDataReporterTests"
    var testDefaults: UserDefaults!
    let mockCalendar = MockCalendar()
    lazy var statisticsStore = StatisticsUserDefaults(groupName: testSuiteName)

    var reporter: PrivacyProDataReporter!
    var anotherReporter: PrivacyProDataReporter!

    override func setUp() {
        super.setUp()
        testDefaults = UserDefaults(suiteName: testSuiteName)
        reporter = PrivacyProDataReporter(
            configurationManager: configManager,
            variantManager: MockVariantManager(currentVariant: VariantIOS(name: "sc", weight: 0, isIncluded: VariantIOS.When.always, features: [])),
            userDefaults: testDefaults,
            emailManager: EmailManager(storage: MockEmailStorage.mock),
            tutorialSettings: MockTutorialSettings(hasSeenOnboarding: false),
            appSettings: AppSettingsMock(),
            statisticsStore: statisticsStore,
            featureFlagger: MockFeatureFlagger(),
            autofillCheck: { true },
            secureVaultMaker: { nil },
            tabsModel: TabsModel(tabs: [], desktop: false),
            fireproofing: MockFireproofing(),
            dateGenerator: mockCalendar.now
        )
        anotherReporter = PrivacyProDataReporter(
            configurationManager: configManager,
            variantManager: MockVariantManager(currentVariant: VariantIOS(name: "ru", weight: 0, isIncluded: VariantIOS.When.always, features: [])),
            userDefaults: testDefaults,
            emailManager: EmailManager(storage: MockEmailStorage.anotherMock),
            tutorialSettings: MockTutorialSettings(hasSeenOnboarding: true),
            appSettings: AppSettingsMock.mockWithWidget,
            featureFlagger: MockFeatureFlagger(),
            autofillCheck: { true },
            secureVaultMaker: { nil },
            tabsModel: TabsModel(tabs: [Tab(), Tab(), Tab(), Tab()], desktop: false),
            fireproofing: MockFireproofing()
        )
    }

    override func tearDown() {
        testDefaults.removePersistentDomain(forName: testSuiteName)
        super.tearDown()
    }

    func testIsReinstall() {
        XCTAssertFalse(reporter.isReinstall())
        XCTAssertTrue(anotherReporter.isReinstall())
    }

    func testIsFireButtonUser() {
        for _ in 1...6 {
            XCTAssertFalse(reporter.isFireButtonUser())
            reporter.saveFireCount()
        }
        XCTAssertTrue(reporter.isFireButtonUser())
    }

    func testIsAppOnboardingCompleted() {
        XCTAssertFalse(reporter.isAppOnboardingCompleted())
        XCTAssertTrue(anotherReporter.isAppOnboardingCompleted())
    }

    func testIsEmailEnabled() {
        XCTAssertTrue(reporter.isEmailEnabled())
        XCTAssertFalse(anotherReporter.isEmailEnabled())
    }

    func testIsWidgetAdded() async {
        await reporter.saveWidgetAdded()
        XCTAssertFalse(reporter.isWidgetAdded())
        await anotherReporter.saveWidgetAdded()
        XCTAssertTrue(anotherReporter.isWidgetAdded())
    }

    func testIsFrequentUser() {
        XCTAssertFalse(reporter.isFrequentUser())

        reporter.saveApplicationLastSessionEnded()
        mockCalendar.advance(by: .day, value: 1)
        XCTAssertTrue(reporter.isFrequentUser())

        reporter.saveApplicationLastSessionEnded()
        mockCalendar.advance(by: .weekOfMonth, value: 2)
        XCTAssertFalse(reporter.isFrequentUser())
    }

    func testIsLongTermUser() {
        statisticsStore.installDate = mockCalendar.now()
        XCTAssertFalse(reporter.isLongTermUser())

        mockCalendar.advance(by: .day, value: 15)
        XCTAssertFalse(reporter.isLongTermUser())

        mockCalendar.advance(by: .day, value: 33)
        XCTAssertTrue(reporter.isLongTermUser())
    }

    func testIsValidOpenTabsCount() {
        XCTAssertFalse(reporter.isValidOpenTabsCount())
        XCTAssertTrue(anotherReporter.isValidOpenTabsCount())
    }

    func testIsSearchUser() {
        for _ in 1...51 {
            XCTAssertFalse(reporter.isSearchUser())
            reporter.saveSearchCount()
        }
        XCTAssertTrue(reporter.isSearchUser())
    }

    func testAttachedParameters() {
        XCTAssertEqual(reporter.randomizedParameters(for: .messageID("some_id")).count, 0)
        XCTAssertEqual(reporter.randomizedParameters(for: .origin("some_origin")).count, 0)
        for _ in 0...50 {
            let params = reporter.randomizedParameters(for: .messageID("test_origin"))
            XCTAssertLessThanOrEqual(params.count, 8)
            XCTAssertGreaterThanOrEqual(params.count, 7)
        }
        for _ in 0...50 {
            let params = reporter.randomizedParameters(for: .origin("test_origin"))
            XCTAssertLessThanOrEqual(params.count, 8)
            XCTAssertGreaterThanOrEqual(params.count, 7)
        }
    }
}

class MockEmailStorage: EmailManagerStorage {
    private let username: String?
    private let token: String?

    init(username: String?, token: String?) {
        self.username = username
        self.token = token
    }

    static let mock = MockEmailStorage(username: "player1", token: "letmein")
    static let anotherMock = MockEmailStorage(username: nil, token: nil)

    func getUsername() throws -> String? { username }
    func getToken() throws -> String? { token }
    func getAlias() throws -> String? { nil }
    func getCohort() throws -> String? { nil }
    func getLastUseDate() throws -> String? { nil }
    func store(token: String, username: String, cohort: String?) throws {}
    func store(alias: String) throws {}
    func store(lastUseDate: String) throws {}
    func deleteAlias() throws {}
    func deleteAuthenticationState() throws {}
    func deleteWaitlistState() throws {}
}

extension AppSettingsMock {
    static var mockWithWidget: AppSettingsMock {
        let mock = AppSettingsMock()
        mock.widgetInstalled = true
        return mock
    }
}

class MockCalendar {
    private var date: Date
    private let calendar = Calendar.current

    init(date: Date = .init(timeIntervalSince1970: 123456)) {
        self.date = date
    }

    func advance(by component: Calendar.Component, value: Int) {
        date = calendar.date(byAdding: component, value: value, to: now())!
    }

    func now() -> Date {
        date
    }
}
