//
//  OverlayWindowManager.swift
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

import UIKit

final class OverlayWindowManager {

    private var overlayWindow: UIWindow?
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    @discardableResult
    func displayBlankSnapshotWindow(addressBarPosition: AddressBarPosition, voiceSearchHelper: VoiceSearchHelper) -> BlankSnapshotViewController {
        // If `voiceSearchHelper` is not needed, remove it from here or pass nil
        let blankSnapshotViewController = BlankSnapshotViewController(addressBarPosition: addressBarPosition, voiceSearchHelper: voiceSearchHelper)
        blankSnapshotViewController.delegate = self
        displayOverlay(with: blankSnapshotViewController)
        return blankSnapshotViewController
    }

    @discardableResult
    func displayAuthenticationWindow() -> AuthenticationViewController {
        let authenticationViewController = AuthenticationViewController.loadFromStoryboard()
        displayOverlay(with: authenticationViewController)
        return authenticationViewController
    }

    private func displayOverlay(with viewController: UIViewController) {
        guard overlayWindow == nil else { return }

        overlayWindow = UIWindow(frame: window.frame)
        overlayWindow?.windowLevel = .alert
        overlayWindow?.rootViewController = viewController
        overlayWindow?.makeKeyAndVisible()
        window.isHidden = true
    }

    func removeOverlay() {
        if overlayWindow == nil {
            tryToObtainOverlayWindow()
        }

        if let overlay = overlayWindow {
            overlay.isHidden = true
            overlayWindow = nil
            window.makeKeyAndVisible()
        }
    }

    func removeNonAuthenticationOverlay() {
        if !(overlayWindow?.rootViewController is AuthenticationViewController) {
            removeOverlay()
        }
    }

    private func tryToObtainOverlayWindow() {
        for window in UIApplication.shared.foregroundSceneWindows where window.rootViewController is BlankSnapshotViewController {
            overlayWindow = window
            return
        }
    }

}

extension OverlayWindowManager: BlankSnapshotViewRecoveringDelegate {

    func recoverFromPresenting(controller: BlankSnapshotViewController) {
        removeOverlay()
    }

}
