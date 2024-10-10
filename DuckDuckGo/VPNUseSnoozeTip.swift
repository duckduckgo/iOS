//
//  VPNUseSnoozeTip.swift
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
struct VPNUseSnoozeTip {}

/// Necessary split to support older iOS versions.
///
@available(iOS 17.0, *)
extension VPNUseSnoozeTip: Tip {

    @Parameter(.transient)
    static var vpnEnabled: Bool = false

    var id: String {
        "com.duckduckgo.tipkit.VPNUseSnoozeTip"
    }

    var title: Text {
        Text("Avoid VPN Conflicts")
    }

    var message: Text? {
        Text("Snooze briefly disconnects the VPN so you can use sites or apps that block VPN traffic.")
    }

    var image: Image? {
        Image(systemName: "powersleep")
    }

    var actions: [Action] {
        [Action(title: "Learn more") {
            let url = URL(string: "https://duckduckgo.com/duckduckgo-help-pages/privacy-pro/vpn/troubleshooting/")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }]
    }

    var rules: [Rule] {
        #Rule(Self.$vpnEnabled) {
            $0 == true
        }
    }
}
