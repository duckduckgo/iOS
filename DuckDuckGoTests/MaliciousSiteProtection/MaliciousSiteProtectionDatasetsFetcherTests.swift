//
//  MaliciousSiteProtectionDatasetsFetcherTests.swift
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

import Testing
import Foundation
import MaliciousSiteProtection
import enum UIKit.UIBackgroundRefreshStatus
@testable import DuckDuckGo

@Suite("Malicious Site Protection - Feature Flags", .serialized)
final class MaliciousSiteProtectionDatasetsFetcherTests {
    private var sut: MaliciousSiteProtectionDatasetsFetcher!
    private var updateManagerMock: MockMaliciousSiteProtectionUpdateManager!
    private var featureFlaggerMock: MockMaliciousSiteProtectionFeatureFlags!
    private var userPreferencesManagerMock: MockMaliciousSiteProtectionPreferencesManager!
    private var backgroundSchedulerMock: MockBackgroundScheduler!
    private var timeTraveller: TimeTraveller!
    private var application: MockBackgroundRefreshApplication!

    init() {
        setupSUT()
    }

    func setupSUT(
        updateManagerMock: MockMaliciousSiteProtectionUpdateManager = .init(),
        featureFlaggerMock: MockMaliciousSiteProtectionFeatureFlags = .init(),
        userPreferencesManagerMock: MockMaliciousSiteProtectionPreferencesManager = .init(),
        dateProvider: @escaping () -> Date = Date.init,
        backgroundSchedulerMock: MockBackgroundScheduler = .init(),
        application: MockBackgroundRefreshApplication = .init()
    ) {
        self.updateManagerMock = updateManagerMock
        self.featureFlaggerMock = featureFlaggerMock
        self.userPreferencesManagerMock = userPreferencesManagerMock
        self.backgroundSchedulerMock = backgroundSchedulerMock
        self.timeTraveller = TimeTraveller()
        self.application = application

        sut = MaliciousSiteProtectionDatasetsFetcher(
            updateManager: updateManagerMock,
            featureFlagger: featureFlaggerMock,
            userPreferencesManager: userPreferencesManagerMock,
            dateProvider: timeTraveller.getDate,
            backgroundTaskScheduler: backgroundSchedulerMock,
            application: application
        )
    }

    // MARK: - Explicitely Fetch Datasets

    @Test("Fetch Datasets When Feature Is Enabled and User Turned On the Feature")
    func whenStartFetchingCalled_AndFeatureEnabled_AndPreferencesEnabled_ThenStartUpdateTask() {
        // GIVEN
        featureFlaggerMock.isMaliciousSiteProtectionEnabled = true
        userPreferencesManagerMock.isMaliciousSiteProtectionOn = true
        #expect(updateManagerMock.updateDatasets[.hashPrefixSet] == false)
        #expect(updateManagerMock.updateDatasets[.filterSet] == false)

        // WHEN
        sut.startFetching()

        // THEN
        #expect(updateManagerMock.updateDatasets[.hashPrefixSet] == true)
        #expect(updateManagerMock.updateDatasets[.filterSet] == true)
    }

    @Test("Do not Fetch Datasets When Feature is Disabled")
    func whenStartFetchingCalled_AndFeatureDisabled_ThenDoNotStartUpdateTask() {
        // GIVEN
        featureFlaggerMock.isMaliciousSiteProtectionEnabled = false
        userPreferencesManagerMock.isMaliciousSiteProtectionOn = true
        #expect(updateManagerMock.updateDatasets[.hashPrefixSet] == false)
        #expect(updateManagerMock.updateDatasets[.filterSet] == false)

        // WHEN
        sut.startFetching()

        // THEN
        #expect(updateManagerMock.updateDatasets[.hashPrefixSet] == false)
        #expect(updateManagerMock.updateDatasets[.filterSet] == false)
    }

    @Test("Do not Fetch Datasets When User Turned Off the Feature")
    func whentartFetchingCalled_AndFeatureEnabled_AndPreferencesDisabled_ThenDoNotStartUpdateTask() {
        // GIVEN
        featureFlaggerMock.isMaliciousSiteProtectionEnabled = true
        userPreferencesManagerMock.isMaliciousSiteProtectionOn = false
        #expect(updateManagerMock.updateDatasets[.hashPrefixSet] == false)
        #expect(updateManagerMock.updateDatasets[.filterSet] == false)

        // WHEN
        sut.startFetching()

        // THEN
        #expect(updateManagerMock.updateDatasets[.hashPrefixSet] == false)
        #expect(updateManagerMock.updateDatasets[.filterSet] == false)
    }

