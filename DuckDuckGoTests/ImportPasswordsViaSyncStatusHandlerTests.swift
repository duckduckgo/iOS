//
//  ImportPasswordsViaSyncStatusHandlerTests.swift
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
@testable import DDGSync
@testable import DuckDuckGo
@testable import Core
@testable import BrowserServicesKit
@testable import Common

final class ImportPasswordsViaSyncStatusHandlerTests: XCTestCase {

    private let appSettings = AppSettingsMock()
    private let scheduler = CapturingScheduler()
    private var syncService: MockDDGSyncing!

    override func setUpWithError() throws {
        syncService = MockDDGSyncing(authState: .inactive, scheduler: scheduler, isSyncInProgress: false)
    }

    override func tearDownWithError() throws {
        syncService = nil
    }

    func testWhenAuthStateInactiveThenSetImportViaSyncStartDate() async {
        appSettings.autofillImportViaSyncStart = nil
        syncService.authState = .inactive

        let importPasswordsStatusHandler = ImportPasswordsViaSyncStatusHandler(appSettings: appSettings, syncService: syncService)
        let expectation = XCTestExpectation(description: "CheckSyncSuccessStatus completes")

        importPasswordsStatusHandler.setImportViaSyncStartDateIfRequired()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertNotNil(appSettings.autofillImportViaSyncStart)
    }

    func testWhenAuthStateActiveAndHasNotSyncedDesktopDeviceThenSetImportViaSyncStartDate() async {
        appSettings.autofillImportViaSyncStart = nil
        syncService.authState = .active
        syncService.registeredDevices = []

        let importPasswordsStatusHandler = ImportPasswordsViaSyncStatusHandler(appSettings: appSettings, syncService: syncService)
        
        let expectation = XCTestExpectation(description: "CheckSyncSuccessStatus completes")

        importPasswordsStatusHandler.setImportViaSyncStartDateIfRequired()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertNotNil(appSettings.autofillImportViaSyncStart)
    }

    func testWhenAuthStateActiveAndHasSyncedDesktopDeviceThenDoNotSetImportViaSyncStartDate() async {
        appSettings.autofillImportViaSyncStart = nil
        syncService.authState = .active
        syncService.registeredDevices = [RegisteredDevice(id: "1", name: "Device 1", type: "desktop")]

        let importPasswordsStatusHandler = ImportPasswordsViaSyncStatusHandler(appSettings: appSettings, syncService: syncService)

        let expectation = XCTestExpectation(description: "CheckSyncSuccessStatus completes")
        
        importPasswordsStatusHandler.setImportViaSyncStartDateIfRequired()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertNil(appSettings.autofillImportViaSyncStart)
    }

    func testWhenNeverStartedImportThenNoPixelFired() async {

        let importPasswordsStatusHandler = TestImportPasswordsViaSyncStatusHandler.init(appSettings: appSettings, syncService: syncService)
        let expectation = XCTestExpectation(description: "CheckSyncSuccessStatus completes")

        importPasswordsStatusHandler.checkSyncSuccessStatus()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertNil(importPasswordsStatusHandler.lastFiredPixel)
    }

    func testWhenRecentlyStartedImportAndSyncAuthStateIsActiveAndHasSyncedDesktopDeviceThenSuccessPixelFired() async {

        appSettings.autofillImportViaSyncStart = Date()
        syncService.authState = .active
        syncService.registeredDevices = [RegisteredDevice(id: "1", name: "Device 1", type: "desktop")]

        let importPasswordsStatusHandler = TestImportPasswordsViaSyncStatusHandler.init(appSettings: appSettings, syncService: syncService)
        let expectation = XCTestExpectation(description: "CheckSyncSuccessStatus completes")

        importPasswordsStatusHandler.checkSyncSuccessStatus()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertEqual(importPasswordsStatusHandler.lastFiredPixel, .autofillLoginsImportSuccess)
        XCTAssertNil(appSettings.autofillImportViaSyncStart)
    }

