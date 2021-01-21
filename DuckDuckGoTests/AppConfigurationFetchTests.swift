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

    override func setUp() {
        UserDefaults(suiteName: testGroupName)?.removePersistentDomain(forName: testGroupName)
    }

    @available(iOS 13.0, *)
    func testBackgroundRefreshCompletionHandler_expired_noPreviousStatus() {
        assert(current: .expired, previous: nil)
    }

    @available(iOS 13.0, *)
    func testBackgroundRefreshCompletionHandler_expired_previouslyExpired() {
        assert(current: .expired, previous: .expired)
    }

    @available(iOS 13.0, *)
    func testBackgroundRefreshCompletionHandler_expired_previouslySucceededWithNoData() {
        assert(current: .expired, previous: .noData)
    }

    @available(iOS 13.0, *)
    func testBackgroundRefreshCompletionHandler_expired_previouslySucceededWithNewData() {
        assert(current: .expired, previous: .newData)
    }

    @available(iOS 13.0, *)
    func testBackgroundRefreshCompletionHandler_noData_noPreviousStatus() {
        assert(current: .noData, previous: nil)
    }

    @available(iOS 13.0, *)
    func testBackgroundRefreshCompletionHandler_noData_previouslyExpired() {
        assert(current: .noData, previous: .expired)
    }

    @available(iOS 13.0, *)
    func testBackgroundRefreshCompletionHandler_noData_previouslySucceededWithNoData() {
        assert(current: .noData, previous: .noData)
    }

    @available(iOS 13.0, *)
    func testBackgroundRefreshCompletionHandler_noData_previouslySucceededWithNewData() {
        assert(current: .noData, previous: .newData)
    }

    @available(iOS 13.0, *)
    func testBackgroundRefreshCompletionHandler_newData_noPreviousStatus() {
        assert(current: .newData, previous: nil)
    }

    @available(iOS 13.0, *)
    func testBackgroundRefreshCompletionHandler_newData_previouslyExpired() {
        assert(current: .newData, previous: .expired)
    }

    @available(iOS 13.0, *)
    func testBackgroundRefreshCompletionHandler_newData_previouslySucceededWithNoData() {
        assert(current: .newData, previous: .noData)
    }

    @available(iOS 13.0, *)
    func testBackgroundRefreshCompletionHandler_newData_previouslySucceededWithNewData() {
        assert(current: .newData, previous: .newData)
    }

    @available(iOS 13.0, *)
    func testWhenTheCompletionHandlerTriesToUpdateStatisticsThenTheCountCannotBeNegative() {
        let store = AppUserDefaults(groupName: testGroupName)
        let task = MockBackgroundTask()

        store.backgroundFetchTaskExpirationCount = 0
        store.backgroundNoDataCount = 0
        store.backgroundNewDataCount = 0

        var previousStatus: AppConfigurationFetch.BackgroundRefreshCompletionStatus? = .expired

        MockAppConfigurationFetch.backgroundRefreshTaskCompletionHandler(store: store,
                                                                         refreshStartDate: Date(),
                                                                         task: task,
                                                                         status: .noData,
                                                                         previousStatus: &previousStatus)

        XCTAssertEqual(previousStatus, .noData)

        XCTAssertEqual(store.backgroundFetchTaskExpirationCount, 0)
        XCTAssertEqual(store.backgroundNoDataCount, 0)
        XCTAssertEqual(store.backgroundNewDataCount, 0)
    }

    @available(iOS 13.0, *)
    private func assert(current: AppConfigurationFetch.BackgroundRefreshCompletionStatus,
                        previous: AppConfigurationFetch.BackgroundRefreshCompletionStatus?) {

        let store = AppUserDefaults(groupName: testGroupName)
        let task = MockBackgroundTask()

        let updateStore: (AppConfigurationFetch.BackgroundRefreshCompletionStatus?) -> Void = { status in
            switch status {
            case .expired:
                store.backgroundFetchTaskExpirationCount += 1
            case .noData:
                store.backgroundNoDataCount += 1
            case .newData:
                store.backgroundNewDataCount += 1
            case .none: break
            }
        }

        // Set up the counts for the current and previous statuses. The completion handler expects that the statistic counts have already been
        // updated before completion.

        updateStore(current)
        updateStore(previous)

        var previousStatus: AppConfigurationFetch.BackgroundRefreshCompletionStatus? = previous

        MockAppConfigurationFetch.backgroundRefreshTaskCompletionHandler(store: store,
                                                                         refreshStartDate: Date(),
                                                                         task: task,
                                                                         status: current,
                                                                         previousStatus: &previousStatus)

        XCTAssertEqual(previousStatus, current)

        XCTAssertEqual(store.backgroundFetchTaskExpirationCount, current == .expired ? 1 : 0)
        XCTAssertEqual(store.backgroundNoDataCount, current == .noData ? 1 : 0)
        XCTAssertEqual(store.backgroundNewDataCount, current == .newData ? 1 : 0)
    }
}

private class MockAppConfigurationFetch: AppConfigurationFetch {
    func fetchConfigurationFiles(isBackground: Bool) -> Bool {
        return true
    }
}

@available(iOS 13.0, *)
private class MockBackgroundTask: BGTask {
    /// Used to instantiate background tasks, as `BGTask` marks its `init` unavailable.
    init(_ unusedValue: String? = nil) {}

    override func setTaskCompleted(success: Bool) {
        // no-op
    }
}
