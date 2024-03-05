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

    func test_whenURLIsDDGQuery_ThenOnlyQueryIsStored() {
        let capture = makeCapture()
        capture.webViewDidCommit(url: URL.makeSearchURL(query: "test")!)
        XCTAssertEqual(1, mockHistoryCoordinator.addVisitCalls.count)
        XCTAssertEqual("https://duckduckgo.com?q=test", mockHistoryCoordinator.addVisitCalls[0].absoluteString)
    }

    func test_whenURLIsDDGQueryWithExtraParams_ThenOnlyQueryIsStored() {
        let capture = makeCapture()
        capture.webViewDidCommit(url: URL.makeSearchURL(query: "test")!.appendingParameter(name: "ia", value: "web"))
        XCTAssertEqual(1, mockHistoryCoordinator.addVisitCalls.count)
        XCTAssertEqual("https://duckduckgo.com?q=test", mockHistoryCoordinator.addVisitCalls[0].absoluteString)
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

    func makeCapture() -> HistoryCapture {
        return HistoryCapture(historyManager: MockHistoryManager(historyCoordinator: mockHistoryCoordinator))
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

    init(historyCoordinator: HistoryCoordinating) {
        self.historyCoordinator = historyCoordinator
    }

}
