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

    static let widgetActionId = "com.duckduckgo.tipkit.VPNChangeLocationTip.widgetActionId"

    @Parameter(.transient)
    static var vpnEnabled: Bool = false

    private static let vpnDisconnectedEvent = Tips.Event(id: "com.duckduckgo.tipkit.VPNChangeLocationTip.vpnDisconnectedEvent")

    var id: String {
        "com.duckduckgo.tipkit.VPNAddWidgetTip"
    }

    var title: Text {
        Text("Add VPN Widget")
    }

    var message: Text? {
        Text("Turn the VPN on and off right from the Home Screen.")
    }

    var image: Image? {
        Image(systemName: "rectangle.and.hand.point.up.left.fill")
    }

    var actions: [Action] {
        [Action(id: Self.widgetActionId, title: "Add widget")]
    }

    var rules: [Rule] {
        #Rule(Self.$vpnEnabled) {
            $0 == false
        }
    }
}
