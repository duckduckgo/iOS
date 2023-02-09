//
//  WaitlistStorageTests.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import WaitlistMocks
@testable import Waitlist

class WaitlistStorageTests: XCTestCase {

    func testWaitlistKeychainServiceName() {
        XCTAssertEqual(
            WaitlistKeychainStore(waitlistIdentifier: "mac", keychainPrefix: "com.duckduckgo.test").keychainServiceName(for: .waitlistTimestamp),
            "com.duckduckgo.test.waitlist.mac.timestamp"
        )

        XCTAssertEqual(
            WaitlistKeychainStore(waitlistIdentifier: "windows", keychainPrefix: "com.duckduckgo.test").keychainServiceName(for: .inviteCode),
            "com.duckduckgo.test.waitlist.windows.invite-code"
        )

        XCTAssertEqual(
            WaitlistKeychainStore(waitlistIdentifier: "mac", keychainPrefix: "com.duckduckgo.test").keychainServiceName(for: .waitlistToken),
            "com.duckduckgo.test.waitlist.mac.token"
        )
    }

    func testWhenCheckingIfUserIsOnWaitlist_AndUserHasNoTokenOrTimeStamp_ThenIsOnWaitlistIsFalse() {
        let storage = MockWaitlistStorage()

        XCTAssertFalse(storage.isOnWaitlist)
        XCTAssertFalse(storage.isInvited)
    }

    func testWhenCheckingIfUserIsOnWaitlist_AndUserHasTokenAndTimeStamp_ThenIsOnWaitlistIsTrue() {
        let storage = MockWaitlistStorage()
        storage.store(waitlistToken: "token")
        storage.store(waitlistTimestamp: 1)

        XCTAssertTrue(storage.isOnWaitlist)
        XCTAssertFalse(storage.isInvited)
    }

    func testWhenCheckingIfUserIsOnWaitlist_AndUserHasTokenAndTimeStamp_AndUserHasInviteCode_ThenIsOnWaitlistIsFalse_AndIsInvitedIsTrue() {
        let storage = MockWaitlistStorage()
        storage.store(waitlistToken: "token")
        storage.store(waitlistTimestamp: 1)
        storage.store(inviteCode: "INVITECODE")

        XCTAssertFalse(storage.isOnWaitlist)
        XCTAssertTrue(storage.isInvited)
    }

}
