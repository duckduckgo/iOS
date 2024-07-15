//
//  OnboardingNavigationDelegateTests.swift
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
import Persistence
import Bookmarks
import DDGSync
import History
import BrowserServicesKit
@testable import DuckDuckGo
@testable import Core

final class OnboardingNavigationDelegateTests: XCTestCase {

    var mainVC: MainViewController!

    override func setUp() {
        let model = CoreDataDatabase.loadModel(from: Bookmarks.bundle, named: "BookmarksModel")!
        let db = CoreDataDatabase(name: "Test", containerLocation: tempDBDir(), model: model)
        db.loadStore()
        let bookmarkDatabaseCleaner = BookmarkDatabaseCleaner(bookmarkDatabase: db, errorEvents: nil)
        let historyManager = HistoryManager(
            privacyConfigManager: MockPrivacyConfigurationManager(),
            variantManager: MockVariantManager(),
            database: db,
            internalUserDecider: DefaultInternalUserDecider(),
            isEnabledByUser: false)
        let dataProviders = SyncDataProviders(
            bookmarksDatabase: db,
            secureVaultFactory: AutofillSecureVaultFactory,
            secureVaultErrorReporter: SecureVaultReporter(),
            settingHandlers: [],
            favoritesDisplayModeStorage: MockFavoritesDisplayModeStoring(),
            syncErrorHandler: SyncErrorHandler()
        )
        let tabsModel = TabsModel(desktop: true)
        mainVC = MainViewController(
            bookmarksDatabase: db,
            bookmarksDatabaseCleaner: bookmarkDatabaseCleaner,
            historyManager: historyManager,
            syncService: MockDDGSyncing(authState: .active, isSyncInProgress: false),
            syncDataProviders: dataProviders,
            appSettings: AppSettingsMock(),
            previewsSource: TabPreviewsSource(),
            tabsModel: tabsModel,
            syncPausedStateManager: CapturingSyncPausedStateManager(),
            variantManager: MockVariantManager())
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        window.rootViewController?.present(mainVC, animated: false, completion: nil)

        let viewLoadedExpectation = expectation(description: "View is loaded")
        DispatchQueue.main.async {
            XCTAssertNotNil(self.mainVC.view, "The view should be loaded")
            viewLoadedExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        mainVC.loadQueryInNewTab("try something")
    }

    override func tearDown() {
        mainVC = nil
    }

    func testSearchForQueryLoadsQueryInCurrentTab() throws {
        // GIVEN
        let query = "Some query"
        let expectedUrl = URL.makeSearchURL(query: query, queryContext: nil)

        // WHEN
        mainVC.searchFor(query)

        // THEN
        XCTAssertNotNil(mainVC.currentTab?.url)
        XCTAssertEqual(mainVC.currentTab?.url?.scheme, expectedUrl?.scheme)
        XCTAssertEqual(mainVC.currentTab?.url?.host, expectedUrl?.host)
        XCTAssertEqual(mainVC.currentTab?.url?.query, expectedUrl?.query)
    }

    func testNavigateToURLLoadsSiteInCurrentTab() throws {
        // GIVEN
        let site = "duckduckgo.com"
        let expectedUrl = URL(string: site)!

        // WHEN
        mainVC.navigateTo(url: expectedUrl)

        // THEN
        XCTAssertNotNil(mainVC.currentTab?.url)
        XCTAssertEqual(mainVC.currentTab?.url, expectedUrl)
    }

}
