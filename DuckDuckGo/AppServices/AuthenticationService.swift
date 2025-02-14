//
//  AuthenticationService.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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

import Foundation

protocol AuthenticationServiceProtocol {

    func authenticate() async

}

final class AuthenticationService {

    private let authenticator = Authenticator()
    private let overlayWindowManager: OverlayWindowManager
    private let privacyStore: PrivacyStore = PrivacyUserDefaults()

    init(overlayWindowManager: OverlayWindowManager) {
        self.overlayWindowManager = overlayWindowManager
    }

    // MARK: - Suspend

    func suspend() {
        if privacyStore.authenticationEnabled {
            overlayWindowManager.displayBlankSnapshotWindow()
        }
    }

}

extension AuthenticationService: AuthenticationServiceProtocol {

    @MainActor
    func authenticate() async {
        guard shouldAuthenticate else {
            return
        }
        let authenticationViewController = showAuthenticationScreen()
        authenticationViewController.delegate = self
        await authenticate(with: authenticationViewController)
    }

    private var shouldAuthenticate: Bool {
         privacyStore.authenticationEnabled && authenticator.canAuthenticate()
    }

    @MainActor
    private func authenticate(with authenticationViewController: AuthenticationViewController) async {
        let didAuthenticate = await authenticator.authenticate(reason: UserText.appUnlock)
        if didAuthenticate {
            overlayWindowManager.removeOverlay()
            authenticationViewController.dismiss(animated: true)
        } else {
            authenticationViewController.showUnlockInstructions()
        }
    }

    private func showAuthenticationScreen() -> AuthenticationViewController {
        overlayWindowManager.removeOverlay()
        return overlayWindowManager.displayAuthenticationWindow()
    }

}

extension AuthenticationService: AuthenticationViewControllerDelegate {

    func authenticationViewController(authenticationViewController: AuthenticationViewController, didTapWithSender sender: Any) {
        Task { @MainActor in
            authenticationViewController.hideUnlockInstructions()
            await authenticate(with: authenticationViewController)
        }
    }

}
