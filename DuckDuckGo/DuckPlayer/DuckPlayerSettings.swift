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

protocol DuckPlayerSettingsProtocol {
    
    var duckPlayerSettingsPublisher: AnyPublisher<Void, Never> { get }
    var mode: DuckPlayerMode { get }
    var askModeOverlayHidden: Bool { get }
    
    init(appSettings: AppSettings, privacyConfigManager: PrivacyConfigurationManaging)
    
    func setMode(_ mode: DuckPlayerMode)
    func setOverlayHidden(_ overlayHidden: Bool)
    func triggerNotification()
}

final class DuckPlayerSettings: DuckPlayerSettingsProtocol {
    
    private var appSettings: AppSettings
    private let privacyConfigManager: PrivacyConfigurationManaging
    private var isFeatureEnabledCancellable: AnyCancellable?
    
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
    
    init(appSettings: AppSettings = AppDependencyProvider.shared.appSettings,
         privacyConfigManager: PrivacyConfigurationManaging = ContentBlocking.shared.privacyConfigurationManager) {
        self.appSettings = appSettings
        self.privacyConfigManager = privacyConfigManager
        self._isFeatureEnabled = privacyConfigManager.privacyConfig.isEnabled(featureKey: .duckPlayer)
        registerConfigPublisher()
        registerForNotificationChanges()
    }
    
    public struct OriginDomains {
        static let duckduckgo = "duckduckgo.com"
        static let youtubeWWW = "www.youtube.com"
        static let youtube = "youtube.com"
        static let youtubeMobile = "m.youtube.com"
    }
    
    var mode: DuckPlayerMode {
        if isFeatureEnabled {
            return appSettings.duckPlayerMode
        } else {
            return .disabled
        }
    }
    
    var overlayHidden: Bool {
        if isFeatureEnabled {
            return appSettings.duckPlayerAskModeOverlayHidden
        } else {
            return false
        }
    }
    
    @UserDefaultsWrapper(key: .duckPlayerAskModeOverlayHidden, defaultValue: false)
    var askModeOverlayHidden: Bool
    
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
    
    private func registerForNotificationChanges() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(publishUpdate),
                                               name: AppUserDefaults.Notifications.duckPlayerSettingsUpdated,
                                               object: nil)
    }
    
    func setMode(_ mode: DuckPlayerMode) {
        if mode != appSettings.duckPlayerMode {
            appSettings.duckPlayerMode = mode
            triggerNotification()
        }
    }
    
    func setOverlayHidden(_ overlayHidden: Bool) {
        if overlayHidden != appSettings.duckPlayerAskModeOverlayHidden {
            appSettings.duckPlayerAskModeOverlayHidden = overlayHidden
            triggerNotification()
        }
    }
    
    @objc private func publishUpdate(_ notification: Notification) {
        triggerNotification()
    }
    
    func triggerNotification() {
        duckPlayerSettingsSubject.send()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
