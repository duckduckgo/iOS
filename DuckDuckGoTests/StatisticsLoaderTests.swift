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
import OHHTTPStubsSwift
@testable import Core
@testable import BrowserServicesKit

class StatisticsLoaderTests: XCTestCase {

    var mockStatisticsStore: StatisticsStore!
    var mockUsageSegmentation: MockUsageSegmentation!
    var mockPixelFiring: PixelFiringMock.Type!
    var testee: StatisticsLoader!
    private var fireAppRetentionExperimentPixelsCalled = false
    private var fireSearchExperimentPixelsCalled = false

    override func setUpWithError() throws {
        try super.setUpWithError()

        PixelFiringMock.tearDown()

        mockPixelFiring = PixelFiringMock.self
        mockStatisticsStore = MockStatisticsStore()
        mockUsageSegmentation = MockUsageSegmentation()
        testee = StatisticsLoader(statisticsStore: mockStatisticsStore,
                                  usageSegmentation: mockUsageSegmentation,
                                  fireAppRetentionExperimentPixels: { self.fireAppRetentionExperimentPixelsCalled = true },
                                  fireSearchExperimentPixels: { self.fireSearchExperimentPixelsCalled = true },
                                  pixelFiring: mockPixelFiring)
    }

    override func tearDown() {
        HTTPStubs.removeAllStubs()
        PixelFiringMock.tearDown()
        super.tearDown()
    }

    func testWhenAppRefreshHappensButNotInstalledAndReturningUser_ThenRetentionSegmentationNotified() {
        mockStatisticsStore.variant = "ru"
        mockStatisticsStore.atb = "v101-1"
        
        loadSuccessfulExiStub()

        let testExpectation = expectation(description: "refresh complete")
        testee.refreshAppRetentionAtb {
            testExpectation.fulfill()
        }
        wait(for: [testExpectation], timeout: 5.0)
        XCTAssertTrue(mockUsageSegmentation.atbs[0].installAtb.isReturningUser)
        XCTAssertTrue(fireAppRetentionExperimentPixelsCalled)
    }

    func testWhenReturnUser_ThenSegmentationIncludesCorrectVariant() {
        mockStatisticsStore.variant = "ru"
        mockStatisticsStore.atb = "v101-1"
        mockStatisticsStore.searchRetentionAtb = "v101-2"
        loadSuccessfulAtbStub()

        let testExpectation = expectation(description: "refresh complete")
        testee.refreshSearchRetentionAtb {
            testExpectation.fulfill()
        }
        wait(for: [testExpectation], timeout: 5.0)
        XCTAssertTrue(mockUsageSegmentation.atbs[0].installAtb.isReturningUser)
        XCTAssertTrue(fireSearchExperimentPixelsCalled)
    }

    func testWhenSearchRefreshHappensButNotInstalled_ThenRetentionSegmentationNotified() {
        loadSuccessfulExiStub()

        let testExpectation = expectation(description: "refresh complete")
        testee.refreshSearchRetentionAtb {
            testExpectation.fulfill()
        }
        wait(for: [testExpectation], timeout: 5.0)
        XCTAssertFalse(mockUsageSegmentation.atbs.isEmpty)
        XCTAssertTrue(fireSearchExperimentPixelsCalled)
    }

    func testWhenAppRefreshHappensButNotInstalled_ThenRetentionSegmentationNotified() {
        loadSuccessfulExiStub()

        let testExpectation = expectation(description: "refresh complete")
        testee.refreshAppRetentionAtb {
            testExpectation.fulfill()
        }
        wait(for: [testExpectation], timeout: 5.0)
        XCTAssertFalse(mockUsageSegmentation.atbs.isEmpty)
        XCTAssertTrue(fireAppRetentionExperimentPixelsCalled)
    }

