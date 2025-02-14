//
//  DuckPlayerSettings.swift
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
import Combine
import Core

/// Represents the different modes for Duck Player operation.
enum DuckPlayerMode: Equatable, Codable, CustomStringConvertible, CaseIterable {
    case enabled, alwaysAsk, disabled
    
    private static let enabledString = "enabled"
    private static let alwaysAskString = "alwaysAsk"
    private static let neverString = "disabled"
        
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

    /// Initializes a `DuckPlayerMode` from a string value.
    ///
    /// - Parameter stringValue: The string representation of the mode.
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

// Custom Error privacy config settings
struct CustomErrorSettings: Codable {
    let signInRequiredSelector: String
}

/// Protocol defining the settings for Duck Player.
protocol DuckPlayerSettings: AnyObject {
    
    /// Publisher that emits when Duck Player settings change.
    var duckPlayerSettingsPublisher: AnyPublisher<Void, Never> { get }
    
    /// The current mode of Duck Player.
    var mode: DuckPlayerMode { get }
    
    /// Indicates if the "Always Ask" overlay has been hidden.
    var askModeOverlayHidden: Bool { get }
    
    /// Flag to allow the first video to play in Youtube
    var allowFirstVideo: Bool { get set }
    
    /// Determines if Duck Player should open videos in a new tab.
    var openInNewTab: Bool { get }
    
    /// Determines if the native UI should be used
    var nativeUI: Bool { get }
    
    /// Autoplay Videos when opening
    var autoplay: Bool { get }
    
    // Determines if we should show a custom view when YouTube returns an error
    var customError: Bool { get }

    // Holds additional configuration for the custom error view
    var customErrorSettings: CustomErrorSettings? { get }
    
    /// Initializes a new instance with the provided app settings and privacy configuration manager.
    ///
    /// - Parameters:
    ///   - appSettings: The application settings.
    ///   - privacyConfigManager: The privacy configuration manager.
    init(appSettings: AppSettings, privacyConfigManager: PrivacyConfigurationManaging, internalUserDecider: InternalUserDecider)
    
    /// Sets the Duck Player mode.
    ///
    /// - Parameter mode: The mode to set.
    func setMode(_ mode: DuckPlayerMode)
    
    /// Sets whether the "Always Ask" overlay has been hidden.
    ///
    /// - Parameter overlayHidden: A Boolean indicating if the overlay is hidden.
    func setAskModeOverlayHidden(_ overlayHidden: Bool)
    
    /// Triggers a notification to update subscribers about settings changes.
    func triggerNotification()
}

/// Default implementation of `DuckPlayerSettings`.
final class DuckPlayerSettingsDefault: DuckPlayerSettings {
    
    private var appSettings: AppSettings
    private let privacyConfigManager: PrivacyConfigurationManaging
    private var isFeatureEnabledCancellable: AnyCancellable?
    private var internalUserDecider: InternalUserDecider
    
    private var _isFeatureEnabled: Bool
    private var isFeatureEnabled: Bool {
        get {
            return _isFeatureEnabled
        }
        set {
            if _isFeatureEnabled != newValue {
                _isFeatureEnabled = newValue
                duckPlayerSettingsSubject.send()
            }
        }
    }
    
    private let duckPlayerSettingsSubject = PassthroughSubject<Void, Never>()
    var duckPlayerSettingsPublisher: AnyPublisher<Void, Never> {
        duckPlayerSettingsSubject.eraseToAnyPublisher()
    }
    
    /// Initializes a new instance with the provided app settings and privacy configuration manager.
    ///
    /// - Parameters:
    ///   - appSettings: The application settings.
    ///   - privacyConfigManager: The privacy configuration manager.
    init(appSettings: AppSettings = AppDependencyProvider.shared.appSettings,
         privacyConfigManager: PrivacyConfigurationManaging = ContentBlocking.shared.privacyConfigurationManager,
         internalUserDecider: InternalUserDecider = AppDependencyProvider.shared.internalUserDecider) {
        self.appSettings = appSettings
        self.privacyConfigManager = privacyConfigManager
        self._isFeatureEnabled = privacyConfigManager.privacyConfig.isEnabled(featureKey: .duckPlayer)
        self.internalUserDecider = internalUserDecider
        registerConfigPublisher()
        registerForNotificationChanges()
    }
    