    @Test("Fetch Hash Prefix Dataset When Start Fetching Is Called And Last Update Date Is Greater Than Update Interval")
    func whenStartFetchingCalled_AndLastHashPrefixSetUpdateDateIsGreaterThanUpdateInterval_ThenFetchHashPrefixSet() {
        // GIVEN
        let timeTraveller = TimeTraveller()
        timeTraveller.advanceBy(-.minutes(6))
        updateManagerMock.lastHashPrefixSetUpdateDate = timeTraveller.getDate()
        updateManagerMock.lastFilterSetUpdateDate = timeTraveller.getDate()
        featureFlaggerMock.hashPrefixUpdateFrequency = 5 // Value expressed in minutes
        featureFlaggerMock.filterSetUpdateFrequency = 10 // Value expressed in minutes
        featureFlaggerMock.isMaliciousSiteProtectionEnabled = true
        userPreferencesManagerMock.isMaliciousSiteProtectionOn = true
        #expect(updateManagerMock.updateDatasets[.hashPrefixSet] == false)
        #expect(updateManagerMock.updateDatasets[.filterSet] == false)

        // WHEN
        sut.startFetching()

        // THEN
        #expect(updateManagerMock.updateDatasets[.hashPrefixSet] == true)
        #expect(updateManagerMock.updateDatasets[.filterSet] == false)
    }

    @Test("Fetch Filter Dataset When Start Fetching Is Called And Last Update Date Is Greater Than Update Interval")
    func whenStartFetchingCalled_AndLastFilterSetUpdateDateIsGreaterThanUpdateInterval_ThenFetchHashPrefixSet() {
        // GIVEN
        let timeTraveller = TimeTraveller()
        timeTraveller.advanceBy(-.minutes(11))
        updateManagerMock.lastHashPrefixSetUpdateDate = timeTraveller.getDate()
        updateManagerMock.lastFilterSetUpdateDate = timeTraveller.getDate()
        featureFlaggerMock.hashPrefixUpdateFrequency = 15 // Value expressed in minutes
        featureFlaggerMock.filterSetUpdateFrequency = 10 // Value expressed in minutes
        featureFlaggerMock.isMaliciousSiteProtectionEnabled = true
        userPreferencesManagerMock.isMaliciousSiteProtectionOn = true
        #expect(updateManagerMock.updateDatasets[.hashPrefixSet] == false)
        #expect(updateManagerMock.updateDatasets[.filterSet] == false)

        // WHEN
        sut.startFetching()

        // THEN
        #expect(updateManagerMock.updateDatasets[.hashPrefixSet] == false)
        #expect(updateManagerMock.updateDatasets[.filterSet] == true)
    }

    @Test("Fetch Datasets When Update Interval Becomes Grather Than Last Update Interval")
    func whenStartFetchingCalled_AndUpdateIntervalBecomesGraterThanLastUpdateDate_ThenFetchDatasets() {
        // GIVEN
        updateManagerMock.lastHashPrefixSetUpdateDate = timeTraveller.getDate()
        updateManagerMock.lastFilterSetUpdateDate = timeTraveller.getDate()
        featureFlaggerMock.hashPrefixUpdateFrequency = 15 // Value expressed in minutes
        featureFlaggerMock.filterSetUpdateFrequency = 10 // Value expressed in minutes
        featureFlaggerMock.isMaliciousSiteProtectionEnabled = true
        userPreferencesManagerMock.isMaliciousSiteProtectionOn = true
        sut.startFetching()
        #expect(updateManagerMock.updateDatasets[.hashPrefixSet] == false)
        #expect(updateManagerMock.updateDatasets[.filterSet] == false)

        // WHEN
        timeTraveller.advanceBy(.minutes(16))
        sut.startFetching()

        // THEN
        #expect(updateManagerMock.updateDatasets[.hashPrefixSet] == true)
        #expect(updateManagerMock.updateDatasets[.filterSet] == true)
    }

    // MARK: - Events Upon User Preference Subscription

