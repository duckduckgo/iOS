//
//  StatisticsLoaderTests.swift
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

class StatisticsLoaderTests: XCTestCase {

    let appUrls = AppUrls()
    var mockStatisticsStore: StatisticsStore!
    var testee: StatisticsLoader!

    override func setUp() {
        mockStatisticsStore = MockStatisticsStore()
        testee = StatisticsLoader(statisticsStore: mockStatisticsStore)
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testWhenSearchRefreshHasSuccessfulUpdateAtbRequestThenSearchRetentionAtbUpdated() {

        mockStatisticsStore.atb = "atb"
        mockStatisticsStore.searchRetentionAtb = "retentionatb"
        loadSuccessfulUpdateAtbStub()

        let expect = expectation(description: "Successful atb updates retention store")
        testee.refreshSearchRetentionAtb {
            XCTAssertEqual(self.mockStatisticsStore.atb, "v20-1")
            XCTAssertEqual(self.mockStatisticsStore.searchRetentionAtb, "v77-5")
            expect.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testWhenAppRefreshHasSuccessfulUpdateAtbRequestThenAppRetentionAtbUpdated() {

        mockStatisticsStore.atb = "atb"
        mockStatisticsStore.appRetentionAtb = "retentionatb"
        loadSuccessfulUpdateAtbStub()

        let expect = expectation(description: "Successful atb updates retention store")
        testee.refreshAppRetentionAtb {
            XCTAssertEqual(self.mockStatisticsStore.atb, "v20-1")
            XCTAssertEqual(self.mockStatisticsStore.appRetentionAtb, "v77-5")
            expect.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testWhenLoadHasSuccessfulAtbAndExtiRequestsThenStoreUpdatedWithVariant() {

        loadSuccessfulAtbStub()
        loadSuccessfulExiStub()

        let expect = expectation(description: "Successfult atb and exti updates store")
        testee.load {
            XCTAssertTrue(self.mockStatisticsStore.hasInstallStatistics)
            XCTAssertEqual(self.mockStatisticsStore.atb, "v77-5")
            expect.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testWhenLoadHasUnsuccessfulAtbThenStoreNotUpdated() {

        loadUnsuccessfulAtbStub()
        loadSuccessfulExiStub()

        let expect = expectation(description: "Unsuccessfult atb does not update store")
        testee.load {
            XCTAssertFalse(self.mockStatisticsStore.hasInstallStatistics)
            XCTAssertNil(self.mockStatisticsStore.atb)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testWhenLoadHasUnsuccessfulExtiThenStoreNotUpdated() {

        loadSuccessfulAtbStub()
        loadUnsuccessfulExiStub()

        let expect = expectation(description: "Unsuccessful exti does not update store")
        testee.load {
            XCTAssertFalse(self.mockStatisticsStore.hasInstallStatistics)
            XCTAssertNil(self.mockStatisticsStore.atb)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testWhenSearchRefreshHasSuccessfulAtbRequestThenSearchRetentionAtbUpdated() {

        mockStatisticsStore.atb = "atb"
        mockStatisticsStore.searchRetentionAtb = "retentionatb"
        loadSuccessfulAtbStub()

        let expect = expectation(description: "Successful atb updates retention store")
        testee.refreshSearchRetentionAtb {
            XCTAssertEqual(self.mockStatisticsStore.atb, "atb")
            XCTAssertEqual(self.mockStatisticsStore.searchRetentionAtb, "v77-5")
            expect.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWhenAppRefreshHasSuccessfulAtbRequestThenAppRetentionAtbUpdated() {
        
        mockStatisticsStore.atb = "atb"
        mockStatisticsStore.appRetentionAtb = "retentionatb"
        loadSuccessfulAtbStub()
        
        let expect = expectation(description: "Successful atb updates retention store")
        testee.refreshAppRetentionAtb {
            XCTAssertEqual(self.mockStatisticsStore.atb, "atb")
            XCTAssertEqual(self.mockStatisticsStore.appRetentionAtb, "v77-5")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testWhenSearchRefreshHasUnsuccessfulAtbRequestThenSearchRetentionAtbNotUpdated() {
        mockStatisticsStore.atb = "atb"
        mockStatisticsStore.searchRetentionAtb = "retentionAtb"
        loadUnsuccessfulAtbStub()

        let expect = expectation(description: "Unsuccessful atb does not update store")
        testee.refreshSearchRetentionAtb {
            XCTAssertEqual(self.mockStatisticsStore.atb, "atb")
            XCTAssertEqual(self.mockStatisticsStore.searchRetentionAtb, "retentionAtb")
            expect.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWhenAppRefreshHasUnsuccessfulAtbRequestThenSearchRetentionAtbNotUpdated() {
        mockStatisticsStore.atb = "atb"
        mockStatisticsStore.appRetentionAtb = "retentionAtb"
        loadUnsuccessfulAtbStub()
        
        let expect = expectation(description: "Unsuccessful atb does not update store")
        testee.refreshAppRetentionAtb {
            XCTAssertEqual(self.mockStatisticsStore.atb, "atb")
            XCTAssertEqual(self.mockStatisticsStore.appRetentionAtb, "retentionAtb")
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    func loadSuccessfulAtbStub() {
        stub(condition: isHost(appUrls.initialAtb.host!)) { _ in
            let path = OHPathForFile("MockFiles/atb.json", type(of: self))!
            return fixture(filePath: path, status: 200, headers: nil)
        }
    }

    func loadSuccessfulUpdateAtbStub() {
        stub(condition: isHost(appUrls.initialAtb.host!)) { _ in
            let path = OHPathForFile("MockFiles/atb-with-update.json", type(of: self))!
            return fixture(filePath: path, status: 200, headers: nil)
        }
    }

    func loadUnsuccessfulAtbStub() {
        stub(condition: isHost(appUrls.initialAtb.host!)) { _ in
            let path = OHPathForFile("MockFiles/invalid.json", type(of: self))!
            return fixture(filePath: path, status: 400, headers: nil)
        }
    }

    func loadSuccessfulExiStub() {
        stub(condition: isPath(appUrls.exti(forAtb: "").path)) { _ -> OHHTTPStubsResponse in
            let path = OHPathForFile("MockFiles/empty", type(of: self))!
            return fixture(filePath: path, status: 200, headers: nil)
        }
    }

    func loadUnsuccessfulExiStub() {
        stub(condition: isPath(appUrls.exti(forAtb: "").path)) { _ -> OHHTTPStubsResponse in
            let path = OHPathForFile("MockFiles/empty", type(of: self))!
            return fixture(filePath: path, status: 400, headers: nil)
        }
    }

}
