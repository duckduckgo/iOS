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
    var appeareance: SettingsStateAppeareance
    var privacy: SettingsStatePrivacy
    var customization: SettingsStateCustomization
    var logins: SettingsStateLogins
    var netP: SettingsStateNetP
    var about: SettingsStateAbout
    
    static var defaults: SettingsState {
        return SettingsState(
            appeareance: SettingsStateAppeareance.defaults,
            privacy: SettingsStatePrivacy.defaults,
            customization: SettingsStateCustomization.defaults,
            logins: SettingsStateLogins.defaults,
            netP: SettingsStateNetP.defaults,
            about: SettingsStateAbout.defaults
        )
    }
}

struct SettingsStateAppeareance {
    var appTheme: ThemeName
    var appIcon: AppIcon
    var fireButtonAnimation: FireButtonAnimationType
    var textSize: Int
    var addressBarPosition: AddressBarPosition
    
    static var defaults: SettingsStateAppeareance {
        return SettingsStateAppeareance(
            appTheme: .systemDefault,
            appIcon: AppIconManager.shared.appIcon,
            fireButtonAnimation: .fireRising,
            textSize: 100,
            addressBarPosition: .top
        )
    }
}

struct SettingsStatePrivacy {
    var sendDoNotSell: Bool
    var autoconsentEnabled: Bool
    var autoclearDataEnabled: Bool
    var applicationLock: Bool
    
    static var defaults: SettingsStatePrivacy {
        return SettingsStatePrivacy(
            sendDoNotSell: true,
            autoconsentEnabled: false,
            autoclearDataEnabled: false,
            applicationLock: false
        )
    }
}

struct SettingsStateCustomization {
    var autocomplete: Bool
    var voiceSearchEnabled: Bool
    var longPressPreviews: Bool
    var allowUniversalLinks: Bool
    
    static var defaults: SettingsStateCustomization {
        return SettingsStateCustomization(
            autocomplete: true,
            voiceSearchEnabled: false,
            longPressPreviews: true,
            allowUniversalLinks: true
        )
    }
}

struct SettingsStateLogins {
    var activeWebsiteAccount: SecureVaultModels.WebsiteAccount?

    static var defaults: SettingsStateLogins {
        return SettingsStateLogins(activeWebsiteAccount: nil)
    }
}

struct SettingsStateNetP {
    var subtitle: String

    static var defaults: SettingsStateNetP {
        return SettingsStateNetP(subtitle: "")
    }
}

struct SettingsStateAbout {
    var version: String

    static var defaults: SettingsStateAbout {
        return SettingsStateAbout(version: "0.0.0.0")
    }
    
}
