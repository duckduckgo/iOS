//
//  MacBrowserWaitlistTests.swift
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
@testable import DuckDuckGo
@testable import Core

class MacBrowserWaitlistTests: XCTestCase {
 
    func testWhenUserHasNotJoinedWaitlist_ThenSettingsSubtitleIsCorrect() {
        let store = MockWaitlistStorage()
        let request = MockWaitlistRequest.failure()
        let waitlist = MacBrowserWaitlist(store: store, request: request)
        
        XCTAssertEqual(waitlist.settingsSubtitle(), UserText.macWaitlistBrowsePrivately)
    }
    
    func testWhenUserHasIsInvited_ThenSettingsSubtitleIsCorrect() {
        let store = MockWaitlistStorage()
        store.store(inviteCode: "code")

        let request = MockWaitlistRequest.failure()
        let waitlist = MacBrowserWaitlist(store: store, request: request)
        
        XCTAssertEqual(waitlist.settingsSubtitle(), UserText.macWaitlistBrowsePrivately)
    }

    func testWhenFetchingInviteCode_AndUserIsNotOnWaitlist_ThenErrorIsReturned() async {
        let store = MockWaitlistStorage()
        let request = MockWaitlistRequest.failure()
        let waitlist = MacBrowserWaitlist(store: store, request: request)
        
        let error = await waitlist.fetchInviteCodeIfAvailable()
        
        XCTAssertEqual(error, .notOnWaitlist)
    }
    
    func testWhenFetchingInviteCode_AndUserIsAlreadyInvited_ThenErrorIsReturned() async {
        let store = MockWaitlistStorage()
        store.store(inviteCode: "code")
        
        let request = MockWaitlistRequest.failure()
        let waitlist = MacBrowserWaitlist(store: store, request: request)
        
        let error = await waitlist.fetchInviteCodeIfAvailable()
        
        XCTAssertEqual(error, .alreadyHasInviteCode)
    }
    
    func testWhenFetchingInviteCode_AndUserHasNotBeenInvited_ThenErrorIsReturned() async {
        let store = MockWaitlistStorage()
        store.store(waitlistToken: "token")
        store.store(waitlistTimestamp: 10)
        
        let request = MockWaitlistRequest(joinResult: .success(.init(token: "token", timestamp: 10)),
                                          statusResult: .success(.init(timestamp: 0)),
                                          inviteCodeResult: .failure(.noData))
        
        let waitlist = MacBrowserWaitlist(store: store, request: request)
        let error = await waitlist.fetchInviteCodeIfAvailable()
        
        XCTAssertEqual(error, .noCodeAvailable)
    }
    
    func testWhenFetchingInviteCode_AndUserHasBeenInvited_ThenErrorIsReturned() async {
        let store = MockWaitlistStorage()
        store.store(waitlistToken: "token")
        store.store(waitlistTimestamp: 10)
        
        let request = MockWaitlistRequest(joinResult: .success(.init(token: "token", timestamp: 10)),
                                          statusResult: .success(.init(timestamp: 20)),
                                          inviteCodeResult: .success(.init(code: "INVITECODE")))
        
        let waitlist = MacBrowserWaitlist(store: store, request: request)
        let error = await waitlist.fetchInviteCodeIfAvailable()
        
        XCTAssertNil(error)
        XCTAssertTrue(store.isInvited)
        XCTAssertEqual(store.getWaitlistInviteCode(), "INVITECODE")
    }
    
}
