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
import ContentScopeScripts

/// Values that the Frontend can use to determine the current state.
struct InitialPlayerSettings: Codable {
    struct PlayerSettings: Codable {
        let pip: PIP
    }

    struct PIP: Codable {
        let status: Status
    }
    
    struct Platform: Codable {
        let name: String
    }

    enum Status: String, Codable {
        case enabled
        case disabled
    }
    
    enum Environment: String, Codable {
        case development
        case production
    }

    let userValues: UserValues
    let ui: UIValues
    let settings: PlayerSettings
    let platform: Platform
    let locale: String
    let localeStrings: String?
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

public struct UIValues: Codable {
    enum CodingKeys: String, CodingKey {
        case allowFirstVideo
    }
    let allowFirstVideo: Bool
}

public enum DuckPlayerReferrer {
    case youtube, other, serp
    
    // Computed property to get string values
        var stringValue: String {
            switch self {
            case .youtube:
                return "youtube"
            case .serp:
                return "serp"
            default:
                return "other"
                
            }
        }
}

protocol DuckPlayerProtocol: AnyObject {
    
    var settings: DuckPlayerSettings { get }
    var hostView: UIViewController? { get }
    
    init(settings: DuckPlayerSettings, featureFlagger: FeatureFlagger)

    func setUserValues(params: Any, message: WKScriptMessage) -> Encodable?
    func getUserValues(params: Any, message: WKScriptMessage) -> Encodable?
    func openVideoInDuckPlayer(url: URL, webView: WKWebView)
    func openDuckPlayerSettings(params: Any, message: WKScriptMessage) async -> Encodable?
    func openDuckPlayerInfo(params: Any, message: WKScriptMessage) async -> Encodable?
    
    func initialSetupPlayer(params: Any, message: WKScriptMessage) async -> Encodable?
    func initialSetupOverlay(params: Any, message: WKScriptMessage) async -> Encodable?
    
    func setHostViewController(_ vc: UIViewController)
}

final class DuckPlayer: DuckPlayerProtocol {
    
    struct Constants {
        static let duckPlayerHost: String = "player"
        static let commonName = "Duck Player"
        static let translationFile = "duckplayer"
        static let translationFileExtension = "json"
        static let defaultLocale = "en"
        static let translationPath = "pages/duckplayer/locales/"
        static let featureNameKey = "featureName"
    }
    
    private(set) var settings: DuckPlayerSettings
    private(set) weak var hostView: UIViewController?
    private var featureFlagger: FeatureFlagger
    
    private lazy var localeStrings: String? = {
        let languageCode = Locale.current.languageCode ?? Constants.defaultLocale
        if let localizedFile = ContentScopeScripts.Bundle.path(forResource: Constants.translationFile,
                                                               ofType: Constants.translationFileExtension,
                                                               inDirectory: "\(Constants.translationPath)\(languageCode)") {
            return try? String(contentsOfFile: localizedFile)
        }
        return nil
    }()
    
    private struct WKMessageData: Codable {
        var context: String?
        var featureName: String?
        var method: String?
    }
    
    private enum FeatureName: String {
        case page = "duckPlayerPage"
        case overlay = "duckPlayer"
    }
    
    init(settings: DuckPlayerSettings = DuckPlayerSettingsDefault(),
         featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger) {
        self.settings = settings
        self.featureFlagger = featureFlagger
    }
    
    // Sets a presenting VC, so DuckPlayer can present the
    // info sheet directly
    public func setHostViewController(_ vc: UIViewController) {
        hostView = vc
    }
    
    // MARK: - Common Message Handlers
    
    public func setUserValues(params: Any, message: WKScriptMessage) -> Encodable? {
        guard let userValues: UserValues = DecodableHelper.decode(from: params) else {
            assertionFailure("DuckPlayer: expected JSON representation of UserValues")
            return nil
        }
        
        Task {
            // Fires pixels
            await firePixels(message: message, userValues: userValues)
            
            // Update Settings
            await updateSettings(userValues: userValues)
        }
        return userValues
    }
        
    private func updateSettings(userValues: UserValues) async {
        settings.setMode(userValues.duckPlayerMode)
        settings.setAskModeOverlayHidden(userValues.askModeOverlayHidden)
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
    
    public func openDuckPlayerSettings(params: Any, message: WKScriptMessage) async -> Encodable? {
        NotificationCenter.default.post(
            name: .settingsDeepLinkNotification,
            object: SettingsViewModel.SettingsDeepLinkSection.duckPlayer,
            userInfo: nil
        )
        return nil
    }
    
    @MainActor
    public func presentDuckPlayerInfo(context: DuckPlayerModalPresenter.PresentationContext) {
        guard let hostView else { return }
        DuckPlayerModalPresenter(context: context).presentDuckPlayerFeatureModal(on: hostView)
    }
    
    @MainActor
    public func openDuckPlayerInfo(params: Any, message: WKScriptMessage) async -> Encodable? {
        guard let body = message.body as? [String: Any],
              let featureNameString = body[Constants.featureNameKey] as? String,
              let featureName = FeatureName(rawValue: featureNameString) else {
            return nil
        }
        let context: DuckPlayerModalPresenter.PresentationContext = featureName == .page ? .youtube : .SERP
        presentDuckPlayerInfo(context: context)
        return nil
    }

    private func encodeUserValues() -> UserValues {
        return UserValues(
            duckPlayerMode: featureFlagger.isFeatureOn(.duckPlayer) ? settings.mode : .disabled,
            askModeOverlayHidden: settings.askModeOverlayHidden
        )
    }
    
    private func encodeUIValues() -> UIValues {
        UIValues(
            allowFirstVideo: settings.allowFirstVideo
        )
    }

    @MainActor
    private func encodedPlayerSettings(with webView: WKWebView?) async -> InitialPlayerSettings {
        let isPiPEnabled = webView?.configuration.allowsPictureInPictureMediaPlayback == true
        let pip = InitialPlayerSettings.PIP(status: isPiPEnabled ? .enabled : .disabled)
        let platform = InitialPlayerSettings.Platform(name: "ios")
        let locale = Locale.current.languageCode ?? "en"
        let playerSettings = InitialPlayerSettings.PlayerSettings(pip: pip)
        let userValues = encodeUserValues()
        let uiValues = encodeUIValues()
        let settings = InitialPlayerSettings(userValues: userValues,
                                                   ui: uiValues,
                                                   settings: playerSettings,
                                                   platform: platform,
                                                   locale: locale,
                                                   localeStrings: localeStrings)
        return settings
    }
        
    // Accessing WKMessage needs main thread
    @MainActor
    private func firePixels(message: WKScriptMessage, userValues: UserValues) {
        
        guard let messageData: WKMessageData = DecodableHelper.decode(from: message.body) else {
            assertionFailure("DuckPlayer: expected JSON representation of Message")
            return
        }
        guard let feature = messageData.featureName else { return }
        let event: Pixel.Event = feature == FeatureName.page.rawValue ? .duckPlayerSettingAlwaysDuckPlayer : .duckPlayerSettingAlwaysDuckPlayer
        if userValues.duckPlayerMode == .enabled {
            Pixel.fire(pixel: event)
        }
       
    }
    
}
