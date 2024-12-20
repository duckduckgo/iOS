//
//  UserTextShared.swift
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

extension UserText {
    static let vpnNeedsToBeEnabledFromApp = NSLocalizedString("intent.vpn.needs.to.be.enabled.from.app", value: "You need to enable the VPN from the DuckDuckGo App.", comment: "Message that comes up when trying to enable the VPN from intents, asking the user to enable it from the app so it's configured")
    static let vpnControlWidgetToggleIntentTitle = NSLocalizedString("intent.vpn.control.widget.toggle.intent.title", value: "Toggle DuckDuckGo VPN from the Control Center Widget", comment: "Title for the control widget toggle intent")
    static let vpnControlWidgetToggleIntentDescription = NSLocalizedString("intent.vpn.control.widget.toggle.intent.description", value: "Toggles the DuckDuckGo VPN from the Control Center widget", comment: "Description for the control widget toggle intent")
}
