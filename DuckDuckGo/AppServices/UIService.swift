//
//  UIService.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

final class UIService: NSObject {

    var overlayWindow: UIWindow?
    let window: UIWindow

    var showKeyboardIfSettingOn = true // temporary

    init(window: UIWindow) {
        self.window = window
    }

    func displayBlankSnapshotWindow(voiceSearchHelper: VoiceSearchHelper,
                                    addressBarPosition: AddressBarPosition) {
        guard overlayWindow == nil else { return }

        overlayWindow = UIWindow(frame: window.frame)
        overlayWindow?.windowLevel = UIWindow.Level.alert

        // TODO: most likely we do not need voiceSearchHelper for BlankSnapshotVC
        let overlay = BlankSnapshotViewController(addressBarPosition: addressBarPosition, voiceSearchHelper: voiceSearchHelper)
        overlay.delegate = self

        overlayWindow?.rootViewController = overlay
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

    func tryToObtainOverlayWindow() {
        for window in UIApplication.shared.foregroundSceneWindows where window.rootViewController is BlankSnapshotViewController {
            overlayWindow = window
            return
        }
    }

    func displayAuthenticationWindow() {
        guard overlayWindow == nil else { return }
        overlayWindow = UIWindow(frame: window.frame)
        overlayWindow?.windowLevel = UIWindow.Level.alert
        overlayWindow?.rootViewController = AuthenticationViewController.loadFromStoryboard()
        overlayWindow?.makeKeyAndVisible()
        window.isHidden = true
    }

}

extension UIService: BlankSnapshotViewRecoveringDelegate {

    func recoverFromPresenting(controller: BlankSnapshotViewController) {
        if overlayWindow == nil {
            tryToObtainOverlayWindow()
        }

        overlayWindow?.isHidden = true
        overlayWindow = nil
        window.makeKeyAndVisible()
    }

}

extension UIService: UIScreenshotServiceDelegate {

    func screenshotService(_ screenshotService: UIScreenshotService,
                           generatePDFRepresentationWithCompletion completionHandler: @escaping (Data?, Int, CGRect) -> Void) {
        guard let mainViewController = window.rootViewController as? MainViewController, // todo, will it be needed?
              let webView = mainViewController.currentTab?.webView else {
            completionHandler(nil, 0, .zero)
            return
        }

        let zoomScale = webView.scrollView.zoomScale

        // The PDF's coordinate space has its origin at the bottom left, so the view's origin.y needs to be converted
        let visibleBounds = CGRect(
            x: webView.scrollView.contentOffset.x / zoomScale,
            y: (webView.scrollView.contentSize.height - webView.scrollView.contentOffset.y - webView.bounds.height) / zoomScale,
            width: webView.bounds.width / zoomScale,
            height: webView.bounds.height / zoomScale
        )

        webView.createPDF { result in
            let data = try? result.get()
            completionHandler(data, 0, visibleBounds)
        }
    }

}
