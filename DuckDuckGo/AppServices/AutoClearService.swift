//
//  AutoClearService.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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

final class AutoClearService {

    private let autoClear: AutoClear
    private let overlayWindowManager: OverlayWindowManager
    private let application: UIApplication

    private var autoClearTask: Task<Void, Never>?

    init(worker: AutoClearWorker,
         overlayWindowManager: OverlayWindowManager,
         application: UIApplication = UIApplication.shared) {
        autoClear = AutoClear(worker: worker)
        self.overlayWindowManager = overlayWindowManager
        self.application = application
    }

    @MainActor
    func waitForDataCleared() async {
        guard let autoClearTask else {
            assertionFailure("AutoClear task must be started before registering. Call register after onLaunching or onResuming.")
            return
        }
        await autoClearTask.value
        overlayWindowManager.removeNonAuthenticationOverlay()
    }

    func onLaunching() {
        autoClearTask = Task {
            await autoClear.clearDataIfEnabled(applicationState: .init(with: application.applicationState))
        }
    }

    func onResuming() {
        autoClearTask = Task {
            await autoClear.clearDataIfEnabledAndTimeExpired(applicationState: .active)
        }
    }

    func onBackground() {
        if autoClear.isClearingEnabled {
            overlayWindowManager.displayBlankSnapshotWindow()
        }
        autoClear.startClearingTimer()
    }

    var isClearingEnabled: Bool {
        autoClear.isClearingEnabled
    }

}
