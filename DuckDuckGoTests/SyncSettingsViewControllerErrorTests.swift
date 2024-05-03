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
import DDGSync
import Persistence

final class SyncSettingsViewControllerErrorTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!
    var vc: SyncSettingsViewController!
    var errorHandler: CapturingSyncSettingsErrorHandler!

    @MainActor
    override func setUpWithError() throws {
        cancellables = []
        errorHandler = CapturingSyncSettingsErrorHandler()
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
        let ddgSyncing = MockDDGSyncing(authState: .active, isSyncInProgress: false)
        let bookmarksAdapter = SyncBookmarksAdapter(database: database, favoritesDisplayModeStorage: MockFavoritesDisplayModeStoring(), syncAdapterErrorHandler: CapturingAdapterErrorHandler())
        let credentialsAdapter = SyncCredentialsAdapter(secureVaultErrorReporter: MockSecureVaultReporting(), syncAdapterErrorHandler: CapturingAdapterErrorHandler())
        vc = SyncSettingsViewController(syncService: ddgSyncing, syncBookmarksAdapter: bookmarksAdapter, syncCredentialsAdapter: credentialsAdapter, syncSettingsErrorHandler: errorHandler)
    }

    override func tearDownWithError() throws {
        cancellables = nil
        errorHandler = nil
        vc = nil
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

    @MainActor
    func test_ErrorHandlerReturnsExpectedSyncBookmarksPausedMetadata() {
        XCTAssertEqual(vc.syncBookmarksPausedTitle, errorHandler.syncBookmarksPausedMetadata.syncPausedTitle)
        XCTAssertEqual(vc.syncBookmarksPausedDescription, errorHandler.syncBookmarksPausedMetadata.syncPausedMessage)
        XCTAssertEqual(vc.syncBookmarksPausedButtonTitle, errorHandler.syncBookmarksPausedMetadata.syncPausedButtonTitle)
    }

    @MainActor
    func test_ErrorHandlerReturnsExpectedSyncCredentialsPausedMetadata() {
        XCTAssertEqual(vc.syncCredentialsPausedTitle, errorHandler.syncCredentialsPausedMetadata.syncPausedTitle)
        XCTAssertEqual(vc.syncCredentialsPausedDescription, errorHandler.syncCredentialsPausedMetadata.syncPausedMessage)
        XCTAssertEqual(vc.syncCredentialsPausedButtonTitle, errorHandler.syncCredentialsPausedMetadata.syncPausedButtonTitle)
    }

    @MainActor
    func test_ErrorHandlerReturnsExpectedSyncIsPausedMetadata() {
        XCTAssertEqual(vc.syncPausedTitle, errorHandler.syncPausedMetadata?.syncPausedTitle)
        XCTAssertEqual(vc.syncPausedDescription, errorHandler.syncPausedMetadata?.syncPausedMessage)
    }
}

class MockFavoritesDisplayModeStoring: MockFavoriteDisplayModeStorage {}
