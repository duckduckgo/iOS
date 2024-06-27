//
//  YoutubeOverlayUserScript.swift
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
import UserScript
import Combine

final class YoutubeOverlayUserScript: NSObject, Subfeature {
        
    private var duckPlayer: DuckPlayer
    private var userValuesCancellable = Set<AnyCancellable>()
    weak var webView: WKWebView?
    
    struct Constants {
        static let featureName = "duckPlayer"
    }
    
    init(duckPlayer: DuckPlayer) {
        self.duckPlayer = duckPlayer
        super.init()
        subscribeToDuckPlayerMode()
    }
    
    // Listen to DuckPlayer Settings changed
    private func subscribeToDuckPlayerMode() {
        duckPlayer.$userValues
            .sink { [weak self] updatedValues in
                self?.userValuesUpdated(userValues: updatedValues)
            }
            .store(in: &userValuesCancellable)
    }
    
    enum MessageOrigin {
        case duckPlayer, serpOverlay, youtubeOverlay

        init?(url: URL) {
            switch url.host {
            case DuckPlayerSettings.OriginDomains.duckduckgo:
                self = .serpOverlay
            case DuckPlayerSettings.OriginDomains.youtubeMobile:
                self = .youtubeOverlay
            case DuckPlayerSettings.OriginDomains.youtube:
                self = .youtubeOverlay
            case DuckPlayerSettings.OriginDomains.youtubeWWW:
                self = .youtubeOverlay
            default:
                return nil
            }
        }
    }
    
    struct Handlers {
        static let setUserValues = "setUserValues"
        static let getUserValues = "getUserValues"
        static let openDuckPlayer = "openDuckPlayer"
        static let sendDuckPlayerPixel = "sendDuckPlayerPixel"
    }

    weak var broker: UserScriptMessageBroker?
    weak var webView: WKWebView?
    
    let messageOriginPolicy: MessageOriginPolicy = .only(rules: [
        .exact(hostname: DuckPlayerSettings.OriginDomains.duckduckgo),
        .exact(hostname: DuckPlayerSettings.OriginDomains.youtube),
        .exact(hostname: DuckPlayerSettings.OriginDomains.youtubeMobile)
    ])
    public var featureName: String = Constants.featureName

    // MARK: - Subfeature

    func with(broker: UserScriptMessageBroker) {
        self.broker = broker
    }

    // MARK: - MessageNames

    func handler(forMethodNamed methodName: String) -> Subfeature.Handler? {
        switch methodName {
        case Handlers.setUserValues:
            return duckPlayer.setUserValues
        case Handlers.getUserValues:
            return duckPlayer.getUserValues
        case Handlers.openDuckPlayer:
            return openDuckPlayer
        case Handlers.sendDuckPlayerPixel:
            return handleSendJSPixel
        default:
            assertionFailure("YoutubeOverlayUserScript: Failed to parse User Script message: \(methodName)")
            // TODO: Send pixel here
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
    private func openDuckPlayer(params: Any, original: WKScriptMessage) -> Encodable? {
        guard let dict = params as? [String: Any],
                let href = dict["href"] as? String,
                let url = href.url,
                let webView = original.webView else {
            assertionFailure("Could not parse WKMessage to obtain video details")
            // TODO: Send Pixel Here
            return nil
        }
        duckPlayer.openVideoInDuckPlayer(url: url, webView: webView)
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
        

        return nil
    }
}
