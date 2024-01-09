//
//  SettingsState.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

struct SettingsState {
    
    struct AddressBar {
        var enabled: Bool
        var position: AddressBarPosition
    }
    
    struct TextSize {
        var enabled: Bool
        var size: Int
    }
    
    struct NetworkProtection {
        var enabled: Bool
        var status: String
    }
    
    struct PrivacyPro {
        var enabled: Bool
        var canPurchaseSubscription: Bool
        var hasActiveSubscription: Bool
    }
    
    // Appearance properties
    var appTheme: ThemeName
    var appIcon: AppIcon
    var fireButtonAnimation: FireButtonAnimationType
    var textSize: TextSize
    var addressbar: AddressBar

    // Privacy properties
    var sendDoNotSell: Bool
    var autoconsentEnabled: Bool
    var autoclearDataEnabled: Bool
    var applicationLock: Bool

    // Customization properties
    var autocomplete: Bool
    var longPressPreviews: Bool
    var allowUniversalLinks: Bool

    // Logins properties
    var activeWebsiteAccount: SecureVaultModels.WebsiteAccount?

    // About properties
    var version: String
        
    // Features
    var debugModeEnabled: Bool
    var syncEnabled: Bool
    var voiceSearchEnabled: Bool
    var speechRecognitionEnabled: Bool
    var loginsEnabled: Bool
    
    // Network Protection properties
    var networkProtection: NetworkProtection
    
    // Subscriptions Properties
    var privacyPro: PrivacyPro

    static var defaults: SettingsState {
        return SettingsState(
            appTheme: .systemDefault,
            appIcon: AppIconManager.shared.appIcon,
            fireButtonAnimation: .fireRising,
            textSize: TextSize(enabled: false, size: 100),
            addressbar: AddressBar(enabled: false, position: .top),
            sendDoNotSell: true,
            autoconsentEnabled: false,
            autoclearDataEnabled: false,
            applicationLock: false,
            autocomplete: true,
            longPressPreviews: true,
            allowUniversalLinks: true,
            activeWebsiteAccount: nil,
            version: "0.0.0.0",
            debugModeEnabled: false,
            syncEnabled: false,
            voiceSearchEnabled: false,
            speechRecognitionEnabled: false,
            loginsEnabled: false,
            networkProtection: NetworkProtection(enabled: false, status: ""),
            privacyPro: PrivacyPro(enabled: false, canPurchaseSubscription: false, hasActiveSubscription: false)
        )
    }
}
