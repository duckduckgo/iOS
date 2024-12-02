//
//  UserText.swift
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

import Foundation

final class UserText {

    static let credentialProviderActivatedTitle = NSLocalizedString("credential.provider.activated.title", value: "Autofill activated!", comment: "The title of the screen confirming DuckDuckGo can now be used for autofilling passwords")

    static let credentialProviderActivatedSubtitle = NSLocalizedString("credential.provider.activated.subtitle", value: "You can now autofill your DuckDuckGo passwords from anywhere.", comment: "The subtitle of the screen confirming DuckDuckGo can now be used for autofilling passwords")

    static let credentialProviderActivatedButton = NSLocalizedString("credential.provider.activated.button", value: "Open DuckDuckGo", comment: "Title of button to launch the DuckDuckGo app")

    static let actionCancel = NSLocalizedString("action.button.cancel", value: "Cancel", comment: "Cancel button title")

    static let actionClose = NSLocalizedString("action.button.cancel", value: "Close", comment: "Close button title")

    static let autofillLoginListTitle = NSLocalizedString("autofill.logins.list.title", value: "Passwords", comment: "Title for screen listing autofill logins")

    static let autofillLoginListSearchPlaceholder = NSLocalizedString("autofill.logins.list.search-placeholder", value: "Search passwords", comment: "Placeholder for search field on autofill login listing")

    static let autofillEmptyViewTitle = NSLocalizedString("autofill.logins.empty-view.title", value: "No passwords saved yet", comment: "Title for view displayed when autofill has no items")

    static let autofillEmptyViewSubtitle = NSLocalizedString("autofill.logins.list.enable.footer", value: "Passwords are stored securely on your device.", comment: "Footer label displayed below table section with option to enable autofill")

    static let autofillLoginListSuggested = NSLocalizedString("autofill.logins.list.suggested", value: "Suggested", comment: "Section title for group of suggested saved logins")

    static let autofillSearchNoResultTitle = NSLocalizedString("autofill.logins.search.no-results.title", value: "No Results", comment: "Title displayed when there are no results on Autofill search")

    static func autofillSearchNoResultSubtitle(for query: String) -> String {
        let message = NSLocalizedString("autofill.logins.search.no-results.subtitle", value: "for '%@'", comment: "Subtitle displayed when there are no results on Autofill search, example : No Result (Title) for Duck (Subtitle)")
        return message.format(arguments: query)
    }

    static let autofillLoginListAuthenticationReason = NSLocalizedString("autofill.logins.list.auth.reason", value: "Unlock device to access passwords", comment: "Reason for auth when opening login list")

    static let autofillLoginListAuthenticationCancelButton = NSLocalizedString("autofill.logins.list.auth.cancel", value: "Cancel", comment: "Cancel button for auth when opening login list")

    static let autofillNoDeviceAuthSetTitle = NSLocalizedString("autofill.no-device-auth-set.title", value: "Device Passcode Required", comment: "Title for alert when device authentication is not set")

    static let autofillNoDeviceAuthSetMessage = NSLocalizedString("autofill.no-device-auth-set.message", value: "Set a passcode on %@ to autofill your DuckDuckGo passwords.", comment: "Message for alert when device authentication is not set, where %@ is iPhone|iPad|device")

    static let deviceTypeiPhone = NSLocalizedString("device.type.iphone", value: "iPhone", comment: "Device type is iPhone")
    static let deviceTypeiPad = NSLocalizedString("device.type.pad", value: "iPad", comment: "Device type is iPad")
    static let deviceTypeDefault = NSLocalizedString("device.type.default", value: "device", comment: "Default string used if users device is not iPhone or iPad")

}
