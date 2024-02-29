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
    var didBurnTimestamp: Date?

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
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first!, .reloadTwice)
    }

    func testWhenUserRefreshesAndThenReopensAppItSendsReloadAndRestartEvent() {
        monitor.handleAction(.refresh)
        monitor.handleAction(.reopenApp)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first!, .reloadAndRestart)
    }

    func testWhenUserRefreshesAndThenUsesFireButtonItSendsReloadAndFireButtonEvent() {
        monitor.handleAction(.refresh)
        monitor.handleAction(.burn)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first!, .reloadAndFireButton)
    }

    func testWhenUserRefreshesAndThenOpensSettingsItSendsReloadAndOpenSettingsEvent() {
        monitor.handleAction(.refresh)
        monitor.handleAction(.openSettings)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first!, .reloadAndOpenSettings)
    }

    func testWhenUserRefreshesAndThenTogglesProtectionsItSendsReloadAndTogglePrivacyControlsEvent() {
        monitor.handleAction(.refresh)
        monitor.handleAction(.toggleProtections)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first!, .reloadAndTogglePrivacyControls)
    }

    func testWhenUserUsesFireButtonAndThenReopensAppItSendsFireButtonAndRestartEvent() {
        monitor.handleAction(.burn)
        monitor.handleAction(.reopenApp)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first!, .fireButtonAndRestart)
    }

    func testWhenUserUsesFireButtonAndThenTogglesProtectionsItSendsFireButtonAndTogglePrivacyControlsEvent() {
        monitor.handleAction(.burn)
        monitor.handleAction(.toggleProtections)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first!, .fireButtonAndTogglePrivacyControls)
    }

    func testWhenUserUsesFireButtonThenOpensSettingsThenReopensAppItSendsFireButtonAndRestartEvent() {
        monitor.handleAction(.burn)
        monitor.handleAction(.openSettings)
        monitor.handleAction(.reopenApp)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first!, .fireButtonAndRestart)
    }

    func testWhenUserUsesFireButtonThenRefreshesThenReopensAppItSendsTwoEvents() {
        monitor.handleAction(.burn)
        monitor.handleAction(.refresh)
        monitor.handleAction(.reopenApp)
        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events[0], .reloadAndRestart)
        XCTAssertEqual(events[1], .fireButtonAndRestart)
    }

    func testWhenUserRefreshesThenReopensAppThenUsesFireButtonThenItSendsThreeEvents() {
        monitor.handleAction(.refresh)
        monitor.handleAction(.burn)
        monitor.handleAction(.reopenApp)
        XCTAssertEqual(events.count, 3)
        XCTAssertEqual(events[0], .reloadAndFireButton)
        XCTAssertEqual(events[1], .reloadAndRestart)
        XCTAssertEqual(events[2], .fireButtonAndRestart)
    }

    // Not expecting any events

    func testWhenUserUsesFireButtonAndThenRefreshesItShouldNotSendAnyEvent() {
        monitor.handleAction(.burn)
        monitor.handleAction(.refresh)
        XCTAssertTrue(events.isEmpty)
    }

    // Timing

    func testFireReloadTwiceEventOnlyIfItHappenedWithin10seconds() {
        let date = Date()
        monitor.handleAction(.refresh, date: date)
        monitor.handleAction(.refresh, date: date + 10) // 10 seconds after the first event
        XCTAssertTrue(events.isEmpty)
        monitor.handleAction(.refresh, date: date + 15) // 5 seconds after the second event
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first!, .reloadTwice)
    }

    func testFireReloadAndRestartEventOnlyIfItHappenedWithin30seconds() {
        let date = Date()
        monitor.handleAction(.refresh, date: date)
        monitor.handleAction(.reopenApp, date: date + 30) // 30 seconds after the first event
        XCTAssertTrue(events.isEmpty)
        monitor.handleAction(.refresh, date: date + 30)
        monitor.handleAction(.reopenApp, date: date + 50) // 20 seconds after the second event
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first!, .reloadAndRestart)
    }

    func testFireButtonAndRestartEventOnlyIfItHappenedWithin30seconds() {
        let date = Date()
        monitor.handleAction(.burn, date: date)
        monitor.handleAction(.reopenApp, date: date + 30) // 30 seconds after the first event
        XCTAssertTrue(events.isEmpty)
        monitor.handleAction(.burn, date: date + 30)
        monitor.handleAction(.reopenApp, date: date + 50) // 20 seconds after the second event
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first!, .fireButtonAndRestart)
    }

}
