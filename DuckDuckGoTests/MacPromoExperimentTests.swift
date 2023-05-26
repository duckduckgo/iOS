//
//  MacPromoExperimentTests.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
@testable import DuckDuckGo
import BrowserServicesKit

class MacPromoExperimentTests: XCTestCase {

    var scheduledMessage: RemoteMessageModel?

    override func setUp() {
        super.setUp()
        MacPromoExperiment(remoteMessagingStore: self).cohort = .unassigned
    }

    func testWhenNoScheduledMessageThenDontShowMessageOrSheet() {
        let experiment = MacPromoExperiment(remoteMessagingStore: self)
        XCTAssertEqual(experiment.cohort, .unassigned)
        XCTAssertFalse(experiment.shouldShowMessage())
        XCTAssertFalse(experiment.shouldShowSheet())
    }

    func testWhenCohortAssignedMessageThenShowMessageDontShowSheet() {

        scheduledMessage = .init(id: MacPromoExperiment.promoId,
                                 content: .small(titleText: "title", descriptionText: "description"),
                                 matchingRules: [],
                                 exclusionRules: [])

        let experiment = MacPromoExperiment(remoteMessagingStore: self, randomBool: returnFalse)
        XCTAssertEqual(experiment.cohort, .unassigned)
        XCTAssertFalse(experiment.shouldShowSheet())
        XCTAssertTrue(experiment.shouldShowMessage())
        XCTAssertEqual(experiment.cohort, .message)
    }

    func testWhenCohortAssignedSheetThenShowSheetDontShowMessage() {

        scheduledMessage = .init(id: MacPromoExperiment.promoId,
                                 content: .small(titleText: "title", descriptionText: "description"),
                                 matchingRules: [],
                                 exclusionRules: [])

        let experiment = MacPromoExperiment(remoteMessagingStore: self, randomBool: returnTrue)
        XCTAssertEqual(experiment.cohort, .unassigned)
        XCTAssertFalse(experiment.shouldShowMessage())
        XCTAssertTrue(experiment.shouldShowSheet())
        XCTAssertEqual(experiment.cohort, .sheet)
    }

    func testWhenOtherMessageReturnedThenShowMessageButDontAllocateCohort() {

        scheduledMessage = .init(id: "other",
                                 content: .small(titleText: "title", descriptionText: "description"),
                                 matchingRules: [],
                                 exclusionRules: [])

        let experiment = MacPromoExperiment(remoteMessagingStore: self, randomBool: returnTrue)
        XCTAssertTrue(experiment.shouldShowMessage())
        XCTAssertFalse(experiment.shouldShowSheet())
        XCTAssertEqual(experiment.cohort, .unassigned)
    }

    func returnFalse() -> Bool {
        return false
    }

    func returnTrue() -> Bool {
        return true
    }

}

extension MacPromoExperimentTests: RemoteMessagingStoring {

    func saveProcessedResult(_ processorResult: RemoteMessagingConfigProcessor.ProcessorResult) {
    }

    func fetchRemoteMessagingConfig() -> RemoteMessagingConfig? {
        return nil
    }

    func fetchScheduledRemoteMessage() -> RemoteMessageModel? {
        return scheduledMessage
    }

    func fetchRemoteMessage(withId id: String) -> RemoteMessageModel? {
        return nil
    }

    func hasShownRemoteMessage(withId id: String) -> Bool {
        return false
    }

    func hasDismissedRemoteMessage(withId id: String) -> Bool {
        return false
    }

    func dismissRemoteMessage(withId id: String) {
    }

    func fetchDismissedRemoteMessageIds() -> [String] {
        return []
    }

    func updateRemoteMessage(withId id: String, asShown shown: Bool) {
    }

}
