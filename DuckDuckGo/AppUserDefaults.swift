//
//  AppUserDefaults.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
import Bookmarks
import Core
import WidgetKit

public class AppUserDefaults: AppSettings {
    
    public struct Notifications {
        public static let doNotSellStatusChange = Notification.Name("com.duckduckgo.app.DoNotSellStatusChange")
        public static let currentFireButtonAnimationChange = Notification.Name("com.duckduckgo.app.CurrentFireButtonAnimationChange")
        public static let textZoomChange = Notification.Name("com.duckduckgo.app.TextZoomChange")
        public static let favoritesDisplayModeChange = Notification.Name("com.duckduckgo.app.FavoritesDisplayModeChange")
        public static let syncPausedStateChanged = SyncBookmarksAdapter.syncBookmarksPausedStateChanged
        public static let syncCredentialsPausedStateChanged = SyncCredentialsAdapter.syncCredentialsPausedStateChanged
        public static let autofillEnabledChange = Notification.Name("com.duckduckgo.app.AutofillEnabledChange")
        public static let didVerifyInternalUser = Notification.Name("com.duckduckgo.app.DidVerifyInternalUser")
        public static let inspectableWebViewsToggled = Notification.Name("com.duckduckgo.app.DidToggleInspectableWebViews")
        public static let addressBarPositionChanged = Notification.Name("com.duckduckgo.app.AddressBarPositionChanged")
        public static let showsFullURLAddressSettingChanged = Notification.Name("com.duckduckgo.app.ShowsFullURLAddressSettingChanged")
        public static let autofillDebugScriptToggled = Notification.Name("com.duckduckgo.app.DidToggleAutofillDebugScript")
        public static let duckPlayerSettingsUpdated = Notification.Name("com.duckduckgo.app.DuckPlayerSettingsUpdated")
        public static let appDataClearingUpdated = Notification.Name("com.duckduckgo.app.dataClearingUpdates")
    }

    private let groupName: String

    struct Keys {
        static let autocompleteKey = "com.duckduckgo.app.autocompleteDisabledKey"
        static let recentlyVisitedSites = "com.duckduckgo.app.recentlyVisitedSitesKey"
        static let currentThemeNameKey = "com.duckduckgo.app.currentThemeNameKey"
        
        static let autoClearActionKey = "com.duckduckgo.app.autoClearActionKey"
        static let autoClearTimingKey = "com.duckduckgo.app.autoClearTimingKey"
        
        static let homePage = "com.duckduckgo.app.homePage"

        static let foregroundFetchStartCount = "com.duckduckgo.app.fgFetchStartCount"
        static let foregroundFetchNoDataCount = "com.duckduckgo.app.fgFetchNoDataCount"
        static let foregroundFetchNewDataCount = "com.duckduckgo.app.fgFetchNewDataCount"
        
        static let backgroundFetchStartCount = "com.duckduckgo.app.bgFetchStartCount"
        static let backgroundFetchNoDataCount = "com.duckduckgo.app.bgFetchNoDataCount"
        static let backgroundFetchNewDataCount = "com.duckduckgo.app.bgFetchNewDataCount"

        static let backgroundFetchTaskExpirationCount = "com.duckduckgo.app.bgFetchTaskExpirationCount"
        
        static let notificationsEnabled = "com.duckduckgo.app.notificationsEnabled"
        static let allowUniversalLinks = "com.duckduckgo.app.allowUniversalLinks"
        static let longPressPreviews = "com.duckduckgo.app.longPressPreviews"
        
        static let currentFireButtonAnimationKey = "com.duckduckgo.app.currentFireButtonAnimationKey"
        
        static let autofillCredentialsEnabled = "com.duckduckgo.ios.autofillCredentialsEnabled"
        static let autofillIsNewInstallForOnByDefault = "com.duckduckgo.ios.autofillIsNewInstallForOnByDefault"

        static let favoritesDisplayMode = "com.duckduckgo.ios.favoritesDisplayMode"