    @Test("Do Not Fetch Datasets on Init when Feature Is Enabled and User Turned On the Feature")
    func whenInitialized_AndFeatureEnabled_AndPreferencesEnabled_ThenStartUpdateTask() {
        // GIVEN
        featureFlaggerMock.isMaliciousSiteProtectionEnabled = true
        userPreferencesManagerMock.isMaliciousSiteProtectionOn = true

        // WHEN
        setupSUT(featureFlaggerMock: featureFlaggerMock, userPreferencesManagerMock: userPreferencesManagerMock)

        // THEN
        #expect(updateManagerMock.updateDatasets[.hashPrefixSet] == false)
        #expect(updateManagerMock.updateDatasets[.filterSet] == false)
    }

    @Test("Start Fetching Datasets When User Turns On the Feature And Last Update Is Greater Than Update Interval")
    func whenPreferencesEnabled_AndLastUpdateDateIsGreaterThanUpdateInterval_ThenStartUpdateTask() {
        // GIVEN
        updateManagerMock.lastHashPrefixSetUpdateDate = .distantPast
        updateManagerMock.lastFilterSetUpdateDate = .distantPast
        featureFlaggerMock.isMaliciousSiteProtectionEnabled = true
        userPreferencesManagerMock.isMaliciousSiteProtectionOn = false
        setupSUT(updateManagerMock: updateManagerMock, featureFlaggerMock: featureFlaggerMock, userPreferencesManagerMock: userPreferencesManagerMock)
        sut.registerBackgroundRefreshTaskHandler()
        #expect(updateManagerMock.updateDatasets[.hashPrefixSet] == false)
        #expect(updateManagerMock.updateDatasets[.filterSet] == false)

        // WHEN
        userPreferencesManagerMock.isMaliciousSiteProtectionOn = true

        // TRUE
        #expect(updateManagerMock.updateDatasets[.hashPrefixSet] == true)
        #expect(updateManagerMock.updateDatasets[.filterSet] == true)
    }

    @Test("Do Not Start Fetching Datasets When User Turns On the Feature and Last Update Is Smaller Than Update Interval")
    func whenPreferencesEnabled_AndLastUpdateDateIsSmallerThanUpdateInterval_ThenDoNotStartUpdateTask() {
        // GIVEN
        let now = Date()
        updateManagerMock.lastHashPrefixSetUpdateDate = now
        updateManagerMock.lastFilterSetUpdateDate = now
        featureFlaggerMock.isMaliciousSiteProtectionEnabled = true
        userPreferencesManagerMock.isMaliciousSiteProtectionOn = false
        setupSUT(updateManagerMock: updateManagerMock, featureFlaggerMock: featureFlaggerMock, userPreferencesManagerMock: userPreferencesManagerMock)
        #expect(updateManagerMock.updateDatasets[.hashPrefixSet] == false)
        #expect(updateManagerMock.updateDatasets[.filterSet] == false)

        // WHEN
        userPreferencesManagerMock.isMaliciousSiteProtectionOn = true

        // TRUE
        #expect(updateManagerMock.updateDatasets[.hashPrefixSet] == false)
        #expect(updateManagerMock.updateDatasets[.filterSet] == false)
    }

    // MARK: - Background Tasks

    @Test("Schedule Background Tasks When Init And Feature Preference Is On")
    func whenInitAndFeaturePreferenceIsOnThenScheduleBackgroundTasks() async {
        // GIVEN
        let expectedBackgroundTasksIdentifiers = [
            "com.duckduckgo.app.maliciousSiteProtectionHashPrefixSetRefresh",
            "com.duckduckgo.app.maliciousSiteProtectionFilterSetRefresh",
        ]
        featureFlaggerMock.isMaliciousSiteProtectionEnabled = true
        userPreferencesManagerMock.isMaliciousSiteProtectionOn = true
        setupSUT(featureFlaggerMock: featureFlaggerMock, userPreferencesManagerMock: userPreferencesManagerMock, backgroundSchedulerMock: backgroundSchedulerMock)

        await confirmation(expectedCount: 2) { submittedBackgroundTask in
            backgroundSchedulerMock.scheduleBackgroundTaskConfirmation = submittedBackgroundTask

            // WHEN
            sut.registerBackgroundRefreshTaskHandler()

            // THEN
            #expect(backgroundSchedulerMock.submittedTaskRequests.map(\.identifier) == expectedBackgroundTasksIdentifiers)
        }
    }

