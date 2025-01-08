//
//  VPNAutoShortcuts.swift
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

import AppIntents
import Foundation

@available(iOS 17.0, *)
struct VPNAutoShortcutsiOS17: AppShortcutsProvider {

    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: EnableVPNIntent(),
                    phrases: [
                        "Connect \(.applicationName) VPN",
                        "Connect the \(.applicationName) VPN",
                        "Turn \(.applicationName) VPN on",
                        "Turn the \(.applicationName) VPN on",
                        "Turn on \(.applicationName) VPN",
                        "Turn on the \(.applicationName) VPN",
                        "Enable \(.applicationName) VPN",
                        "Enable the \(.applicationName) VPN",
                        "Start \(.applicationName) VPN",
                        "Start the \(.applicationName) VPN",
                        "Start the VPN connection with \(.applicationName)",
                        "Secure my connection with \(.applicationName)",
                        "Protect my connection with \(.applicationName)"
                    ],
                    systemImageName: "globe")
        AppShortcut(intent: DisableVPNIntent(),
                    phrases: [
                        "Disconnect \(.applicationName) VPN",
                        "Disconnect the \(.applicationName) VPN",
                        "Turn \(.applicationName) VPN off",
                        "Turn the \(.applicationName) VPN off",
                        "Turn off \(.applicationName) VPN",
                        "Turn off the \(.applicationName) VPN",
                        "Disable \(.applicationName) VPN",
                        "Disable the \(.applicationName) VPN",
                        "Stop \(.applicationName) VPN",
                        "Stop the \(.applicationName) VPN",
                        "Stop the VPN connection with \(.applicationName)"
                    ],
                    systemImageName: "globe")
    }
}
