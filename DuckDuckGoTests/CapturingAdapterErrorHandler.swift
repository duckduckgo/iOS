//
//  CapturingAdapterErrorHandler.swift
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

class CapturingAdapterErrorHandler: SyncErrorHandling {
    var handleBookmarkErrorCalled = false
    var syncCredentialsSuccededCalled = false
    var handleCredentialErrorCalled = false
    var syncBookmarksSuccededCalled = false
    var handleSettingsErrorCalled = false
    var capturedError: Error?

    func handleSettingsError(_ error: Error) {
        handleSettingsErrorCalled = true
        capturedError = error
    }

    func handleBookmarkError(_ error: Error) {
        handleBookmarkErrorCalled = true
        capturedError = error
    }

    func handleCredentialError(_ error: Error) {
        handleCredentialErrorCalled = true
        capturedError = error
    }

    func syncBookmarksSucceded() {
        syncBookmarksSuccededCalled = true
    }

    func syncCredentialsSucceded() {
        syncCredentialsSuccededCalled = true
    }
}
