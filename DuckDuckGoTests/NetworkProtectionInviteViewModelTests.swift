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

final class NetworkProtectionInviteViewModelTests: XCTestCase {

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
        var didCallCompletion = false
        let viewModel = viewModel(withInjectedRedemptionCoordinator: .stubbed()) {
            didCallCompletion.toggle()
        }
        viewModel.getStarted()
        XCTAssertTrue(didCallCompletion)
    }

    private func viewModel(withInjectedRedemptionCoordinator coordinator: NetworkProtectionCodeRedemptionCoordinator, completion: @escaping () -> Void = {}) -> NetworkProtectionInviteViewModel {
        NetworkProtectionInviteViewModel(redemptionCoordinator: coordinator, completion: completion)
    }
}
