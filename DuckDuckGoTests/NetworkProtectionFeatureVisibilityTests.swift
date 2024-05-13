//
//  NetworkProtectionFeatureVisibilityTests.swift
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

import XCTest
@testable import DuckDuckGo
import Subscription
import SubscriptionTestingUtilities

/// Test all permutations according to https://app.asana.com/0/0/1206812323779606/f
final class NetworkProtectionFeatureVisibilityTests: XCTestCase {
    func testPrivacyProNotYetLaunched() {
        // Current waitlist user -> VPN works as usual, no thank-you, no entitlement check
        let mockWithVPNAccess = NetworkProtectionFeatureVisibilityMocks(with: [.isWaitlistBetaActive, .isWaitlistUser])
        XCTAssertFalse(mockWithVPNAccess.shouldMonitorEntitlement())
        XCTAssertTrue(mockWithVPNAccess.shouldKeepVPNAccessViaWaitlist())
        XCTAssertFalse(mockWithVPNAccess.shouldShowThankYouMessaging())
        XCTAssertTrue(mockWithVPNAccess.shouldShowVPNShortcut())

        // Not current waitlist user -> Show nothing, use nothing
        let mockWithBetaActive = NetworkProtectionFeatureVisibilityMocks(with: [.isWaitlistBetaActive])
        XCTAssertFalse(mockWithBetaActive.shouldMonitorEntitlement())
        XCTAssertFalse(mockWithBetaActive.shouldKeepVPNAccessViaWaitlist())
        XCTAssertFalse(mockWithBetaActive.shouldShowThankYouMessaging())
        XCTAssertFalse(mockWithBetaActive.shouldShowVPNShortcut())

        // Waitlist beta OFF, current waitlist user -> Show nothing, use nothing
        let mockWithBetaInactive = NetworkProtectionFeatureVisibilityMocks(with: [.isWaitlistUser])
        XCTAssertFalse(mockWithBetaInactive.shouldMonitorEntitlement())
        XCTAssertFalse(mockWithBetaInactive.shouldKeepVPNAccessViaWaitlist())
        XCTAssertFalse(mockWithBetaInactive.shouldShowThankYouMessaging())
        XCTAssertFalse(mockWithBetaInactive.shouldShowVPNShortcut())

        // Waitlist beta OFF, not current waitlist user -> Show nothing, use nothing
        let mockWithNothing = NetworkProtectionFeatureVisibilityMocks(with: [])
        XCTAssertFalse(mockWithNothing.shouldMonitorEntitlement())
        XCTAssertFalse(mockWithNothing.shouldKeepVPNAccessViaWaitlist())
        XCTAssertFalse(mockWithNothing.shouldShowThankYouMessaging())
        XCTAssertFalse(mockWithNothing.shouldShowVPNShortcut())
    }

    func testPrivacyProLaunched() {
        let baseMock = NetworkProtectionFeatureVisibilityMocks(with: [.isPrivacyProLaunched])

        // Current waitlist user -> Show thank-you, enforce entitlement check, no more VPN use
        let mockWithVPNAccess = baseMock.adding([.isWaitlistUser, .isWaitlistBetaActive])
        XCTAssertTrue(mockWithVPNAccess.shouldMonitorEntitlement())
        XCTAssertFalse(mockWithVPNAccess.shouldKeepVPNAccessViaWaitlist())
        XCTAssertTrue(mockWithVPNAccess.shouldShowThankYouMessaging())
        XCTAssertFalse(mockWithVPNAccess.shouldShowVPNShortcut())

        // Not current waitlist user -> Enforce entitlement check, no more VPN use, no thank-you
        let mockWithBetaActive = baseMock.adding([.isWaitlistBetaActive])
        XCTAssertTrue(mockWithBetaActive.shouldMonitorEntitlement())
        XCTAssertFalse(mockWithBetaActive.shouldKeepVPNAccessViaWaitlist())
        XCTAssertFalse(mockWithBetaActive.shouldShowThankYouMessaging())
        XCTAssertFalse(mockWithBetaActive.shouldShowVPNShortcut())

        // Waitlist beta OFF, current waitlist user -> Show thank-you, enforce entitlement check, no more VPN use
        let mockWithBetaInactive = baseMock.adding([.isWaitlistUser])
        XCTAssertTrue(mockWithBetaInactive.shouldMonitorEntitlement())
        XCTAssertFalse(mockWithBetaInactive.shouldKeepVPNAccessViaWaitlist())
        XCTAssertTrue(mockWithBetaInactive.shouldShowThankYouMessaging())
        XCTAssertFalse(mockWithBetaInactive.shouldShowVPNShortcut())

        // Waitlist beta OFF, not current waitlist user -> Enforce entitlement check, nothing else
        let mockWithNothingElse = baseMock
        XCTAssertTrue(mockWithNothingElse.shouldMonitorEntitlement())
        XCTAssertFalse(mockWithNothingElse.shouldKeepVPNAccessViaWaitlist())
        XCTAssertFalse(mockWithNothingElse.shouldShowThankYouMessaging())
        XCTAssertFalse(mockWithNothingElse.shouldShowVPNShortcut())
    }
}

struct NetworkProtectionFeatureVisibilityMocks: NetworkProtectionFeatureVisibility {
    
    let accountManager = AccountManagerMock(isUserAuthenticated: true) // TODO: this makes no sense

    func shouldShowThankYouMessaging() -> Bool {
        isPrivacyProLaunched() && isWaitlistUser()
    }

    func shouldKeepVPNAccessViaWaitlist() -> Bool {
        !isPrivacyProLaunched() && isWaitlistBetaActive() && isWaitlistUser()
    }

    func shouldShowVPNShortcut() -> Bool {
        if isPrivacyProLaunched() {
            return accountManager.isUserAuthenticated
        } else {
            return shouldKeepVPNAccessViaWaitlist()
        }
    }

    struct Options: OptionSet {
        let rawValue: Int

        static let isWaitlistBetaActive = Options(rawValue: 1 << 0)
        static let isWaitlistUser = Options(rawValue: 1 << 1)
        static let isPrivacyProLaunched = Options(rawValue: 1 << 2)
    }

    let options: Options

    init(with options: Options) {
        self.options = options
    }

    func adding(_ additionalOptions: Options) -> NetworkProtectionFeatureVisibilityMocks {
        NetworkProtectionFeatureVisibilityMocks(with: options.union(additionalOptions))
    }

    func isWaitlistBetaActive() -> Bool {
        options.contains(.isWaitlistBetaActive)
    }

    func isWaitlistUser() -> Bool {
        options.contains(.isWaitlistUser)
    }

    func isPrivacyProLaunched() -> Bool {
        options.contains(.isPrivacyProLaunched)
    }

    func shouldMonitorEntitlement() -> Bool {
        isPrivacyProLaunched()
    }
}
