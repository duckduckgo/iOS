//
//  VPNAddWidgetTip.swift
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

/// A tip to suggest to the user that they add our VPN widget for quick access to the VPN
///
struct VPNAddWidgetTip {}

/// Necessary split to support older iOS versions.
///
@available(iOS 17.0, *)
extension VPNAddWidgetTip: Tip {

    enum ActionIdentifiers: String {
        case addWidget = "com.duckduckgo.vpn.tip.addWidget.action.addWidget"
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

    private static let vpnDisconnectedEvent = Tips.Event(id: "com.duckduckgo.vpn.tip.addWidget.vpnDisconnectedEvent")

    var id: String {
        "com.duckduckgo.vpn.tip.addWidget"
    }

    var title: Text {
        Text(UserText.networkProtectionAddWidgetTipTitle)
    }

    var message: Text? {
        Text(UserText.networkProtectionAddWidgetTipMessage)
    }

    var image: Image? {
        Image(.vpnAddWidgetTipIcon)
    }

    var actions: [Action] {
        [Action(id: ActionIdentifiers.addWidget.rawValue) {
            Text(UserText.networkProtectionAddWidgetTipAction)
                .foregroundStyle(Color(designSystemColor: .accent))
        }]
    }

    var rules: [Rule] {
        #Rule(Self.$vpnEnabled) {
            $0 == false
        }
        #Rule(Self.$isDistancedFromPreviousTip) {
            $0
        }
    }
}
