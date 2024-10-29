//
//  VPNSnoozeTip.swift
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

/// A tip to suggest to the user to use the snooze feature to momentarily disable the VPN
///
struct VPNSnoozeTip {}

/// Necessary split to support older iOS versions.
///
@available(iOS 17.0, *)
extension VPNSnoozeTip: Tip {

    enum ActionIdentifiers: String {
        case learnMore = "com.duckduckgo.vpn.tip.snooze.learnMoreId"
    }

    static let geolocationTipDismissedEvent = Tips.Event(id: "com.duckduckgo.vpn.tip.snooze.geolocationTipDismissedEvent")

    @Parameter(.transient)
    static var vpnEnabled: Bool = false

    var id: String {
        "com.duckduckgo.vpn.tip.snooze"
    }

    var title: Text {
        Text("Avoid VPN Conflicts")
    }

    var message: Text? {
        Text("You can use sites or apps that block VPN traffic by snoozing the VPN connection.")
    }

    var image: Image? {
        Image(.vpnUseSnoozeTipIcon)
    }

    var actions: [Action] {
        [Action(id: ActionIdentifiers.learnMore.rawValue) {
            Text("Learn more")
                .foregroundStyle(Color(designSystemColor: .accent))
        }]
    }

    var rules: [Rule] {
        #Rule(Self.geolocationTipDismissedEvent) {
            $0.donations.count > 0
        }
        #Rule(Self.$vpnEnabled) {
            $0 == true
        }
    }
}
