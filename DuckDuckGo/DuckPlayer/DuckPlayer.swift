//
//  DuckPlayer.swift
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

import BrowserServicesKit
import Common
import Combine
import Foundation
import WebKit
import UserScript
import Core

enum DuckPlayerMode: Equatable, Codable, CustomStringConvertible, CaseIterable {
    case enabled, alwaysAsk, disabled
    
    private static let enabledString = "enabled"
    private static let alwaysAskString = "alwaysAsk"
    private static let neverString = "alwaysAsk"
    
    var description: String {
        switch self {
        case .enabled:
            return UserText.duckPlayerAlwaysEnabledLabel
        case .alwaysAsk:
            return UserText.duckPlayerAskLabel
        case .disabled:
            return UserText.duckPlayerDisabledLabel
        }
    }
    
    var stringValue: String {
        switch self {
        case .enabled:
            return Self.enabledString
        case .alwaysAsk:
            return Self.alwaysAskString
        case .disabled:
            return Self.neverString
        }
    }

    init?(stringValue: String) {
        switch stringValue {
        case Self.enabledString:
            self = .enabled
        case Self.alwaysAskString:
            self = .alwaysAsk
        case Self.neverString:
            self = .disabled
        default:
            return nil
        }
    }
}

/// Values that the Frontend can use to determine the current state.
struct InitialSetupSettings: Codable {
    struct PlayerSettings: Codable {
        let pip: PIP
    }

    struct PIP: Codable {
        let status: Status
    }

    enum Status: String, Codable {
        case enabled
        case disabled
    }

    let userValues: UserValues
    let settings: PlayerSettings
}

/// Values that the Frontend can use to determine user settings
public struct UserValues: Codable {
    enum CodingKeys: String, CodingKey {
        case duckPlayerMode = "privatePlayerMode"
        case overlayInteracted
    }
    let duckPlayerMode: DuckPlayerMode
    let overlayInteracted: Bool
}

class DuckPlayerSettings {
    
    @UserDefaultsWrapper(key: .duckPlayerMode, defaultValue: .alwaysAsk)
    var mode: DuckPlayerMode
    
    @UserDefaultsWrapper(key: .duckPlayerOverlayInteracted, defaultValue: false)
    var overlayInteracted: Bool
    
    @UserDefaultsWrapper(key: .duckPlayerOverlayButtonsUsed, defaultValue: false)
    var overlayButtonsUsed: Bool
    
}

final class DuckPlayer {
    
    static let duckPlayerHost: String = "player"
    static let commonName = "Duck Player"
        
    private var settings: DuckPlayerSettings
    
    // @Published var mode: DuckPlayerMode
    // @Published var overlayInteracted: Bool
    // @Published var overlayButtonsUsed: Bool
    

    init(settings: DuckPlayerSettings = DuckPlayerSettings()) {
        self.settings = settings
    }

    // MARK: - Common Message Handlers
    
    public func handleSetUserValuesMessage(
        from origin: YoutubeOverlayUserScript.MessageOrigin
    ) -> (_ params: Any, _ message: UserScriptMessage) -> Encodable? {

        return { [weak self] params, _ -> Encodable? in
            guard let self else {
                return nil
            }
            guard let userValues: UserValues = DecodableHelper.decode(from: params) else {
                assertionFailure("YoutubeOverlayUserScript: expected JSON representation of UserValues")
                return nil
            }
                
            return self.encodeUserValues()
        }
    }

    public func handleGetUserValues(params: Any, message: UserScriptMessage) -> Encodable? {
        encodeUserValues()
    }

    public func initialSetup(with webView: WKWebView?) -> (_ params: Any, _ message: UserScriptMessage) async -> Encodable? {
        return { _, _ in
            return await self.encodedSettings(with: webView)
        }
    }

    private func encodeUserValues() -> UserValues {
        UserValues(
            duckPlayerMode: settings.mode,
            overlayInteracted: settings.overlayInteracted
        )
    }

    @MainActor
    private func encodedSettings(with webView: WKWebView?) async -> InitialSetupSettings {
        let isPiPEnabled = webView?.configuration.allowsPictureInPictureMediaPlayback == true
        let pip = InitialSetupSettings.PIP(status: isPiPEnabled ? .enabled : .disabled)

        let playerSettings = InitialSetupSettings.PlayerSettings(pip: pip)
        let userValues = encodeUserValues()

        return InitialSetupSettings(userValues: userValues, settings: playerSettings)
    }

    // MARK: - Private

    private static let websiteTitlePrefix = "\(commonName) - "
}
