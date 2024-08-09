//
//  HistoryCaptureTests.swift
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
import BrowserServicesKit
import Persistence
import History
@testable import Core

final class HistoryCaptureTests: XCTestCase {

    let mockHistoryCoordinator = MockHistoryCoordinator()

    func test_whenURLIsCommitted_ThenVisitIsStored() {
        let capture = makeCapture()
        capture.webViewDidCommit(url: URL.example)
        XCTAssertEqual(1, mockHistoryCoordinator.addVisitCalls.count)
        XCTAssertEqual([URL.example], mockHistoryCoordinator.addVisitCalls)
    }

    func test_whenTitleIsUpdatedForMatchingURL_ThenTitleIsSaved() {
        let capture = makeCapture()
        capture.webViewDidCommit(url: URL.example)
        capture.titleDidChange("test", forURL: URL.example)
        XCTAssertEqual(1, mockHistoryCoordinator.updateTitleIfNeededCalls.count)
        XCTAssertEqual(mockHistoryCoordinator.updateTitleIfNeededCalls[0].title, "test")
        XCTAssertEqual(mockHistoryCoordinator.updateTitleIfNeededCalls[0].url, URL.example)
    }

    func test_whenTitleIsUpdatedForDifferentURL_ThenTitleIsIgnored() {
        let capture = makeCapture()
        capture.webViewDidCommit(url: URL.example)
        capture.titleDidChange("test", forURL: URL.example.appendingPathComponent("path"))
        XCTAssertEqual(0, mockHistoryCoordinator.updateTitleIfNeededCalls.count)
    }

    func test_whenComittedURLIsASearch_thenCleanURLIsUsed() {
        let capture = makeCapture()
        capture.webViewDidCommit(url: URL(string: "https://duckduckgo.com/?q=search+terms&t=osx&ia=web")!)

        func assertUrlIsExpected(_ url: URL?) {
            XCTAssertEqual(true, url?.isDuckDuckGoSearch)
            XCTAssertEqual(url?.getQueryItems()?.count, 1)
            XCTAssertEqual("search terms", url?.searchQuery)
        }

        assertUrlIsExpected(capture.url)
        XCTAssertEqual(1, mockHistoryCoordinator.addVisitCalls.count)
        assertUrlIsExpected(mockHistoryCoordinator.addVisitCalls[0])
    }

    func test_whenTitleUpdatedForSearchURL_thenCleanURLIsUsed() {
        let capture = makeCapture()
        capture.webViewDidCommit(url: URL(string: "https://duckduckgo.com/?q=search+terms&t=osx&ia=web")!)

        // Note parameter order has changed
        capture.titleDidChange("title", forURL: URL(string: "https://duckduckgo.com/?q=search+terms&ia=web&t=osx")!)

        XCTAssertEqual(true, capture.url?.isDuckDuckGoSearch)
        XCTAssertEqual(capture.url?.getQueryItems()?.count, 1)
        XCTAssertEqual(1, mockHistoryCoordinator.updateTitleIfNeededCalls.count)
    }

    func makeCapture() -> HistoryCapture {
        let mock = MockHistoryManager(historyCoordinator: mockHistoryCoordinator,
                                      isEnabledByUser: true,
                                      historyFeatureEnabled: true)
        return HistoryCapture(historyManager: mock)
    }

}

class MockHistoryCoordinator: NullHistoryCoordinator {

    var addVisitCalls = [URL]()
    var updateTitleIfNeededCalls = [(title: String, url: URL)]()

    override func addVisit(of url: URL) -> Visit? {
        addVisitCalls.append(url)
        return nil
    }

    override func updateTitleIfNeeded(title: String, url: URL) {
        updateTitleIfNeededCalls.append((title: title, url: url))
    }

}

private extension URL {
    static let example = URL(string: "https://example.com")!
}

class MockHistoryManager: HistoryManaging {

    let historyCoordinator: HistoryCoordinating
    var isEnabledByUser: Bool
    var historyFeatureEnabled: Bool

    init(historyCoordinator: HistoryCoordinating, isEnabledByUser: Bool, historyFeatureEnabled: Bool) {
        self.historyCoordinator = historyCoordinator
        self.historyFeatureEnabled = historyFeatureEnabled
        self.isEnabledByUser = isEnabledByUser
    }

    func isHistoryFeatureEnabled() -> Bool {
        return historyFeatureEnabled
    }

    func removeAllHistory() async {
    }

    func deleteHistoryForURL(_ url: URL) async {
    }

 }
