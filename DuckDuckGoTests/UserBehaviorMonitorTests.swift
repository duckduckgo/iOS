//
//  UserBehaviorMonitorTests.swift
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

import XCTest
import Common
@testable import DuckDuckGo

final class MockUserBehaviorEventsMapping: EventMapping<UserBehaviorEvent> {

    init(captureEvent: @escaping (UserBehaviorEvent) -> Void) {
        super.init { event, _, _, _ in
            captureEvent(event)
        }
    }

    override init(mapping: @escaping EventMapping<UserBehaviorEvent>.Mapping) {
        fatalError("Use init()")
    }
}

final class MockUserBehaviorStore: UserBehaviorStoring {

    var didRefreshTimestamp: Date?
    var didDoubleRefreshTimestamp: Date?
    var didRefreshCounter: Int = 0

}

final class UserBehaviorMonitorTests: XCTestCase {

    var eventMapping: MockUserBehaviorEventsMapping!
    var monitor: UserBehaviorMonitor!
    var events: [UserBehaviorEvent] = []

    override func setUp() {
        super.setUp()
        events.removeAll()
        eventMapping = MockUserBehaviorEventsMapping(captureEvent: { event in
            self.events.append(event)
        })
        monitor = UserBehaviorMonitor(eventMapping: eventMapping,
                                      store: MockUserBehaviorStore())
    }

    // - MARK: Behavior testing
    // Expecting events

    func testWhenUserRefreshesTwiceItSendsReloadTwiceEvent() {
        monitor.handleRefreshAction()
        monitor.handleRefreshAction()
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0], .reloadTwiceWithin12Seconds)
    }

    func testWhenUserRefreshesThreeTimesItSendsTwoReloadTwiceEvents() {
        monitor.handleRefreshAction()
        monitor.handleRefreshAction()
        monitor.handleRefreshAction()
        XCTAssertEqual(events.count, 3)
        XCTAssertEqual(events[0], .reloadTwiceWithin12Seconds)
        XCTAssertEqual(events[1], .reloadTwiceWithin12Seconds)
    }

    func testWhenUserRefreshesThreeTimesItSendsReloadThreeTimesEvent() {
        monitor.handleRefreshAction()
        monitor.handleRefreshAction()
        monitor.handleRefreshAction()
        XCTAssertEqual(events.count, 3)
        XCTAssertEqual(events[2], .reloadThreeTimesWithin20Seconds)
    }

    // Timed pixels

    func testReloadTwiceEventShouldNotSendEventIfSecondRefreshOccuredAfter12Seconds() {
        let date = Date()
        monitor.handleRefreshAction(date: date)
        monitor.handleRefreshAction(date: date + 13) // 13 seconds after the first event
        XCTAssertTrue(events.isEmpty)
    }

    func testReloadTwiceEventShouldSendEventIfSecondRefreshOccurredBelow12Seconds() {
        let date = Date()
        monitor.handleRefreshAction(date: date)
        monitor.handleRefreshAction(date: date + 11) // 20 seconds after the first event
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0], .reloadTwiceWithin12Seconds)
    }

    func testReloadThreeTimesEventShouldNotSendEventIfThreeRefreshesOccurredAfter20Seconds() {
        let date = Date()
        monitor.handleRefreshAction(date: date)
        monitor.handleRefreshAction(date: date)
        monitor.handleRefreshAction(date: date + 21) // 21 seconds after the first event
        events.removeAll { $0 == .reloadTwiceWithin12Seconds } // remove events that are not being tested
        XCTAssertTrue(events.isEmpty)
    }

    func testReloadThreeTimesEventShouldSendEventIfThreeRefreshesOccurredBelow20Seconds() {
        let date = Date()
        monitor.handleRefreshAction(date: date)
        monitor.handleRefreshAction(date: date)
        monitor.handleRefreshAction(date: date + 19) // 10 seconds after the first event
        events.removeAll { $0 == .reloadTwiceWithin12Seconds } // remove events that are not being tested
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0], .reloadThreeTimesWithin20Seconds)
    }

}