    func testWhenRecentlyStartedImportAndSyncAuthStateIsActiveAndHasNotSyncedDesktopDeviceThenNoPixelFired() async {

        appSettings.autofillImportViaSyncStart = Date()
        syncService.authState = .active
        syncService.registeredDevices = []

        let importPasswordsStatusHandler = TestImportPasswordsViaSyncStatusHandler.init(appSettings: appSettings, syncService: syncService)
        let expectation = XCTestExpectation(description: "CheckSyncSuccessStatus completes")

        importPasswordsStatusHandler.checkSyncSuccessStatus()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertNil(importPasswordsStatusHandler.lastFiredPixel)
        XCTAssertNotNil(appSettings.autofillImportViaSyncStart)
    }

    func testWhenRecentlyStartedImportAndSyncAuthStateIsInactiveThenNoPixelFired() async {

        appSettings.autofillImportViaSyncStart = Date()
        syncService.authState = .inactive

        let importPasswordsStatusHandler = TestImportPasswordsViaSyncStatusHandler.init(appSettings: appSettings, syncService: syncService)
        let expectation = XCTestExpectation(description: "CheckSyncSuccessStatus completes")

        importPasswordsStatusHandler.checkSyncSuccessStatus()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertNil(importPasswordsStatusHandler.lastFiredPixel)
        XCTAssertNotNil(appSettings.autofillImportViaSyncStart)
    }

    func testWhenImportStartedMoreThan48HoursAgoAndSyncAuthStateIsActiveAndHasSyncedDesktopDeviceThenNoPixelFired() async {

        appSettings.autofillImportViaSyncStart = Date().addingTimeInterval(-60 * 60 * 49)
        syncService.authState = .active
        syncService.registeredDevices = [RegisteredDevice(id: "1", name: "Device 1", type: "desktop")]

        let importPasswordsStatusHandler = TestImportPasswordsViaSyncStatusHandler.init(appSettings: appSettings, syncService: syncService)
        let expectation = XCTestExpectation(description: "CheckSyncSuccessStatus completes")

        importPasswordsStatusHandler.checkSyncSuccessStatus()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertNil(importPasswordsStatusHandler.lastFiredPixel)
        XCTAssertNil(appSettings.autofillImportViaSyncStart)
    }

    func testWhenImportStartedMoreThan48HoursAgoAndSyncAuthStateIsActiveAndHasNotSyncedDesktopDeviceThenFailurePixelFired() async {

        appSettings.autofillImportViaSyncStart = Date().addingTimeInterval(-60 * 60 * 49)
        syncService.authState = .active
        syncService.registeredDevices = []

        let importPasswordsStatusHandler = TestImportPasswordsViaSyncStatusHandler.init(appSettings: appSettings, syncService: syncService)
        let expectation = XCTestExpectation(description: "CheckSyncSuccessStatus completes")

        importPasswordsStatusHandler.checkSyncSuccessStatus()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertEqual(importPasswordsStatusHandler.lastFiredPixel, .autofillLoginsImportFailure)
        XCTAssertNil(appSettings.autofillImportViaSyncStart)
    }

    func testWhenImportStartedMoreThan48HoursAgoAndSyncAuthStateIsInactiveThenFailurePixelFired() async {

        appSettings.autofillImportViaSyncStart = Date().addingTimeInterval(-60 * 60 * 49)
        syncService.authState = .inactive

        let importPasswordsStatusHandler = TestImportPasswordsViaSyncStatusHandler.init(appSettings: appSettings, syncService: syncService)
        let expectation = XCTestExpectation(description: "CheckSyncSuccessStatus completes")

        importPasswordsStatusHandler.checkSyncSuccessStatus()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertEqual(importPasswordsStatusHandler.lastFiredPixel, .autofillLoginsImportFailure)
        XCTAssertNil(appSettings.autofillImportViaSyncStart)
    }
}

class TestImportPasswordsViaSyncStatusHandler: ImportPasswordsViaSyncStatusHandler {
    var lastFiredPixel: Pixel.Event?

    override func clearSettingAndFirePixel(_ type: Pixel.Event) {
        lastFiredPixel = type
        super.clearSettingAndFirePixel(type)
    }
}