    @Test("Register Background Tasks")
    func whenRegisterBackgroundRefreshTaskHandlerIsCalledThenRegisterBackgroundTasks() {
        // GIVEN
        let expectedBackgroundTasksIdentifiers = [
            "com.duckduckgo.app.maliciousSiteProtectionHashPrefixSetRefresh",
            "com.duckduckgo.app.maliciousSiteProtectionFilterSetRefresh",
        ]
        #expect(backgroundSchedulerMock.capturedRegisteredTaskIdentifiers.isEmpty)

        // WHEN
        sut.registerBackgroundRefreshTaskHandler()

        // THEN
        #expect(backgroundSchedulerMock.capturedRegisteredTaskIdentifiers == expectedBackgroundTasksIdentifiers)
    }

    @Test(
        "Do Not Execute Background Task When Dataset Does Not Need To Update",
        arguments: [
            (type: DataManager.StoredDataType.Kind.hashPrefixSet, updateFrequency: 1),
            (type: .filterSet, updateFrequency: 5),
        ]
    )
    func whenRegisterBackgroundRefreshTaskHandlerIsExecuted_AndShouldNotRefreshDataset_ThenSetTaskCompletedTrueAndScheduleRefreshTask(datasetInfo: (type: DataManager.StoredDataType.Kind, updateFrequency: Int)) throws {
        // GIVEN
        featureFlaggerMock.isMaliciousSiteProtectionEnabled = true
        userPreferencesManagerMock.isMaliciousSiteProtectionOn = true
        featureFlaggerMock.hashPrefixUpdateFrequency = 1
        featureFlaggerMock.filterSetUpdateFrequency = 5
        let date = Date()
        updateManagerMock.lastHashPrefixSetUpdateDate = date
        updateManagerMock.lastFilterSetUpdateDate = date
        let identifier = datasetInfo.type.backgroundTaskIdentifier
        let backgroundTask = MockBGTask(identifier: identifier)
        sut.registerBackgroundRefreshTaskHandler()
        #expect(!backgroundTask.didCallSetTaskCompleted)
        #expect(backgroundTask.capturedTaskCompletedSuccess == nil)
        let launchHandler = try #require(backgroundSchedulerMock.launchHandlers[identifier])

        // WHEN
        launchHandler?(backgroundTask)

        // THEN
        let tolerance: TimeInterval = 5
        #expect(backgroundTask.didCallSetTaskCompleted)
        #expect(backgroundTask.capturedTaskCompletedSuccess == true)
        #expect(backgroundTask.expirationHandler == nil)
        #expect(backgroundSchedulerMock.didCallSubmitTaskRequest)
        let capturedSubmittedTaskRequest = try #require(backgroundSchedulerMock.capturedSubmittedTaskRequest)
        let earliestBeginDate = try #require(capturedSubmittedTaskRequest.earliestBeginDate)
        #expect(capturedSubmittedTaskRequest.identifier == identifier)
        #expect(abs(earliestBeginDate.timeIntervalSince1970 - Date(timeIntervalSinceNow: .minutes(datasetInfo.updateFrequency)).timeIntervalSince1970) < tolerance)
    }

    @Test(
        "Execute Background Task When Dataset Needs To Update",
        arguments: [
            DataManager.StoredDataType.Kind.hashPrefixSet,
            .filterSet,
        ]
    )
    func whenRegisterBackgroundRefreshTaskHandlerIsExecuted_AndShouldRefreshDataset_ThenRunTask(datasetType: DataManager.StoredDataType.Kind) throws {
        // GIVEN
        featureFlaggerMock.isMaliciousSiteProtectionEnabled = true
        userPreferencesManagerMock.isMaliciousSiteProtectionOn = true
        updateManagerMock.lastFilterSetUpdateDate = .distantPast
        updateManagerMock.lastFilterSetUpdateDate = .distantPast
        let identifier = datasetType.backgroundTaskIdentifier
        let backgroundTask = MockBGTask(identifier: identifier)
        sut.registerBackgroundRefreshTaskHandler()
        let launchHandler = try #require(backgroundSchedulerMock.launchHandlers[identifier])
        #expect(backgroundTask.expirationHandler == nil)

        // WHEN
        launchHandler?(backgroundTask)

        // THEN
        #expect(backgroundTask.expirationHandler != nil)
    }

