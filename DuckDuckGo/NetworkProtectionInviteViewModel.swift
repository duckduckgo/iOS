//
//  NetworkProtectionInviteViewModel.swift
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

#if NETWORK_PROTECTION

import Combine
import NetworkProtection

protocol NetworkProtectionInviteViewModelDelegate: AnyObject {
    func didCompleteInviteFlow()
}

enum NetworkProtectionInviteStep {
    case codeEntry, success
}

final class NetworkProtectionInviteViewModel: ObservableObject {
    @Published var currentStep: NetworkProtectionInviteStep = .codeEntry
    @Published var text: String = "" {
        didSet {
            if oldValue != text {
                text = text.uppercased()
            }
        }
    }
    var errorText: String = ""
    @Published var shouldShowAlert: Bool = false

    private let redemptionCoordinator: NetworkProtectionCodeRedeeming
    private weak var delegate: NetworkProtectionInviteViewModelDelegate?

    init(delegate: NetworkProtectionInviteViewModelDelegate?, redemptionCoordinator: NetworkProtectionCodeRedeeming) {
        self.delegate = delegate
        self.redemptionCoordinator = redemptionCoordinator
    }

    @MainActor
    func submit() async {
        do {
            try await redemptionCoordinator.redeem(text.trimmingWhitespace())
        } catch NetworkProtectionClientError.invalidInviteCode {
            errorText = UserText.inviteDialogUnrecognizedCodeMessage
            shouldShowAlert = true
            return
        } catch {
            errorText = UserText.unknownErrorTryAgainMessage
            shouldShowAlert = true
            return
        }
        currentStep = .success
    }

    func getStarted() {
        delegate?.didCompleteInviteFlow()
    }

    // TODO: Dev only. Not to be merged

    @MainActor
    func clear() async {
        errorText = ""
        do {
            try NetworkProtectionKeychainTokenStore().deleteToken()
            updateAuthenticatedText()
        } catch {
            errorText = "Could not clear token"
        }
    }

    @Published var redeemedText: String?

    private func updateAuthenticatedText() {
        redeemedText = NetworkProtectionKeychainTokenStore().isFeatureActivated ? "Already redeemed" : nil
    }
}

#endif
