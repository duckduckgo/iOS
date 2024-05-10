//
//  SyncPausedStateManaging.swift
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
import Combine

/// The SyncPausedStateManaging protocol manages sync error states. It provides properties and methods to detect and handle changes in the synchronization status, aiding in error user notification.
public protocol SyncPausedStateManaging: ObservableObject {
    var isSyncPaused: Bool { get }
    var isSyncBookmarksPaused: Bool { get }
    var isSyncCredentialsPaused: Bool { get }
    var syncPausedChangedPublisher: AnyPublisher<Void, Never> { get }
//    var syncPausedMessageData: SyncPausedMessageData? { get }
//    var syncBookmarksPausedMessageData: SyncPausedMessageData? { get }
//    var syncCredentialsPausedMessageData: SyncPausedMessageData? { get }
    var currentSyncAllPausedError: String? { get }
    var currentSyncBookmarksPausedError: String? { get }
    var currentSyncCredentialsPausedError: String? { get }


    func syncDidTurnOff()
}
