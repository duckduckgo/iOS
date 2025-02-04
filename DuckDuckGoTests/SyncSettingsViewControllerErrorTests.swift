//
//  SyncSettingsViewControllerErrorTests.swift
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
@testable import DuckDuckGo
import Core
import Combine
@testable import DDGSync
import Persistence
import Common
import SyncUI_iOS

final class SyncSettingsViewControllerErrorTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!
    var vc: SyncSettingsViewController!
    var errorHandler: CapturingSyncPausedStateManager!
    var ddgSyncing: MockDDGSyncing!
    var testRecoveryCode = "eyJyZWNvdmVyeSI6eyJ1c2VyX2lkIjoiMDZGODhFNzEtNDFBRS00RTUxLUE2UkRtRkEwOTcwMDE5QkYwIiwicHJpbWFyeV9rZXkiOiI1QTk3U3dsQVI5RjhZakJaU09FVXBzTktnSnJEYnE3aWxtUmxDZVBWazgwPSJ9fQ=="

    @MainActor
    override func setUpWithError() throws {
        try super.setUpWithError()
        cancellables = []
        errorHandler = CapturingSyncPausedStateManager()
        let bundle = DDGSync.bundle
        guard let model = CoreDataDatabase.loadModel(from: bundle, named: "SyncMetadata") else {
            XCTFail("Failed to load model")
            return
        }
        let database = CoreDataDatabase(name: "",
                                        containerLocation: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString),
                                        model: model,
                                        readOnly: true,
                                        options: [:])
        ddgSyncing = MockDDGSyncing(authState: .active, isSyncInProgress: false)
        let bookmarksAdapter = SyncBookmarksAdapter(
            database: database,
            favoritesDisplayModeStorage: MockFavoritesDisplayModeStoring(),
            syncErrorHandler: CapturingAdapterErrorHandler(),
            faviconStoring: MockFaviconStore())
        let credentialsAdapter = SyncCredentialsAdapter(
            secureVaultErrorReporter: MockSecureVaultReporting(),
            syncErrorHandler: CapturingAdapterErrorHandler(),
            tld: TLD())
        let featureFlagger = MockFeatureFlagger(enabledFeatureFlags: [.syncSeamlessAccountSwitching])
        vc = SyncSettingsViewController(
            syncService: ddgSyncing,
            syncBookmarksAdapter: bookmarksAdapter,
            syncCredentialsAdapter: credentialsAdapter,
            syncPausedStateManager: errorHandler,
            featureFlagger: featureFlagger
        )
    }

    override func tearDown() {
        cancellables = nil
        errorHandler = nil
        vc = nil
        super.tearDown()
    }

    @MainActor
    func test_WhenSyncPausedIsTrue_andChangePublished_isSyncPausedIsUpdated() async {
        let expectation2 = XCTestExpectation(description: "isSyncPaused received the update")
        let expectation1 = XCTestExpectation(description: "isSyncPaused published")
        vc.viewModel?.$isSyncPaused
            .dropFirst()
            .sink { isPaused in
                XCTAssertTrue(isPaused)
                expectation2.fulfill()
            }
            .store(in: &cancellables)

        Task {
            errorHandler.isSyncPaused = true
            errorHandler.isSyncPausedChangedPublisher.send()
            expectation1.fulfill()
        }

        await self.fulfillment(of: [expectation1, expectation2], timeout: 5.0)
    }

    @MainActor
    func test_WhenSyncBookmarksPausedIsTrue_andChangePublished_isSyncBookmarksPausedIsUpdated() async {
        let expectation2 = XCTestExpectation(description: "isSyncBookmarksPaused received the update")
        let expectation1 = XCTestExpectation(description: "isSyncBookmarksPaused published")
        vc.viewModel?.$isSyncBookmarksPaused
            .dropFirst()
            .sink { isPaused in
                XCTAssertTrue(isPaused)
                expectation2.fulfill()
            }
            .store(in: &cancellables)

        Task {
            errorHandler.isSyncBookmarksPaused = true
            errorHandler.isSyncPausedChangedPublisher.send()
            expectation1.fulfill()
        }

        await self.fulfillment(of: [expectation1, expectation2], timeout: 5.0)
    }

    @MainActor
    func test_WhenSyncCredentialsPausedIsTrue_andChangePublished_isSyncCredentialsPausedIsUpdated() async {
        let expectation2 = XCTestExpectation(description: "isSyncCredentialsPaused received the update")
        let expectation1 = XCTestExpectation(description: "isSyncCredentialsPaused published")
        vc.viewModel?.$isSyncCredentialsPaused
            .dropFirst()
            .sink { isPaused in
                XCTAssertTrue(isPaused)
                expectation2.fulfill()
            }
            .store(in: &cancellables)

        Task {
            errorHandler.isSyncCredentialsPaused = true
            errorHandler.isSyncPausedChangedPublisher.send()
            expectation1.fulfill()
        }

        await self.fulfillment(of: [expectation1, expectation2], timeout: 5.0)
    }

    @MainActor
    func test_WhenSyncIsTurnedOff_ErrorHandlerSyncDidTurnOffCalled() async {
        let expectation = XCTestExpectation(description: "Sync Turned off")
        Task {
            _ = await vc.confirmAndDisableSync()
        }
        Task {
            vc.onConfirmSyncDisable?()
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 5.0)
        XCTAssertTrue(errorHandler.syncDidTurnOffCalled)
    }

    @MainActor
    func test_WhenAccountRemoved_ErrorHandlerSyncDidTurnOffCalled() async {
        let expectation = XCTestExpectation(description: "Sync Turned off")

        Task {
            _ = await vc.confirmAndDeleteAllData()
        }
        Task {
            vc.onConfirmAndDeleteAllData?()
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 5.0)
        XCTAssertTrue(errorHandler.syncDidTurnOffCalled)
    }

    func x_test_syncCodeEntered_accountAlreadyExists_oneDevice_disconnectsThenLogsInAgain() async {
        await setUpWithSingleDevice(id: "1")

        var secondLoginCalled = false

        ddgSyncing.spyLogin = { [weak self] _, _, _ in
            guard let self else { return [] }
            ddgSyncing.spyLogin = { [weak self] _, _, _ in
                secondLoginCalled = true
                guard let self else { return [] }
                // Assert disconnect was called first
                XCTAssert(ddgSyncing.disconnectCalled)
                return [RegisteredDevice(id: "1", name: "iPhone", type: "iPhone"), RegisteredDevice(id: "2", name: "Macbook Pro", type: "Macbook Pro")]
            }
            throw SyncError.accountAlreadyExists
        }

        _ = await vc.syncCodeEntered(code: testRecoveryCode)

        XCTAssert(secondLoginCalled)
    }

    func x_test_syncCodeEntered_accountAlreadyExists_oneDevice_updatesDevicesWithReturnedDevices() async throws {
        await setUpWithSingleDevice(id: "1")

        ddgSyncing.spyLogin = { [weak self] _, _, _ in
            self?.ddgSyncing.spyLogin = { _, _, _ in
                return [RegisteredDevice(id: "1", name: "iPhone", type: "iPhone"), RegisteredDevice(id: "2", name: "Macbook Pro", type: "Macbook Pro")]
            }
            throw SyncError.accountAlreadyExists
        }

        _ = await vc.syncCodeEntered(code: testRecoveryCode)

        let deviceIDs = await vc.viewModel?.devices.flatMap(\.id)
        XCTAssertEqual(deviceIDs, ["1", "2"])
    }

    func x_test_switchAccounts_disconnectsThenLogsInAgain() async throws {
        var loginCalled = false

        ddgSyncing.spyLogin = { [weak self] _, _, _ in
            guard let self else { return [] }
            // Assert disconnect before returning from login to ensure correct order
            XCTAssert(ddgSyncing.disconnectCalled)
            loginCalled = true
            return [RegisteredDevice(id: "1", name: "iPhone", type: "iPhone"), RegisteredDevice(id: "2", name: "Macbook Pro", type: "Macbook Pro")]
        }

        guard let syncCode = try? SyncCode.decodeBase64String(testRecoveryCode),
            let recoveryKey = syncCode.recovery else {
            XCTFail("Could not create RecoveryKey from code")
            return
        }

        await vc.switchAccounts(recoveryKey: recoveryKey)

        XCTAssert(loginCalled)
    }

    func x_test_switchAccounts_updatesDevicesWithReturnedDevices() async throws {
        ddgSyncing.spyLogin = { [weak self] _, _, _ in
            guard let self else { return [] }
            // Assert disconnect before returning from login to ensure correct order
            XCTAssert(ddgSyncing.disconnectCalled)
            return [RegisteredDevice(id: "1", name: "iPhone", type: "iPhone"), RegisteredDevice(id: "2", name: "Macbook Pro", type: "Macbook Pro")]
        }

        guard let syncCode = try? SyncCode.decodeBase64String(testRecoveryCode),
              let recoveryKey = syncCode.recovery else {
            XCTFail("Could not create RecoveryKey from code")
            return
        }

        await vc.switchAccounts(recoveryKey: recoveryKey)

        let deviceIDs = await vc.viewModel?.devices.flatMap(\.id)
        XCTAssertEqual(deviceIDs, ["1", "2"])
    }

    @MainActor
    private func setUpWithSingleDevice(id: String) {
        ddgSyncing.account = SyncAccount(deviceId: id, deviceName: "iPhone", deviceType: "iPhone", userId: "", primaryKey: Data(), secretKey: Data(), token: nil, state: .active)
        ddgSyncing.registeredDevices = [RegisteredDevice(id: id, name: "iPhone", type: "iPhone")]
        vc.viewModel?.devices = [SyncSettingsViewModel.Device(id: id, name: "iPhone", type: "iPhone", isThisDevice: true)]
    }
}

class MockFavoritesDisplayModeStoring: MockFavoriteDisplayModeStorage {}
