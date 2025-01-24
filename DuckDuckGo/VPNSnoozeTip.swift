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

    /// This condition tries to verify that this tip is distanced from the previous tip..
    ///
    /// The conditions that will trigger this are:
    ///     - The status view was opened when previous tip's status is invalidated.
    ///     - The VPN is enabled when previous tip's status is invalidated.
    ///
    @Parameter
    static var isDistancedFromPreviousTip: Bool = false

    @Parameter(.transient)
    static var vpnEnabled: Bool = false

    var id: String {
        "com.duckduckgo.vpn.tip.snooze"
    }

    var title: Text {
        Text(UserText.networkProtectionSnoozeTipTitle)
    }

    var message: Text? {
        Text(UserText.networkProtectionSnoozeTipMessage)
    }

    var image: Image? {
        Image(.vpnUseSnoozeTipIcon)
    }

    var actions: [Action] {
        [Action(id: ActionIdentifiers.learnMore.rawValue) {
            Text(UserText.networkProtectionSnoozeTipAction)
                .foregroundStyle(Color(designSystemColor: .accent))
        }]
    }

    var rules: [Rule] {
        #Rule(Self.$vpnEnabled) {
            $0 == true
        }
        #Rule(Self.$isDistancedFromPreviousTip) {
            $0
        }
    }
}
