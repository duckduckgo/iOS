//
//  SyncPromoManagerTests.swift
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
@testable import BrowserServicesKit
@testable import Core
@testable import DDGSync
@testable import DuckDuckGo

final class SyncPromoManagerTests: XCTestCase {

    let testGroupName = "test"
    var customSuite: UserDefaults!
    var syncService: MockDDGSyncing!

    override func setUpWithError() throws {
        try super.setUpWithError()

        customSuite = UserDefaults(suiteName: testGroupName)
        customSuite.removePersistentDomain(forName: testGroupName)
        syncService = MockDDGSyncing(authState: .inactive, scheduler: CapturingScheduler(), isSyncInProgress: false)
        UserDefaults.app = customSuite
    }

    override func tearDownWithError() throws {
        UserDefaults.app = .standard
        syncService = nil

        super.tearDown()
    }

    func testWhenAllConditionsMetThenShouldPresentPromoForBookmarks() {
        let featureFlagger = createFeatureFlagger(withFeatureFlagsEnabled: [.syncPromotionBookmarks, .sync])
        syncService.authState = .inactive

        let syncPromoManager = SyncPromoManager(syncService: syncService, featureFlagger: featureFlagger)
        syncPromoManager.resetPromos()

        XCTAssertTrue(syncPromoManager.shouldPresentPromoFor(.bookmarks, count: 1))
    }


    func testWhenSyncPromotionBookmarksFeatureFlagDisabledThenShouldNotPresentPromoForBookmarks() {
        let featureFlagger = createFeatureFlagger(withFeatureFlagsEnabled: [.sync])
        syncService.authState = .inactive

        let syncPromoManager = SyncPromoManager(syncService: syncService, featureFlagger: featureFlagger)
        syncPromoManager.resetPromos()

        XCTAssertFalse(syncPromoManager.shouldPresentPromoFor(.bookmarks, count: 1))
    }

    func testWhenSyncFeatureFlagDisabledThenShouldNotPresentPromoForBookmarks() {
        let featureFlagger = createFeatureFlagger(withFeatureFlagsEnabled: [.syncPromotionBookmarks])
        syncService.authState = .inactive

        let syncPromoManager = SyncPromoManager(syncService: syncService, featureFlagger: featureFlagger)
        syncPromoManager.resetPromos()

        XCTAssertFalse(syncPromoManager.shouldPresentPromoFor(.bookmarks, count: 1))
    }

    func testWhenSyncServiceAuthStateActiveThenShouldNotPresentPromoForBookmarks() {
        let featureFlagger = createFeatureFlagger(withFeatureFlagsEnabled: [.syncPromotionBookmarks, .sync])
        syncService.authState = .active

        let syncPromoManager = SyncPromoManager(syncService: syncService, featureFlagger: featureFlagger)
        syncPromoManager.resetPromos()

        XCTAssertFalse(syncPromoManager.shouldPresentPromoFor(.bookmarks, count: 1))
    }

    func testWhenSyncPromoBookmarksDismissedThenShouldNotPresentPromoForBookmarks() {
        let featureFlagger = createFeatureFlagger(withFeatureFlagsEnabled: [.syncPromotionBookmarks, .sync])
        syncService.authState = .inactive

        let syncPromoManager = SyncPromoManager(syncService: syncService, featureFlagger: featureFlagger)
        syncPromoManager.resetPromos()
        syncPromoManager.dismissPromoFor(.bookmarks)

        XCTAssertFalse(syncPromoManager.shouldPresentPromoFor(.bookmarks, count: 1))
    }

    func testWhenBookmarksCountIsZeroThenShouldNotPresentPromoForBookmarks() {
        let featureFlagger = createFeatureFlagger(withFeatureFlagsEnabled: [.syncPromotionBookmarks, .sync])
        syncService.authState = .inactive

        let syncPromoManager = SyncPromoManager(syncService: syncService, featureFlagger: featureFlagger)
        syncPromoManager.resetPromos()

        XCTAssertFalse(syncPromoManager.shouldPresentPromoFor(.bookmarks, count: 0))
    }

    func testWhenAllConditionsMetThenShouldPresentPromoForPasswords() {
        let featureFlagger = createFeatureFlagger(withFeatureFlagsEnabled: [.syncPromotionPasswords, .sync])
        syncService.authState = .inactive

        let syncPromoManager = SyncPromoManager(syncService: syncService, featureFlagger: featureFlagger)
        syncPromoManager.resetPromos()

        XCTAssertTrue(syncPromoManager.shouldPresentPromoFor(.passwords, count: 1))
    }

    func testWhenSyncPromotionPasswordsFeatureFlagDisabledThenShouldNotPresentPromoForPasswords() {
        let featureFlagger = createFeatureFlagger(withFeatureFlagsEnabled: [.sync])
        syncService.authState = .inactive

        let syncPromoManager = SyncPromoManager(syncService: syncService, featureFlagger: featureFlagger)
        syncPromoManager.resetPromos()

        XCTAssertFalse(syncPromoManager.shouldPresentPromoFor(.passwords, count: 1))
    }

    func testWhenSyncFeatureFlagDisabledThenShouldNotPresentPromoForPasswords() {
        let featureFlagger = createFeatureFlagger(withFeatureFlagsEnabled: [.syncPromotionPasswords])
        syncService.authState = .inactive

        let syncPromoManager = SyncPromoManager(syncService: syncService, featureFlagger: featureFlagger)
        syncPromoManager.resetPromos()

        XCTAssertFalse(syncPromoManager.shouldPresentPromoFor(.passwords, count: 1))
    }

    func testWhenSyncServiceAuthStateActiveThenShouldNotPresentPromoForPasswords() {
        let featureFlagger = createFeatureFlagger(withFeatureFlagsEnabled: [.syncPromotionPasswords, .sync])
        syncService.authState = .active

        let syncPromoManager = SyncPromoManager(syncService: syncService, featureFlagger: featureFlagger)
        syncPromoManager.resetPromos()

        XCTAssertFalse(syncPromoManager.shouldPresentPromoFor(.passwords, count: 1))
    }

    func testWhenSyncPromoPasswordsDismissedThenShouldNotPresentPromoForPasswords() {
        let featureFlagger = createFeatureFlagger(withFeatureFlagsEnabled: [.syncPromotionPasswords, .sync])
        syncService.authState = .inactive

        let syncPromoManager = SyncPromoManager(syncService: syncService, featureFlagger: featureFlagger)
        syncPromoManager.resetPromos()
        syncPromoManager.dismissPromoFor(.passwords)

        XCTAssertFalse(syncPromoManager.shouldPresentPromoFor(.passwords, count: 1))
    }

    func testWhenPasswordsCountIsZeroThenShouldNotPresentPromoForPasswords() {
        let featureFlagger = createFeatureFlagger(withFeatureFlagsEnabled: [.syncPromotionPasswords, .sync])
        syncService.authState = .inactive

        let syncPromoManager = SyncPromoManager(syncService: syncService, featureFlagger: featureFlagger)
        syncPromoManager.resetPromos()

        XCTAssertFalse(syncPromoManager.shouldPresentPromoFor(.passwords, count: 0))
    }

    // MARK: - Mock Creation

    private func createFeatureFlagger(withFeatureFlagsEnabled featureFlags: [FeatureFlag]) -> FeatureFlagger {
        let mockFeatureFlagger = MockFeatureFlagger()
        mockFeatureFlagger.enabledFeatureFlags.append(contentsOf: featureFlags)
        return mockFeatureFlagger
    }

}
