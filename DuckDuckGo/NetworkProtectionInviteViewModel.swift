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

enum NetworkProtectionInviteStep {
    case codeEntry, success

    var isSuccess: Bool {
        self == .success
    }
}

final class NetworkProtectionInviteViewModel: ObservableObject {
    @Published var currentStep: NetworkProtectionInviteStep = .codeEntry
    @Published var text: String = "" {
        didSet {
            if oldValue != text {
                text = text.uppercased()
                shouldDisableSubmit = text.count == 0
            }
        }
    }
    var errorText: String = ""
    @Published var shouldShowAlert: Bool = false
    @Published var shouldDisableSubmit: Bool = true
    @Published var shouldDisableTextField: Bool = false

    private let redemptionCoordinator: NetworkProtectionCodeRedeeming
    private let completion: () -> Void

    init(redemptionCoordinator: NetworkProtectionCodeRedeeming, completion: @escaping () -> Void) {
        self.completion = completion
        self.redemptionCoordinator = redemptionCoordinator
    }

    private var isLoading = false

    @MainActor
    func submit() async {
        guard !isLoading else {
            return
        }
        isLoading = true
        shouldDisableTextField = true
        defer {
            shouldDisableTextField = false
            isLoading = false
        }
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
        completion()
    }

    // MARK: Dev only. Will be removed during https://app.asana.com/0/0/1205084446087078/f

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
