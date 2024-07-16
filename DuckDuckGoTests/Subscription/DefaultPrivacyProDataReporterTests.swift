//
//  DefaultPrivacyProDataReporterTests.swift
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
@testable import DDGSyncTestingUtilities
@testable import SecureStorage
@testable import SecureStorageTestsUtils

final class DefaultPrivacyProDataReporterTests: XCTestCase {
    let testSuiteName = "DefaultPrivacyProDataReporterTests"
    var testDefaults: UserDefaults!
    let mockCalendar = MockCalendar()
    lazy var statisticsStore = StatisticsUserDefaults(groupName: testSuiteName)

    var mockCryptoProvider = MockCryptoProvider()
    var mockDatabaseProvider = (try! MockAutofillDatabaseProvider())
    var mockKeystoreProvider = MockKeystoreProvider()
    lazy var testVault = DefaultAutofillSecureVault(providers: SecureStorageProviders(crypto: mockCryptoProvider,
                                                                                      database: mockDatabaseProvider,
                                                                                      keystore: mockKeystoreProvider))

    var reporter: DefaultPrivacyProDataReporter!
    var anotherReporter: DefaultPrivacyProDataReporter!

    override func setUp() {
        super.setUp()
        testDefaults = UserDefaults(suiteName: testSuiteName)
        reporter = DefaultPrivacyProDataReporter(
            variantManager: MockVariantManager(currentVariant: VariantIOS(name: "sc", weight: 0, isIncluded: VariantIOS.When.always, features: [])),
            userDefaults: testDefaults,
            emailManager: EmailManager(storage: MockEmailStorage.mock),
            tutorialSettings: MockTutorialSettings(hasSeenOnboarding: false),
            appSettings: AppSettingsMock(),
            statisticsStore: statisticsStore,
            secureVault: testVault,
            tabsModel: TabsModel(tabs: [], desktop: false),
            dateGenerator: mockCalendar.now
        )
        anotherReporter = DefaultPrivacyProDataReporter(
            variantManager: MockVariantManager(currentVariant: VariantIOS(name: "ru", weight: 0, isIncluded: VariantIOS.When.always, features: [])),
            userDefaults: testDefaults,
            emailManager: EmailManager(storage: MockEmailStorage.anotherMock),
            tutorialSettings: MockTutorialSettings(hasSeenOnboarding: true),
            appSettings: AppSettingsMock.mockWithWidget,
            tabsModel: TabsModel(tabs: [Tab(), Tab(), Tab(), Tab()], desktop: false)
        )
    }

    override func tearDown() {
        testDefaults.removePersistentDomain(forName: testSuiteName)
        try? testVault.deleteAllWebsiteCredentials()
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

    func testIsSyncUsed() {
        let dependencies = MockSyncDependencies()
        dependencies.keyValueStore.set(true, forKey: DDGSync.Constants.syncEnabledKey)
        let syncService = DDGSync(dataProvidersSource: MockDataProvidersSource(),
                                  dependencies: dependencies)
        reporter.injectSyncService(syncService)
        XCTAssertEqual(syncService.authState, .initializing)
        XCTAssertTrue(reporter.isSyncUsed())

        syncService.initializeIfNeeded()
        XCTAssertEqual(syncService.authState, .inactive)
        XCTAssertFalse(reporter.isSyncUsed())
    }

    func testIsFireproofingUsed() {
        XCTAssertFalse(reporter.isFireproofingUsed())
        reporter.saveFireproofingUsed()
        XCTAssertTrue(reporter.isFireproofingUsed())
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
        let hasNothing = await reporter.isWidgetAdded()
        XCTAssertFalse(hasNothing)
        let hasSomething = await anotherReporter.isWidgetAdded()
        XCTAssertTrue(hasSomething)
    }

    func testIsFrequentUser() {
        XCTAssertFalse(reporter.isFrequentUser())

        reporter.saveApplicationLastActiveDate()
        mockCalendar.advance(by: .day, value: 1)
        XCTAssertTrue(reporter.isFrequentUser())

        reporter.saveApplicationLastActiveDate()
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

    func testIsAutofillUser() throws {
        XCTAssertFalse(reporter.isAutofillUser())

        mockCryptoProvider._decryptedData = "decrypted".data(using: .utf8)
        mockKeystoreProvider._generatedPassword = "generated".data(using: .utf8)
        mockCryptoProvider._derivedKey = "derived".data(using: .utf8)
        mockKeystoreProvider._encryptedL2Key = "encryptedL2Key".data(using: .utf8)

        for accountId in 1...6 {
            let account = SecureVaultModels.WebsiteAccount(id: "\(accountId)", username: "user\(accountId)@example.com", domain: "example.com", created: Date(), lastUpdated: Date())
            let credentials = SecureVaultModels.WebsiteCredentials(account: account, password: "password\(accountId)".data(using: .utf8)!)
            _ = try testVault.storeWebsiteCredentials(credentials)
            self.mockDatabaseProvider._accounts.append(account)
        }

        XCTAssertEqual(try testVault.accounts().count, 6)
        XCTAssertTrue(reporter.isAutofillUser())
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

    func testAttachedParameters() async {
        let params1 = await DefaultPrivacyProDataReporter.shared.randomizedParameters(for: .messageID("test"))
        let params2 = await DefaultPrivacyProDataReporter.shared.randomizedParameters(for: .origin("test"))
        let params3 = await DefaultPrivacyProDataReporter.shared.randomizedParameters(for: .messageID("message"))
        let params4 = await DefaultPrivacyProDataReporter.shared.randomizedParameters(for: .origin("origins"))
        XCTAssertEqual(params1.count, 0)
        XCTAssertEqual(params2.count, 0)
        XCTAssertEqual(params3.count, 4)
        XCTAssertEqual(params4.count, 4)
    }
}

struct MockTutorialSettings: TutorialSettings {
    var lastVersionSeen: Int { 0 }
    var hasSeenOnboarding: Bool

    init(hasSeenOnboarding: Bool) {
        self.hasSeenOnboarding = hasSeenOnboarding
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
