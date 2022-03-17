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

    @MainActor
    func testWhenWaitlistNotJoined_ThenViewStateIsJoinQueue() {
        let request = MockWaitlistRequest.failure()
        let storage = MockWaitlistStorage()
        let viewModel = MacWaitlistViewModel(waitlistRequest: request, waitlistStorage: storage)
        
        XCTAssertEqual(viewModel.viewState, .notJoinedQueue)
    }
    
    @MainActor
    func testWhenWaitlistNotJoined_AndJoinQueueActionIsPerformed_AndRequestSucceeds_ThenViewStateIsJoiningQueue() async {
        let request = MockWaitlistRequest.returning(.success(.init(token: mockToken, timestamp: oldTimestamp)))
        let storage = MockWaitlistStorage()
        let viewModel = MacWaitlistViewModel(waitlistRequest: request, waitlistStorage: storage)
        
        XCTAssertFalse(viewModel.showNotificationPrompt)
        
        await viewModel.perform(action: .joinQueue)
        
        XCTAssertEqual(viewModel.viewState, .joiningQueue)
        XCTAssertTrue(viewModel.showNotificationPrompt)
    }
    
    @MainActor
    func testWhenWaitlistNotJoined_AndJoinQueueActionIsPerformed_AndRequestFails_ThenViewStateIsNotJoined() async {
        let request = MockWaitlistRequest.failure()
        let storage = MockWaitlistStorage()
        let viewModel = MacWaitlistViewModel(waitlistRequest: request, waitlistStorage: storage)
        
        XCTAssertFalse(viewModel.showNotificationPrompt)
        
        await viewModel.perform(action: .joinQueue)
        
        XCTAssertEqual(viewModel.viewState, .notJoinedQueue)
        XCTAssertFalse(viewModel.showNotificationPrompt)
    }
    
    @MainActor
    func testWhenWaitlistJoiningQueue_AndAcceptNotificationsActionIsPerformed_AndNotificationPermissionIsGranted_ThenViewStateIsJoinedQueue() async {
        let request = MockWaitlistRequest.returning(.success(.init(token: mockToken, timestamp: newTimestamp)))
        let storage = MockWaitlistStorage()
        let notificationService = MockNotificationService(authorized: true)
        let viewModel = MacWaitlistViewModel(waitlistRequest: request, waitlistStorage: storage, notificationService: notificationService)

        await viewModel.perform(action: .joinQueue)

        XCTAssertEqual(viewModel.viewState, .joiningQueue)
        XCTAssertTrue(viewModel.showNotificationPrompt)
        XCTAssertFalse(storage.shouldReceiveNotifications())

        await viewModel.perform(action: .acceptNotifications)

        XCTAssertTrue(storage.shouldReceiveNotifications())
        XCTAssertEqual(viewModel.viewState, .joinedQueue(.notificationAllowed))
    }
    
    @MainActor
    func testWhenWaitlistJoiningQueue_AndAcceptNotificationsActionIsPerformed_AndNotificationPermissionIsDenied_ThenViewStateIsJoinedQueue() async {
        let request = MockWaitlistRequest.returning(.success(.init(token: mockToken, timestamp: newTimestamp)))
        let storage = MockWaitlistStorage()
        let notificationService = MockNotificationService(authorized: false)
        let viewModel = MacWaitlistViewModel(waitlistRequest: request, waitlistStorage: storage, notificationService: notificationService)

        await viewModel.perform(action: .joinQueue)

        XCTAssertEqual(viewModel.viewState, .joiningQueue)
        XCTAssertTrue(viewModel.showNotificationPrompt)
        XCTAssertFalse(storage.shouldReceiveNotifications())

        await viewModel.perform(action: .acceptNotifications)

        XCTAssertFalse(storage.shouldReceiveNotifications())
        XCTAssertEqual(viewModel.viewState, .joinedQueue(.notificationsDisabled))
    }
    
    @MainActor
    func testWhenWaitlistJoiningQueue_AndDeclineNotificationsActionIsPerformed_ThenViewStateIsJoinedQueue() async {
        let request = MockWaitlistRequest.returning(.success(.init(token: mockToken, timestamp: newTimestamp)))
        let storage = MockWaitlistStorage()
        let viewModel = MacWaitlistViewModel(waitlistRequest: request, waitlistStorage: storage)
        
        await viewModel.perform(action: .joinQueue)
        
        XCTAssertEqual(viewModel.viewState, .joiningQueue)
        XCTAssertTrue(viewModel.showNotificationPrompt)
        XCTAssertFalse(storage.shouldReceiveNotifications())
        
        await viewModel.perform(action: .declineNotifications)
        
        XCTAssertFalse(storage.shouldReceiveNotifications())
        XCTAssertEqual(viewModel.viewState, .joinedQueue(.notificationDenied))
    }
    
    @MainActor
    func testWhenWaitlistHasTokenAndTimestamp_AndInviteCodeIsNil_ThenViewStateIsJoinedQueue() {
        let request = MockWaitlistRequest.failure()
        let storage = MockWaitlistStorage()
        storage.store(waitlistToken: mockToken)
        storage.store(waitlistTimestamp: oldTimestamp)
        storage.store(shouldReceiveNotifications: true)

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
        let request = MockWaitlistRequest.returning(.success(.init(token: mockToken, timestamp: newTimestamp)))
        let storage = MockWaitlistStorage()
        let viewModel = MacWaitlistViewModel(waitlistRequest: request, waitlistStorage: storage)
        
        XCTAssertFalse(viewModel.showShareSheet)
        await viewModel.perform(action: .openShareSheet)
        XCTAssertTrue(viewModel.showShareSheet)
    }
    
}

