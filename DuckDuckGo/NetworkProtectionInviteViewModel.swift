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

import NetworkProtection
import Combine
import Common

final class NetworkProtectionInviteViewModel: ObservableObject {
    @Published var text: String = "" {
        didSet {
            if oldValue != text {
                text = text.uppercased()
            }
        }
    }
    @Published var redeemedText: String?
    @Published var errorText: String?

    private let tokenStore: NetworkProtectionTokenStore
    private let redemptionCoordinator: NetworkProtectionCodeRedeeming
    private let featureVisibility: NetworkProtectionFeatureVisibility
    private var textCancellable: AnyCancellable?

    private static let errorEvents: EventMapping<NetworkProtectionError> = .init { _, _, _, _ in

    }

    init() {
        let tokenStore = NetworkProtectionKeychainTokenStore(useSystemKeychain: false,
                                                             errorEvents: nil)
        self.tokenStore = tokenStore
        self.redemptionCoordinator = NetworkProtectionCodeRedemptionCoordinator(tokenStore: tokenStore,
                                                                                errorEvents: Self.errorEvents)
        self.featureVisibility = tokenStore
        updateAuthenticatedText()
    }

    @MainActor
    func submit() async {
        errorText = nil
        do {
            try await redemptionCoordinator.redeem(text.trimmingWhitespace())
            updateAuthenticatedText()
        } catch NetworkProtectionClientError.invalidInviteCode {
            errorText = "Unrecognized invite code"
            return
        } catch {
            errorText = "Error: try again"
        }
    }

    @MainActor
    func clear() async {
        errorText = nil
        do {
            try tokenStore.deleteToken()
            updateAuthenticatedText()
        } catch {
            errorText = "Could not clear token"
        }
    }

    private func updateAuthenticatedText() {
        redeemedText = featureVisibility.isFeatureActivated ? "Already redeemed" : nil
    }
}

#endif
