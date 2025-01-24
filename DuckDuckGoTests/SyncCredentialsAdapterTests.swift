//
//  SyncCredentialsAdapterTests.swift
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
import BrowserServicesKit
import Combine
import DDGSync
import SecureStorage
import Core
import Common
@testable import DuckDuckGo

final class SyncCredentialsAdapterTests: XCTestCase {

    var errorHandler: CapturingAdapterErrorHandler!
    var adapter: SyncCredentialsAdapter!
    let metadataStore = MockMetadataStore()
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        errorHandler = CapturingAdapterErrorHandler()
        adapter = SyncCredentialsAdapter(secureVaultErrorReporter: MockSecureVaultReporting(), syncErrorHandler: errorHandler, tld: TLD())
        cancellables = []
    }

    override func tearDownWithError() throws {
        errorHandler = nil
        adapter = nil
        cancellables = nil
    }

    func testWhenSyncErrorPublished_ThenErrorHandlerHandleCredentialErrorCalled() async {
        let expectation = XCTestExpectation(description: "Sync did fail")
        let expectedError = NSError(domain: "some error", code: 400)
        adapter.setUpProviderIfNeeded(secureVaultFactory: AutofillSecureVaultFactory, metadataStore: metadataStore)
        adapter.provider!.syncErrorPublisher
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        adapter.provider?.handleSyncError(expectedError)

        await self.fulfillment(of: [expectation], timeout: 10.0)
        XCTAssertTrue(errorHandler.handleCredentialErrorCalled)
        XCTAssertEqual(errorHandler.capturedError as? NSError, expectedError)
    }

    func testWhenSyncErrorPublished_ThenErrorHandlerSyncCredentialsSuccededCalled() async {
        let expectation = XCTestExpectation(description: "Sync Did Update")
        adapter.setUpProviderIfNeeded(secureVaultFactory: AutofillSecureVaultFactory, metadataStore: metadataStore)

        Task {
            adapter.provider?.syncDidUpdateData()
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 5.0)
        XCTAssertTrue(errorHandler.syncCredentialsSuccededCalled)
    }

}

class MockSecureVaultReporting: SecureVaultReporting {
    func secureVaultError(_ error: SecureStorage.SecureStorageError) {}
}
