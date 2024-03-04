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

    func test_whenNoNavigationOccuredYetAndURLDidChange_ThenDoNotAddToHistory() {
        let capture = makeCapture()
        capture.urlDidChange(URL.ddg)
        XCTAssertEqual([], mockHistoryCoordinator.addVisitCalls)
    }

    func test_whenNavigatingAndURLDidChange_ThenDoNotAddToHistory() {
        let capture = makeCapture()
        capture.webViewDidCommit()
        capture.urlDidChange(URL.ddg)
        XCTAssertEqual([], mockHistoryCoordinator.addVisitCalls)
    }

    func test_whenIdleAndURLDidChange_ThenAddToHistory() {
        let capture = makeCapture()
        capture.webViewDidCommit()
        capture.webViewDidFinishNavigation()
        capture.urlDidChange(URL.ddg)
        XCTAssertEqual([URL.ddg], mockHistoryCoordinator.addVisitCalls)
    }

    func test_whenErrorAndURLDidChange_ThenDoNotAddToHistory() {
        let capture = makeCapture()
        capture.webViewDidCommit()
        capture.webViewDidFailNavigation()
        capture.urlDidChange(URL.ddg)
        XCTAssertEqual([], mockHistoryCoordinator.addVisitCalls)
    }

    func test_whenNavigationDidFinish_ThenAddToHistory() {
        let capture = makeCapture()
        capture.webViewDidCommit()
        capture.urlDidChange(URL.ddg)
        capture.webViewDidFinishNavigation()
        XCTAssertEqual([URL.ddg], mockHistoryCoordinator.addVisitCalls)
    }

    func test_whenNavigationDidFinishForSubFrame_ThenDoNotAddToHistory() {
        let capture = makeCapture()
        capture.webViewDidCommit()
        capture.webViewRequestedPolicyDecisionForNavigationAction(onMainFrame: false)
        capture.urlDidChange(URL.ddg)
        capture.webViewDidFinishNavigation()
        XCTAssertEqual([], mockHistoryCoordinator.addVisitCalls)
    }

    func makeCapture() -> HistoryCapture {
        return HistoryCapture(historyManager: MockHistoryManager(historyCoordinator: mockHistoryCoordinator))
    }

}

class MockHistoryCoordinator: NullHistoryCoordinator {

    var addVisitCalls = [URL]()

    override func addVisit(of url: URL) -> Visit? {
        addVisitCalls.append(url)
        return nil
    }

}

class MockHistoryManager: HistoryManaging {

    let historyCoordinator: HistoryCoordinating

    init(historyCoordinator: HistoryCoordinating) {
        self.historyCoordinator = historyCoordinator
    }

}
