//
//  YoutubePlayerUserScript.swift
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

import WebKit
import Common
import UserScript
import Combine

final class YoutubePlayerUserScript: NSObject, Subfeature {
    
    var duckPlayer: DuckPlayerControlling
    private var cancellables = Set<AnyCancellable>()
    
    struct Constants {
        static let featureName = "duckPlayerPage"
    }
    
    struct Handlers {
        static let setUserValues = "setUserValues"
        static let getUserValues = "getUserValues"
        static let initialSetup = "initialSetup"
        static let openSettings = "openSettings"
        static let openInfo = "openInfo"
        static let telemetryEvent = "telemetryEvent"
        static let reportYouTubeError = "reportYouTubeError"
    }
    
    init(duckPlayer: DuckPlayerControlling) {
        self.duckPlayer = duckPlayer
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
    
    weak var broker: UserScriptMessageBroker?
    weak var webView: WKWebView?
    
    // Allow all origins as this is a 'specialPage'
    public let messageOriginPolicy: MessageOriginPolicy = .all
    public let featureName: String = Constants.featureName

    // MARK: - Subfeature

    public func with(broker: UserScriptMessageBroker) {
        self.broker = broker
    }

    func handler(forMethodNamed methodName: String) -> Subfeature.Handler? {
        switch methodName {
        case Handlers.getUserValues:
            return duckPlayer.getUserValues
        case Handlers.setUserValues:
            return duckPlayer.setUserValues
        case Handlers.initialSetup:
            return duckPlayer.initialSetupPlayer
        case Handlers.openSettings:
            return duckPlayer.openDuckPlayerSettings
        case Handlers.openInfo:
            return duckPlayer.openDuckPlayerInfo
        case Handlers.telemetryEvent:
            return duckPlayer.telemetryEvent
        case Handlers.reportYouTubeError:
            return duckPlayer.handleYoutubeError
        default:
            assertionFailure("YoutubePlayerUserScript: Failed to parse User Script message: \(methodName)")
            return nil
        }
    }

    public func userValuesUpdated(userValues: UserValues) {
        if let webView {
            broker?.push(method: "onUserValuesChanged", params: userValues, for: self, into: webView)
        }
    }
    
    private func handleSettingsChange() {
        let values = UserValues(duckPlayerMode: duckPlayer.settings.mode, askModeOverlayHidden: duckPlayer.settings.askModeOverlayHidden)
        userValuesUpdated(userValues: values)
    }
    
    deinit {
        cancellables.removeAll()
    }
    
}
