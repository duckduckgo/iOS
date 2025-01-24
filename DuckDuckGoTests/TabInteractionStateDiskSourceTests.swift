//
//  TabInteractionStateDiskSourceTests.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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
import Core

@testable import DuckDuckGo

final class TabInteractionStateDiskSourceTests: XCTestCase {

    var sut: TabInteractionStateDiskSource!
    private let mockFileManager = MockFileManager()

    override func setUp() {
        sut = TabInteractionStateDiskSource(fileManager: mockFileManager)
    }

    override func tearDown() {
        sut = nil
    }

    func testSaveStateWritesInCacheLocation() {
        let state = Data.random()
        let tab = Tab.mock()

        sut.saveState(state, for: tab)

        XCTAssertTrue(FileManager.default.fileExists(atPath: testPathForTab(tab)))
        XCTAssertEqual(mockFileManager.lastURLsDirectoryParameter, .cachesDirectory)
        XCTAssertEqual(mockFileManager.lastDomainMaskParameter, .userDomainMask)
    }

    func testPopLastStateReadsFromCacheLocation() {
        let state = Data.random()
        let tab = Tab.mock()
        
        sut.saveState(state, for: tab)
        let result = sut.popLastStateForTab(tab)

        XCTAssertEqual(result, state)
    }

    func testPopLastStateRemovesFileAfterReading() {
        let state = Data.random()
        let tab = Tab.mock()
        
        sut.saveState(state, for: tab)
        _ = sut.popLastStateForTab(tab)

        XCTAssertFalse(FileManager.default.fileExists(atPath: testPathForTab(tab)))
    }

    func testRemoveStateDeletesFile() {
        let state = Data.random()
        let tab = Tab.mock()

        sut.saveState(state, for: tab)
        sut.removeStateForTab(tab)
        
        XCTAssertFalse(FileManager.default.fileExists(atPath: testPathForTab(tab)))
    }

    func testCleanUpRemovesAllFiles() throws {
        for _ in 0..<10 {
            let state = Data.random()
            let tab = Tab.mock()

            sut.saveState(state, for: tab)
        }

        sut.removeAll(excluding: [])

        XCTAssertTrue(try FileManager.default.contentsOfDirectory(atPath: testDirectory()).isEmpty)
    }

    func testCleanUpSkipsExclusions() throws {

        var excludedTabs = [Tab]()
        for i in 0..<10 {
            let state = Data.random()
            let tab = Tab.mock()

            sut.saveState(state, for: tab)

            if i % 3 == 0 {
                excludedTabs.append(tab)
            }
        }

        sut.removeAll(excluding: excludedTabs)

        let directoryContents = try FileManager.default.contentsOfDirectory(atPath: testDirectory())

        XCTAssertEqual(Set(directoryContents), Set(excludedTabs.map(\.uid)))
    }

    private func testPathForTab(_ tab: Tab) -> String {
        testDirectory()
            .appendingPathComponent(tab.uid)
    }

    private func testDirectory() -> String {
        NSTemporaryDirectory()
            .appendingPathComponent(Bundle.main.bundleIdentifier!)
            .appendingPathComponent("webview-interaction")
    }
}

private extension Tab {
    static func mock() -> Tab {
        Tab(link: Link(title: nil, url: URL("https://example.com")!), lastViewedDate: nil)
    }
}

private final class MockFileManager: FileManager {
    var lastURLsDirectoryParameter: FileManager.SearchPathDirectory?
    var lastDomainMaskParameter: FileManager.SearchPathDomainMask?
    override func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        lastURLsDirectoryParameter = directory
        lastDomainMaskParameter = domainMask

        return [temporaryDirectory]
    }
}
