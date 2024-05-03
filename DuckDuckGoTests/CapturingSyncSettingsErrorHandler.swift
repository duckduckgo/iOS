//
//  CapturingSyncSettingsErrorHandler.swift
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
import Combine

class CapturingSyncSettingsErrorHandler: SyncSettingsErrorHandler {
    var isSyncPausedChangedPublisher = PassthroughSubject<Void, Never>()
    var syncDidTurnOffCalled = false

    var isSyncPaused: Bool = false

    var isSyncBookmarksPaused: Bool = false

    var isSyncCredentialsPaused: Bool = false

    var syncPausedChangedPublisher: AnyPublisher<Void, Never> {
        isSyncPausedChangedPublisher.eraseToAnyPublisher()
    }

    var syncPausedMetadata: SyncPausedErrorMetadata? = SyncPausedErrorMetadata(
        syncPausedTitle: "syncPausedTitle",
        syncPausedMessage: "syncPausedMessage",
        syncPausedButtonTitle: "syncPausedButtonTitle")

    var syncBookmarksPausedMetadata: SyncPausedErrorMetadata = SyncPausedErrorMetadata(
        syncPausedTitle: "syncPausedTitle bookmarks",
        syncPausedMessage: "syncPausedMessage bookmarks",
        syncPausedButtonTitle: "syncPausedButtonTitle bookmarks")

    var syncCredentialsPausedMetadata: SyncPausedErrorMetadata = SyncPausedErrorMetadata(
        syncPausedTitle: "syncPausedTitle credentials ",
        syncPausedMessage: "syncPausedMessage credentials",
        syncPausedButtonTitle: "syncPausedButtonTitle credentials")

    func syncDidTurnOff() {
        syncDidTurnOffCalled = true
    }

}