    @Test(
        "Check Expiration Handler Cancel Task",
        arguments: [
            DataManager.StoredDataType.Kind.hashPrefixSet,
            .filterSet,
        ]
    )
    func whenExpirationHandlerIsCalledThenCancelTask(datasetType: DataManager.StoredDataType.Kind) throws {
        // GIVEN
        featureFlaggerMock.isMaliciousSiteProtectionEnabled = true
        userPreferencesManagerMock.isMaliciousSiteProtectionOn = true
        updateManagerMock.lastFilterSetUpdateDate = .distantPast
        updateManagerMock.lastFilterSetUpdateDate = .distantPast
        let identifier = datasetType.backgroundTaskIdentifier
        let backgroundTask = MockBGTask(identifier: identifier)
        sut.registerBackgroundRefreshTaskHandler()
        let launchHandler = try #require(backgroundSchedulerMock.launchHandlers[identifier])
        #expect(!backgroundTask.didCallSetTaskCompleted)
        #expect(backgroundTask.capturedTaskCompletedSuccess == nil)
        launchHandler?(backgroundTask)

        // WHEN
        backgroundTask.expirationHandler?()

        // THEN
        #expect(backgroundTask.didCallSetTaskCompleted)
        #expect(backgroundTask.capturedTaskCompletedSuccess == false)
    }

    @Test("Start Background Update Task When User Turns On the Feature And Background Tasks Are Available")
    func whenUserTurnsOnProtectionThenStartBackgroundUpdateTask() {
        // GIVEN
        featureFlaggerMock.isMaliciousSiteProtectionEnabled = true
        userPreferencesManagerMock.isMaliciousSiteProtectionOn = false
        setupSUT(updateManagerMock: updateManagerMock, featureFlaggerMock: featureFlaggerMock, userPreferencesManagerMock: userPreferencesManagerMock)
        sut.registerBackgroundRefreshTaskHandler()
        #expect(!backgroundSchedulerMock.didCallSubmitTaskRequest)
        #expect(backgroundSchedulerMock.capturedSubmittedTaskRequest == nil)

        // WHEN
        userPreferencesManagerMock.isMaliciousSiteProtectionOn = true

        // TRUE
        #expect(backgroundSchedulerMock.didCallSubmitTaskRequest)
        #expect(backgroundSchedulerMock.capturedSubmittedTaskRequest != nil)
    }

    @Test(
        "Do Not Start Background Update Task When User Turns On the Feature And Background Tasks Are Not Available",
        arguments: [
            UIBackgroundRefreshStatus.denied,
            .restricted,
        ]
    )
    func whenUserTurnsOnProtectionThenStartBackgroundUpdateTask(backgroundRefreshStatus: UIBackgroundRefreshStatus) {
        // GIVEN
        featureFlaggerMock.isMaliciousSiteProtectionEnabled = true
        userPreferencesManagerMock.isMaliciousSiteProtectionOn = false
        application.backgroundRefreshStatus = backgroundRefreshStatus
        setupSUT(updateManagerMock: updateManagerMock, featureFlaggerMock: featureFlaggerMock, userPreferencesManagerMock: userPreferencesManagerMock, application: application)
        sut.registerBackgroundRefreshTaskHandler()
        #expect(!backgroundSchedulerMock.didCallSubmitTaskRequest)
        #expect(backgroundSchedulerMock.capturedSubmittedTaskRequest == nil)

        // WHEN
        userPreferencesManagerMock.isMaliciousSiteProtectionOn = true

        // TRUE
        #expect(!backgroundSchedulerMock.didCallSubmitTaskRequest)
        #expect(backgroundSchedulerMock.capturedSubmittedTaskRequest == nil)
    }

    @Test("Stop Background Update Task When User Turns Off the Feature")
    func whenUserTurnsOffProtectionThenStopBackgroundUpdateTask() {
        // GIVEN
        featureFlaggerMock.isMaliciousSiteProtectionEnabled = true
        setupSUT(featureFlaggerMock: featureFlaggerMock)
        sut.registerBackgroundRefreshTaskHandler()
        userPreferencesManagerMock.isMaliciousSiteProtectionOn = true
        #expect(!backgroundSchedulerMock.didCallCancelTaskRequestWithIdentifier)

        // WHEN
        userPreferencesManagerMock.isMaliciousSiteProtectionOn = false

        // TRUE
        #expect(backgroundSchedulerMock.didCallCancelTaskRequestWithIdentifier)
    }

}
