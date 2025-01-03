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

/// Values that the frontend can use to determine the current state.
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

/// Values that the frontend can use to determine user settings.
public struct UserValues: Codable {
    enum CodingKeys: String, CodingKey {
        case duckPlayerMode = "privatePlayerMode"
        case askModeOverlayHidden = "overlayInteracted"
    }
    let duckPlayerMode: DuckPlayerMode
    let askModeOverlayHidden: Bool
}

/// UI-related values for the frontend.
public struct UIValues: Codable {
    enum CodingKeys: String, CodingKey {
        case allowFirstVideo
    }
    let allowFirstVideo: Bool
}

// Wrapper to allow sibling properties on each event in the future.
struct TelemetryEvent: Decodable {
    let attributes: Attributes
}

// This is the first example of a new telemetry event
struct ImpressionAttributes: Decodable {
    enum Layout: String, Decodable {
        case landscape = "landscape-layout"
    }

    let name: String
    let value: Layout
}

// Designed to represent the discriminated union used by the FE (where all events are schema-driven)
enum Attributes: Decodable {

    // more events can be added here later, without needing a new handler
    case impression(ImpressionAttributes)

    private enum CodingKeys: String, CodingKey {
        case name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)

        switch name {
        case "impression":
            let attributes = try ImpressionAttributes(from: decoder)
            self = .impression(attributes)

        default:
            throw DecodingError.dataCorruptedError(
                forKey: .name,
                in: container,
                debugDescription: "Unknown name value: \(name)"
            )
        }
    }
}


/// Protocol defining the Duck Player functionality.
protocol DuckPlayerControlling: AnyObject {
    
    /// The current Duck Player settings.
    var settings: DuckPlayerSettings { get }
    
    /// The host view controller, if any.
    var hostView: UIViewController? { get }
    
    /// Initializes a new instance of DuckPlayer with the provided settings and feature flagger.
    ///
    /// - Parameters:
    ///   - settings: The Duck Player settings.
    ///   - featureFlagger: The feature flag manager.
    init(settings: DuckPlayerSettings, featureFlagger: FeatureFlagger)

    /// Sets user values received from the web content.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
    /// - Returns: An optional `Encodable` response.
    func setUserValues(params: Any, message: WKScriptMessage) -> Encodable?
    
    /// Retrieves user values to send to the web content.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
    /// - Returns: An optional `Encodable` response.
    func getUserValues(params: Any, message: WKScriptMessage) -> Encodable?
    
    /// Opens a video in Duck Player within the specified web view.
    ///
    /// - Parameters:
    ///   - url: The URL of the video.
    ///   - webView: The web view to load the video in.
    func openVideoInDuckPlayer(url: URL, webView: WKWebView)
    
    /// Opens Duck Player settings.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
    func openDuckPlayerSettings(params: Any, message: WKScriptMessage) async -> Encodable?
    
    /// Opens Duck Player information modal.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
    func openDuckPlayerInfo(params: Any, message: WKScriptMessage) async -> Encodable?
    
    /// Sends a telemetry event from the FE.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
    func telemetryEvent(params: Any, message: WKScriptMessage) async -> Encodable?
    
    /// Performs initial setup for the player.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
    /// - Returns: An optional `Encodable` response.
    func initialSetupPlayer(params: Any, message: WKScriptMessage) async -> Encodable?
    
    /// Performs initial setup for the overlay.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
    /// - Returns: An optional `Encodable` response.
    func initialSetupOverlay(params: Any, message: WKScriptMessage) async -> Encodable?
    
    /// Sets the host view controller for presenting modals.
    ///
    /// - Parameter vc: The view controller to set as host.
    func setHostViewController(_ vc: UIViewController)
    
    /// Removes the host view controller.
    func removeHostView()
}

/// Implementation of the DuckPlayerControlling.
final class DuckPlayer: DuckPlayerControlling {
    
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
    
    /// Initializes a new instance of DuckPlayer with the provided settings and feature flagger.
    ///
    /// - Parameters:
    ///   - settings: The Duck Player settings.
    ///   - featureFlagger: The feature flag manager.
    init(settings: DuckPlayerSettings = DuckPlayerSettingsDefault(),
         featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger) {
        self.settings = settings
        self.featureFlagger = featureFlagger
    }
    
    /// Sets the host view controller for presenting modals.
    ///
    /// - Parameter vc: The view controller to set as host.
    public func setHostViewController(_ vc: UIViewController) {
        hostView = vc
    }
    
    /// Removes the host view controller.
    public func removeHostView() {
        hostView = nil
    }
    
    // MARK: - Common Message Handlers
    
    /// Sets user values received from the web content.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
    /// - Returns: An optional `Encodable` response.
    public func setUserValues(params: Any, message: WKScriptMessage) -> Encodable? {
        guard let userValues: UserValues = DecodableHelper.decode(from: params) else {
            assertionFailure("DuckPlayer: expected JSON representation of UserValues")
            return nil
        }
        
        Task {
            // Fire pixels for analytics
            await firePixels(message: message, userValues: userValues)
            
            // Update settings based on user values
            await updateSettings(userValues: userValues)
        }
        return userValues
    }
    
    /// Updates Duck Player settings based on user values.
    ///
    /// - Parameter userValues: The user values to update settings with.
    private func updateSettings(userValues: UserValues) async {
        settings.setMode(userValues.duckPlayerMode)
        settings.setAskModeOverlayHidden(userValues.askModeOverlayHidden)
    }
    