    /// DuckPlayer features are only available in these domains
    public struct OriginDomains {
        static let duckduckgo = "duckduckgo.com"
        static let youtubeWWW = "www.youtube.com"
        static let youtube = "youtube.com"
        static let youtubeMobile = "m.youtube.com"
    }
    
    /// The current mode of Duck Player.
    var mode: DuckPlayerMode {
        if isFeatureEnabled {
            return appSettings.duckPlayerMode
        } else {
            return .disabled
        }
    }
    
    /// Indicates if the "Always Ask" overlay has been hidden.
    var askModeOverlayHidden: Bool {
        if isFeatureEnabled {
            return appSettings.duckPlayerAskModeOverlayHidden
        } else {
            return false
        }
    }
    
    /// Flag to allow the first video to play without redirection.
    var allowFirstVideo: Bool = false
    
    /// Determines if Duck Player should open videos in a new tab.
    var openInNewTab: Bool {
        return appSettings.duckPlayerOpenInNewTab
    }
    
    // Determines if we should use the native verion of DuckPlayer (Internal only)
    var nativeUI: Bool {
        return appSettings.duckPlayerNativeUI && internalUserDecider.isInternalUser && UIDevice.current.userInterfaceIdiom == .phone
    }
    
    // Determines if we should use the native verion of DuckPlayer (Internal only)
    var autoplay: Bool {
        return appSettings.duckPlayerAutoplay && internalUserDecider.isInternalUser && UIDevice.current.userInterfaceIdiom == .phone
    }
    
    // Determines if we should show a custom view when YouTube returns an error
    var customError: Bool {
        return privacyConfigManager.privacyConfig.isSubfeatureEnabled(DuckPlayerSubfeature.customError)
    }
    
    // Holds additional configuration for the custom error view
    var customErrorSettings: CustomErrorSettings? {
        let decoder = JSONDecoder()

        if let customErrorSettingsJSON = privacyConfigManager.privacyConfig.settings(for: DuckPlayerSubfeature.customError),
           let jsonData = customErrorSettingsJSON.data(using: .utf8) {
            do {
                let customErrorSettings = try decoder.decode(CustomErrorSettings.self, from: jsonData)
                return customErrorSettings
            } catch {
                return nil
            }
        }
        return nil
    }

    /// Registers a publisher to listen for changes in the privacy configuration.
    private func registerConfigPublisher() {
        isFeatureEnabledCancellable = privacyConfigManager.updatesPublisher
            .map { [weak privacyConfigManager] in
                privacyConfigManager?.privacyConfig.isEnabled(featureKey: .duckPlayer) == true
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.isFeatureEnabled = isEnabled
            }
    }
    
    /// Registers for notification changes in Duck Player settings.
    private func registerForNotificationChanges() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(publishUpdate),
                                               name: AppUserDefaults.Notifications.duckPlayerSettingsUpdated,
                                               object: nil)
    }
    
    /// Sets the Duck Player mode.
    ///
    /// - Parameter mode: The mode to set.
    func setMode(_ mode: DuckPlayerMode) {
        if mode != appSettings.duckPlayerMode {
            appSettings.duckPlayerMode = mode
            triggerNotification()
        }
    }
    
    /// Sets whether the "Always Ask" overlay has been hidden.
    ///
    /// - Parameter overlayHidden: A Boolean indicating if the overlay is hidden.
    func setAskModeOverlayHidden(_ overlayHidden: Bool) {
        if overlayHidden != appSettings.duckPlayerAskModeOverlayHidden {
            appSettings.duckPlayerAskModeOverlayHidden = overlayHidden
            triggerNotification()
        }
    }
    
    /// Publishes an update notification when settings change.
    ///
    /// - Parameter notification: The notification received.
    @objc private func publishUpdate(_ notification: Notification) {
        triggerNotification()
    }
    
    /// Triggers a notification to update subscribers about settings changes.
    func triggerNotification() {
        duckPlayerSettingsSubject.send()
    }
    
    deinit {
        isFeatureEnabledCancellable?.cancel()
        NotificationCenter.default.removeObserver(self, name: AppUserDefaults.Notifications.duckPlayerSettingsUpdated, object: nil)
    }
}
