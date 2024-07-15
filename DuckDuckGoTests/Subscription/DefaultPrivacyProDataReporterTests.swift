//
//  DefaultPrivacyProDataReporterTests.swift
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

final class DefaultPrivacyProDataReporterTests: XCTestCase {
    let testSuiteName = "DefaultPrivacyProDataReporterTests"
    var testDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        testDefaults = UserDefaults(suiteName: testSuiteName)
    }

    override func tearDown() {
        testDefaults.removePersistentDomain(forName: testSuiteName)
        super.tearDown()
    }

    func testIsReinstall() {
        let variant = VariantIOS(name: "sc", weight: 0, isIncluded: VariantIOS.When.always, features: [])
        let reporter = DefaultPrivacyProDataReporter(variantManager: MockVariantManager(currentVariant: variant))
        XCTAssertFalse(reporter.isReinstall())

        let anotherVariant = VariantIOS(name: "ru", weight: 0, isIncluded: VariantIOS.When.always, features: [])
        let anotherReporter = DefaultPrivacyProDataReporter(variantManager: MockVariantManager(currentVariant: anotherVariant))
        XCTAssertTrue(anotherReporter.isReinstall())
    }

    func testIsFireButtonUser() {
        let reporter = DefaultPrivacyProDataReporter(userDefaults: testDefaults)
        for counter in 0...5 {
            XCTAssertFalse(reporter.isFireButtonUser())
            reporter.saveFireCount()
        }
        XCTAssertTrue(reporter.isFireButtonUser())
    }

    func testIsSyncUsed() {
        let syncService = DDGSync(dataProvidersSource: MockDataProvidersSource(),
                                  dependencies: MockSyncDependencies())
        let reporter = DefaultPrivacyProDataReporter()
        reporter.injectSyncService(syncService)
    }
}