    /// Retrieves user values to send to the web content.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
    /// - Returns: An optional `Encodable` response.
    public func getUserValues(params: Any, message: WKScriptMessage) -> Encodable? {
        if featureFlagger.isFeatureOn(.duckPlayer) {
            return encodeUserValues()
        }
        return nil
    }
    
    /// Opens a video in Duck Player within the specified web view.
    ///
    /// - Parameters:
    ///   - url: The URL of the video.
    ///   - webView: The web view to load the video in.
    @MainActor
    public func openVideoInDuckPlayer(url: URL, webView: WKWebView) {
        webView.load(URLRequest(url: url))
    }

    /// Performs initial setup for the player.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
    /// - Returns: An optional `Encodable` response.
    @MainActor
    public func initialSetupPlayer(params: Any, message: WKScriptMessage) async -> Encodable? {
        let webView = message.webView
        return await self.encodedPlayerSettings(with: webView)
    }
    
    /// Performs initial setup for the overlay.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
    /// - Returns: An optional `Encodable` response.
    @MainActor
    public func initialSetupOverlay(params: Any, message: WKScriptMessage) async -> Encodable? {
        let webView = message.webView
        return await self.encodedPlayerSettings(with: webView)
    }
    
    /// Opens Duck Player settings.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
    public func openDuckPlayerSettings(params: Any, message: WKScriptMessage) async -> Encodable? {
        NotificationCenter.default.post(
            name: .settingsDeepLinkNotification,
            object: SettingsViewModel.SettingsDeepLinkSection.duckPlayer,
            userInfo: nil
        )
        return nil
    }
    
    /// Sends a telemetry event from the FE.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
    @MainActor
        public func telemetryEvent(params: Any, message: WKScriptMessage) async -> Encodable? {
            guard let event: TelemetryEvent = DecodableHelper.decode(from: params) else {
                return nil
            }

            switch event.attributes {
            case .impression(let attrs):
                switch attrs.value {
                case .landscape:
                    Pixel.fire(pixel: .duckPlayerLandscapeLayoutImpressions)
                }
            }

            return nil
        }
    
    /// Opens Duck Player information modal.
    ///
    /// - Parameters:
    ///   - params: Parameters from the web content.
    ///   - message: The script message containing the parameters.
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

    /// Presents the Duck Player info modal.
    ///
    /// - Parameter context: The presentation context for the modal.
    @MainActor
    public func presentDuckPlayerInfo(context: DuckPlayerModalPresenter.PresentationContext) {
        guard let hostView else { return }
        DuckPlayerModalPresenter(context: context).presentDuckPlayerFeatureModal(on: hostView)
    }
    
    /// Encodes user values for sending to the web content.
    ///
    /// - Returns: An instance of `UserValues`.
    private func encodeUserValues() -> UserValues {
        return UserValues(
            duckPlayerMode: featureFlagger.isFeatureOn(.duckPlayer) ? settings.mode : .disabled,
            askModeOverlayHidden: settings.askModeOverlayHidden
        )
    }
    
    /// Encodes UI values for sending to the web content.
    ///
    /// - Returns: An instance of `UIValues`.
    private func encodeUIValues() -> UIValues {
        UIValues(
            allowFirstVideo: settings.allowFirstVideo
        )
    }

    /// Prepares and encodes player settings to send to the web content.
    ///
    /// - Parameter webView: The web view to check for PiP capability.
    /// - Returns: An instance of `InitialPlayerSettings`.
    @MainActor
    private func encodedPlayerSettings(with webView: WKWebView?) async -> InitialPlayerSettings {
        let isPiPEnabled = webView?.configuration.allowsPictureInPictureMediaPlayback == true
        let pip = InitialPlayerSettings.PIP(status: isPiPEnabled ? .enabled : .disabled)
        let platform = InitialPlayerSettings.Platform(name: "ios")
        let locale = Locale.current.languageCode ?? "en"
        let playerSettings = InitialPlayerSettings.PlayerSettings(pip: pip)
        let userValues = encodeUserValues()
        let uiValues = encodeUIValues()
        let settings = InitialPlayerSettings(
            userValues: userValues,
            ui: uiValues,
            settings: playerSettings,
            platform: platform,
            locale: locale,
            localeStrings: localeStrings
        )
        return settings
    }
        
    /// Fires analytics pixels based on user interactions.
    ///
    /// - Parameters:
    ///   - message: The script message containing the interaction data.
    ///   - userValues: The user values to determine which pixels to fire.
    @MainActor
    private func firePixels(message: WKScriptMessage, userValues: UserValues) {
        
        guard let messageData: WKMessageData = DecodableHelper.decode(from: message.body) else {
            assertionFailure("DuckPlayer: expected JSON representation of Message")
            return
        }
        guard let feature = messageData.featureName else { return }
        
        // Get the webView URL
        let webView = message.webView
        guard let webView = message.webView, let url = webView.url else {
            return
        }
        
        // Based on the URL, determine which pixels to fire
        let isSERP = url.isDuckDuckGoSearch
            
        // Assume we are in the SERP Overlay
        if isSERP {
            switch userValues.duckPlayerMode {
            case .enabled:
                Pixel.fire(pixel: .duckPlayerSettingsAlwaysOverlaySERP)
            case .disabled:
                Pixel.fire(pixel: .duckPlayerSettingsNeverOverlaySERP)
            default: break
            }
        
            // Assume we are in the Youtube Overlay
        } else {
            switch userValues.duckPlayerMode {
            case .enabled:
                Pixel.fire(pixel: .duckPlayerSettingsAlwaysOverlayYoutube)
            case .disabled:
                Pixel.fire(pixel: .duckPlayerSettingsNeverOverlayYoutube)
            default: break
            }
        }
       
    }
    
}
