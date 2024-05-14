//
//  ImportPasswordsStatusHandlerTests.swift
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

final class ImportPasswordsStatusHandlerTests: XCTestCase {

    private let appSettings = AppSettingsMock()
    private let scheduler = CapturingScheduler()
    private var syncService: MockDDGSyncing!

    override func setUpWithError() throws {
        syncService = MockDDGSyncing(authState: .inactive, scheduler: scheduler, isSyncInProgress: false)
    }

    override func tearDownWithError() throws {
        syncService = nil
    }

    func testWhenAuthStateInactiveThenSetImportViaSyncStartDate() {
        appSettings.autofillImportViaSyncStart = nil
        syncService.authState = .inactive

        let importPasswordsStatusHandler = ImportPasswordsStatusHandler(appSettings: appSettings, syncService: syncService)
        let expectation = XCTestExpectation(description: "CheckSyncSuccessStatus completes")

        importPasswordsStatusHandler.setImportViaSyncStartDateIfRequired()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)

        XCTAssertNotNil(appSettings.autofillImportViaSyncStart)
    }

    func testWhenAuthStateActiveAndHasNotSyncedDesktopDeviceThenSetImportViaSyncStartDate() {
        appSettings.autofillImportViaSyncStart = nil
        syncService.authState = .active
        syncService.registeredDevices = []

        let importPasswordsStatusHandler = ImportPasswordsStatusHandler(appSettings: appSettings, syncService: syncService)
        
        let expectation = XCTestExpectation(description: "CheckSyncSuccessStatus completes")

        importPasswordsStatusHandler.setImportViaSyncStartDateIfRequired()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)

        XCTAssertNotNil(appSettings.autofillImportViaSyncStart)
    }

    func testWhenAuthStateActiveAndHasSyncedDesktopDeviceThenDoNotSetImportViaSyncStartDate() {
        appSettings.autofillImportViaSyncStart = nil
        syncService.authState = .active
        syncService.registeredDevices = [RegisteredDevice(id: "1", name: "Device 1", type: "desktop")]

        let importPasswordsStatusHandler = ImportPasswordsStatusHandler(appSettings: appSettings, syncService: syncService)

        let expectation = XCTestExpectation(description: "CheckSyncSuccessStatus completes")
        
        importPasswordsStatusHandler.setImportViaSyncStartDateIfRequired()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)

        XCTAssertNil(appSettings.autofillImportViaSyncStart)
    }

    func testWhenNeverStartedImportThenNoPixelFired() {

        let importPasswordsStatusHandler = TestImportPasswordsStatusHandler.init(appSettings: appSettings, syncService: syncService)
        let expectation = XCTestExpectation(description: "CheckSyncSuccessStatus completes")

        importPasswordsStatusHandler.checkSyncSuccessStatus()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)

        XCTAssertNil(importPasswordsStatusHandler.lastFiredPixel)
    }

    func testWhenRecentlyStartedImportAndSyncAuthStateIsActiveAndHasSyncedDesktopDeviceThenSuccessPixelFired() {

        appSettings.autofillImportViaSyncStart = Date()
        syncService.authState = .active
        syncService.registeredDevices = [RegisteredDevice(id: "1", name: "Device 1", type: "desktop")]

        let importPasswordsStatusHandler = TestImportPasswordsStatusHandler.init(appSettings: appSettings, syncService: syncService)
        let expectation = XCTestExpectation(description: "CheckSyncSuccessStatus completes")

        importPasswordsStatusHandler.checkSyncSuccessStatus()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)

        XCTAssertEqual(importPasswordsStatusHandler.lastFiredPixel, .autofillLoginsImportSuccess)
        XCTAssertNil(appSettings.autofillImportViaSyncStart)
    }

    func testWhenRecentlyStartedImportAndSyncAuthStateIsActiveAndHasNotSyncedDesktopDeviceThenNoPixelFired() {

        appSettings.autofillImportViaSyncStart = Date()
        syncService.authState = .active
        syncService.registeredDevices = []

        let importPasswordsStatusHandler = TestImportPasswordsStatusHandler.init(appSettings: appSettings, syncService: syncService)
        let expectation = XCTestExpectation(description: "CheckSyncSuccessStatus completes")

        importPasswordsStatusHandler.checkSyncSuccessStatus()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)

        XCTAssertNil(importPasswordsStatusHandler.lastFiredPixel)
        XCTAssertNotNil(appSettings.autofillImportViaSyncStart)
    }

    func testWhenRecentlyStartedImportAndSyncAuthStateIsInactiveThenNoPixelFired() {

        appSettings.autofillImportViaSyncStart = Date()
        syncService.authState = .inactive

        let importPasswordsStatusHandler = TestImportPasswordsStatusHandler.init(appSettings: appSettings, syncService: syncService)
        let expectation = XCTestExpectation(description: "CheckSyncSuccessStatus completes")

        importPasswordsStatusHandler.checkSyncSuccessStatus()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)

        XCTAssertNil(importPasswordsStatusHandler.lastFiredPixel)
        XCTAssertNotNil(appSettings.autofillImportViaSyncStart)
    }

    func testWhenImportStartedMoreThan48HoursAgoAndSyncAuthStateIsActiveAndHasSyncedDesktopDeviceThenNoPixelFired() {

        appSettings.autofillImportViaSyncStart = Date().addingTimeInterval(-60 * 60 * 49)
        syncService.authState = .active
        syncService.registeredDevices = [RegisteredDevice(id: "1", name: "Device 1", type: "desktop")]

        let importPasswordsStatusHandler = TestImportPasswordsStatusHandler.init(appSettings: appSettings, syncService: syncService)
        let expectation = XCTestExpectation(description: "CheckSyncSuccessStatus completes")

        importPasswordsStatusHandler.checkSyncSuccessStatus()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)

        XCTAssertNil(importPasswordsStatusHandler.lastFiredPixel)
        XCTAssertNil(appSettings.autofillImportViaSyncStart)
    }

    func testWhenImportStartedMoreThan48HoursAgoAndSyncAuthStateIsActiveAndHasNotSyncedDesktopDeviceThenFailurePixelFired() {

        appSettings.autofillImportViaSyncStart = Date().addingTimeInterval(-60 * 60 * 49)
        syncService.authState = .active
        syncService.registeredDevices = []

        let importPasswordsStatusHandler = TestImportPasswordsStatusHandler.init(appSettings: appSettings, syncService: syncService)
        let expectation = XCTestExpectation(description: "CheckSyncSuccessStatus completes")

        importPasswordsStatusHandler.checkSyncSuccessStatus()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)

        XCTAssertEqual(importPasswordsStatusHandler.lastFiredPixel, .autofillLoginsImportFailure)
        XCTAssertNil(appSettings.autofillImportViaSyncStart)
    }

    func testWhenImportStartedMoreThan48HoursAgoAndSyncAuthStateIsInactiveThenFailurePixelFired() {

        appSettings.autofillImportViaSyncStart = Date().addingTimeInterval(-60 * 60 * 49)
        syncService.authState = .inactive

        let importPasswordsStatusHandler = TestImportPasswordsStatusHandler.init(appSettings: appSettings, syncService: syncService)
        let expectation = XCTestExpectation(description: "CheckSyncSuccessStatus completes")

        importPasswordsStatusHandler.checkSyncSuccessStatus()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)

        XCTAssertEqual(importPasswordsStatusHandler.lastFiredPixel, .autofillLoginsImportFailure)
        XCTAssertNil(appSettings.autofillImportViaSyncStart)
    }
}


class TestImportPasswordsStatusHandler: ImportPasswordsStatusHandler {
    var lastFiredPixel: Pixel.Event?

    override func clearSettingAndFirePixel(_ type: Pixel.Event) {
        lastFiredPixel = type
        super.clearSettingAndFirePixel(type)
    }
}
