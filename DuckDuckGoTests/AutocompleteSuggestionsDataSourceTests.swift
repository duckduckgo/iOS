//
//  AutocompleteSuggestionsDataSourceTests.swift
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

import Foundation

import XCTest
import Persistence
import CoreData
import Bookmarks
import BrowserServicesKit
import Suggestions
import History

@testable import Core
@testable import DuckDuckGo
@testable import PersistenceTestingUtils

final class AutocompleteSuggestionsDataSourceTests: XCTestCase {

    var db: CoreDataDatabase!
    var mainContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        try super.setUpWithError()

        let model = CoreDataDatabase.loadModel(from: Bookmarks.bundle, named: "BookmarksModel")!

        db = CoreDataDatabase(name: "Test", containerLocation: tempDBDir(), model: model)
        db.loadStore()

        self.mainContext = db.makeContext(concurrencyType: .mainQueueConcurrencyType, name: "TestContext")
        BasicBookmarksStructure.populateDB(context: mainContext)
    }

    override func tearDown() {
        try? db.tearDown(deleteStores: true)
    }

    func testDataSourceReturnsHistory() {
        let dataSource = makeDataSource(tabsEnabled: false)
        XCTAssertEqual(dataSource.history(for: MockSuggestionLoading()).count, 2)
    }

    func testWhenSuggestTabsFeatureIsDisable_ThenNoTabsReturned() {
        let dataSource = makeDataSource(tabsEnabled: false)

        let result = dataSource.openTabs(for: MockSuggestionLoading())
        XCTAssertTrue(result.isEmpty)
    }

    func testWhenSuggestTabsFeatureIsEnabled_ThenProvidesOpenTabsExcludingCurrent() {
        let dataSource = makeDataSource()

        // Current tab is the last one added, which has two tabs with the same URL, so only 2 of the 4 will be returned.
        let result = dataSource.openTabs(for: MockSuggestionLoading())
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual("Different", result[0].title)
        XCTAssertEqual("DDG", result[1].title)
    }

    func testDataSourceReturnsBookmarks() {
        let dataSource = makeDataSource()
        let bookmarks = dataSource.bookmarks(for: MockSuggestionLoading())
        XCTAssertEqual(bookmarks.count, 5)
    }

    func testDataSourceReturnsEmptyInternalPages() {
        let dataSource = makeDataSource()
        XCTAssertTrue(dataSource.internalPages(for: MockSuggestionLoading()).isEmpty)
    }

    private func makeDataSource(tabsEnabled: Bool = true) -> AutocompleteSuggestionsDataSource {

        var mockHistoryCoordinator = MockHistoryCoordinator()
        mockHistoryCoordinator.history = [
            makeHistory(.appStore, "App Store"),
            makeHistory(.mac, "DDG for macOS")
        ]
        // mockHistoryCoordinator.

        return AutocompleteSuggestionsDataSource(
            historyManager: MockHistoryManager(historyCoordinator: mockHistoryCoordinator, isEnabledByUser: true, historyFeatureEnabled: true),
            bookmarksDatabase: db,
            featureFlagger: makeFeatureFlagger(tabsEnabled: tabsEnabled),
            tabsModel: makeTabsModel()) { _, completion in
                completion("[]".data(using: .utf8), nil)
        }
    }

    private func makeFeatureFlagger(tabsEnabled: Bool = true) -> FeatureFlagger {
        let mock = MockFeatureFlagger()
        if tabsEnabled {
            mock.enabledFeatureFlags.append(.autcompleteTabs)
        }
        return mock
    }

    private func makeTabsModel() -> TabsModel {
        let model = TabsModel(desktop: false)
        model.add(tab: Tab(uid: "uid1", link: Link(title: "Example", url: URL(string: "https://example.com")!)))
        model.add(tab: Tab(uid: "uid2", link: Link(title: "Different", url: URL(string: "https://different.com")!)))
        model.add(tab: Tab(uid: "uid3", link: Link(title: "DDG", url: URL(string: "https://duckduckgo.com")!)))
        model.add(tab: Tab(uid: "uid4", link: Link(title: "Example", url: URL(string: "https://example.com")!)))
        return model
    }

    private func makeHistory(_ url: URL, _ title: String) -> HistoryEntry {
        .init(identifier: UUID(),
              url: url,
              title: title,
              failedToLoad: false,
              numberOfTotalVisits: 0,
              lastVisit: Date(),
              visits: .init(),
              numberOfTrackersBlocked: 0,
              blockedTrackingEntities: .init(),
              trackersFound: false)
    }

}

final class MockSuggestionLoading: SuggestionLoading {
    func getSuggestions(query: Query, usingDataSource dataSource: any SuggestionLoadingDataSource, completion: @escaping (SuggestionResult?, (any Error)?) -> Void) {
    }
}

private extension MenuBookmarksViewModel {

    convenience init(bookmarksDatabase: CoreDataDatabase) {
        self.init(bookmarksDatabase: bookmarksDatabase,
                  errorEvents: .init(mapping: { event, _, _, _ in
            XCTFail("Unexpected error: \(event)")
        }))
    }
}
