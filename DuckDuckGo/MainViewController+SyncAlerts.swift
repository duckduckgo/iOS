//
//  MainViewController+SyncAlerts.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import Core

extension MainViewController: SyncAlertsPresenting {
    func showSyncPausedAlert(for error: AsyncErrorType) {
        switch error {
        case .bookmarksCountLimitExceeded, .bookmarksRequestSizeLimitExceeded:
            showSyncPausedAlert(
                title: UserText.syncBookmarkPausedAlertTitle,
                informative: UserText.syncBookmarkPausedAlertDescription)
        case .credentialsCountLimitExceeded, .credentialsRequestSizeLimitExceeded:
            showSyncPausedAlert(
                title: UserText.syncCredentialsPausedAlertTitle,
                informative: UserText.syncCredentialsPausedAlertDescription)
        case .invalidLoginCredentials:
            showSyncPausedAlert(
                title: UserText.syncPausedAlertTitle,
                informative: UserText.syncInvalidLoginAlertDescription)
        case .tooManyRequests:
            showSyncPausedAlert(
                title: UserText.syncErrorAlertTitle,
                informative: UserText.syncTooManyRequestsAlertDescription)
        case .badRequestBookmarks:
            showSyncPausedAlert(
                title: UserText.syncBookmarkPausedAlertTitle,
                informative: UserText.syncBadBookmarksRequestAlertDescription)
        case .badRequestCredentials:
            showSyncPausedAlert(
                title: UserText.syncBookmarkPausedAlertTitle,
                informative: UserText.syncBadCredentialsRequestAlertDescription)
        }
    }
    
    private func showSyncPausedAlert(title: String, informative: String) {
        Task {
            await MainActor.run {
                if self.presentedViewController is SyncSettingsViewController {
                    return
                }
                self.presentedViewController?.dismiss(animated: true)
                let alert = UIAlertController(title: title,
                                              message: informative,
                                              preferredStyle: .alert)
                let learnMoreAction = UIAlertAction(title: UserText.syncPausedAlertLearnMoreButton, style: .default) { _ in
                    self.segueToSettingsSync()
                }
                let okAction = UIAlertAction(title: UserText.syncPausedAlertOkButton, style: .cancel)
                alert.addAction(learnMoreAction)
                alert.addAction(okAction)
                self.present(alert, animated: true)
            }
        }
    }

}
