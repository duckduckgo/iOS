//
//  NetworkProtectionFeatureVisibility.swift
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

import Foundation

public protocol NetworkProtectionFeatureVisibility {
    func isWaitlistBetaActive() -> Bool
    func isWaitlistUser() -> Bool
    func isPrivacyProLaunched() -> Bool

    /// Whether to show Privacy Pro entry point and let the user purchase a subscription
    func shouldShowPrivacyPro() -> Bool

    /// Whether to show the thank-you messaging for current waitlist users
    func shouldShowThankYouMessaging() -> Bool

    /// Whether to let the user continues to use the VPN
    /// This should only happen pre-launch
    func shouldKeepWaitlist() -> Bool

    /// Whether to enforce entitlement check
    /// This should always happen post-launch
    func shouldMonitorEntitlement() -> Bool

    /// Whether to show VPN shortcut on the homescreen
    func shouldShowVPNShortcut() -> Bool
}

public extension NetworkProtectionFeatureVisibility {
    func shouldShowPrivacyPro() -> Bool {
        isPrivacyProLaunched()
    }

    func shouldShowThankYouMessaging() -> Bool {
        isPrivacyProLaunched() && isWaitlistUser()
    }

    func shouldKeepWaitlist() -> Bool {
        !isPrivacyProLaunched() && isWaitlistBetaActive() && isWaitlistUser()
    }

    func shouldShowVPNShortcut() -> Bool {
        isPrivacyProLaunched() || shouldKeepWaitlist()
    }
}
