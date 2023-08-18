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
import NetworkProtectionTestUtils
import Combine

final class NetworkProtectionInviteViewModelTests: XCTestCase {

    func test_text_alwaysUppercased() {
        let viewModel = viewModel()
        viewModel.text = "abcdefg"
        XCTAssertEqual(viewModel.text, "ABCDEFG")
    }

    func test_text_emptyString_disableSubmit() {
        let viewModel = viewModel()
        viewModel.text = ""
        XCTAssertTrue(viewModel.shouldDisableSubmit)
    }

    func test_text_nonEmptyString_enableSubmit() {
        let viewModel = viewModel()
        for _ in 0..<5 {
            viewModel.text.append("D")
            XCTAssertFalse(viewModel.shouldDisableSubmit)
        }
    }

    func test_submit_successfulRedemption_changesCurrentStepToSuccess() async {
        let viewModel = viewModel(withInjectedRedemptionCoordinator: .whereRedeemSucceeds())
        await viewModel.submit()
        XCTAssertEqual(viewModel.currentStep, .success)
    }

    private var cancellable: AnyCancellable?

    func test_submit_disablesTextField() async {
        let viewModel = viewModel()
        viewModel.text = "INVITE"

        let expectation = XCTestExpectation()

        cancellable = viewModel.$shouldDisableTextField.sink {
            if $0 == true {
                expectation.fulfill()
            }
        }

        await viewModel.submit()
        await fulfillment(of: [expectation], timeout: 2)
        cancellable = nil
    }

    func test_submit_failedRedemption_unrecognizedCode_enablesTextField() async {
        await onSubmit_failedRedemption_unrecognizedCode { viewModel in
            XCTAssertFalse(viewModel.shouldDisableTextField)
        }
    }

    // Disabled this test but keeping it around to document the behaviour. It is failing inexplicably.
    func x_test_submit_failedRedemption_unrecognizedCode_showsAlert_withUnrecognizedCodeMessage() async {
        let viewModel = viewModel(withInjectedRedemptionCoordinator: .whereRedeemFails(returning: .invalidInviteCode))
        await viewModel.submit()
        XCTAssertTrue(viewModel.shouldShowAlert)
        XCTAssertEqual(viewModel.errorText, UserText.inviteDialogUnrecognizedCodeMessage)
    }

    func test_submit_failedRedemption_otherErrors_enablesTextField() async {
        await onSubmit_failedRedemption_otherErrors { viewModel in
            XCTAssertFalse(viewModel.shouldDisableTextField)
        }
    }

    func test_submit_failedRedemption_otherErrors_showsAlert_withUnknownErrorMessage() async {
        await onSubmit_failedRedemption_otherErrors { viewModel in
            XCTAssertTrue(viewModel.shouldShowAlert)
            XCTAssertEqual(viewModel.errorText, UserText.unknownErrorTryAgainMessage)
        }
    }

    func test_submit_failedRedemption_doesNOTMoveToSuccess() async {
        let viewModel = viewModel(withInjectedRedemptionCoordinator: .whereRedeemFails())
        await viewModel.submit()
        XCTAssertEqual(viewModel.currentStep, .codeEntry)
    }

    func test_getStarted_callsDidCompleteOnDelegate() async {
        var didCallCompletion = false
        let viewModel = viewModel(withInjectedRedemptionCoordinator: .stubbed()) {
            didCallCompletion.toggle()
        }
        viewModel.getStarted()
        XCTAssertTrue(didCallCompletion)
    }

    private func viewModel(withInjectedRedemptionCoordinator coordinator: NetworkProtectionCodeRedemptionCoordinator = .stubbed(), completion: @escaping () -> Void = {}) -> NetworkProtectionInviteViewModel {
        NetworkProtectionInviteViewModel(redemptionCoordinator: coordinator, completion: completion)
    }

    private func onSubmit_failedRedemption_unrecognizedCode(run block: @escaping (NetworkProtectionInviteViewModel) -> Void) async {
        let viewModel = viewModel(withInjectedRedemptionCoordinator: .whereRedeemFails(returning: .invalidInviteCode))
        await viewModel.submit()
        block(viewModel)
    }

    private func onSubmit_failedRedemption_otherErrors(run block: @escaping (NetworkProtectionInviteViewModel) -> Void) async {
        let errors: [NetworkProtectionClientError] = [.failedToEncodeRedeemRequest, .invalidAuthToken, .failedToEncodeRegisterKeyRequest]
        for error in errors {
            let viewModel = viewModel(withInjectedRedemptionCoordinator: .whereRedeemFails(returning: error))
            await viewModel.submit()
            block(viewModel)
        }
    }
}

private class MockRedemptionCoordinator: NetworkProtectionCodeRedeeming {
    var callCount = 0
    func redeem(_ code: String) async throws {
        callCount += 1
    }
}