// MARK: - Private Mocks

private struct MockWaitlistRequest: WaitlistRequest {
    
    static func failure() -> MockWaitlistRequest {
        return MockWaitlistRequest(joinResult: .failure(.noData),
                                   statusResult: .failure(.noData),
                                   inviteCodeResult: .failure(.noData))
    }
    
    static func returning(_ joinResult: WaitlistJoinResult) -> MockWaitlistRequest {
        return MockWaitlistRequest(joinResult: joinResult,
                                   statusResult: .success(.init(timestamp: 0)),
                                   inviteCodeResult: .failure(.noData))
    }
    
    let joinResult: WaitlistJoinResult
    let statusResult: Result<WaitlistResponse.Status, WaitlistResponse.StatusError>
    let inviteCodeResult: Result<WaitlistResponse.InviteCode, WaitlistResponse.InviteCodeError>
    
    func joinWaitlist(completionHandler: @escaping WaitlistJoinCompletion) {
        completionHandler(joinResult)
    }
    
    func joinWaitlist() async -> WaitlistJoinResult {
        return joinResult
    }
    
    func getWaitlistStatus(completionHandler: @escaping (Result<WaitlistResponse.Status, WaitlistResponse.StatusError>) -> Void) {
        completionHandler(statusResult)
    }
    
    func getInviteCode(token: String, completionHandler: @escaping (Result<WaitlistResponse.InviteCode, WaitlistResponse.InviteCodeError>) -> Void) {
        completionHandler(inviteCodeResult)
    }
    
}

private class MockWaitlistStorage: MacBrowserWaitlistStorage {
    
    private var token: String?
    private var timestamp: Int?
    private var code: String?
    private var receiveNotifications: Bool = false
    
    func getWaitlistToken() -> String? {
        return token
    }
    
    func getWaitlistTimestamp() -> Int? {
        return timestamp
    }
    
    func getWaitlistInviteCode() -> String? {
        return code
    }
    
    func store(waitlistToken: String) {
        token = waitlistToken
    }
    
    func store(waitlistTimestamp: Int) {
        timestamp = waitlistTimestamp
    }
    
    func store(inviteCode: String) {
        code = inviteCode
    }
    
    func deleteWaitlistState() {
        token = nil
        timestamp = nil
        code = nil
    }
    
    func store(shouldReceiveNotifications: Bool) {
        receiveNotifications = shouldReceiveNotifications
    }
    
    func shouldReceiveNotifications() -> Bool {
        return receiveNotifications
    }
    
}

private struct MockNotificationService: NotificationService {
    
    let authorized: Bool

    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        return authorized
    }
    
}
