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

/// Values that the Frontend can use to determine the current state.
struct InitialSetupSettings: Codable {
    struct PlayerSettings: Codable {
        let pip: PIP
    }

    struct PIP: Codable {
        let status: Status
    }
    
    enum Platform: String, Codable {
        case ios
        case macos
    }

    enum Status: String, Codable {
        case enabled
        case disabled
    }
    
    enum Environment: String, Codable {
        case development
        case production
    }
    
    enum Locale: String, Codable {
        case en
    }

    let userValues: UserValues
    let settings: PlayerSettings
    let platform: Platform
    let locale: Locale
}


/// Values that the Frontend can use to determine user settings
public struct UserValues: Codable {
    enum CodingKeys: String, CodingKey {
        case duckPlayerMode = "privatePlayerMode"
        case askModeOverlayHidden = "overlayInteracted"
    }
    let duckPlayerMode: DuckPlayerMode
    let askModeOverlayHidden: Bool
}

public enum DuckPlayerReferrer {
    case youtube, other
}

protocol DuckPlayerProtocol {
    
    var settings: DuckPlayerSettingsProtocol { get }
    
    init(settings: DuckPlayerSettingsProtocol)

    func setUserValues(params: Any, message: WKScriptMessage) -> Encodable?
    func getUserValues(params: Any, message: WKScriptMessage) -> Encodable?
    func openVideoInDuckPlayer(url: URL, webView: WKWebView)
    
    func initialSetupPlayer(params: Any, message: WKScriptMessage) async -> Encodable?
    func initialSetupOverlay(params: Any, message: WKScriptMessage) async -> Encodable?
}

final class DuckPlayer: DuckPlayerProtocol {
    
    static let duckPlayerHost: String = "player"
    static let commonName = "Duck Player"
        
    private(set) var settings: DuckPlayerSettingsProtocol
    
    init(settings: DuckPlayerSettingsProtocol = DuckPlayerSettings()) {
        self.settings = settings
    }
    
    // MARK: - Common Message Handlers
    
    public func setUserValues(params: Any, message: WKScriptMessage) -> Encodable? {
        guard let userValues: UserValues = DecodableHelper.decode(from: params) else {
            assertionFailure("DuckPlayer: expected JSON representation of UserValues")
            return nil
        }
        settings.setMode(userValues.duckPlayerMode)
        settings.setOverlayHidden(userValues.askModeOverlayHidden)
        return userValues
    }
        
    public func getUserValues(params: Any, message: WKScriptMessage) -> Encodable? {
        encodeUserValues()
    }
    
    @MainActor
    public func openVideoInDuckPlayer(url: URL, webView: WKWebView) {
        webView.load(URLRequest(url: url))
    }

    @MainActor
    public func initialSetupPlayer(params: Any, message: WKScriptMessage) async -> Encodable? {
        let webView = message.webView
        return await self.encodedPlayerSettings(with: webView)
    }
    
    @MainActor
    public func initialSetupOverlay(params: Any, message: WKScriptMessage) async -> Encodable? {
        let webView = message.webView
        return await self.encodedPlayerSettings(with: webView)
    }

    private func encodeUserValues() -> UserValues {
        UserValues(
            duckPlayerMode: settings.mode,
            askModeOverlayHidden: settings.askModeOverlayHidden
        )
    }

    @MainActor
    private func encodedPlayerSettings(with webView: WKWebView?) async -> InitialSetupSettings {
        let isPiPEnabled = webView?.configuration.allowsPictureInPictureMediaPlayback == true
        let pip = InitialSetupSettings.PIP(status: isPiPEnabled ? .enabled : .disabled)
        let platform = InitialSetupSettings.Platform.ios
        let environment = InitialSetupSettings.Environment.development
        let locale = InitialSetupSettings.Locale.en
        let playerSettings = InitialSetupSettings.PlayerSettings(pip: pip)
        let userValues = encodeUserValues()
        return InitialSetupSettings(userValues: userValues, settings: playerSettings, platform: platform, locale: locale)
    }
    
    @MainActor
    private func encodedOverlaySettings(with webView: WKWebView?) async -> InitialSetupSettings {
        let isPiPEnabled = webView?.configuration.allowsPictureInPictureMediaPlayback == true
        let pip = InitialSetupSettings.PIP(status: isPiPEnabled ? .enabled : .disabled)
        let platform = InitialSetupSettings.Platform.ios
        let environment = InitialSetupSettings.Environment.development
        let locale = InitialSetupSettings.Locale.en
        let playerSettings = InitialSetupSettings.PlayerSettings(pip: pip)
        let userValues = encodeUserValues()
        return InitialSetupSettings(userValues: userValues, settings: playerSettings, platform: platform, locale: locale)
    }
    
}
