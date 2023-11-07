//
//  NotificationsAuthorizationController.swift
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

import UserNotifications
import UIKit
import Combine

protocol NotificationsAuthorizationControlling {
    var authorizationStatus: UNAuthorizationStatus { get async }
    var delegate: NotificationsPermissionsControllerDelegate? { get set }

    func requestAlertAuthorization()
}

protocol NotificationsPermissionsControllerDelegate: AnyObject {
    func authorizationStateDidChange(toStatus status: UNAuthorizationStatus)
}

final class NotificationsAuthorizationController: NotificationsAuthorizationControlling {

    weak var delegate: NotificationsPermissionsControllerDelegate?
    var notificationCancellable: AnyCancellable?

    var authorizationStatus: UNAuthorizationStatus {
        get async {
            let settings: UNNotificationSettings = await UNUserNotificationCenter.current().notificationSettings()
            return settings.authorizationStatus
        }
    }

    init() {
        // To handle navigating back from iOS Settings after changing the authorization
        notificationCancellable = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { _ in
                Task { [weak self] in
                    await self?.updateDelegateWithNewState()
                }
            }
    }

    func requestAlertAuthorization() {
        Task {
            switch await authorizationStatus {
            case .notDetermined:
                await requestAuthorization(options: .alert)
            case .denied:
                _ = await UIApplication.shared.openAppNotificationSettings()
            case .authorized, .provisional, .ephemeral:
                break
            @unknown default:
                break
            }
        }
    }

    private func requestAuthorization(options: UNAuthorizationOptions) async {
        do {
            let authorized = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
            if authorized {
                await updateDelegateWithNewState()
            }
        } catch { }
    }

    private func updateDelegateWithNewState() async {
        let newState = await authorizationStatus
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.authorizationStateDidChange(toStatus: newState)
        }
    }
}
