//
//  MaliciousSiteProtectionMocks.swift
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

import Foundation
import Combine
import MaliciousSiteProtection
import BackgroundTasks
import Testing
import enum UIKit.UIBackgroundRefreshStatus
@testable import DuckDuckGo

final class MockMaliciousSiteProtectionUpdateManager: MaliciousSiteUpdateManaging {
    private(set) var updateDatasets: [MaliciousSiteProtection.DataManager.StoredDataType.Kind: Bool] = [
        .hashPrefixSet: false,
        .filterSet: false
    ]

    var lastHashPrefixSetUpdateDate: Date = .distantPast
    var lastFilterSetUpdateDate: Date = .distantPast

    func startPeriodicUpdates() -> Task<Void, any Error> {
        Task { }
    }
    
    func updateData(datasetType: MaliciousSiteProtection.DataManager.StoredDataType.Kind) -> Task<Void, any Error> {
        updateDatasets[datasetType] = true
        return Task { }
    }
}

final class MockMaliciousSiteProtectionPreferencesManager: MaliciousSiteProtectionPreferencesManaging {
    var isMaliciousSiteProtectionOn: Bool = false {
        didSet {
            subject.send(isMaliciousSiteProtectionOn)
        }
    }

    private lazy var subject = CurrentValueSubject<Bool, Never>(isMaliciousSiteProtectionOn)

    var isMaliciousSiteProtectionOnPublisher: AnyPublisher<Bool, Never> {
        subject.eraseToAnyPublisher()
    }
}

final class MockMaliciousSiteProtectionFeatureFlags: MaliciousSiteProtectionFeatureFlagger, MaliciousSiteProtectionFeatureFlagsSettingsProvider {
    var shouldDetectMaliciousThreatForDomainResult = false

    var isMaliciousSiteProtectionEnabled = false

    var hashPrefixUpdateFrequency: Int = 10

    var filterSetUpdateFrequency: Int = 20

    func shouldDetectMaliciousThreat(forDomain domain: String?) -> Bool {
        shouldDetectMaliciousThreatForDomainResult
    }
}

final class MockBackgroundScheduler: BGTaskScheduling {
    private(set) var capturedRegisteredTaskIdentifiers: [String] = []

    private(set) var didCallSubmitTaskRequest = false
    private(set) var capturedSubmittedTaskRequest: BGTaskRequest?
    private(set) var submittedTaskRequests: [BGTaskRequest] = []

    private(set) var didCallCancelTaskRequestWithIdentifier = false
    private(set) var capturedCanceledTaskRequestIdentifier: String?

    var scheduleBackgroundTaskConfirmation: Confirmation?

    var launchHandlers: [String: ((BGTaskInterface) -> Void)?] = [:]

    func register(forTaskWithIdentifier identifier: String, launchHandler: @escaping (BGTaskInterface) -> Void) -> Bool {
        capturedRegisteredTaskIdentifiers.append(identifier)
        self.launchHandlers[identifier] = launchHandler
        return true
    }
    
    func submit(_ taskRequest: BGTaskRequest) throws {
        didCallSubmitTaskRequest = true
        capturedSubmittedTaskRequest = taskRequest
        submittedTaskRequests.append(taskRequest)
        scheduleBackgroundTaskConfirmation?()
    }
    
    func cancel(taskRequestWithIdentifier identifier: String) {
        didCallCancelTaskRequestWithIdentifier = true
        capturedCanceledTaskRequestIdentifier = identifier
    }
    
    func pendingTaskRequests() async -> [BGTaskRequest] {
        []
    }

    func getPendingTaskRequests(completionHandler: @escaping ([BGTaskRequest]) -> Void) {
        completionHandler([])
    }
}

final class MockBGTask: BGTaskInterface {
    private(set) var didCallSetTaskCompleted = false
    private(set) var capturedTaskCompletedSuccess: Bool?

    let identifier: String
    var expirationHandler: (() -> Void)?

    init(identifier: String) {
        self.identifier = identifier
    }

    func setTaskCompleted(success: Bool) {
        didCallSetTaskCompleted = true
        capturedTaskCompletedSuccess = success
    }
}

final class MockMaliciousSiteProtectionDataFetcher: MaliciousSiteProtectionDatasetsFetching {
    private(set) var didCallStartFetching = false
    private(set) var didCallRegisterBackgroundRefreshTaskHandler = false

    func startFetching() {
        didCallStartFetching = true
    }
    
    func registerBackgroundRefreshTaskHandler() {
        didCallRegisterBackgroundRefreshTaskHandler = true
    }
}

final class MockBackgroundRefreshApplication: BackgroundRefreshCapable {
    var backgroundRefreshStatus: UIBackgroundRefreshStatus = .available
}

final class MockMaliciousSiteFileStore: MaliciousSiteProtection.FileStoring {
    private var storage: [String: Data] = [:]
    var didWriteToDisk: Bool = false
    var didReadFromDisk: Bool = false

    func write(data: Data, to filename: String) throws {
        didWriteToDisk = true
        storage[filename] = data
    }

    func read(from filename: String) -> Data? {
        didReadFromDisk = true
        return storage[filename]
    }
}

final class MockMaliciousSiteDetector: MaliciousSiteProtection.MaliciousSiteDetecting {

    var isMalicious: (URL) -> MaliciousSiteProtection.ThreatKind? = { url in
        if url.absoluteString.contains("phishing") {
            .phishing
        } else if url.absoluteString.contains("malware") {
            .malware
        } else {
            nil
        }
    }

    init(isMalicious: ((URL) -> MaliciousSiteProtection.ThreatKind?)? = nil) {
        if let isMalicious {
            self.isMalicious = isMalicious
        }
    }

    func evaluate(_ url: URL) async -> MaliciousSiteProtection.ThreatKind? {
        return isMalicious(url)
    }

}

final class MockMaliciousSiteProtectionPreferencesStore: MaliciousSiteProtectionPreferencesStorage {
    var isEnabled: Bool = true
}
