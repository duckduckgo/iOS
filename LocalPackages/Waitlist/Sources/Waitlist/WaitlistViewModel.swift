//
//  WaitlistViewModel.swift
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

import UIKit
import SwiftUI
import Combine

// sourcery: AutoMockable
public protocol WaitlistViewModelDelegate: AnyObject {
    func waitlistViewModelDidAskToReceiveJoinedNotification(_ viewModel: WaitlistViewModel) async -> Bool
    func waitlistViewModelDidJoinQueueWithNotificationsAllowed(_ viewModel: WaitlistViewModel)
    func waitlistViewModelDidOpenInviteCodeShareSheet(_ viewModel: WaitlistViewModel, inviteCode: String, senderFrame: CGRect)
    func waitlistViewModelDidOpenDownloadURLShareSheet(_ viewModel: WaitlistViewModel, senderFrame: CGRect)

    func waitlistViewModel(_ viewModel: WaitlistViewModel, didTriggerCustomAction action: WaitlistViewModel.ViewCustomAction)
}

@MainActor
public final class WaitlistViewModel: ObservableObject {

    public enum ViewState: Equatable {
        case notJoinedQueue
        case joiningQueue
        case joinedQueue(NotificationPermissionState)
        case invited(inviteCode: String)
        case waitlistRemoved
    }

    public enum ViewAction: Equatable {
        case joinQueue
        case requestNotificationPermission
        case openNotificationSettings
        case openShareSheet(CGRect)
        case copyDownloadURLToPasteboard
        case copyInviteCodeToPasteboard
        case custom(ViewCustomAction)
    }

    public struct ViewCustomAction: Equatable {
        public let identifier: String

        public init(identifier: String) {
            self.identifier = identifier
        }
    }

    public enum NotificationPermissionState {
        case notDetermined
        case notificationAllowed
        case notificationsDisabled
    }

    @Published public private(set) var viewState: ViewState

    public weak var delegate: WaitlistViewModelDelegate?

    public init(waitlistRequest: WaitlistRequest, waitlistStorage: WaitlistStorage, notificationService: NotificationService?, downloadURL: URL) {
        self.waitlistRequest = waitlistRequest
        self.waitlistStorage = waitlistStorage
        self.notificationService = notificationService
        self.downloadURL = downloadURL

        guard notificationService != nil else {
            viewState = .waitlistRemoved
            return
        }

        if waitlistStorage.getWaitlistTimestamp() != nil, waitlistStorage.getWaitlistInviteCode() == nil {
             viewState = .joinedQueue(.notDetermined)

             Task {
                 await checkNotificationPermissions()
             }
         } else if let inviteCode = waitlistStorage.getWaitlistInviteCode() {
             viewState = .invited(inviteCode: inviteCode)
         } else {
             viewState = .notJoinedQueue
         }
    }

    public func updateViewState() async {
        guard viewState != .waitlistRemoved else {
            return
        }
        if waitlistStorage.getWaitlistTimestamp() != nil, waitlistStorage.getWaitlistInviteCode() == nil {
            await checkNotificationPermissions()
        } else if let inviteCode = waitlistStorage.getWaitlistInviteCode() {
            self.viewState = .invited(inviteCode: inviteCode)
        } else {
            self.viewState = .notJoinedQueue
        }
    }

    public func perform(action: ViewAction) async {
        switch action {
        case .joinQueue: await joinQueue()
        case .requestNotificationPermission: await promptForNotifications()
        case .openNotificationSettings: openNotificationSettings()
        case .openShareSheet(let frame): openShareSheet(senderFrame: frame)
        case .copyDownloadURLToPasteboard: copyDownloadUrlToClipboard()
        case .copyInviteCodeToPasteboard: copyInviteCodeToClipboard()
        case .custom(let action): delegate?.waitlistViewModel(self, didTriggerCustomAction: action)
        }
    }

    // MARK: - Private

    private func checkNotificationPermissions() async {
        switch await notificationService?.authorizationStatus() {
        case .notDetermined:
            viewState = .joinedQueue(.notDetermined)
        case .denied:
            viewState = .joinedQueue(.notificationsDisabled)
        default:
            viewState = .joinedQueue(.notificationAllowed)
            delegate?.waitlistViewModelDidJoinQueueWithNotificationsAllowed(self)
        }
    }

    private func joinQueue() async {
        self.viewState = .joiningQueue

        let waitlistJoinResult = await waitlistRequest.joinWaitlist()

        switch waitlistJoinResult {
        case .success(let joinResponse):
            waitlistStorage.store(waitlistToken: joinResponse.token)
            waitlistStorage.store(waitlistTimestamp: joinResponse.timestamp)
            await checkNotificationPermissions()
        case .failure:
            self.viewState = .notJoinedQueue
        }
    }

    private func promptForNotifications() async {
        let shouldEnableNotifications: Bool = await {
            if viewState == .joinedQueue(.notDetermined) {
                return await delegate?.waitlistViewModelDidAskToReceiveJoinedNotification(self) == true
            }
            return true
        }()

        guard shouldEnableNotifications else {
            return
        }

        do {
            let permissionGranted = try await notificationService?.requestAuthorization(options: [.alert]) == true

            if permissionGranted {
                self.viewState = .joinedQueue(.notificationAllowed)
                delegate?.waitlistViewModelDidJoinQueueWithNotificationsAllowed(self)
            } else {
                self.viewState = .joinedQueue(.notificationsDisabled)
            }
        } catch {
            await checkNotificationPermissions()
        }
    }

    private func openNotificationSettings() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
            UIApplication.shared.open(appSettings)
        }
    }

    private func openShareSheet(senderFrame: CGRect) {
        if viewState == .waitlistRemoved {
            self.delegate?.waitlistViewModelDidOpenDownloadURLShareSheet(self, senderFrame: senderFrame)
            return
        }

        guard let inviteCode = waitlistStorage.getWaitlistInviteCode() else {
             assertionFailure("Failed to get invite code when creating share sheet")
             return
         }

        self.delegate?.waitlistViewModelDidOpenInviteCodeShareSheet(self, inviteCode: inviteCode, senderFrame: senderFrame)
    }

    private func copyDownloadUrlToClipboard() {
        UIPasteboard.general.url = downloadURL
    }

    private func copyInviteCodeToClipboard() {
        guard let inviteCode = waitlistStorage.getWaitlistInviteCode() else {
            assertionFailure("Failed to get waitlist invite code when copying")
            return
        }

        UIPasteboard.general.string = inviteCode
    }

    private let waitlistRequest: WaitlistRequest
    private let waitlistStorage: WaitlistStorage
    private let notificationService: NotificationService?
    private let downloadURL: URL
}
