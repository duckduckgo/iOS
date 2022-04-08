//
//  MacWaitlistViewModelTests.swift
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

class MacWaitlistViewModelTests: XCTestCase {

    private let mockToken = "mock-token"
    private let oldTimestamp = 100
    private let newTimestamp = 200

    private let notificationsAllowed = MockNotificationService(authorized: true)
    private let notificationsDisabled = MockNotificationService(authorized: false)
    
    @MainActor
    func testWhenWaitlistNotJoined_ThenViewStateIsJoinQueue() {
        let request = MockWaitlistRequest.failure()
        let storage = MockWaitlistStorage()
        let viewModel = MacWaitlistViewModel(waitlistRequest: request, waitlistStorage: storage)
        
        XCTAssertEqual(viewModel.viewState, .notJoinedQueue)
    }
    
    @MainActor
    func testWhenWaitlistNotJoined_AndJoinQueueActionIsPerformed_AndRequestSucceeds_AndNotificationsAreAllowed_ThenViewStateIsJoinedQueue() async {
        let request = MockWaitlistRequest.returning(.success(.init(token: mockToken, timestamp: oldTimestamp)))
        let storage = MockWaitlistStorage()
        let viewModel = MacWaitlistViewModel(waitlistRequest: request, waitlistStorage: storage, notificationService: notificationsAllowed)
        
        await viewModel.perform(action: .joinQueue)
        
        XCTAssertEqual(viewModel.viewState, .joinedQueue(.notificationAllowed))
    }
    
    @MainActor
    func testWhenWaitlistNotJoined_AndJoinQueueActionIsPerformed_AndRequestSucceeds_AndNotificationsAreDeclined_ThenViewStateIsJoinedQueue() async {
        let request = MockWaitlistRequest.returning(.success(.init(token: mockToken, timestamp: oldTimestamp)))
        let storage = MockWaitlistStorage()
        let viewModel = MacWaitlistViewModel(waitlistRequest: request, waitlistStorage: storage, notificationService: notificationsDisabled)
        
        await viewModel.perform(action: .joinQueue)
        
        XCTAssertEqual(viewModel.viewState, .joinedQueue(.notificationsDisabled))
    }
    
    @MainActor
    func testWhenWaitlistNotJoined_AndJoinQueueActionIsPerformed_AndRequestFails_ThenViewStateIsNotJoined() async {
        let request = MockWaitlistRequest.failure()
        let storage = MockWaitlistStorage()
        let viewModel = MacWaitlistViewModel(waitlistRequest: request, waitlistStorage: storage)

        await viewModel.perform(action: .joinQueue)

        XCTAssertEqual(viewModel.viewState, .notJoinedQueue)
    }
    
    @MainActor
    func testWhenWaitlistHasTokenAndTimestamp_AndInviteCodeIsNil_ThenViewStateIsJoinedQueue() {
        let request = MockWaitlistRequest.failure()
        let storage = MockWaitlistStorage()
        storage.store(waitlistToken: mockToken)
        storage.store(waitlistTimestamp: oldTimestamp)

        let viewModel = MacWaitlistViewModel(waitlistRequest: request, waitlistStorage: storage)

        XCTAssertEqual(viewModel.viewState, .joinedQueue(.notificationAllowed))
    }
    
    @MainActor
    func testWhenWaitlistHasInviteCode_ThenViewStateIsInvited() {
        let request = MockWaitlistRequest.failure()
        let storage = MockWaitlistStorage()
        storage.store(inviteCode: "invite-code")

        let viewModel = MacWaitlistViewModel(waitlistRequest: request, waitlistStorage: storage)

        XCTAssertEqual(viewModel.viewState, .invited(inviteCode: "invite-code"))
    }
    
    @MainActor
    func testWhenOpenShareSheetActionIsPerformed_ThenShowShareSheetIsTrue() async {
        let inviteCode = "INVITECODE"
        let request = MockWaitlistRequest.returning(.success(.init(token: mockToken, timestamp: newTimestamp)))
        let storage = MockWaitlistStorage()
        storage.store(inviteCode: inviteCode)

        let viewModel = MacWaitlistViewModel(waitlistRequest: request, waitlistStorage: storage)
        let delegate = MockMacWaitlistViewModelDelegate()
        viewModel.delegate = delegate
        
        await viewModel.perform(action: .openShareSheet(.zero))
        
        XCTAssertTrue(delegate.didOpenShareSheetCalled)
        XCTAssertEqual(delegate.didOpenShareSheetInviteCode, inviteCode)
    }
    
}