    func testWhenStatisticsInstalled_ThenRetentionSegmentationNotNotified() {
        loadSuccessfulExiStub()

        let testExpectation = expectation(description: "install complete")
        testee.load {
            testExpectation.fulfill()
        }
        wait(for: [testExpectation], timeout: 5.0)
        XCTAssertTrue(mockUsageSegmentation.atbs.isEmpty)
    }

    func testWhenAppRefreshHappens_ThenRetentionSegmentationNotified() {
        mockStatisticsStore.atb = "atb"
        mockStatisticsStore.appRetentionAtb = "retentionatb"
        loadSuccessfulAtbStub()

        let testExpectation = expectation(description: "refresh complete")
        testee.refreshAppRetentionAtb {
            testExpectation.fulfill()
        }
        wait(for: [testExpectation], timeout: 5.0)
        XCTAssertFalse(mockUsageSegmentation.atbs.isEmpty)
        XCTAssertTrue(fireAppRetentionExperimentPixelsCalled)
    }

    func testWhenSearchRetentionRefreshHappens_ThenRetentionSegmentationNotified() {
        mockStatisticsStore.atb = "atb"
        mockStatisticsStore.searchRetentionAtb = "retentionatb"
        loadSuccessfulAtbStub()

        let testExpectation = expectation(description: "refresh complete")
        testee.refreshSearchRetentionAtb {
            testExpectation.fulfill()
        }
        wait(for: [testExpectation], timeout: 5.0)
        XCTAssertFalse(mockUsageSegmentation.atbs.isEmpty)
        XCTAssertTrue(self.fireSearchExperimentPixelsCalled)
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

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(self.fireSearchExperimentPixelsCalled)
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

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(self.fireAppRetentionExperimentPixelsCalled)
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

        waitForExpectations(timeout: 5, handler: nil)
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

        waitForExpectations(timeout: 5, handler: nil)
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

        waitForExpectations(timeout: 5, handler: nil)
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

        waitForExpectations(timeout: 5, handler: nil)
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
        
        waitForExpectations(timeout: 5, handler: nil)
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

        waitForExpectations(timeout: 5, handler: nil)
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
        
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testWhenInstallStatisticsRequestedThenInstallPixelIsFired() {
        loadSuccessfulExiStub()

        let testExpectation = expectation(description: "refresh complete")
        testee.refreshAppRetentionAtb {
            Thread.sleep(forTimeInterval: .seconds(0.1))
            testExpectation.fulfill()
        }

        wait(for: [testExpectation], timeout: 5.0)
        XCTAssertEqual(mockPixelFiring.lastPixelName, Pixel.Event.appInstall.name)
    }

    func loadSuccessfulAtbStub() {
        stub(condition: isHost(URL.atb.host!)) { _ in
            let path = OHPathForFile("MockFiles/atb.json", type(of: self))!
            return fixture(filePath: path, status: 200, headers: nil)
        }
    }

    func loadSuccessfulUpdateAtbStub() {
        stub(condition: isHost(URL.atb.host!)) { _ in
            let path = OHPathForFile("MockFiles/atb-with-update.json", type(of: self))!
            return fixture(filePath: path, status: 200, headers: nil)
        }
    }

    func loadUnsuccessfulAtbStub() {
        stub(condition: isHost(URL.atb.host!)) { _ in
            let path = OHPathForFile("MockFiles/invalid.json", type(of: self))!
            return fixture(filePath: path, status: 400, headers: nil)
        }
    }

    func loadSuccessfulExiStub() {
        stub(condition: isPath(URL.makeExtiURL(atb: "").path)) { _ -> HTTPStubsResponse in
            let path = OHPathForFile("MockFiles/empty", type(of: self))!
            return fixture(filePath: path, status: 200, headers: nil)
        }
    }

    func loadUnsuccessfulExiStub() {
        stub(condition: isPath(URL.makeExtiURL(atb: "").path)) { _ -> HTTPStubsResponse in
            let path = OHPathForFile("MockFiles/empty", type(of: self))!
            return fixture(filePath: path, status: 400, headers: nil)
        }
    }

}
