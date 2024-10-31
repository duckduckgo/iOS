//
//  TextZoomCoordinator.swift
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

import Foundation
import WebKit
import Common
import BrowserServicesKit
import Core

protocol TextZoomCoordinating {

    /// Based on .textZoom feature flag
    var isEnabled: Bool { get }

    /// Storeage for setting and domain specific values
    var storage: TextZoomStoring { get }

    // MARK: Applying the text zoom
    func onWebViewCreated(applyToWebView webView: WKWebView)
    func onNavigationCommitted(applyToWebView webView: WKWebView)
    func onTextZoomChange(applyToWebView webView: WKWebView)

    // MARK: Support operations for the UI
    func onShowTextZoomEditor(inController controller: UIViewController, forWebView webView: WKWebView)
    func makeBrowsingMenuEntry(forLink: Link, inController controller: UIViewController, forWebView webView: WKWebView) -> BrowsingMenuEntry?

}

final class TextZoomCoordinator: TextZoomCoordinating {

    let appSettings: AppSettings
    let storage: TextZoomStoring
    let featureFlagger: FeatureFlagger

    var isEnabled: Bool {
        // TODO featureFlagger.isFeatureOn(.textZoom)
        true
    }

    init(appSettings: AppSettings, storage: TextZoomStoring, featureFlagger: FeatureFlagger) {
        self.appSettings = appSettings
        self.storage = storage
        self.featureFlagger = featureFlagger
    }

    func onWebViewCreated(applyToWebView webView: WKWebView) {
        applyTextZoom(webView)
    }

    func onNavigationCommitted(applyToWebView webView: WKWebView) {
        applyTextZoom(webView)
    }

    func onTextZoomChange(applyToWebView webView: WKWebView) {
        applyTextZoom(webView)
    }

    private func applyTextZoom(_ webView: WKWebView) {
        guard isEnabled else { return }

        let domain = TLD().eTLDplus1(webView.url?.host) ?? ""
        // If the webview returns no host then there won't be a setting for a blank string anyway.
        let level = storage.textZoomLevelForDomain(domain)
            // And if there's no setting for whatever domain is passed in, use the app default
            ?? appSettings.defaultTextZoomLevel

        let dynamicTypeScalePercentage = UIFontMetrics.default.scaledValue(for: 1.0)
        let viewScale = CGFloat(level.rawValue) / 100 * dynamicTypeScalePercentage

        webView.applyViewScale(viewScale)
    }

    @MainActor
    func onShowTextZoomEditor(inController controller: UIViewController, forWebView webView: WKWebView) {
        guard isEnabled else { return }

        guard let domain = TLD().eTLDplus1(webView.url?.host) else { return }
        let zoomController = TextZoomController(
            domain: domain,
            storage: storage,
            defaultTextZoom: appSettings.defaultTextZoomLevel
        )

        zoomController.modalPresentationStyle = .formSheet
        if #available(iOS 16.0, *) {
            zoomController.sheetPresentationController?.detents = [.custom(resolver: { _ in
                return 152
            })]

            zoomController.sheetPresentationController?.prefersScrollingExpandsWhenScrolledToEdge = false
            zoomController.sheetPresentationController?.prefersEdgeAttachedInCompactHeight = true
            zoomController.sheetPresentationController?.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        } else {
            zoomController.sheetPresentationController?.detents = [.medium()]
        }

        controller.present(zoomController, animated: true)
    }

    func makeBrowsingMenuEntry(forLink: Link,
                               inController controller: UIViewController,
                               forWebView webView: WKWebView) -> BrowsingMenuEntry? {
        guard isEnabled else { return nil }
        return BrowsingMenuEntry.regular(name: UserText.textZoomMenuItem,
                                         image: UIImage(named: "Type-Size-16")!,
                                         showNotificationDot: false) { [weak self, weak controller, weak webView] in
            guard let self = self, let controller = controller, let webView = webView else { return }
            Task { @MainActor in
                self.onShowTextZoomEditor(inController: controller, forWebView: webView)
                Pixel.fire(pixel: .browsingMenuZoom)
            }
        }
    }
}

extension WKWebView {

    func applyViewScale(_ scale: CGFloat) {
        let key = "viewScale"
        guard responds(to: NSSelectorFromString("_\(key)")) else {
            assertionFailure("viewScale API has changed")
            return
        }
        setValue(scale, forKey: key)
    }

}
