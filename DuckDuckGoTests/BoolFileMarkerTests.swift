//
//  BoolFileMarkerTests.swift
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
@testable import Core

final class BoolFileMarkerTests: XCTestCase {

    private let marker = BoolFileMarker(name: .init(rawValue: "test"))!

    override func tearDown() {
        super.tearDown()

        marker.unmark()
    }

    private var testFileURL: URL? {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appendingPathComponent("test.marker")
    }

    func testMarkCreatesCorrectFile() throws {

        marker.mark()

        let fileURL = try XCTUnwrap(testFileURL)

        let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
#if targetEnvironment(simulator)
        XCTAssertNil(attributes[.protectionKey])
#else
        XCTAssertEqual(attributes[.protectionKey] as? FileProtectionType, FileProtectionType.none)
#endif
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))
        XCTAssertEqual(marker.isPresent, true)
    }

    func testUnmarkRemovesFile() throws {
        marker.mark()
        marker.unmark()

        let fileURL = try XCTUnwrap(testFileURL)

        XCTAssertFalse(marker.isPresent)
        XCTAssertFalse(FileManager.default.fileExists(atPath: fileURL.path))
    }
}
