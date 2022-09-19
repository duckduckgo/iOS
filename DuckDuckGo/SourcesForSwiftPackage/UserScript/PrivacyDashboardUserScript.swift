//
//  PrivacyDashboardUserScript.swift
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

import WebKit
import os
import BrowserServicesKit
import TrackerRadarKit

protocol PrivacyDashboardUserScriptDelegate: AnyObject {

    func userScript(_ userScript: PrivacyDashboardUserScript, didChangeProtectionStateTo protectionState: Bool)
    func userScript(_ userScript: PrivacyDashboardUserScript, setHeight height: Int)
    func userScriptDidRequestClosing(_ userScript: PrivacyDashboardUserScript)
    func userScriptDidRequestShowReportBrokenSite(_ userScript: PrivacyDashboardUserScript)

}

final class PrivacyDashboardUserScript: NSObject, StaticUserScript {

    enum MessageNames: String, CaseIterable {
        case privacyDashboardSetProtection
        case privacyDashboardFirePixel
        case privacyDashboardClose
        case privacyDashboardShowReportBrokenSite
    }

    static var injectionTime: WKUserScriptInjectionTime { .atDocumentStart }
    static var forMainFrameOnly: Bool { false }
    static var source: String = ""
    static var script: WKUserScript = PrivacyDashboardUserScript.makeWKUserScript()
    var messageNames: [String] { MessageNames.allCases.map(\.rawValue) }

    weak var delegate: PrivacyDashboardUserScriptDelegate?

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let messageType = MessageNames(rawValue: message.name) else {
            assertionFailure("PrivacyDashboardUserScript: unexpected message name \(message.name)")
            return
        }

        switch messageType {
        case .privacyDashboardSetProtection:
            handleSetProtection(message: message)
        case .privacyDashboardFirePixel:
            handleFirePixel(message: message)
        case .privacyDashboardClose:
            handleClose()
        case .privacyDashboardShowReportBrokenSite:
            handleShowReportBrokenSite()
        }
    }

    private func handleSetProtection(message: WKScriptMessage) {
        guard let isProtected = message.body as? Bool else {
            assertionFailure("privacyDashboardSetProtection: expected Bool")
            return
        }

        delegate?.userScript(self, didChangeProtectionStateTo: isProtected)
    }

    private func handleFirePixel(message: WKScriptMessage) {
//        guard let pixel = message.body as? String else {
//            assertionFailure("privacyDashboardFirePixel: expected Pixel String")
//            return
//        }
//
//        let etag = ContentBlocking.shared.contentBlockingManager.currentRules.first?.etag
//                    .trimmingCharacters(in: CharacterSet(charactersIn: "\"")) ?? ""
//        Pixel.shared?.fire(pixelNamed: pixel,
//                           withAdditionalParameters: [
//                            "tds": etag
//        ])
    }

    private func handleClose() {
        delegate?.userScriptDidRequestClosing(self)
    }
    
    private func handleShowReportBrokenSite() {
        delegate?.userScriptDidRequestShowReportBrokenSite(self)
    }

    func setTrackerInfo(_ tabUrl: URL, trackerInfo: TrackerInfo, webView: WKWebView) {
        guard let trackerBlockingDataJson = try? JSONEncoder().encode(trackerInfo).utf8String() else {
            assertionFailure("Can't encode trackerInfoViewModel into JSON")
            return
        }

        guard let safeTabUrl = try? JSONEncoder().encode(tabUrl).utf8String() else {
            assertionFailure("Can't encode tabUrl into JSON")
            return
        }

        evaluate(js: "window.onChangeTrackerBlockingData(\(safeTabUrl), \(trackerBlockingDataJson))", in: webView)
    }

    func setProtectionStatus(_ isProtected: Bool, webView: WKWebView) {
        evaluate(js: "window.onChangeProtectionStatus(\(isProtected))", in: webView)
    }

    func setUpgradedHttps(_ upgradedHttps: Bool, webView: WKWebView) {
        evaluate(js: "window.onChangeUpgradedHttps(\(upgradedHttps))", in: webView)
    }

    func setParentEntity(_ parentEntity: Entity?, webView: WKWebView) {
        if parentEntity == nil { return }

        guard let parentEntityJson = try? JSONEncoder().encode(parentEntity).utf8String() else {
            assertionFailure("Can't encode parentEntity into JSON")
            return
        }

        evaluate(js: "window.onChangeParentEntity(\(parentEntityJson))", in: webView)
    }

    func setTheme(_ themeName: String?, webView: WKWebView) {
        if themeName == nil { return }

        guard let themeNameJson = try? JSONEncoder().encode(themeName).utf8String() else {
            assertionFailure("Can't encode themeName into JSON")
            return
        }

        evaluate(js: "window.onChangeTheme(\(themeNameJson))", in: webView)
    }

    func setServerTrust(_ serverTrustViewModel: ServerTrustViewModel, webView: WKWebView) {
        guard let certificateDataJson = try? JSONEncoder().encode(serverTrustViewModel).utf8String() else {
            assertionFailure("Can't encode serverTrustViewModel into JSON")
            return
        }

        evaluate(js: "window.onChangeCertificateData(\(certificateDataJson))", in: webView)
    }

    func setIsPendingUpdates(_ isPendingUpdates: Bool, webView: WKWebView) {
        evaluate(js: "window.onIsPendingUpdates(\(isPendingUpdates))", in: webView)
    }

    private func evaluate(js: String, in webView: WKWebView) {
        webView.evaluateJavaScript(js)
    }

}

extension Data {

    func utf8String() -> String? {
        return String(data: self, encoding: .utf8)
    }

}
