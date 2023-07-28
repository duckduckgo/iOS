//
//  NetworkProtectionInviteViewModelTests.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import NetworkProtection

final class NetworkProtectionInviteViewModelTests: XCTestCase {
    private var delegate: MockNetworkProtectionInviteViewModelDelegate!

    override func setUp() {
        super.setUp()
        delegate = MockNetworkProtectionInviteViewModelDelegate()
    }

    override func tearDown() {
        delegate = nil
        super.tearDown()
    }

    func test_text_alwaysUppercased() {
        let viewModel = viewModel(withInjectedRedemptionCoordinator: .stubbed())
        viewModel.text = "abcdefg"
        XCTAssertEqual(viewModel.text, "ABCDEFG")
    }

    func test_submit_successfulRedemption_changesCurrentStepToSuccess() async {
        let viewModel = viewModel(withInjectedRedemptionCoordinator: .whereRedeemSucceeds())
        await viewModel.submit()
        XCTAssertEqual(viewModel.currentStep, .success)
    }

    func test_submit_failedRedemption_doesNOTMoveToSuccess() async {
        let viewModel = viewModel(withInjectedRedemptionCoordinator: .whereRedeemFails())
        await viewModel.submit()
        XCTAssertEqual(viewModel.currentStep, .codeEntry)
    }

    func test_submit_failedRedemption_unrecognizedCode_showsAlert_withUnrecognizedCodeMessage() async {
        let viewModel = viewModel(withInjectedRedemptionCoordinator: .whereRedeemFails(returning: .invalidInviteCode))
        await viewModel.submit()
        XCTAssertTrue(viewModel.shouldShowAlert)
        XCTAssertEqual(viewModel.errorText, UserText.inviteDialogUnrecognizedCodeMessage)
    }

    func test_submit_failedRedemption_otherErrors_showsAlert_withUnknownErrorMessage() async {
        let errors: [NetworkProtectionClientError] = [.failedToEncodeRedeemRequest, .invalidAuthToken, .failedToEncodeRegisterKeyRequest]
        for error in errors {
            let viewModel = viewModel(withInjectedRedemptionCoordinator: .whereRedeemFails(returning: error))
            await viewModel.submit()
            XCTAssertTrue(viewModel.shouldShowAlert)
            XCTAssertEqual(viewModel.errorText, UserText.unknownErrorTryAgainMessage)
        }
    }

    func test_getStarted_callsDidCompleteOnDelegate() async {
        let viewModel = viewModel(withInjectedRedemptionCoordinator: .stubbed())
        viewModel.getStarted()
        XCTAssertTrue(delegate.didCompleteInviteFlowCalled)
    }

    private func viewModel(withInjectedRedemptionCoordinator coordinator: NetworkProtectionCodeRedemptionCoordinator) -> NetworkProtectionInviteViewModel {
        NetworkProtectionInviteViewModel(delegate: delegate, redemptionCoordinator: coordinator)
    }
}

private final class MockNetworkProtectionInviteViewModelDelegate: NetworkProtectionInviteViewModelDelegate {
    var didCompleteInviteFlowCalled = false
    func didCompleteInviteFlow() {
        didCompleteInviteFlowCalled = true
    }
}
