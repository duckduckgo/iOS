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
    
    private var duckPlayer: DuckPlayer
    
    struct Constants {
        static let featureName = "duckPlayerPage"
    }
    
    struct Handlers {
        static let setUserValues = "setUserValues"
        static let getUserValues = "getUserValues"
        static let initialSetup = "initialSetup"
    }
    
    private var userValuesCancellable = Set<AnyCancellable>()
    
    init(duckPlayer: DuckPlayer) {
        self.duckPlayer = duckPlayer
        super.init()
        subscribeToDuckPlayerMode()
    }
    
    // Listen to DuckPlayer Settings changed
    private func subscribeToDuckPlayerMode() {
        duckPlayer.$userValues
            .dropFirst()
            .sink { [weak self] updatedValues in
                self?.userValuesUpdated(userValues: updatedValues)
            }
            .store(in: &userValuesCancellable)
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
            return duckPlayer.initialSetup
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
    
    deinit {
        userValuesCancellable.removeAll()
    }
}
