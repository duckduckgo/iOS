//
//  RemoteMessagingStoreTests.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import Foundation
import CoreData
@testable import DuckDuckGo
@testable import Core
@testable import BrowserServicesKit
@testable import RemoteMessaging

class RemoteMessagingStoreTests: XCTestCase {

    private var data = JsonTestDataLoader()

    private var store: RemoteMessagingStore!

    private let notificationCenter = NotificationCenter()

    override func setUpWithError() throws {
        try super.setUpWithError()
        let container = CoreData.remoteMessagingContainer()
        let context = container.viewContext
        store = RemoteMessagingStore(context: context, notificationCenter: notificationCenter)
    }

    override func tearDownWithError() throws {
        store = nil
        try super.tearDownWithError()
    }

    // Tests:
    // 1. saveProcessedResult()
    // 2. fetch RemoteMessagingConfig and RemoteMessage successfully returned from save in step 1
    // 3. NSNotification RemoteMessagesDidChange is posted
    func testWhenSaveProcessedResultThenFetchRemoteConfigAndMessageExistsAndNotificationSent() throws {
        let expectation = XCTNSNotificationExpectation(name: RemoteMessaging.Notifications.remoteMessagesDidChange,
                                                       object: nil, notificationCenter: notificationCenter)

        _ = try saveProcessedResultFetchRemoteMessage()

        // 3. NSNotification RemoteMessagesDidChange is posted
        wait(for: [expectation], timeout: 10)
    }

    func saveProcessedResultFetchRemoteMessage() throws -> RemoteMessageModel {
        let processorResult = try processorResult()
        // 1. saveProcessedResult()
        store.saveProcessedResult(processorResult)

        // 2. fetch RemoteMessagingConfig and RemoteMessage successfully returned from save in step 1
        let config = store.fetchRemoteMessagingConfig()
        XCTAssertNotNil(config)
        XCTAssertEqual(config?.version, processorResult.version)
        guard let remoteMessage = store.fetchScheduledRemoteMessage() else {
            XCTFail("No remote message found")
            return RemoteMessageModel(id: "", content: nil, matchingRules: [], exclusionRules: [])
        }

        XCTAssertNotNil(remoteMessage)
        XCTAssertEqual(remoteMessage, processorResult.message)
        return remoteMessage
    }

    func testWhenHasNotShownMessageThenReturnFalse() throws {
        let remoteMessage = try saveProcessedResultFetchRemoteMessage()
        XCTAssertFalse(store.hasShownRemoteMessage(withId: remoteMessage.id))
    }

    func testWhenUpdateRemoteMessageAsShownMessageThenHasShownIsTrue() throws {
        let remoteMessage = try saveProcessedResultFetchRemoteMessage()
        store.updateRemoteMessage(withId: remoteMessage.id, asShown: true)
        XCTAssertTrue(store.hasShownRemoteMessage(withId: remoteMessage.id))
    }

    func testWhenUpdateRemoteMessageAsShownFalseThenHasShownIsFalse() throws {
        let remoteMessage = try saveProcessedResultFetchRemoteMessage()
        store.updateRemoteMessage(withId: remoteMessage.id, asShown: false)
        XCTAssertFalse(store.hasShownRemoteMessage(withId: remoteMessage.id))
    }

    func testWhenDismissRemoteMessageThenFetchedMessageHasDismissedState() throws {
        let remoteMessage = try saveProcessedResultFetchRemoteMessage()

        store.dismissRemoteMessage(withId: remoteMessage.id)

        guard let fetchedRemoteMessage = store.fetchRemoteMessage(withId: remoteMessage.id) else {
            XCTFail("No remote message found")
            return
        }

        XCTAssertEqual(fetchedRemoteMessage.id, remoteMessage.id)
        XCTAssertTrue(store.hasDismissedRemoteMessage(withId: fetchedRemoteMessage.id))
    }

    func testFetchDismissedRemoteMessageIds() throws {
        let remoteMessage = try saveProcessedResultFetchRemoteMessage()

        store.dismissRemoteMessage(withId: remoteMessage.id)

        let dismissedRemoteMessageIds = store.fetchDismissedRemoteMessageIds()
        XCTAssertEqual(dismissedRemoteMessageIds.count, 1)
        XCTAssertEqual(dismissedRemoteMessageIds.first, remoteMessage.id)
    }

    func decodeJson(fileName: String) throws -> RemoteMessageResponse.JsonRemoteMessagingConfig {
        let validJson = data.fromJsonFile(fileName)
        let remoteMessagingConfig = try JSONDecoder().decode(RemoteMessageResponse.JsonRemoteMessagingConfig.self, from: validJson)
        XCTAssertNotNil(remoteMessagingConfig)

        return remoteMessagingConfig
    }

    func processorResult() throws -> RemoteMessagingConfigProcessor.ProcessorResult {
        let jsonRemoteMessagingConfig = try decodeJson(fileName: "MockFiles/remote-messaging-config-example.json")
        let remoteMessagingConfigMatcher = RemoteMessagingConfigMatcher(
                appAttributeMatcher: AppAttributeMatcher(statisticsStore: MockStatisticsStore(), variantManager: MockVariantManager()),
                userAttributeMatcher: UserAttributeMatcher(statisticsStore: MockStatisticsStore(),
                                                           variantManager: MockVariantManager(),
                                                           bookmarksCount: 0,
                                                           favoritesCount: 0,
                                                           appTheme: "light",
                                                           isWidgetInstalled: false,
                                                           isNetPWaitlistUser: false,
                                                           daysSinceNetPEnabled: -1),
                dismissedMessageIds: []
        )

        let processor = RemoteMessagingConfigProcessor(remoteMessagingConfigMatcher: remoteMessagingConfigMatcher)
        let config: RemoteMessagingConfig = RemoteMessagingConfig(version: jsonRemoteMessagingConfig.version - 1,
                                                                  invalidate: false,
                                                                  evaluationTimestamp: Date())

        if let processorResult = processor.process(jsonRemoteMessagingConfig: jsonRemoteMessagingConfig, currentConfig: config) {
            return processorResult
        } else {
            XCTFail("Processor result message is nil")
            return RemoteMessagingConfigProcessor.ProcessorResult(version: 0, message: nil)
        }
    }
}