        static let crashCollectionOptInStatus = "com.duckduckgo.ios.crashCollectionOptInStatus"
        static let crashCollectionShouldRevertOptedInStatusTrigger = "com.duckduckgo.ios.crashCollectionShouldRevertOptedInStatusTrigger"

        static let duckPlayerMode = "com.duckduckgo.ios.duckPlayerMode"
        static let duckPlayerAskModeOverlayHidden = "com.duckduckgo.ios.duckPlayerAskModeOverlayHidden"
        static let duckPlayerOpenInNewTab = "com.duckduckgo.ios.duckPlayerOpenInNewTab"
    }

    private struct DebugKeys {
        static let inspectableWebViewsEnabledKey = "com.duckduckgo.ios.debug.inspectableWebViewsEnabled"
        static let autofillDebugScriptEnabledKey = "com.duckduckgo.ios.debug.autofillDebugScriptEnabled"
        static let onboardingAddToDockStateKey = "com.duckduckgo.ios.debug.onboardingAddToDockState"
    }

    private var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: groupName)
    }

    private var bookmarksUserDefaults: UserDefaults? {
        UserDefaults(suiteName: "group.com.duckduckgo.bookmarks")
    }

    lazy var featureFlagger = AppDependencyProvider.shared.featureFlagger

    init(groupName: String = "group.com.duckduckgo.app") {
        self.groupName = groupName
    }

    var autocomplete: Bool {

        get {
            return userDefaults?.bool(forKey: Keys.autocompleteKey, defaultValue: true) ?? true
        }

        set {
            userDefaults?.setValue(newValue, forKey: Keys.autocompleteKey)
        }

    }
    
    var recentlyVisitedSites: Bool {

        get {
            return userDefaults?.bool(forKey: Keys.recentlyVisitedSites, defaultValue: true) ?? true
        }

        set {
            userDefaults?.setValue(newValue, forKey: Keys.recentlyVisitedSites)
        }

    }

    var currentThemeName: ThemeName {
        
        get {
            var currentThemeName: ThemeName?
            if let stringName = userDefaults?.string(forKey: Keys.currentThemeNameKey) {
                currentThemeName = ThemeName(rawValue: stringName)
            }
            
            if let themeName = currentThemeName {
                return themeName
            } else {
                return .systemDefault
            }
        }
        
        set {
            userDefaults?.setValue(newValue.rawValue, forKey: Keys.currentThemeNameKey)
        }
        
    }

    var autoClearAction: AutoClearSettingsModel.Action {
        
        get {
            let value = userDefaults?.integer(forKey: Keys.autoClearActionKey) ?? 0
            return AutoClearSettingsModel.Action(rawValue: value)
        }
        
        set {
            userDefaults?.setValue(newValue.rawValue, forKey: Keys.autoClearActionKey)
            NotificationCenter.default.post(name: Notifications.appDataClearingUpdated, object: nil)
        }
        
    }
    
    var autoClearTiming: AutoClearSettingsModel.Timing {
        
        get {
            if let rawValue = userDefaults?.integer(forKey: Keys.autoClearTimingKey),
                let value = AutoClearSettingsModel.Timing(rawValue: rawValue) {
                return value
            }
            return .termination
        }
        
        set {
            userDefaults?.setValue(newValue.rawValue, forKey: Keys.autoClearTimingKey)
        }
        
    }
    
    var allowUniversalLinks: Bool {
        get {
            return userDefaults?.object(forKey: Keys.allowUniversalLinks) as? Bool ?? true
        }
        
        set {
            userDefaults?.set(newValue, forKey: Keys.allowUniversalLinks)
        }
    }

    var longPressPreviews: Bool {
        get {
            return userDefaults?.object(forKey: Keys.longPressPreviews) as? Bool ?? true
        }

        set {
            userDefaults?.set(newValue, forKey: Keys.longPressPreviews)
        }
    }
    
    @UserDefaultsWrapper(key: .doNotSell, defaultValue: true)
    var sendDoNotSell: Bool
    
    var currentFireButtonAnimation: FireButtonAnimationType {
        get {
            if let string = userDefaults?.string(forKey: Keys.currentFireButtonAnimationKey),
               let currentAnimation = FireButtonAnimationType(rawValue: string) {
                
                return currentAnimation
            } else {
                return .fireRising
            }
        }
        set {
            userDefaults?.setValue(newValue.rawValue, forKey: Keys.currentFireButtonAnimationKey)
        }
    }

    @UserDefaultsWrapper(key: .addressBarPosition, defaultValue: nil)
    private var addressBarPositionStorage: String?

    var currentAddressBarPosition: AddressBarPosition {
        get {
            return AddressBarPosition(rawValue: addressBarPositionStorage?.lowercased()  ?? "") ?? .top
        }

        set {
            addressBarPositionStorage = newValue.rawValue
            NotificationCenter.default.post(name: Notifications.addressBarPositionChanged, object: currentAddressBarPosition)
        }
    }

    @UserDefaultsWrapper(key: .showFullURLAddress, defaultValue: false)
    var showFullSiteAddress: Bool {
        didSet {
            NotificationCenter.default.post(name: Notifications.showsFullURLAddressSettingChanged, object: showFullSiteAddress)
        }
    }

    @UserDefaultsWrapper(key: .textZoom, defaultValue: 100)
    private var textZoom: Int {
        didSet {
            NotificationCenter.default.post(name: Notifications.textZoomChange, object: textZoom)
        }
    }

    var defaultTextZoomLevel: TextZoomLevel {
        get {
            return TextZoomLevel(rawValue: textZoom) ?? .percent100
        }
        set {
            textZoom = newValue.rawValue
        }
    }

    public var favoritesDisplayMode: FavoritesDisplayMode {
        get {
            guard let string = userDefaults?.string(forKey: Keys.favoritesDisplayMode), let favoritesDisplayMode = FavoritesDisplayMode(string) else {
                return .default
            }
            return favoritesDisplayMode
        }
        set {
            userDefaults?.setValue(newValue.description, forKey: Keys.favoritesDisplayMode)
            bookmarksUserDefaults?.setValue(newValue.description, forKey: Keys.favoritesDisplayMode)
        }
    }

    private func setAutofillCredentialsEnabledAutomaticallyIfNecessary() {
        if autofillCredentialsHasBeenEnabledAutomaticallyIfNecessary {
            return
        }
        if !autofillCredentialsSavePromptShowAtLeastOnce {
            if let isNewInstall = autofillIsNewInstallForOnByDefault,
               isNewInstall,
               featureFlagger.isFeatureOn(.autofillOnByDefault) {
                enableAutofillCredentials()
            } else if featureFlagger.isFeatureOn(.autofillOnForExistingUsers) {
                enableAutofillCredentials()
            }
        }
    }

    private func enableAutofillCredentials() {
        autofillCredentialsHasBeenEnabledAutomaticallyIfNecessary = true
        autofillCredentialsEnabled = true
    }

    var autofillCredentialsEnabled: Bool {
        get {
            // setAutofillCredentialsEnabledAutomaticallyIfNecessary() used here to automatically turn on autofill for people if:
            // 1. They haven't seen the save prompt before
            // 2. They are a new install
            // 3. The feature flag is enabled
            setAutofillCredentialsEnabledAutomaticallyIfNecessary()
            return userDefaults?.object(forKey: Keys.autofillCredentialsEnabled) as? Bool ?? false
        }
        
        set {
            userDefaults?.set(newValue, forKey: Keys.autofillCredentialsEnabled)
        }
    }

    @UserDefaultsWrapper(key: .autofillCredentialsSavePromptShowAtLeastOnce, defaultValue: false)
    var autofillCredentialsSavePromptShowAtLeastOnce: Bool
    
    @UserDefaultsWrapper(key: .autofillCredentialsHasBeenEnabledAutomaticallyIfNecessary, defaultValue: false)
    var autofillCredentialsHasBeenEnabledAutomaticallyIfNecessary: Bool

    var autofillIsNewInstallForOnByDefault: Bool? {
        get {
            return userDefaults?.object(forKey: Keys.autofillIsNewInstallForOnByDefault) as? Bool
        }
        set {
            userDefaults?.set(newValue, forKey: Keys.autofillIsNewInstallForOnByDefault)
        }
    }

    func setAutofillIsNewInstallForOnByDefault() {
        autofillIsNewInstallForOnByDefault = StatisticsUserDefaults().installDate == nil
    }

    @UserDefaultsWrapper(key: .autofillImportViaSyncStart, defaultValue: nil)
    var autofillImportViaSyncStart: Date?

    func clearAutofillImportViaSyncStart() {
        autofillImportViaSyncStart = nil
    }

    @UserDefaultsWrapper(key: .voiceSearchEnabled, defaultValue: false)
    var voiceSearchEnabled: Bool

    func isWidgetInstalled() async -> Bool {
        return await withCheckedContinuation { continuation in
            WidgetCenter.shared.getCurrentConfigurations { result in
                switch result {
                case .success(let configurations):
                    continuation.resume(returning: configurations.count > 0)
                case .failure:
                    continuation.resume(returning: false)
                }
            }
        }
    }

    var autoconsentEnabled: Bool {
        get {
            // Use settings value if present
            if let isEnabled = autoconsentEnabledSetting {
                return isEnabled
            }

            // Use onByDefault rollout otherwise
            return featureFlagger.isFeatureOn(.autoconsentOnByDefault)
        }

        set {
            autoconsentEnabledSetting = newValue
        }
    }

    // Only for testing and `DebugViewController` purposes
    func clearAutoconsentUserSetting() {
        autoconsentEnabledSetting = nil
    }

    @UserDefaultsWrapper(key: .autoconsentEnabled, defaultValue: false)
    private var autoconsentEnabledSetting: Bool?

    var inspectableWebViewEnabled: Bool {
        get {
            return userDefaults?.object(forKey: DebugKeys.inspectableWebViewsEnabledKey) as? Bool ?? false
        }

        set {
            userDefaults?.set(newValue, forKey: DebugKeys.inspectableWebViewsEnabledKey)
        }
    }

    var autofillDebugScriptEnabled: Bool {
        get {
            return userDefaults?.object(forKey: DebugKeys.autofillDebugScriptEnabledKey) as? Bool ?? false
        }

        set {
            userDefaults?.set(newValue, forKey: DebugKeys.autofillDebugScriptEnabledKey)
        }
    }

    var crashCollectionOptInStatus: CrashCollectionOptInStatus {
        get {
            guard let string = userDefaults?.string(forKey: Keys.crashCollectionOptInStatus),
                  let optInStatus = CrashCollectionOptInStatus(rawValue: string)
            else {
                return .undetermined
            }
            return optInStatus
        }
        set {
            userDefaults?.setValue(newValue.rawValue, forKey: Keys.crashCollectionOptInStatus)
        }
    }
    
    var crashCollectionShouldRevertOptedInStatusTrigger: Int {
        get {
            if let resetTrigger = userDefaults?.integer(forKey: Keys.crashCollectionShouldRevertOptedInStatusTrigger) {
                return resetTrigger
            } else {
                return 0
            }
        }
        set {
            userDefaults?.setValue(newValue, forKey: Keys.crashCollectionShouldRevertOptedInStatusTrigger)
        }
    }
    
    var duckPlayerMode: DuckPlayerMode {
        get {
            if let value = userDefaults?.string(forKey: Keys.duckPlayerMode),
               let mode = DuckPlayerMode(stringValue: value) {
                return mode
            }
            return .alwaysAsk
        }
        set {
            userDefaults?.set(newValue.stringValue, forKey: Keys.duckPlayerMode)
            // Reset Hidden overlay setting when changing Mode
            userDefaults?.set(false, forKey: Keys.duckPlayerAskModeOverlayHidden)
            NotificationCenter.default.post(name: AppUserDefaults.Notifications.duckPlayerSettingsUpdated,
                                            object: duckPlayerMode)
        }
    }
    
    var duckPlayerAskModeOverlayHidden: Bool {
        get {
            if let value = userDefaults?.bool(forKey: Keys.duckPlayerAskModeOverlayHidden) {
                return value
            }
            return false
        }
        set {
            userDefaults?.set(newValue, forKey: Keys.duckPlayerAskModeOverlayHidden)
            NotificationCenter.default.post(name: AppUserDefaults.Notifications.duckPlayerSettingsUpdated,
                                            object: duckPlayerMode)
        }
    }
    
    @UserDefaultsWrapper(key: .duckPlayerOpenInNewTab, defaultValue: true)
    var duckPlayerOpenInNewTab: Bool
    
    @UserDefaultsWrapper(key: .duckPlayerNativeUI, defaultValue: false)
    var duckPlayerNativeUI: Bool
    
    @UserDefaultsWrapper(key: .duckPlayerAutoplay, defaultValue: true)
    var duckPlayerAutoplay: Bool

    @UserDefaultsWrapper(key: .debugOnboardingHighlightsEnabledKey, defaultValue: false)
    var onboardingHighlightsEnabled: Bool

    var onboardingAddToDockState: OnboardingAddToDockState {
        get {
            guard let rawValue = userDefaults?.string(forKey: DebugKeys.onboardingAddToDockStateKey) else { return .disabled }
            return OnboardingAddToDockState(rawValue: rawValue) ?? .disabled
        }
        set {
            userDefaults?.set(newValue.rawValue, forKey: DebugKeys.onboardingAddToDockStateKey)
        }
    }
}

