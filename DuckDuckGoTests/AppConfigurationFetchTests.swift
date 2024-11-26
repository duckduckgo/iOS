//
//  AppConfigurationFetchTests.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

import XCTest
import BackgroundTasks
@testable import DuckDuckGo

class AppConfigurationFetchTests: XCTestCase {

    let testGroupName = "configurationFetchTestGroup"

    override func setUpWithError() throws {
#if !targetEnvironment(simulator)
        throw XCTSkip("Ignore when ran on a device")
#endif
        
        try super.setUpWithError()

        UserDefaults(suiteName: testGroupName)?.removePersistentDomain(forName: testGroupName)
    }

    func testBackgroundRefreshCompletionStatusSuccess() {
        XCTAssertFalse(AppConfigurationFetch.BackgroundRefreshCompletionStatus.expired.success)
        XCTAssertTrue(AppConfigurationFetch.BackgroundRefreshCompletionStatus.noData.success)
        XCTAssertTrue(AppConfigurationFetch.BackgroundRefreshCompletionStatus.newData.success)
    }

    // MARK: - Test Expired

    func testBackgroundRefreshCompletionHandlerWhenExpiredWithNoPreviousStatus() {
        assert(current: .expired, previous: nil)
    }

    func testBackgroundRefreshCompletionHandlerWhenExpiredWithPreviousExpiration() {
        assert(current: .expired, previous: .expired)
    }

    func testBackgroundRefreshCompletionHandlerWhenExpiredWithPreviousNoDataSuccess() {
        assert(current: .expired, previous: .noData)
    }

    func testBackgroundRefreshCompletionHandlerWhenExpiredWithPreviousNewDataSuccess() {
        assert(current: .expired, previous: .newData)
    }

    // MARK: - Test Success With No Data

    func testBackgroundRefreshCompletionHandlerWhenSucceededWithNoDataAndNoPreviousStatus() {
        assert(current: .noData, previous: nil)
    }

    func testBackgroundRefreshCompletionHandlerWhenSucceededWithNoDataAndPreviousExpiration() {
        assert(current: .noData, previous: .expired)
    }

    func testBackgroundRefreshCompletionHandlerWhenSucceededWithNoDataAndPreviousNoData() {
        assert(current: .noData, previous: .noData)
    }

    func testBackgroundRefreshCompletionHandlerWhenSucceededWithNoDataAndPreviousNewData() {
        assert(current: .noData, previous: .newData)
    }

    // MARK: - Test Success With New Data

    func testBackgroundRefreshCompletionHandlerWhenSucceededWithNewDataAndNoPreviousStatus() {
        assert(current: .newData, previous: nil)
    }

    func testBackgroundRefreshCompletionHandlerWhenSucceededWithNewDataAndPreviousExpiration() {
        assert(current: .newData, previous: .expired)
    }

    func testBackgroundRefreshCompletionHandlerWhenSucceededWithNewDataAndPreviousNoData() {
        assert(current: .newData, previous: .noData)
    }

    func testBackgroundRefreshCompletionHandlerWhenSucceededWithNewDataAndPreviousNewData() {
        assert(current: .newData, previous: .newData)
    }

    func testWhenTheCompletionHandlerTriesToUpdateStatisticsThenTheCountCannotBeNegative() {
        let store = AppUserDefaults(groupName: testGroupName)
        let task = MockBackgroundTask()

        store.backgroundFetchTaskExpirationCount = 0
        store.backgroundNoDataCount = 0
        store.backgroundNewDataCount = 0

        let newStatus = MockAppConfigurationFetch.backgroundRefreshTaskCompletionHandler(store: store,
                                                                                         refreshStartDate: Date(),
                                                                                         task: task,
                                                                                         status: .noData,
                                                                                         previousStatus: .expired)

        XCTAssertEqual(newStatus, .noData)

        XCTAssertEqual(store.backgroundFetchTaskExpirationCount, 0)
        XCTAssertEqual(store.backgroundNoDataCount, 0)
        XCTAssertEqual(store.backgroundNewDataCount, 0)

    }

    // This function sets up the environment that the completion handler expects when called. Specifically:
    //
    // - It expects `backgroundFetchTaskExpirationCount` to only be incremented if there is no previous status
    // - `backgroundNoDataCount` and `backgroundNewDataCount` will be incremented even if there is a previous status
    private func assert(current: AppConfigurationFetch.BackgroundRefreshCompletionStatus,
                        previous: AppConfigurationFetch.BackgroundRefreshCompletionStatus?) {

        let store = AppUserDefaults(groupName: testGroupName)
        let task = MockBackgroundTask()

        // Set up the counts for the current and previous statuses. The completion handler expects that the statistic counts have already been
        // updated before completion.

        switch current {
        case .expired:
            // This counter will have only been incremented if there was no previous completion.
            if previous == nil {
                store.backgroundFetchTaskExpirationCount += 1
            }
        case .noData:
            store.backgroundNoDataCount += 1
        case .newData:
            store.backgroundNewDataCount += 1
        }

        let newStatus = MockAppConfigurationFetch.backgroundRefreshTaskCompletionHandler(store: store,
                                                                                         refreshStartDate: Date(),
                                                                                         task: task,
                                                                                         status: current,
                                                                                         previousStatus: previous)

        XCTAssertEqual(newStatus, current)

        XCTAssertEqual(store.backgroundFetchTaskExpirationCount, (current == .expired && previous == nil) ? 1 : 0)
        XCTAssertEqual(store.backgroundNoDataCount, current == .noData ? 1 : 0)
        XCTAssertEqual(store.backgroundNewDataCount, current == .newData ? 1 : 0)

    }
}

private class MockAppConfigurationFetch: AppConfigurationFetch {

    func fetchConfigurationFiles(isBackground: Bool) -> Bool {
        return true
    }

}

private class MockBackgroundTask: CompletableTask {

    func setTaskCompleted(success: Bool) {
        // no-op
    }

}
