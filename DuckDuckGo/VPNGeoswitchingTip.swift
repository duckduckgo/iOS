//
//  VPNGeoswitchingTip.swift
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

import TipKit

/// A tip to suggest to the user to change their location using geo-switching
///
struct VPNGeoswitchingTip {}

@available(iOS 17.0, *)
extension VPNGeoswitchingTip: Tip {

    private static let vpnConnectedEvent = Tips.Event(id: "com.duckduckgo.vpn.tip.geoswitching.vpnConnectedEvent")

    var id: String {
        "com.duckduckgo.vpn.tip.geoswitching"
    }

    var title: Text {
        Text("Change Your Location")
    }

    var message: Text? {
        Text("You can customize your VPN location by connecting to any of our servers worldwide.")
    }

    var image: Image? {
        Image(.vpnChangeLocationTipIcon)
    }

    var rules: [Rule] {
        #Rule(Self.vpnConnectedEvent) {
            $0.donations.donatedWithin(.week).count > 0
        }
    }

    static func donateVPNConnectedEvent() {
        Task {
            await vpnConnectedEvent.donate()
        }
    }
}