extension AppUserDefaults: AppConfigurationFetchStatistics {
    
    var foregroundStartCount: Int {
        get {
            return userDefaults?.integer(forKey: Keys.foregroundFetchStartCount) ?? 0
        }
        set {
            userDefaults?.setValue(newValue, forKey: Keys.foregroundFetchStartCount)
        }
    }
    
    var foregroundNoDataCount: Int {
        get {
            return userDefaults?.integer(forKey: Keys.foregroundFetchNoDataCount) ?? 0
        }
        set {
            userDefaults?.setValue(newValue, forKey: Keys.foregroundFetchNoDataCount)
        }
    }
    
    var foregroundNewDataCount: Int {
        get {
            return userDefaults?.integer(forKey: Keys.foregroundFetchNewDataCount) ?? 0
        }
        set {
            userDefaults?.setValue(newValue, forKey: Keys.foregroundFetchNewDataCount)
        }
    }
    
    var backgroundStartCount: Int {
        get {
            return userDefaults?.integer(forKey: Keys.backgroundFetchStartCount) ?? 0
        }
        set {
            userDefaults?.setValue(newValue, forKey: Keys.backgroundFetchStartCount)
        }
    }
    
    var backgroundNoDataCount: Int {
        get {
            return userDefaults?.integer(forKey: Keys.backgroundFetchNoDataCount) ?? 0
        }
        set {
            userDefaults?.setValue(newValue, forKey: Keys.backgroundFetchNoDataCount)
        }
    }
    
    var backgroundNewDataCount: Int {
        get {
            return userDefaults?.integer(forKey: Keys.backgroundFetchNewDataCount) ?? 0
        }
        set {
            userDefaults?.setValue(newValue, forKey: Keys.backgroundFetchNewDataCount)
        }
    }

    var backgroundFetchTaskExpirationCount: Int {
        get {
            return userDefaults?.integer(forKey: Keys.backgroundFetchTaskExpirationCount) ?? 0
        }
        set {
            userDefaults?.setValue(newValue, forKey: Keys.backgroundFetchTaskExpirationCount)
        }
    }
}
