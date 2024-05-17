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
        monitor.handleAction(.refresh)
        monitor.handleAction(.refresh)
        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events[0], .reloadTwiceWithin12Seconds)
        XCTAssertEqual(events[1], .reloadTwiceWithin24Seconds)
    }

    func testWhenUserRefreshesAndThenReopensAppItSendsReloadAndRestartEvent() {
        monitor.handleAction(.refresh)
        monitor.handleAction(.reopenApp)
        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events[0], .reloadAndRestartWithin30Seconds)
        XCTAssertEqual(events[1], .reloadAndRestartWithin50Seconds)
    }

    func testWhenUserRefreshesThreeTimesItSendsTwoReloadTwiceEvents() {
        monitor.handleAction(.refresh)
        monitor.handleAction(.refresh)
        monitor.handleAction(.refresh)
        XCTAssertEqual(events.count, 6)
        XCTAssertEqual(events[0], .reloadTwiceWithin12Seconds)
        XCTAssertEqual(events[1], .reloadTwiceWithin24Seconds)
        XCTAssertEqual(events[2], .reloadTwiceWithin12Seconds)
        XCTAssertEqual(events[3], .reloadTwiceWithin24Seconds)
    }

    func testWhenUserRefreshesThreeTimesItSendsReloadThreeTimesEvent() {
        monitor.handleAction(.refresh)
        monitor.handleAction(.refresh)
        monitor.handleAction(.refresh)
        XCTAssertEqual(events.count, 6)
        XCTAssertEqual(events[4], .reloadThreeTimesWithin20Seconds)
        XCTAssertEqual(events[5], .reloadThreeTimesWithin40Seconds)
    }

    func testWhenUserRefreshesThenReopensAppThenRefreshesAgainItSendsTwoEvents() {
        monitor.handleAction(.refresh)
        monitor.handleAction(.reopenApp)
        monitor.handleAction(.refresh)
        XCTAssertEqual(events.count, 4)
        XCTAssertEqual(events[0], .reloadAndRestartWithin30Seconds)
        XCTAssertEqual(events[1], .reloadAndRestartWithin50Seconds)
        XCTAssertEqual(events[2], .reloadTwiceWithin12Seconds)
        XCTAssertEqual(events[3], .reloadTwiceWithin24Seconds)
    }

    // Not expecting any events

    func testWhenUserUsesReopensAppAndThenRefreshesItShouldNotSendAnyEvent() {
        monitor.handleAction(.reopenApp)
        monitor.handleAction(.refresh)
        XCTAssertTrue(events.isEmpty)
    }

    // Timed pixels

    func testReloadTwiceEventShouldNotSendEventIfSecondRefreshOccuredAfter24Seconds() {
        let date = Date()
        monitor.handleAction(.refresh, date: date)
        monitor.handleAction(.refresh, date: date + 24) // 24 seconds after the first event
        XCTAssertTrue(events.isEmpty)
    }

    func testReloadTwiceEventShouldSendEventIfSecondRefreshOccurredBelow24Seconds() {
        let date = Date()
        monitor.handleAction(.refresh, date: date)
        monitor.handleAction(.refresh, date: date + 20) // 20 seconds after the first event
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0], .reloadTwiceWithin24Seconds)
    }

    func testReloadTwiceEventShouldSendTwoEventsIfSecondRefreshOccurredBelow12Seconds() {
        let date = Date()
        monitor.handleAction(.refresh, date: date)
        monitor.handleAction(.refresh, date: date + 10) // 10 seconds after the first event
        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events[0], .reloadTwiceWithin12Seconds)
        XCTAssertEqual(events[1], .reloadTwiceWithin24Seconds)
    }

    func testReloadAndRestartEventShouldNotSendEventIfRestartOccurredAfter50Seconds() {
        let date = Date()
        monitor.handleAction(.refresh, date: date)
        monitor.handleAction(.reopenApp, date: date + 50) // 50 seconds after the first event
        XCTAssertTrue(events.isEmpty)
    }

    func testReloadAndRestartEventShouldSendEventIfRestartOccurredBelow50Seconds() {
        let date = Date()
        monitor.handleAction(.refresh, date: date)
        monitor.handleAction(.reopenApp, date: date + 30) // 30 seconds after the first event
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0], .reloadAndRestartWithin50Seconds)
    }

    func testReloadAndRestartEventShouldSendTwoEventsIfRestartOccurredBelow30Seconds() {
        let date = Date()
        monitor.handleAction(.refresh, date: date)
        monitor.handleAction(.reopenApp, date: date + 20) // 20 seconds after the first event
        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events[0], .reloadAndRestartWithin30Seconds)
        XCTAssertEqual(events[1], .reloadAndRestartWithin50Seconds)
    }

    func testReloadThreeTimesEventShouldNotSendEventIfSecondRefreshOccuredAfter40Seconds() {
        let date = Date()
        monitor.handleAction(.refresh, date: date)
        monitor.handleAction(.refresh, date: date)
        monitor.handleAction(.refresh, date: date + 40) // 40 seconds after the first event
        events.removeAll { $0 == .reloadTwiceWithin12Seconds || $0 == .reloadTwiceWithin24Seconds } // remove events that are not being tested
        XCTAssertTrue(events.isEmpty)
    }

    func testReloadThreeTimesEventShouldSendEventIfSecondRefreshOccurredBelow40Seconds() {
        let date = Date()
        monitor.handleAction(.refresh, date: date)
        monitor.handleAction(.refresh, date: date)
        monitor.handleAction(.refresh, date: date + 30) // 30 seconds after the first event
        events.removeAll { $0 == .reloadTwiceWithin12Seconds || $0 == .reloadTwiceWithin24Seconds } // remove events that are not being tested
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0], .reloadThreeTimesWithin40Seconds)
    }

    func testReloadThreeTimesEventShouldSendTwoEventsIfSecondRefreshOccurredBelow20Seconds() {
        let date = Date()
        monitor.handleAction(.refresh, date: date)
        monitor.handleAction(.refresh, date: date)
        monitor.handleAction(.refresh, date: date + 10) // 10 seconds after the first event
        events.removeAll { $0 == .reloadTwiceWithin12Seconds || $0 == .reloadTwiceWithin24Seconds } // remove events that are not being tested
        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events[0], .reloadThreeTimesWithin20Seconds)
        XCTAssertEqual(events[1], .reloadThreeTimesWithin40Seconds)
    }

}
