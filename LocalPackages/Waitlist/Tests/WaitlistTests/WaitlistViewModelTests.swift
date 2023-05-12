//
//  WaitlistViewModelTests.swift
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
import Combine
import UserNotifications
import WaitlistMocks
@testable import Waitlist

class WaitlistViewModelTests: XCTestCase {

    private let mockToken = "mock-token"
    private let timestamp = 20

    @MainActor
    func testWhenNotificationServiceIsNilThenStateIsWaitlistRemoved() async {
        let viewModel = WaitlistViewModel(MockWaitlistRequest.failure(), MockWaitlistStorage())

        XCTAssertEqual(viewModel.viewState, .waitlistRemoved)
    }

    // MARK: - Update View State

    @MainActor
    func testWhenTimestampIsPresentAndInviteCodeIsNil_ThenStateIsJoinedQueue() async {

        let request = MockWaitlistRequest.failure()
        let storage = MockWaitlistStorage.init()
        storage.store(waitlistTimestamp: 12345)
        let notificationService = MockNotificationService(authorizationStatus: .authorized)
        let viewModel = WaitlistViewModel(request, storage, notificationService)

        await viewModel.updateViewState()

        XCTAssertEqual(viewModel.viewState, .joinedQueue(.notificationAllowed))
    }

    @MainActor
    func testWhenTimestampIsPresentAndInviteCodeIsAlsoPresent_ThenStateIsInvited() async {

        let request = MockWaitlistRequest.failure()
        let storage = MockWaitlistStorage.init()
        storage.store(waitlistTimestamp: 12345)
        storage.store(inviteCode: "TE5TC0DE")
        let viewModel = WaitlistViewModel(request, storage, MockNotificationService())

        await viewModel.updateViewState()

        XCTAssertEqual(viewModel.viewState, .invited(inviteCode: "TE5TC0DE"))
    }

    @MainActor
    func testWhenTimestampIsNotPresent_ThenStateIsNotJoinedQueue() async {

        let request = MockWaitlistRequest.failure()
        let storage = MockWaitlistStorage.init()
        let viewModel = WaitlistViewModel(request, storage, MockNotificationService())

        await viewModel.updateViewState()

        XCTAssertEqual(viewModel.viewState, .notJoinedQueue)
    }

    // MARK: - Join Queue

    @MainActor
    func testWhenJoinQueueIsCalled_ThenViewStateIsUpdatedToJoinedQueue() async {

        let request = MockWaitlistRequest.returning(.success(.init(token: mockToken, timestamp: timestamp)))
        let storage = MockWaitlistStorage()
        var notificationService = MockNotificationService()
        notificationService.authorizationStatus = .notDetermined
        let viewModel = WaitlistViewModel(request, storage, notificationService)

        var stateUpdates: [WaitlistViewModel.ViewState] = []
        let cancellable = viewModel.$viewState.sink { stateUpdates.append($0) }

        await viewModel.perform(action: .joinQueue)
        cancellable.cancel()

        XCTAssertEqual(stateUpdates, [.notJoinedQueue, .joiningQueue, .joinedQueue(.notDetermined)])
    }

    @MainActor
    func testWhenJoinQueueIsCalledWithNotificationsAllowed_ThenViewStateIsUpdatedToJoinedQueueWithNotificationsAllowed() async {

        let request = MockWaitlistRequest.returning(.success(.init(token: mockToken, timestamp: timestamp)))
        let storage = MockWaitlistStorage()
        var notificationService = MockNotificationService()
        notificationService.authorizationStatus = .authorized
        let viewModel = WaitlistViewModel(request, storage, notificationService)

        var stateUpdates: [WaitlistViewModel.ViewState] = []
        let cancellable = viewModel.$viewState.sink { stateUpdates.append($0) }

        await viewModel.perform(action: .joinQueue)
        cancellable.cancel()

        XCTAssertEqual(stateUpdates, [.notJoinedQueue, .joiningQueue, .joinedQueue(.notificationAllowed)])
    }

    @MainActor
    func testWhenJoinQueueIsCalledWithNotificationsDisabled_ThenViewStateIsUpdatedToJoinedQueueWithNotificationsDisabled() async {

        let request = MockWaitlistRequest.returning(.success(.init(token: mockToken, timestamp: timestamp)))
        let storage = MockWaitlistStorage()
        var notificationService = MockNotificationService()
        notificationService.authorizationStatus = .denied
        let viewModel = WaitlistViewModel(request, storage, notificationService)

        var stateUpdates: [WaitlistViewModel.ViewState] = []
        let cancellable = viewModel.$viewState.sink { stateUpdates.append($0) }

        await viewModel.perform(action: .joinQueue)
        cancellable.cancel()

        XCTAssertEqual(stateUpdates, [.notJoinedQueue, .joiningQueue, .joinedQueue(.notificationsDisabled)])
    }

    @MainActor
    func testWhenJoinQueueIsCalledAndRequestFails_ThenViewStateIsUpdatedToNotJoinedQueue() async {

        let request = MockWaitlistRequest.failure()
        let storage = MockWaitlistStorage()
        var notificationService = MockNotificationService()
        notificationService.authorizationStatus = .denied
        let viewModel = WaitlistViewModel(request, storage, notificationService)

        var stateUpdates: [WaitlistViewModel.ViewState] = []
        let cancellable = viewModel.$viewState.sink { stateUpdates.append($0) }

        await viewModel.perform(action: .joinQueue)
        cancellable.cancel()

        XCTAssertEqual(stateUpdates, [.notJoinedQueue, .joiningQueue, .notJoinedQueue])
    }

