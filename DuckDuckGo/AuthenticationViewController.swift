//
//  AuthenticationViewController.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

import UIKit

class AuthenticationViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.shared.currentTheme.statusBarStyle
    }

    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var unlockInstructions: UIView!

    private let authenticator = Authenticator()

    private var completion: (() -> Void)?

    static func loadFromStoryboard() -> AuthenticationViewController {
        let storyboard = UIStoryboard(name: "Authentication", bundle: nil)
        guard let controller = storyboard.instantiateInitialViewController() as? AuthenticationViewController else {
            fatalError("Failed to instantiate correct Authentication view controller")
        }
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideUnlockInstructions()
        decorate()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    public func beginAuthentication(completion: (() -> Void)?) async {
        self.completion = completion
        if authenticator.canAuthenticate() {
            await authenticate()
        } else {
            onCouldNotAuthenticate()
        }
    }

    private func authenticate() async {
        hideUnlockInstructions()
        let success = await authenticator.authenticate(reason: UserText.appUnlock)
        if success {
            self.onAuthenticationSucceeded()
        } else {
            self.onAuthenticationFailed()
        }
    }

    @IBAction func onTap(_ sender: Any) {
        Task { @MainActor in
            await authenticate()
        }
    }

    private func onCouldNotAuthenticate() {
        completion?()
        dismiss(animated: true, completion: nil)
    }

    private func onAuthenticationSucceeded() {
        completion?()
        dismiss(animated: true, completion: nil)
    }

    private func onAuthenticationFailed() {
        showUnlockInstructions()
    }

    private func hideUnlockInstructions() {
        unlockInstructions.isHidden = true
    }

    private func showUnlockInstructions() {
        unlockInstructions.isHidden = false
    }
}

extension AuthenticationViewController {
    
    private func decorate() {
        let theme = ThemeManager.shared.currentTheme
        view.backgroundColor = theme.backgroundColor
    }
}
