//
//  UserText.swift
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

// swiftlint:disable line_length
public struct UserText {

    // Sync Errors
    static let syncLimitExceededTitle = NSLocalizedString("prefrences.sync.limit-exceeded-title", value: "Sync Paused", comment: "Title for sync limits exceeded warning")
    static let syncErrorTitle = NSLocalizedString("alert.sync.warning.sync-error", value: "Sync Error", comment: "Title of the warning message that tells the user that there was an error with the sync feature.")
    static let bookmarksLimitExceededDescription = NSLocalizedString("prefrences.sync.bookmarks-limit-exceeded-description", value: "You've reached the maximum number of bookmarks. Please delete some to resume sync.", comment: "Description for sync bookmarks limits exceeded warning")
    static let credentialsLimitExceededDescription = NSLocalizedString("prefrences.sync.credentials-limit-exceeded-description", value: "You've reached the maximum number of passwords. Please delete some to resume sync.", comment: "Description for sync credentials limits exceeded warning")
    public static let invalidLoginCredentialErrorDescription = NSLocalizedString("prefrences.sync.invalid-login-description", value: "Sync encountered an error. Try disabling sync on this device and then reconnect using another device or your recovery code.", comment: "Description invalid credentials error when syncing.")
    static let tooManyRequestsErrorDescription = NSLocalizedString("prefrences.sync.invalid-login-description", value: "Sync & Backup is temporarily unavailable.", comment: "Description of too many requests error when syncing.")
    static let badRequestErrorDescription = NSLocalizedString("prefrences.sync.invalid-login-description", value: "Some bookmarks or passwords are formatted incorrectly or too long and were not synced.", comment: "Description of incorrectly formatted data error when syncing.")
    static let bookmarksLimitExceededAction = NSLocalizedString("prefrences.sync.bookmarks-limit-exceeded-action", value: "Manage Bookmarks", comment: "Button title for sync bookmarks limits exceeded warning to go to manage bookmarks")
    static let credentialsLimitExceededAction = NSLocalizedString("prefrences.sync.credentials-limit-exceeded-action", value: "Manage passwords…", comment: "Button title for sync credentials limits exceeded warning to go to manage passwords")
    static let syncErrorAlertTitle = NSLocalizedString("alert.sync-error-title", value: "Sync Error", comment: "Title for alert shown when sync error occurs")
    static let syncPausedAlertTitle = NSLocalizedString("alert.sync-paused-title", value: "Sync is Paused", comment: "Title for alert shown when sync paused for an error")
    static let syncInvalidLoginAlertDescription = NSLocalizedString("alert.sync-invalid-login-error-description", value: "Sync has been paused. If you want to continue syncing this device, reconnect using another device or your recovery code.", comment: "Description for alert shown when user logged off from sync")
    static let syncTooManyRequestsAlertDescription = NSLocalizedString("alert.sync-too-many-requests-error-description", value: "Sync & Backup is temporarily unavailable.", comment: "Description for alert shown when sync error occurs because of too many requests")
    static let syncBadRequestAlertDescription = NSLocalizedString("alert.sync-bad-data-error-description", value: "Some bookmarks or passwords are formatted incorrectly or too long and were not synced.", comment: "Description for alert shown when sync error occurs because of bad data")
    static let syncErrorAlertAction  = NSLocalizedString("alert.sync-error-action", value: "Sync Settings", comment: "Sync error alert action button title, takes the user to the sync settings page.")
    static let syncBookmarkPausedAlertTitle = NSLocalizedString("alert.sync-bookmarks-paused-title", value: "Bookmark Sync is Paused", comment: "Title for alert shown when sync bookmarks paused for too many items")
    static let syncBookmarkPausedAlertDescription = NSLocalizedString("alert.sync-bookmarks-paused-description", value: "You've reached the maximum number of bookmarks. Please delete some bookmarks to resume sync.", comment: "Description for alert shown when sync bookmarks paused for too many items")
    static let syncCredentialsPausedAlertTitle = NSLocalizedString("alert.sync-credentials-paused-title", value: "Password Sync is Paused", comment: "Title for alert shown when sync credentials paused for too many items")
    static let syncCredentialsPausedAlertDescription = NSLocalizedString("alert.sync-credentials-paused-description", value: "You've reached the maximum number of passwords. Please delete some passwords to resume sync.", comment: "Description for alert shown when sync credentials paused for too many items")
    static let syncPausedTitle = NSLocalizedString("alert.sync.warning.sync-paused", value: "Sync & Backup is Paused", comment: "Title of the warning message")
}
// swiftlint:enable line_length