    // MARK: - Request Notification Permission

    @MainActor
    func testWhenRequestNotificationPermissionIsCalledAndPermissionInNotDetermined_ThenDelegateIsCalled() async {

        let request = MockWaitlistRequest.returning(.success(.init(token: mockToken, timestamp: timestamp)))
        let storage = MockWaitlistStorage()
        var notificationService = MockNotificationService()
        notificationService.authorizationStatus = .notDetermined
        notificationService.isAuthorized = true

        let viewModel = WaitlistViewModel(request, storage, notificationService)
        let delegate = MockWaitlistViewModelDelegate()
        viewModel.delegate = delegate

        await viewModel.perform(action: .joinQueue)
        await viewModel.perform(action: .requestNotificationPermission)

        XCTAssertTrue(delegate.didAskToReceiveJoinedNotificationCalled)
        XCTAssertEqual(viewModel.viewState, .joinedQueue(.notificationAllowed))
    }

    @MainActor
    func testWhenUserRejectsPreliminaryNotificationPrompt_ThenViewStateDoesNotChange() async {

        let request = MockWaitlistRequest.returning(.success(.init(token: mockToken, timestamp: timestamp)))
        let storage = MockWaitlistStorage()
        var notificationService = MockNotificationService()
        notificationService.authorizationStatus = .notDetermined

        let viewModel = WaitlistViewModel(request, storage, notificationService)
        let delegate = MockWaitlistViewModelDelegate()
        viewModel.delegate = delegate
        delegate.didAskToReceiveJoinedNotificationReturnValue = false

        await viewModel.perform(action: .joinQueue)
        await viewModel.perform(action: .requestNotificationPermission)

        XCTAssertTrue(delegate.didAskToReceiveJoinedNotificationCalled)
        XCTAssertEqual(viewModel.viewState, .joinedQueue(.notDetermined))
    }

    @MainActor
    func testWhenUserRejectsSystemNotificationPrompt_ThenViewStateIsNotificationsDisabled() async {

        let request = MockWaitlistRequest.returning(.success(.init(token: mockToken, timestamp: timestamp)))
        let storage = MockWaitlistStorage()
        var notificationService = MockNotificationService()
        notificationService.authorizationStatus = .notDetermined
        notificationService.isAuthorized = false

        let viewModel = WaitlistViewModel(request, storage, notificationService)
        let delegate = MockWaitlistViewModelDelegate()
        viewModel.delegate = delegate
        delegate.didAskToReceiveJoinedNotificationReturnValue = true

        await viewModel.perform(action: .joinQueue)
        await viewModel.perform(action: .requestNotificationPermission)

        XCTAssertTrue(delegate.didAskToReceiveJoinedNotificationCalled)
        XCTAssertEqual(viewModel.viewState, .joinedQueue(.notificationsDisabled))
    }

    @MainActor
    func testWhenUserAcceptsSystemNotificationPrompt_ThenViewStateIsNotificationAllowed() async {

        let request = MockWaitlistRequest.returning(.success(.init(token: mockToken, timestamp: timestamp)))
        let storage = MockWaitlistStorage()
        var notificationService = MockNotificationService()
        notificationService.authorizationStatus = .notDetermined
        notificationService.isAuthorized = true

        let viewModel = WaitlistViewModel(request, storage, notificationService)
        let delegate = MockWaitlistViewModelDelegate()
        viewModel.delegate = delegate
        delegate.didAskToReceiveJoinedNotificationReturnValue = true

        await viewModel.perform(action: .joinQueue)
        await viewModel.perform(action: .requestNotificationPermission)

        XCTAssertTrue(delegate.didAskToReceiveJoinedNotificationCalled)
        XCTAssertEqual(viewModel.viewState, .joinedQueue(.notificationAllowed))
    }

    // MARK: - Share Sheet

    @MainActor
    func testWhenOpenShareSheetActionIsPerformed_ThenShowShareSheetIsTrue() async {
        let inviteCode = "INVITECODE"
        let request = MockWaitlistRequest.returning(.success(.init(token: mockToken, timestamp: timestamp)))
        let storage = MockWaitlistStorage()
        storage.store(inviteCode: inviteCode)

        let viewModel = WaitlistViewModel(request, storage, nil)

        let delegate = MockWaitlistViewModelDelegate()
        viewModel.delegate = delegate

        await viewModel.perform(action: .openShareSheet(.zero))

        XCTAssertTrue(delegate.didOpenDownloadURLShareSheetCalled)
    }
}

extension WaitlistViewModel {
    convenience init(_ waitlistRequest: MockWaitlistRequest, _ waitlistStorage: MockWaitlistStorage, _ notificationService: MockNotificationService? = nil) {
        self.init(
            waitlistRequest: waitlistRequest,
            waitlistStorage: waitlistStorage,
            notificationService: notificationService,
            downloadURL: URL(string: "https://duckduckgo.com")!
        )
    }
}
