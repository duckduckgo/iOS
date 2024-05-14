//
//  AutofillPixelReporterTests.swift
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

final class AutofillPixelReporterTests: XCTestCase {

    var statisticsStorage: MockStatisticsStore!
    private let vault = (try? MockSecureVaultFactory.makeVault(reporter: nil))!
    var autofillPixelReporter: AutofillPixelReporter!

    override func setUpWithError() throws {
        statisticsStorage = MockStatisticsStore()

        setupUserDefault(with: #file)
        UserDefaults.app.removeObject(forKey: UserDefaultsWrapper<String>.Key.autofillSearchDauDate.rawValue)
        UserDefaults.app.removeObject(forKey: UserDefaultsWrapper<String>.Key.autofillFillDate.rawValue)
        UserDefaults.app.removeObject(forKey: UserDefaultsWrapper<String>.Key.autofillOnboardedUser.rawValue)

        autofillPixelReporter = AutofillPixelReporter(statisticsStorage: statisticsStorage,
                                                      secureVault: vault)
    }

    override func tearDownWithError() throws {
        statisticsStorage = nil
        autofillPixelReporter = nil
    }

    func testWhenUserSearchDauIsNotTodayAndAutofillDateIsNotTodayAndEventTypeIsSearchDauThenNoPixelsWillBeFired() {
        autofillPixelReporter.autofillSearchDauDate = Date().addingTimeInterval(.days(-2))
        autofillPixelReporter.autofillFillDate = Date().addingTimeInterval(.days(-2))

        XCTAssertTrue(autofillPixelReporter.pixelsToFireFor(.searchDAU).isEmpty)
    }

    func testWhenUserSearchDauIsNotTodayAndAutofillDateIsTodayAndEventTypeIsSearchDauThenNoPixelsWillBeFired() {
        autofillPixelReporter.autofillSearchDauDate = Date().addingTimeInterval(.days(-2))
        autofillPixelReporter.autofillFillDate = Date()

        XCTAssertTrue(autofillPixelReporter.pixelsToFireFor(.searchDAU).isEmpty)
    }

    func testWhenUserSearchDauIsNotTodayAndEventTypeIsFillThenOnePixelWillBeFired() {
        autofillPixelReporter.autofillSearchDauDate = Date().addingTimeInterval(-2 * 60 * 60 * 24)
        autofillPixelReporter.autofillFillDate = Date().addingTimeInterval(-2 * 60 * 60 * 24)

        XCTAssertEqual(autofillPixelReporter.pixelsToFireFor(.fill).count, 1)
    }

    func testWhenUserSearchDauIsTodayAndAutofillDateIsTodayAndEventTypeIsSearchDauAndAccountsCountIsLessThanTenThenOnePixelWillBeFired() {
        autofillPixelReporter.autofillSearchDauDate = Date()
        autofillPixelReporter.autofillFillDate = Date()
        createAccountsInVault(count: 4)

        XCTAssertEqual(autofillPixelReporter.pixelsToFireFor(.searchDAU).count, 1)
    }

    func testWhenUserSearchDauIsTodayAndAutofillDateIsTodayAndEventTypeIsSearchDauAndAccountsCountIsTenThenTwoPixelsWillBeFired() {
        autofillPixelReporter.autofillSearchDauDate = Date()
        autofillPixelReporter.autofillFillDate = Date()
        createAccountsInVault(count: 10)

        XCTAssertEqual(autofillPixelReporter.pixelsToFireFor(.searchDAU).count, 2)
    }

    func testWhenUserSearchDauIsTodayAndAutofillDateIsTodayAndEventTypeIsSearchDauAndAccountsCountIsGreaterThanTenThenTwoPixelsWillBeFired() {
        autofillPixelReporter.autofillSearchDauDate = Date()
        autofillPixelReporter.autofillFillDate = Date()
        createAccountsInVault(count: 15)

        XCTAssertEqual(autofillPixelReporter.pixelsToFireFor(.searchDAU).count, 2)
    }

    func testWhenUserSearchDauIsTodayAndAutofillDateIsNotTodayAndEventTypeIsSearchDauAndAccountsCountIsLessThanTenThenNoPixelsWillBeFired() {
        autofillPixelReporter.autofillSearchDauDate = Date()
        autofillPixelReporter.autofillFillDate = Date().addingTimeInterval(-2 * 60 * 60 * 24)
        createAccountsInVault(count: 4)

        XCTAssertTrue(autofillPixelReporter.pixelsToFireFor(.searchDAU).isEmpty)
    }

    func testWhenUserSearchDauIsTodayAndAutofillDateIsNotTodayAndEventTypeIsSearchDauAndAccountsCountIsTenThenOnePixelWillBeFired() {
        autofillPixelReporter.autofillSearchDauDate = Date()
        autofillPixelReporter.autofillFillDate = Date().addingTimeInterval(-2 * 60 * 60 * 24)
        createAccountsInVault(count: 10)

        XCTAssertEqual(autofillPixelReporter.pixelsToFireFor(.searchDAU).count, 1)
    }

    func testWhenUserSearchDauIsTodayAndAutofillDateIsNotTodayAndEventTypeIsSearchDauAndAccountsCountIsGreaterThanTenThenOnePixelWillBeFired() {
        autofillPixelReporter.autofillSearchDauDate = Date()
        autofillPixelReporter.autofillFillDate = Date().addingTimeInterval(-2 * 60 * 60 * 24)
        createAccountsInVault(count: 15)

        XCTAssertEqual(autofillPixelReporter.pixelsToFireFor(.searchDAU).count, 1)
    }

    func testWhenUserIsNotOnboardedAndInstallDateIsNilThenOnboardedUserPixelShouldNotBeFired() {
        autofillPixelReporter.autofillOnboardedUser = false
        statisticsStorage.installDate = nil

        XCTAssertFalse(autofillPixelReporter.shouldFireOnboardedUserPixel())
    }

    func testWhenUserIsNotOnboardedAndInstallDateIsTodayThenOnboardedUserPixelShouldNotBeFired() {
        autofillPixelReporter.autofillOnboardedUser = false
        statisticsStorage.installDate = Date()

        XCTAssertFalse(autofillPixelReporter.shouldFireOnboardedUserPixel())
    }

    func testWhenUserIsNotOnboardedAndInstallDateIsYesterdayAndAccountsCountIsZeroThenOnboardedUserPixelShouldNotBeFired() {
        autofillPixelReporter.autofillOnboardedUser = false
        statisticsStorage.installDate = Date().addingTimeInterval(.days(-1))
        createAccountsInVault(count: 0)

        XCTAssertFalse(autofillPixelReporter.shouldFireOnboardedUserPixel())
    }

    func testWhenUserIsNotOnboardedAndInstallDateIsYesterdayAndAccountsCountIsGreaterThanZeroThenOnboardedUserPixelShouldBeFiredAndAutofillOnboardedUserShouldBeTrue() {
        autofillPixelReporter.autofillOnboardedUser = false
        statisticsStorage.installDate = Date().addingTimeInterval(.days(-1))
        createAccountsInVault(count: 4)

        XCTAssertTrue(autofillPixelReporter.shouldFireOnboardedUserPixel())
        XCTAssertTrue(autofillPixelReporter.autofillOnboardedUser)
    }

    func testWhenUserIsNotOnboardedAndInstallDateIsLessThanSevenDaysAgoAndAccountsCountIsZeroThenOnboardedUserPixelShouldNotBeFired() {
        autofillPixelReporter.autofillOnboardedUser = false
        statisticsStorage.installDate = Date().addingTimeInterval(.days(-4))
        createAccountsInVault(count: 0)

        XCTAssertFalse(autofillPixelReporter.shouldFireOnboardedUserPixel())
    }

    func testWhenUserIsNotOnboardedAndInstallDateIsLessThanSevenDaysAgoAndAccountsCountIsGreaterThanZeroThenOnboardedUserPixelShouldBeFiredAndAutofillOnboardedUserShouldBeTrue() {
        autofillPixelReporter.autofillOnboardedUser = false
        statisticsStorage.installDate = Date().addingTimeInterval(.days(-4))
        createAccountsInVault(count: 4)

        XCTAssertTrue(autofillPixelReporter.shouldFireOnboardedUserPixel())
        XCTAssertTrue(autofillPixelReporter.autofillOnboardedUser)
    }

    func testWhenUserIsNotOnboardedAndInstallDateIsMoreThanSevenDaysAgoThenOnboardedUserPixelShouldNotBeFiredAndAutofillOnboardedUserShouldBeTrue() {
        autofillPixelReporter.autofillOnboardedUser = false
        statisticsStorage.installDate = Date().addingTimeInterval(.days(-8))

        XCTAssertFalse(autofillPixelReporter.shouldFireOnboardedUserPixel())
        XCTAssertTrue(autofillPixelReporter.autofillOnboardedUser)
    }

    func testWhenUserIsOnboardedThenOnboardedUserPixelShouldNotBeFired() {
        autofillPixelReporter.autofillOnboardedUser = true

        XCTAssertFalse(autofillPixelReporter.shouldFireOnboardedUserPixel())
    }

    private func createAccountsInVault(count: Int) {
        try? vault.deleteAllWebsiteCredentials()

        for i in 0..<count {
            vault.storedAccounts.append(
                SecureVaultModels.WebsiteAccount(id: "\(i)",
                                                 title: "Title \(i)",
                                                 username: "dax-\(i)@duck.com",
                                                 domain: "testsite.com",
                                                 created: Date(),
                                                 lastUpdated: Date())
            )
        }
    }
}
