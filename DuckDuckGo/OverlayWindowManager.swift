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
import BrowserServicesKit

final class OverlayWindowManager {

    private var overlayWindow: UIWindow?

    private let window: UIWindow
    private let appSettings: AppSettings
    private let voiceSearchHelper: VoiceSearchHelperProtocol
    private let featureFlagger: FeatureFlagger
    private let aiChatSettings: AIChatSettings

    init(window: UIWindow,
         appSettings: AppSettings,
         voiceSearchHelper: VoiceSearchHelperProtocol,
         featureFlagger: FeatureFlagger,
         aiChatSettings: AIChatSettings) {
        self.window = window
        self.appSettings = appSettings
        self.voiceSearchHelper = voiceSearchHelper
        self.featureFlagger = featureFlagger
        self.aiChatSettings = aiChatSettings
    }

    @discardableResult
    func displayBlankSnapshotWindow() -> BlankSnapshotViewController {
        let blankSnapshotViewController = BlankSnapshotViewController(addressBarPosition: appSettings.currentAddressBarPosition,
                                                                      aiChatSettings: aiChatSettings,
                                                                      voiceSearchHelper: voiceSearchHelper,
                                                                      featureFlagger: featureFlagger)
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
        ThemeManager.shared.updateUserInterfaceStyle(window: overlayWindow)
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
