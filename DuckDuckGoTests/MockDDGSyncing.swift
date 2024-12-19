//
//  MockDDGSyncing.swift
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
@testable import BrowserServicesKit
@testable import DDGSync

final class MockDDGSyncing: DDGSyncing {

    var registeredDevices = [
        RegisteredDevice(id: "1", name: "Device 1", type: "desktop"),
        RegisteredDevice(id: "2", name: "Device 2", type: "mobile"),
        RegisteredDevice(id: "3", name: "Device 1", type: "desktop")]
    var disconnectCalled = false

    var dataProvidersSource: DataProvidersSource?

    @Published var featureFlags: SyncFeatureFlags = .all

    var featureFlagsPublisher: AnyPublisher<SyncFeatureFlags, Never> {
        $featureFlags.eraseToAnyPublisher()
    }

    @Published var authState: SyncAuthState = .inactive

    var authStatePublisher: AnyPublisher<SyncAuthState, Never> {
        $authState.eraseToAnyPublisher()
    }

    var account: SyncAccount?

    var scheduler: Scheduling

//    var syncDailyStats = SyncDailyStats(store: MockKeyValueStore())
    var syncDailyStats = SyncDailyStats()

    @Published var isSyncInProgress: Bool

    var isSyncInProgressPublisher: AnyPublisher<Bool, Never> {
        $isSyncInProgress.eraseToAnyPublisher()
    }

    init(dataProvidersSource: DataProvidersSource? = nil, authState: SyncAuthState, account: SyncAccount? = nil, scheduler: Scheduling = CapturingScheduler(), isSyncInProgress: Bool) {
        self.dataProvidersSource = dataProvidersSource
        self.authState = authState
        self.account = account
        self.scheduler = scheduler
        self.isSyncInProgress = isSyncInProgress
    }

    func initializeIfNeeded() {
    }

    func createAccount(deviceName: String, deviceType: String) async throws {
    }

    var stubLogin: [RegisteredDevice] = []
    lazy var spyLogin: (SyncCode.RecoveryKey, String, String) throws -> [RegisteredDevice] = { _, _, _ in
        return self.stubLogin
    }

    func login(_ recoveryKey: SyncCode.RecoveryKey, deviceName: String, deviceType: String) async throws -> [RegisteredDevice] {
        return try spyLogin(recoveryKey, deviceName, deviceType)
    }

    func remoteConnect() throws -> RemoteConnecting {
        return MockRemoteConnecting()
    }

    func transmitRecoveryKey(_ connectCode: SyncCode.ConnectCode) async throws {
    }

    func disconnect() async throws {
        disconnectCalled = true
    }

    func disconnect(deviceId: String) async throws {
    }

    func fetchDevices() async throws -> [RegisteredDevice] {
        return registeredDevices
    }

    func updateDeviceName(_ name: String) async throws -> [RegisteredDevice] {
        return []
    }

    func deleteAccount() async throws {
    }

    var serverEnvironment: ServerEnvironment = .production

    func updateServerEnvironment(_ serverEnvironment: ServerEnvironment) {
    }
}

class CapturingScheduler: Scheduling {
    var notifyDataChangedCalled = false

    func notifyDataChanged() {
        notifyDataChangedCalled = true
    }

    func notifyAppLifecycleEvent() {
    }

    func requestSyncImmediately() {
    }

    func cancelSyncAndSuspendSyncQueue() {
    }

    func resumeSyncQueue() {
    }
}

struct MockRemoteConnecting: RemoteConnecting {
    var code: String = ""

    func pollForRecoveryKey() async throws -> SyncCode.RecoveryKey? {
        return nil
    }

    func stopPolling() {
    }
}
