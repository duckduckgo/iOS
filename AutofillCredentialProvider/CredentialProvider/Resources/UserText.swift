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
}
