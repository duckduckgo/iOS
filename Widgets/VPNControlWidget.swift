//
//  VPNControlWidget.swift
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

import Core
import Foundation
import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 18.0, *)
public struct VPNControlWidget: ControlWidget {
    static let displayName = LocalizedStringResource(stringLiteral: "DuckDuckGo\nVPN")
    static let description = LocalizedStringResource(stringLiteral: "View and manage your VPN connection. Requires a Privacy Pro subscription.")
    static let unknownLocation = UserText.vpnControlWidgetLocationUnknown

    public init() {}

    public var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: .vpn,
                                   provider: VPNControlStatusValueProvider()) { status in

            ControlWidgetToggle(title(status: status), isOn: status.isConnected, action: ControlWidgetToggleVPNIntent()) { isOn in
                if isOn {
                    Label(location(status: status), image: "ControlCenter-VPN-on")
                } else {
                    Label(UserText.vpnControlWidgetNotConnected, image: "ControlCenter-VPN-off")
                }
            }
            .tint(.green)
        }.displayName(Self.displayName)
            .description(Self.description)
    }

    private func title(status: VPNStatus) -> String {
        if status.isConnected {
            return UserText.vpnControlWidgetOn
        } else {
            return UserText.vpnControlWidgetOff
        }
    }

    private func location(status: VPNStatus) -> String {
        if status.isConnecting {
            return UserText.vpnControlWidgetConnecting
        } else if status.isDisconnecting {
            return UserText.vpnControlWidgetDisconnecting
        } else if status.isConnected {
            return UserDefaults.networkProtectionGroupDefaults.string(forKey: NetworkProtectionUserDefaultKeys.lastSelectedServerCity) ?? Self.unknownLocation
        } else {
            return Self.unknownLocation
        }
    }
}
