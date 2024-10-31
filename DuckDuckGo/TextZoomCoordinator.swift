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

    var isEnabled: Bool { get }
    var storage: TextZoomStoring { get }

    func onNavigationCommitted(applyToWebView webView: WKWebView)
    func onShowTextZoomEditor(inController controller: UIViewController, forWebView webView: WKWebView)
    func onTextZoomChange(applyToWebView webView: WKWebView)
    func makeBrowsingMenuEntry(forLink: Link, inController controller: UIViewController, forWebView webView: WKWebView) -> BrowsingMenuEntry?

}

// TODO validate wikipedia which had a hardcoded exception
final class TextZoomCoordinator: TextZoomCoordinating {

    let appSettings: AppSettings
    let storage: TextZoomStoring
    let featureFlagger: FeatureFlagger

    var isEnabled: Bool {
        featureFlagger.isFeatureOn(.textZoom)
    }

    init(appSettings: AppSettings, storage: TextZoomStoring, featureFlagger: FeatureFlagger) {
        self.appSettings = appSettings
        self.storage = storage
        self.featureFlagger = featureFlagger
    }

    func onNavigationCommitted(applyToWebView webView: WKWebView) {
        guard isEnabled else { return }
        // TODO logic from textsize.js
    }

    func onTextZoomChange(applyToWebView webView: WKWebView) {
        guard isEnabled else { return }

        let domain = TLD().eTLDplus1(webView.url?.host) ?? ""
        // If the webview returns no host then there won't be a setting for a blank string anyway.
        let level = storage.textZoomLevelForDomain(domain)
            // And if there's no setting for whatever domain is passed in, use the app default
            ?? appSettings.defaultTextZoomLevel
        webView.applyViewScale(CGFloat(level.rawValue) / 100)
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

        zoomController.present(controller, animated: true)
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
        // TODO
    }

}
