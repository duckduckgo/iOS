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

#if NETWORK_PROTECTION

import Foundation

protocol NetworkProtectionFeatureVisibility {
    func isWaitlistBetaActive() -> Bool
    func isWaitlistUser() -> Bool
    func hasWaitlistAccess() -> Bool
    func isPrivacyProLaunched() -> Bool

    func shouldShowPrivacyPro() -> Bool
    func shouldShowThankYouMessaging() -> Bool
    func shouldKeepWaitlist() -> Bool
    func shouldMonitoringEntitlement() -> Bool
}

extension NetworkProtectionFeatureVisibility {
    func shouldShowPrivacyPro() -> Bool {
        isPrivacyProLaunched()
    }

    func shouldShowThankYouMessaging() -> Bool {
        isPrivacyProLaunched() && isWaitlistUser()
    }

    func shouldKeepWaitlist() -> Bool {
        !isPrivacyProLaunched() && hasWaitlistAccess()
    }
}


#endif
