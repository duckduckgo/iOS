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
import Core
import BrowserServicesKit
import DuckPlayer

final class YoutubeOverlayUserScript: NSObject, Subfeature {
        
    var duckPlayer: DuckPlayerControlling
    private var cancellables = Set<AnyCancellable>()
    var statisticsStore: StatisticsStore
    private var duckPlayerStorage: DuckPlayerStorage
    struct Constants {
        static let featureName = "duckPlayer"
    }
    
    init(duckPlayer: DuckPlayerControlling,
         statisticsStore: StatisticsStore = StatisticsUserDefaults(),
         duckPlayerStorage: DuckPlayerStorage = DefaultDuckPlayerStorage()) {
        self.duckPlayer = duckPlayer
        self.statisticsStore = statisticsStore
        self.duckPlayerStorage = duckPlayerStorage
        super.init()
        subscribeToDuckPlayerMode()
    }
    
    // Listen to DuckPlayer Settings changed
    private func subscribeToDuckPlayerMode() {
        duckPlayer.settings.duckPlayerSettingsPublisher
            .sink { [weak self] in
                self?.handleSettingsChange()
            }
            .store(in: &cancellables)
    }
    
    struct Handlers {
        static let setUserValues = "setUserValues"
        static let getUserValues = "getUserValues"
        static let openDuckPlayer = "openDuckPlayer"
        static let sendDuckPlayerPixel = "sendDuckPlayerPixel"
        static let initialSetup = "initialSetup"
        static let openInfo = "openInfo"
    }

    weak var broker: UserScriptMessageBroker?
    weak var webView: WKWebView?
    
    let messageOriginPolicy: MessageOriginPolicy = .only(rules: [
        .exact(hostname: "sosbourne.duckduckgo.com"),
        .exact(hostname: "use-devtesting18.duckduckgo.com"),
        .exact(hostname: DuckPlayerSettingsDefault.OriginDomains.duckduckgo),
        .exact(hostname: DuckPlayerSettingsDefault.OriginDomains.youtube),
        .exact(hostname: DuckPlayerSettingsDefault.OriginDomains.youtubeMobile),
        .exact(hostname: DuckPlayerSettingsDefault.OriginDomains.youtubeWWW)
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
        case Handlers.initialSetup:
            return duckPlayer.initialSetupOverlay
        case Handlers.openInfo:
            return duckPlayer.openDuckPlayerInfo
        default:
            assertionFailure("YoutubeOverlayUserScript: Failed to parse User Script message: \(methodName)")
            // TODO: Send pixel here
            return nil
        }
    }

    public func userValuesUpdated(userValues: UserValues) {
        if let webView {
            broker?.push(method: "onUserValuesChanged", params: userValues, for: self, into: webView)
        }
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

    private func handleSettingsChange() {
        let values = UserValues(duckPlayerMode: duckPlayer.settings.mode, askModeOverlayHidden: duckPlayer.settings.askModeOverlayHidden)
        userValuesUpdated(userValues: values)
    }
    
    deinit {
        cancellables.removeAll()
    }
}

extension YoutubeOverlayUserScript {
    @MainActor
    func handleSendJSPixel(params: Any, message: UserScriptMessage) -> Encodable? {
         guard let body = message.messageBody as? [String: Any], let parameters = body["params"] as? [String: Any] else {
            return nil
         }
         let pixelName = parameters["pixelName"] as? String
        
        switch pixelName {
        case "play.use":
            Pixel.fire(pixel: Pixel.Event.duckPlayerViewFromYoutubeViaMainOverlay, debounce: 2)
            duckPlayerStorage.userInteractedWithDuckPlayer = true
                        
        case "play.do_not_use":
            Pixel.fire(pixel: Pixel.Event.duckPlayerOverlayYoutubeWatchHere, debounce: 2)
            duckPlayerStorage.userInteractedWithDuckPlayer = true

        case "overlay":
            Pixel.fire(pixel: Pixel.Event.duckPlayerOverlayYoutubeImpressions, debounce: 2)
            
        default:
            break
        }

        return nil
    }
}
