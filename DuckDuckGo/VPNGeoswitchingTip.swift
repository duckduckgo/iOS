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

    /// Where the VPN was ever enabled.
    ///
    /// Once set this is never unset.  The tip doesn't need to be hidden when the user is disconnected.
    ///
    @Parameter
    static var vpnEnabledOnce: Bool = false

    var id: String {
        "com.duckduckgo.vpn.tip.geoswitching"
    }

    var title: Text {
        Text(UserText.networkProtectionGeoswitchingTipTitle)
    }

    var message: Text? {
        Text(UserText.networkProtectionGeoswitchingTipMessage)
    }

    var image: Image? {
        Image(.vpnChangeLocationTipIcon)
    }

    var rules: [Rule] {
        #Rule(Self.$vpnEnabledOnce) {
            $0
        }
    }
}
