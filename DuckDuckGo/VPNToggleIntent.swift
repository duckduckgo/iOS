//
//  VPNIntents.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import NetworkExtension
import NetworkProtection
import WidgetKit
import Core

// MARK: - Toggle


/// `ForegroundContinuableIntent` isn't available for extensions, which makes it impossible to call
/// from extensions.  This is the recommended workaround from:
///     https://mastodon.social/@mgorbach/110812347476671807
///
@available(iOS 17.0, *)
struct VPNToggleIntent: SetValueIntent {
    @Parameter(title: "Enabled")
    var value: Bool
}

@available(iOS 17.0, *)
@available(iOSApplicationExtension, unavailable)
extension VPNToggleIntent: SetValueIntent & ForegroundContinuableIntent {
    static let title: LocalizedStringResource = "Toggle DuckDuckGo VPN"
    static let description: LocalizedStringResource = "Toggles the DuckDuckGo VPN"
    static let isDiscoverable: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult {
        do {
            //DailyPixel.fireDailyAndCount(pixel: .networkProtectionWidgetConnectAttempt)

            let controller = VPNIntentTunnelController()

            if value {
                try await controller.start()
            } else {
                try await controller.stop()
            }

            return .result()
        } catch {
            switch error {
            case VPNIntentTunnelController.StartFailure.vpnNotConfigured:
                //DailyPixel.fireDailyAndCount(pixel: .networkProtectionWidgetConnectCancelled)

                let dialog = IntentDialog(stringLiteral: UserText.vpnNeedsToBeEnabledFromApp)
                throw needsToContinueInForegroundError() {
                    await UIApplication.shared.open(AppDeepLinkSchemes.openVPN.url)
                }
            default:
                //DailyPixel.fireDailyAndCount(pixel: .networkProtectionWidgetConnectFailure, error: error)

                throw error
            }
        }
    }
}
