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

/// Central point for coordinating text zoom activities.
/// * Host is used to represent unaltered host from a URL. Domain is a normalised host.
protocol TextZoomCoordinating {

    /// Based on .textZoom feature flag
    var isEnabled: Bool { get }

    /// @return The zoom level for a host or the current default if there isn't one.  Uses eTLDplus1 to determine the domain.
    func textZoomLevel(forHost host: String?) -> TextZoomLevel

    /// Sets the text zoom level for a host. Uses eLTDplus1 to determine the domain.
    /// If the level matches the global default then this specific level for the host is forgotten.
    func set(textZoomLevel level: TextZoomLevel, forHost host: String?)

    /// Reset, ie 'forget', the saved zoom levels for all domains except the ones specified.
    func resetTextZoomLevels(excludingDomains: [String])

    /// Applies appropriate text zoom to webview on creation,. Does nothing if feature is disabled.
    func onWebViewCreated(applyToWebView webView: WKWebView)

    /// Applies appropriate text zoom when navigation is committed. Does nothing if feature is disabled.
    func onNavigationCommitted(applyToWebView webView: WKWebView)

    /// Applies appropriate text zoom to webview when the text zoom has changed (e.g. in settings or for the current tab).
    ///  Does nothing if feature is disabled.
    func onTextZoomChange(applyToWebView webView: WKWebView)

    /// Shows a text zoom editor for the current webview. Does nothing if the feature is disabled.
    func showTextZoomEditor(inController controller: UIViewController, forWebView webView: WKWebView) async

    /// Creates a browsing menu entry for the given link.  Returns nil if the feature is disabled.
    func makeBrowsingMenuEntry(forLink: Link, inController controller: UIViewController, forWebView webView: WKWebView) -> BrowsingMenuEntry?

}

final class TextZoomCoordinator: TextZoomCoordinating {

    let appSettings: AppSettings
    let storage: TextZoomStoring
    let featureFlagger: FeatureFlagger
    let tld: TLD

    var isEnabled: Bool {
        featureFlagger.isFeatureOn(.textZoom)
    }

    init(appSettings: AppSettings, storage: TextZoomStoring, featureFlagger: FeatureFlagger, tld: TLD = TLD()) {
        self.appSettings = appSettings
        self.storage = storage
        self.featureFlagger = featureFlagger
        self.tld = tld
    }

    func textZoomLevel(forHost host: String?) -> TextZoomLevel {
        let domain = tld.eTLDplus1(host) ?? ""
        // If the webview returns no host then there won't be a setting for a blank string anyway.
        return storage.textZoomLevelForDomain(domain)
            // And if there's no setting for whatever domain is passed in, use the app default
            ?? appSettings.defaultTextZoomLevel
    }

    func set(textZoomLevel level: TextZoomLevel, forHost host: String?) {
        guard let domain = tld.eTLDplus1(host) else { return }
        if level == appSettings.defaultTextZoomLevel {
            storage.removeTextZoomLevel(forDomain: domain)
        } else {
            storage.set(textZoomLevel: level, forDomain: domain)
        }
    }

    func resetTextZoomLevels(excludingDomains domains: [String]) {
        storage.resetTextZoomLevels(excludingDomains: domains)
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
        let level = textZoomLevel(forHost: webView.url?.host)
        let viewScale = CGFloat(level.rawValue) / 100
        webView.applyViewScale(viewScale)
    }

    @MainActor
    func showTextZoomEditor(inController controller: UIViewController, forWebView webView: WKWebView) {
        guard isEnabled else { return }

        guard let domain = tld.eTLDplus1(webView.url?.host) else { return }
        let zoomController = TextZoomController(
            domain: domain,
            coordinator: self,
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

    func makeBrowsingMenuEntry(forLink link: Link,
                               inController controller: UIViewController,
                               forWebView webView: WKWebView) -> BrowsingMenuEntry? {
        guard isEnabled else { return nil }

        let label: String
        if let domain = tld.eTLDplus1(link.url.host),
           let level = storage.textZoomLevelForDomain(domain) {
            label = UserText.textZoomWithPercentForMenuItem(level.rawValue)
        } else {
            label = UserText.textZoomMenuItem
        }

        return BrowsingMenuEntry.regular(name: label,
                                         image: UIImage(named: "Type-Size-16")!,
                                         showNotificationDot: false) { [weak self, weak controller, weak webView] in
            guard let self = self, let controller = controller, let webView = webView else { return }
            Task { @MainActor in
                self.showTextZoomEditor(inController: controller, forWebView: webView)
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
