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
import Core

protocol WaitlistViewModelDelegate: AnyObject {
    func waitlistViewModelDidOpenInviteCodeShareSheet(_ viewModel: WaitlistViewModel, inviteCode: String, senderFrame: CGRect)
    func waitlistViewModelDidOpenDownloadURLShareSheet(_ viewModel: WaitlistViewModel, senderFrame: CGRect)
}

@MainActor
final class WaitlistViewModel: ObservableObject {

    enum ViewState: Equatable {
        case notJoinedQueue
        case joiningQueue
        case joinedQueue(NotificationPermissionState)
        case invited(inviteCode: String)
        case waitlistRemoved
    }

    enum ViewAction: Equatable {
        case joinQueue
        case requestNotificationPermission
        case openNotificationSettings
        case openShareSheet(CGRect)
        case copyDownloadURLToPasteboard
        case copyInviteCodeToPasteboard
    }

    enum NotificationPermissionState {
        case notDetermined
        case notificationAllowed
        case notificationsDisabled
    }

    @Published var viewState: ViewState

    weak var delegate: WaitlistViewModelDelegate?

    convenience init(feature: WaitlistFeature) {
        let notificationService: NotificationService? = feature.isWaitlistRemoved ? nil : UNUserNotificationCenter.current()
        self.init(
            waitlistRequest: ProductWaitlistRequest(feature: feature),
            waitlistStorage: WaitlistKeychainStore(feature: feature),
            notificationService: notificationService
        )
    }

    init(waitlistRequest: WaitlistRequest, waitlistStorage: WaitlistStorage, notificationService: NotificationService?) {
        self.waitlistRequest = waitlistRequest
        self.waitlistStorage = waitlistStorage
        self.notificationService = notificationService

        guard notificationService != nil else {
            viewState = .waitlistRemoved
            return
        }

        if waitlistStorage.getWaitlistTimestamp() != nil, waitlistStorage.getWaitlistInviteCode() == nil {
             viewState = .joinedQueue(.notificationAllowed)

             Task {
                 await checkNotificationPermissions()
             }
         } else if let inviteCode = waitlistStorage.getWaitlistInviteCode() {
             viewState = .invited(inviteCode: inviteCode)
         } else {
             viewState = .notJoinedQueue
         }
    }

    func updateViewState() {
        if waitlistStorage.getWaitlistTimestamp() != nil, waitlistStorage.getWaitlistInviteCode() == nil {
            self.viewState = .joinedQueue(.notificationAllowed)

            Task {
                await checkNotificationPermissions()
            }
        } else if let inviteCode = waitlistStorage.getWaitlistInviteCode() {
            self.viewState = .invited(inviteCode: inviteCode)
        } else {
            self.viewState = .notJoinedQueue
        }
    }

    func perform(action: ViewAction) async {
        switch action {
        case .joinQueue: await joinQueue()
        case .requestNotificationPermission: await promptForNotifications()
        case .openNotificationSettings: openNotificationSettings()
        case .openShareSheet(let frame): openShareSheet(senderFrame: frame)
        case .copyDownloadURLToPasteboard: copyDownloadUrlToClipboard()
        case .copyInviteCodeToPasteboard: copyInviteCodeToClipboard()
        }
    }

    // MARK: - Private

    private func checkNotificationPermissions() async {
        let notificationSettings = await UNUserNotificationCenter.current().notificationSettings()

        switch notificationSettings.authorizationStatus {
        case .notDetermined:
            viewState = .joinedQueue(.notDetermined)
        case .denied:
            viewState = .joinedQueue(.notificationsDisabled)
        default:
            viewState = .joinedQueue(.notificationAllowed)
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
        do {
            let permissionGranted = try await notificationService?.requestAuthorization(options: [.alert]) == true

            if permissionGranted {
                self.viewState = .joinedQueue(.notificationAllowed)
                WindowsBrowserWaitlist.shared.scheduleBackgroundRefreshTask()
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
        UIPasteboard.general.url = AppUrls().macBrowserDownloadURL
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
}
