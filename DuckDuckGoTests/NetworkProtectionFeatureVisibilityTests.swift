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

/// Test all permutations according to https://app.asana.com/0/0/1206812323779606/f
final class NetworkProtectionFeatureVisibilityTests: XCTestCase {
    func testPrivacyProNotYetLaunched() {
        // Current waitlist user -> VPN works as usual, no thank-you, no PP access, no entitlement check
        let mockWithVPNAccess = NetworkProtectionFeatureVisibilityMocks(with: [.isWaitlistBetaActive, .isWaitlistUser])
        XCTAssertFalse(mockWithVPNAccess.shouldShowPrivacyPro())
        XCTAssertFalse(mockWithVPNAccess.shouldMonitorEntitlement())
        XCTAssertTrue(mockWithVPNAccess.shouldKeepWaitlist())
        XCTAssertFalse(mockWithVPNAccess.shouldShowThankYouMessaging())
        testCommonSense(for: mockWithVPNAccess)

        // Not current waitlist user -> Show nothing, use nothing
        let mockWithBetaActive = NetworkProtectionFeatureVisibilityMocks(with: [.isWaitlistBetaActive])
        XCTAssertFalse(mockWithBetaActive.shouldShowPrivacyPro())
        XCTAssertFalse(mockWithBetaActive.shouldMonitorEntitlement())
        XCTAssertFalse(mockWithBetaActive.shouldKeepWaitlist())
        XCTAssertFalse(mockWithBetaActive.shouldShowThankYouMessaging())
        testCommonSense(for: mockWithBetaActive)

        // Waitlist beta OFF, current waitlist user -> Show nothing, use nothing
        let mockWithBetaInactive = NetworkProtectionFeatureVisibilityMocks(with: [.isWaitlistUser])
        XCTAssertFalse(mockWithBetaInactive.shouldShowPrivacyPro())
        XCTAssertFalse(mockWithBetaInactive.shouldMonitorEntitlement())
        XCTAssertFalse(mockWithBetaInactive.shouldKeepWaitlist())
        XCTAssertFalse(mockWithBetaInactive.shouldShowThankYouMessaging())
        testCommonSense(for: mockWithBetaInactive)

        // Waitlist beta OFF, not current waitlist user -> Show nothing, use nothing
        let mockWithNothing = NetworkProtectionFeatureVisibilityMocks(with: [])
        XCTAssertFalse(mockWithNothing.shouldShowPrivacyPro())
        XCTAssertFalse(mockWithNothing.shouldMonitorEntitlement())
        XCTAssertFalse(mockWithNothing.shouldKeepWaitlist())
        XCTAssertFalse(mockWithNothing.shouldShowThankYouMessaging())
        testCommonSense(for: mockWithNothing)
    }

    func testPrivacyProLaunched() {
        let baseMock = NetworkProtectionFeatureVisibilityMocks(with: [.isPrivacyProLaunched])

        // Current waitlist user -> Show PP & thank-you, enforce entitlement check, no more VPN use
        let mockWithVPNAccess = baseMock.adding([.isWaitlistUser, .isWaitlistBetaActive])
        XCTAssertTrue(mockWithVPNAccess.shouldShowPrivacyPro())
        XCTAssertTrue(mockWithVPNAccess.shouldMonitorEntitlement())
        XCTAssertFalse(mockWithVPNAccess.shouldKeepWaitlist())
        XCTAssertTrue(mockWithVPNAccess.shouldShowThankYouMessaging())
        testCommonSense(for: mockWithVPNAccess)

        // Not current waitlist user -> Show PP, enforce entitlement check, no more VPN use, no thank-you
        let mockWithBetaActive = baseMock.adding([.isWaitlistBetaActive])
        XCTAssertTrue(mockWithBetaActive.shouldShowPrivacyPro())
        XCTAssertTrue(mockWithBetaActive.shouldMonitorEntitlement())
        XCTAssertFalse(mockWithBetaActive.shouldKeepWaitlist())
        XCTAssertFalse(mockWithBetaActive.shouldShowThankYouMessaging())
        testCommonSense(for: mockWithBetaActive)

        // Waitlist beta OFF, current waitlist user -> Show PP & thank-you, enforce entitlement check, no more VPN use
        let mockWithBetaInactive = baseMock.adding([.isWaitlistUser])
        XCTAssertTrue(mockWithBetaInactive.shouldShowPrivacyPro())
        XCTAssertTrue(mockWithBetaInactive.shouldMonitorEntitlement())
        XCTAssertFalse(mockWithBetaInactive.shouldKeepWaitlist())
        XCTAssertTrue(mockWithBetaInactive.shouldShowThankYouMessaging())
        testCommonSense(for: mockWithBetaInactive)

        // Waitlist beta OFF, not current wailist user -> Show PP, enforce entitlement check, nothing else
        let mockWithNothingElse = baseMock
        XCTAssertTrue(mockWithNothingElse.shouldShowPrivacyPro())
        XCTAssertTrue(mockWithNothingElse.shouldMonitorEntitlement())
        XCTAssertFalse(mockWithNothingElse.shouldKeepWaitlist())
        XCTAssertFalse(mockWithNothingElse.shouldShowThankYouMessaging())
        testCommonSense(for: mockWithNothingElse)
    }

    /// Regardless of scenarios, certain logic should be satisfied at all time
    private func testCommonSense(for mock: NetworkProtectionFeatureVisibilityMocks) {
        if mock.shouldShowPrivacyPro() {
            XCTAssertFalse(mock.shouldKeepWaitlist())
            XCTAssertTrue(mock.shouldMonitorEntitlement())
        }
        
        if mock.shouldShowThankYouMessaging() {
            XCTAssertFalse(mock.shouldKeepWaitlist())
        }

        if mock.shouldMonitorEntitlement() {
            XCTAssertTrue(mock.shouldShowPrivacyPro())
        }

        if mock.shouldKeepWaitlist() {
            XCTAssertFalse(mock.shouldShowPrivacyPro())
        }
    }
}

struct NetworkProtectionFeatureVisibilityMocks: NetworkProtectionFeatureVisibility {
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
