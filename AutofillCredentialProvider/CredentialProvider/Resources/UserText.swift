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

    static let credentialProviderActivatedTitle = NSLocalizedString("credential.provider.activated.title", value: "Autofill Passwords activated!", comment: "The title of the screen confirming DuckDuckGo can now be used for autofilling passwords")

    static let credentialProviderActivatedButton = NSLocalizedString("credential.provider.activated.button", value: "Open DuckDuckGo", comment: "Title of button to launch the DuckDuckGo app")

    static let actionClose = NSLocalizedString("action.button.close", value: "Close", comment: "Close button title")

    static let actionDone = NSLocalizedString("action.button.done", value: "Done", comment: "Done button title")

    static let credentialProviderListTitle = NSLocalizedString("credential.provider.list.title", value: "Passwords", comment: "Title for screen listing autofill logins")

    static let credentialProviderListPrompt = NSLocalizedString("credential.provider.list.prompt", value: "Choose a password to use for \"%@\"", comment: "Prompt above the title for screen listing autofill logins, example: Choose a password to use for \"website.com\"")

    static let credentialProviderListSearchPlaceholder = NSLocalizedString("credential.provider.list.search-placeholder", value: "Search passwords", comment: "Placeholder for search field on autofill login listing")

    static let credentialProviderListEmptyViewTitle = NSLocalizedString("credential.provider.list.empty-view.title", value: "No passwords saved yet", comment: "Title for view displayed when autofill has no items")

    static let credentialProviderListEmptyViewSubtitle = NSLocalizedString("credential.provider.list.empty-view.footer", value: "Passwords are stored securely on your device.", comment: "Footer label displayed below table section with option to enable autofill")

    static let credentialProviderListSuggested = NSLocalizedString("credential.provider.list.suggested", value: "Suggested", comment: "Section title for group of suggested saved logins")

    static let credentialProviderListSearchNoResultTitle = NSLocalizedString("credential.provider.list.search.no-results.title", value: "No Results", comment: "Title displayed when there are no results on Autofill search")

    static func credentialProviderListSearchNoResultSubtitle(for query: String) -> String {
        let message = NSLocalizedString("credential.provider.list.search.no-results.subtitle", value: "for '%@'", comment: "Subtitle displayed when there are no results on Autofill search, example : No Result (Title) for Duck (Subtitle)")
        return message.format(arguments: query)
    }

    static let credentialProviderListAuthenticationReason = NSLocalizedString("credential.provider.list.auth.reason", value: "Unlock device to access passwords", comment: "Reason for auth when opening screen with list of saved passwords")

    static let credentialProviderListAuthenticationCancelButton = NSLocalizedString("credential.provider.list.auth.cancel", value: "Cancel", comment: "Cancel button for auth when opening login list")

    static let credentialProviderNoDeviceAuthSetTitle = NSLocalizedString("credential.provider.no-device-auth-set.title", value: "Device Passcode Required", comment: "Title for alert when device authentication is not set")

    static let credentialProviderNoDeviceAuthSetMessage = NSLocalizedString("credential.provider.no-device-auth-set.message", value: "Set a passcode on %@ to autofill your DuckDuckGo passwords.", comment: "Message for alert when device authentication is not set, where %@ is iPhone|iPad|device")

    static let deviceTypeiPhone = NSLocalizedString("credential.provider.device.type.iphone", value: "iPhone", comment: "Device type is iPhone")
    static let deviceTypeiPad = NSLocalizedString("credential.provider.device.type.pad", value: "iPad", comment: "Device type is iPad")
    static let deviceTypeDefault = NSLocalizedString("credential.provider.device.type.default", value: "device", comment: "Default string used if users device is not iPhone or iPad")

    public static let credentialProviderDetailsCopyToastUsernameCopied = NSLocalizedString("credential.provider.list.details.copy-toast.username-copied", value: "Username copied", comment: "Title for toast when copying username")
    public static let credentialProviderDetailsCopyToastPasswordCopied = NSLocalizedString("credential.provider.list.details.copy-toast.password-copied", value: "Password copied", comment: "Title for toast when copying password")
    public static let credentialProviderDetailsCopyToastAddressCopied = NSLocalizedString("credential.provider.list.details.copy-toast.address-copied", value: "Address copied", comment: "Title for toast when copying address")
    public static let credentialProviderDetailsCopyToastNotesCopied = NSLocalizedString("credential.provider.list.details.copy-toast.notes-copied", value: "Notes copied", comment: "Title for toast when copying notes")

    public static func credentialProviderDetailsLastUpdated(for date: String) -> String {
        let message = NSLocalizedString("credential.provider.list.details.last-updated", value: "Last updated %@", comment: "Message displaying when the login was last updated")
        return message.format(arguments: date)
    }

    public static let credentialProviderDetailsLoginName = NSLocalizedString("credential.provider.list.details.login-name", value: "Title", comment: "Login name label for login details on autofill")
    public static let credentialProviderDetailsUsername = NSLocalizedString("credential.provider.list.details.username", value: "Username", comment: "Username label for login details on autofill")
    public static let credentialProviderDetailsPassword = NSLocalizedString("credential.provider.list.details.password", value: "Password", comment: "Password label for login details on autofill")
    public static let credentialProviderDetailsAddress = NSLocalizedString("credential.provider.list.details.address", value: "Website URL", comment: "Address label for login details on autofill")
        public static let credentialProviderDetailsNotes = NSLocalizedString("credential.provider.list.details.notes", value: "Notes", comment: "Notes label for login details on autofill")


    public static func credentialProviderDetailsCopyPrompt(for type: String) -> String {
        let message = NSLocalizedString("credential.provider.list.details.copy-prompt", value: "Copy %@", comment: "Menu item text for copying autofill login details")
        return message.format(arguments: type)
    }
    public static let credentialProviderDetailsShowPassword = NSLocalizedString("credential.provider.list.details.show-password", value: "Show Password", comment: "Accessibility title for a Show Password button displaying actial password instead of *****")
    public static let credentialProviderDetailsHidePassword = NSLocalizedString("credential.provider.list.details.hide-password", value: "Hide Password", comment: "Accessibility title for a Hide Password button replacing displayed password with *****")
}
