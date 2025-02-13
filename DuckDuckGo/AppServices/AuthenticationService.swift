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

final class AuthenticationService {

    private let authenticator = Authenticator()
    private let overlayWindowManager: OverlayWindowManager
    private let privacyStore: PrivacyStore = PrivacyUserDefaults()

    private var shouldAuthenticate: Bool {
         privacyStore.authenticationEnabled && authenticator.canAuthenticate()
    }

    init(overlayWindowManager: OverlayWindowManager) {
        self.overlayWindowManager = overlayWindowManager
    }

    @MainActor
    func resume() async {
        guard shouldAuthenticate else {
            return
        }
        let authenticationViewController = showAuthenticationScreen()
        authenticationViewController.delegate = self
        await authenticate(with: authenticationViewController)
    }

    func onBackground() {
        if privacyStore.authenticationEnabled {
            overlayWindowManager.displayBlankSnapshotWindow()
        }
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
