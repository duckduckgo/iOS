//
//  YoutubeOverlayUserScript.swift
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import UserScript
// import PixelKit

protocol YoutubeOverlayUserScriptDelegate: AnyObject {
    func youtubeOverlayUserScriptDidRequestDuckPlayer(with url: URL, in webView: WKWebView)
}

final class YoutubeOverlayUserScript: NSObject, Subfeature {

    enum MessageOrigin {
        case duckPlayer, serpOverlay, youtubeOverlay

        init?(url: URL) {
            switch url.host {
            case "duckduckgo.com":
                self = .serpOverlay
            case "www.youtube.com":
                self = .youtubeOverlay
            default:
                return nil
            }
        }
    }

    // let duckPlayerPreferences: DuckPlayerPreferences
    weak var broker: UserScriptMessageBroker?
    weak var delegate: YoutubeOverlayUserScriptDelegate?
    weak var webView: WKWebView?
    let messageOriginPolicy: MessageOriginPolicy = .only(rules: [
        .exact(hostname: "www.youtube.com"),
        .exact(hostname: "duckduckgo.com")
    ])
    public var featureName: String = "duckPlayer"

    /*init(duckPlayerPreferences: DuckPlayerPreferences = DuckPlayerPreferences.shared) {
        self.duckPlayerPreferences = duckPlayerPreferences
    }*/

    // MARK: - Subfeature

    func with(broker: UserScriptMessageBroker) {
        self.broker = broker
    }

    // MARK: - MessageNames

    enum MessageNames: String, CaseIterable {
        case setUserValues
        case getUserValues
        case openDuckPlayer
        case sendDuckPlayerPixel
    }

    func handler(forMethodNamed methodName: String) -> Subfeature.Handler? {
        switch MessageNames(rawValue: methodName) {
        case .setUserValues:
            guard let url = webView?.url, let origin = MessageOrigin(url: url) else {
                assertionFailure("YoutubeOverlayUserScript: Unexpected message origin: \(String(describing: webView?.url))")
                return nil
            }
            return DuckPlayer.shared.handleSetUserValuesMessage(from: origin)
        case .getUserValues:
            return DuckPlayer.shared.handleGetUserValues
        case .openDuckPlayer:
            return handleOpenDuckPlayer
        case .sendDuckPlayerPixel:
            return handleSendJSPixel
        default:
            assertionFailure("YoutubeOverlayUserScript: Failed to parse User Script message: \(methodName)")
            return nil
        }
    }

    public func userValuesUpdated(userValues: UserValues) {
        guard let webView = webView else {
            return assertionFailure("Could not access webView")
        }
        broker?.push(method: "onUserValuesChanged", params: userValues, for: self, into: webView)
    }

    // MARK: - Private Methods

    @MainActor
    private func handleOpenDuckPlayer(params: Any, message: UserScriptMessage) -> Encodable? {
        guard let dict = params as? [String: Any],
              let href = dict["href"] as? String,
              let url = href.url,
              url.isDuckURLScheme,
              let webView = message.messageWebView
        else {
            assertionFailure("YoutubeOverlayUserScript: expected duck:// URL")
            return nil
        }
        self.delegate?.youtubeOverlayUserScriptDidRequestDuckPlayer(with: url, in: webView)
        return nil
    }

    // MARK: - UserValuesNotification

    struct UserValuesNotification: Encodable {
        let userValuesNotification: UserValues
    }
}

extension YoutubeOverlayUserScript {
    @MainActor
    func handleSendJSPixel(params: Any, message: UserScriptMessage) -> Encodable? {
        guard let body = message.messageBody as? [String: Any], let parameters = body["params"] as? [String: Any] else {
            return nil
        }
        let pixelName = parameters["pixelName"] as? String

        /*
        switch pixelName {
        case "play.use":
            duckPlayerPreferences.youtubeOverlayAnyButtonPressed = true
            PixelKit.fire(GeneralPixel.duckPlayerViewFromYoutubeViaMainOverlay)
            // Temporary pixel for first time user uses Duck Player
            if AppDelegate.isNewUser {
                PixelKit.fire(GeneralPixel.watchInDuckPlayerInitial, frequency: .legacyInitial)
            }
        case "play.do_not_use":
            duckPlayerPreferences.youtubeOverlayAnyButtonPressed = true
            PixelKit.fire(GeneralPixel.duckPlayerOverlayYoutubeWatchHere)
        case "overlay":
            PixelKit.fire(GeneralPixel.duckPlayerOverlayYoutubeImpressions)
        default:
            break
        }
         */

        return nil
    }
}
