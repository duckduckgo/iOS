//
//  MockWaitlistViewModelDelegate.swift
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

import Foundation
import Waitlist

public class MockWaitlistViewModelDelegate: WaitlistViewModelDelegate {

    public init() {}

    public private(set) var didOpenInviteCodeShareSheetCalled = false
    public private(set) var didOpenDownloadURLShareSheetCalled = false
    public private(set) var didAskToReceiveJoinedNotificationCalled = false
    public private(set) var didJoinQueueWithNotificationsAllowedCalled = false
    public private(set) var didTriggerCustomActionCalled = false

    public var didAskToReceiveJoinedNotificationReturnValue = true

    public func waitlistViewModelDidOpenInviteCodeShareSheet(_ viewModel: WaitlistViewModel, inviteCode: String, senderFrame: CGRect) {
        didOpenInviteCodeShareSheetCalled = true
    }

    public func waitlistViewModelDidOpenDownloadURLShareSheet(_ viewModel: WaitlistViewModel, senderFrame: CGRect) {
        didOpenDownloadURLShareSheetCalled = true
    }

    public func waitlistViewModelDidAskToReceiveJoinedNotification(_ viewModel: WaitlistViewModel) async -> Bool {
        didAskToReceiveJoinedNotificationCalled = true
        return didAskToReceiveJoinedNotificationReturnValue
    }

    public func waitlistViewModelDidJoinQueueWithNotificationsAllowed(_ viewModel: WaitlistViewModel) {
        didJoinQueueWithNotificationsAllowedCalled = true
    }

    public func waitlistViewModel(_ viewModel: WaitlistViewModel, didTriggerCustomAction action: WaitlistViewModel.ViewCustomAction) {
        didTriggerCustomActionCalled = true
    }

}
