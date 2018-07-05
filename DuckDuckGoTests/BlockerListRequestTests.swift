//
//  BlockerListRequestTests.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
import OHHTTPStubs
@testable import Core

class BlockerListRequestTests: XCTestCase {

    let host = AppUrls().disconnectMeBlockList.host!
    let url = AppUrls().disconnectMeBlockList

    var testee: BlockerListRequest!
    fileprivate var mockEtagStorage: MockEtagStorage!

    override func setUp() {
        super.setUp()
        mockEtagStorage = MockEtagStorage()
        testee = BlockerListRequest(etagStorage: mockEtagStorage)
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testWhenErrorThenCompletesWithNoData() {

        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.validJson(), status: 404, headers: nil )
        }

        let expect = expectation(description: "testWhenMisMatchingEtagCompletesWithData")
        testee.request(.disconnectMe) { (data) in
            XCTAssertNil(data)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testWhenMisMatchingEtagThenCompletesWithDataAndEtagSet() {

        let etag = UUID().uuidString
        mockEtagStorage.etagToReturn = etag
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.validJson(), status: 200, headers: [ "ETag": "different" ] )
        }

        let expect = expectation(description: "testWhenMisMatchingEtagCompletesWithDataAndEtagSet")
        testee.request(.disconnectMe) { (data) in
            XCTAssertEqual("different", self.mockEtagStorage.lastEtagSet)
            XCTAssertNotNil(data)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testWhenEtagAndNoEtagStoredThenCompletesWithDataAndEtagSet() {

        let etag = UUID().uuidString
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.validJson(), status: 200, headers: [ "ETag": etag ] )
        }

        let expect = expectation(description: "testWhenMisMatchingEtagCompletesWithDataAndEtagSet")
        testee.request(.disconnectMe) { (data) in
            XCTAssertEqual(etag, self.mockEtagStorage.lastEtagSet)
            XCTAssertNotNil(data)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testWhenMatchingEtagThenCompletesWithNoData() {

        let etag = UUID().uuidString
        mockEtagStorage.etagToReturn = etag
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.validJson(), status: 200, headers: [ "ETag": etag ] )
        }

        let expect = expectation(description: "testWhenMatchingEtagCompletesWithNoData")
        testee.request(.disconnectMe) { (data) in
            XCTAssertNil(data)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testWhenNoEtagAndNoEtagStoredThenCompletesWithData() {
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: self.validJson(), status: 200, headers: nil )
        }

        let expect = expectation(description: "testWhenNoEtagAndNoEtagStoredCompletesWithData")
        testee.request(.disconnectMe) { (data) in
            XCTAssertNotNil(data)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)

    }

    func validJson() -> String {
        return OHPathForFile("MockJson/disconnect.json", type(of: self))!
    }

}

private class MockEtagStorage: BlockerListETagStorage {

    var lastEtagSet: String?
    var etagToReturn: String?

    func set(etag: String?, for list: BlockerListRequest.List) {
        lastEtagSet = etag
    }

    func etag(for list: BlockerListRequest.List) -> String? {
        return etagToReturn
    }

}
