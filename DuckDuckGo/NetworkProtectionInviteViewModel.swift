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

enum NetworkProtectionInviteDialogKind {
    case codeEntry, success
}

protocol NetworkProtectionInviteViewModelDelegate: AnyObject {
    func didCancelInviteFlow()
    func didCompleteInviteFlow()
}

final class NetworkProtectionInviteViewModel: ObservableObject {
    @Published var currentDialog: NetworkProtectionInviteDialogKind? = .codeEntry
    @Published var text: String = "" {
        didSet {
            if oldValue != text {
                text = text.uppercased()
            }
        }
    }
    @Published var errorText: String?

    private let redemptionCoordinator: NetworkProtectionCodeRedeeming
    private weak var delegate: NetworkProtectionInviteViewModelDelegate?
    private var textCancellable: AnyCancellable?

    init(delegate: NetworkProtectionInviteViewModelDelegate?, redemptionCoordinator: NetworkProtectionCodeRedeeming) {
        self.delegate = delegate
        self.redemptionCoordinator = redemptionCoordinator
        textCancellable = $text.sink { [weak self] _ in
            self?.errorText = nil
        }
    }

    @MainActor
    func submit() async {
        errorText = nil
        do {
            try await redemptionCoordinator.redeem(text.trimmingWhitespace())
        } catch NetworkProtectionClientError.invalidInviteCode {
            errorText = UserText.inviteDialogUnrecognizedCodeMessage
            return
        } catch {
            errorText = UserText.unknownErrorTryAgainMessage
            return
        }
        currentDialog = .success
    }

    func getStarted() {
        delegate?.didCompleteInviteFlow()
    }

    func cancel() {
        delegate?.didCancelInviteFlow()
        currentDialog = nil
    }

    @MainActor
    func clear() async {
        errorText = nil
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
