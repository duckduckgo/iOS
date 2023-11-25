//
//  NetworkProtectionAccessControllerTests.swift
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

#if NETWORK_PROTECTION

import XCTest
import BrowserServicesKit
import NetworkProtection
import NetworkExtension
import NetworkProtectionTestUtils
import WaitlistMocks
@testable import DuckDuckGo

final class NetworkProtectionAccessControllerTests: XCTestCase {

    var internalUserDeciderStore: MockInternalUserStoring!
    
    override func setUp() {
        super.setUp()
        internalUserDeciderStore = MockInternalUserStoring()

        // True by default until NetP ships, as it is not visible at all to external users.
        internalUserDeciderStore.isInternalUser = true
    }

    override func tearDown() {
        internalUserDeciderStore = nil
        super.tearDown()
    }

    func testWhenFeatureFlagsAreDisabled_AndTheUserHasNotBeenDirectlyInvited_ThenNetworkProtectionIsNotAccessible() {
        let controller = createMockAccessController(
            isInternalUser: false,
            featureActivated: false,
            termsAccepted: false,
            featureFlagsEnabled: false,
            hasJoinedWaitlist: false,
            hasBeenInvited: false
        )

        XCTAssertEqual(controller.networkProtectionAccessType(), .none)
    }

    func testWhenFeatureFlagsAreDisabled_AndTheUserHasBeenDirectlyInvited_ThenNetworkProtectionIsNotAccessible() {
        let controller = createMockAccessController(
            featureActivated: true,
            termsAccepted: false,
            featureFlagsEnabled: false,
            hasJoinedWaitlist: false,
            hasBeenInvited: false
        )

        XCTAssertEqual(controller.networkProtectionAccessType(), .inviteCodeInvited)
    }

    func testWhenFeatureFlagsAreEnabled_AndTheUserHasNotSignedUp_ThenNetworkProtectionIsAccessible() {
        let controller = createMockAccessController(
            featureActivated: false,
            termsAccepted: false,
            featureFlagsEnabled: true,
            hasJoinedWaitlist: false,
            hasBeenInvited: false
        )

        XCTAssertEqual(controller.networkProtectionAccessType(), .waitlistAvailable)
    }

    func testWhenFeatureFlagsAreEnabled_AndTheUserHasSignedUp_ThenNetworkProtectionIsAccessible() {
        let controller = createMockAccessController(
            featureActivated: false,
            termsAccepted: false,
            featureFlagsEnabled: true,
            hasJoinedWaitlist: true,
            hasBeenInvited: false
        )

        XCTAssertEqual(controller.networkProtectionAccessType(), .waitlistJoined)
    }

    func testWhenFeatureFlagsAreEnabled_AndTheUserHasBeenInvited_ThenNetworkProtectionIsAccessible() {
        let controller = createMockAccessController(
            featureActivated: true,
            termsAccepted: false,
            featureFlagsEnabled: true,
            hasJoinedWaitlist: true,
            hasBeenInvited: true
        )

        XCTAssertEqual(controller.networkProtectionAccessType(), .waitlistInvitedPendingTermsAcceptance)
    }

    func testWhenFeatureFlagsAreEnabled_AndTheUserHasAcceptedTerms_ThenNetworkProtectionIsAccessible() {
        let controller = createMockAccessController(
            featureActivated: true,
            termsAccepted: true,
            featureFlagsEnabled: true,
            hasJoinedWaitlist: true,
            hasBeenInvited: true
        )

        XCTAssertEqual(controller.networkProtectionAccessType(), .waitlistInvited)
    }

    // MARK: - Mock Creation

    private func createMockAccessController(
        isInternalUser: Bool = true,
        featureActivated: Bool,
        termsAccepted: Bool,
        featureFlagsEnabled: Bool,
        hasJoinedWaitlist: Bool,
        hasBeenInvited: Bool
    ) -> NetworkProtectionAccessController {
        internalUserDeciderStore.isInternalUser = isInternalUser

        let mockActivation = MockNetworkProtectionFeatureActivation()
        mockActivation.isFeatureActivated = featureActivated

        let mockWaitlistStorage = MockWaitlistStorage()

        if hasJoinedWaitlist {
            mockWaitlistStorage.store(waitlistTimestamp: 1)
            mockWaitlistStorage.store(waitlistToken: "token")

            if hasBeenInvited {
                mockWaitlistStorage.store(inviteCode: "INVITECODE")
            }
        }

        let mockTermsAndConditionsStore = MockNetworkProtectionTermsAndConditionsStore()
        mockTermsAndConditionsStore.networkProtectionWaitlistTermsAndConditionsAccepted = termsAccepted
        let mockFeatureFlagger = createFeatureFlagger(withSubfeatureEnabled: featureFlagsEnabled)

        return NetworkProtectionAccessController(
            networkProtectionActivation: mockActivation,
            networkProtectionWaitlistStorage: mockWaitlistStorage,
            networkProtectionTermsAndConditionsStore: mockTermsAndConditionsStore,
            featureFlagger: mockFeatureFlagger
        )
    }

    private func createFeatureFlagger(withSubfeatureEnabled enabled: Bool) -> DefaultFeatureFlagger {
        let mockManager = MockPrivacyConfigurationManager()
        mockManager.privacyConfig = mockConfiguration(subfeatureEnabled: enabled)

        let internalUserDecider = DefaultInternalUserDecider(store: internalUserDeciderStore)
        return DefaultFeatureFlagger(internalUserDecider: internalUserDecider, privacyConfig: mockManager.privacyConfig)
    }

    private func mockConfiguration(subfeatureEnabled: Bool) -> PrivacyConfiguration {
        let mockPrivacyConfiguration = MockPrivacyConfiguration()
        mockPrivacyConfiguration.isSubfeatureKeyEnabled = { _, _ in
            return subfeatureEnabled
        }

        return mockPrivacyConfiguration
    }

}

private class MockNetworkProtectionTermsAndConditionsStore: NetworkProtectionTermsAndConditionsStore {

    var networkProtectionWaitlistTermsAndConditionsAccepted: Bool = false

}

#endif
