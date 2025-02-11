//
//  AutoClear.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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
import UIKit
import Core

protocol AutoClearWorker {

    func clearNavigationStack()
    func forgetData() async
    func forgetData(applicationState: DataStoreWarmup.ApplicationState) async
    func forgetTabs()

    func willStartClearing(_: AutoClear)
    func autoClearDidFinishClearing(_: AutoClear, isLaunching: Bool)
}

class AutoClear {

    private let worker: AutoClearWorker
    private var timestamp: TimeInterval?

    private let appSettings: AppSettings

    var isClearingEnabled: Bool {
        return AutoClearSettingsModel(settings: appSettings) != nil
    }

    init(worker: AutoClearWorker, appSettings: AppSettings = AppDependencyProvider.shared.appSettings) {
        self.worker = worker
        self.appSettings = appSettings
    }

    @MainActor
    func clearDataIfEnabled(launching: Bool = false, applicationState: DataStoreWarmup.ApplicationState = .unknown) async {
        guard let settings = AutoClearSettingsModel(settings: appSettings) else { return }

        worker.willStartClearing(self)

        if settings.action.contains(.clearTabs) {
            worker.forgetTabs()
        }

        if settings.action.contains(.clearData) {
            await worker.forgetData(applicationState: applicationState)
        }

        worker.autoClearDidFinishClearing(self, isLaunching: launching)
    }

    /// Note: function is parametrised because of tests.
    func startClearingTimer(_ time: TimeInterval = Date().timeIntervalSince1970) {
        timestamp = time
    }

    private func shouldClearData(elapsedTime: TimeInterval) -> Bool {
        guard let settings = AutoClearSettingsModel(settings: appSettings) else { return false }

        if ProcessInfo.processInfo.arguments.contains("autoclear-ui-test") {
            return elapsedTime > 5
        }

        switch settings.timing {
        case .termination:
            return false
        case .delay5min:
            return elapsedTime > 5 * 60
        case .delay15min:
            return elapsedTime > 15 * 60
        case .delay30min:
            return elapsedTime > 30 * 60
        case .delay60min:
            return elapsedTime > 60 * 60
        }
    }

    @MainActor
    func clearDataIfEnabledAndTimeExpired(baseTimeInterval: TimeInterval = Date().timeIntervalSince1970,
                                          applicationState: DataStoreWarmup.ApplicationState) async {
        guard isClearingEnabled,
            let timestamp = timestamp,
            shouldClearData(elapsedTime: baseTimeInterval - timestamp) else { return }

        self.timestamp = nil
        worker.clearNavigationStack()
        await clearDataIfEnabled(applicationState: applicationState)
    }
}

extension DataStoreWarmup.ApplicationState {

    init(with state: UIApplication.State) {
        switch state {
        case .inactive:
            self = .inactive
        case .active:
            self = .active
        case .background:
            self = .background
        @unknown default:
            self = .unknown
        }
    }
}
