//
//  LocalNotificationsLogicTests.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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
import UserNotifications

import XCTest
@testable import DuckDuckGo

class LocalNotificationsLogicTests: XCTestCase {
    
    let center = UNUserNotificationCenter.current()
    var store: NotificationsStore = AppUserDefaults()
    
    var mockManager = MockVariantManager(isSupportedReturns: true, currentVariant: nil)
    
    override func setUp() {
        store.notificationsEnabled = true
        cleanUp()
    }
    
    override func tearDown() {
        cleanUp()
        store.notificationsEnabled = false
    }
    
    func cleanUp() {
        center.removeAllPendingNotificationRequests()
        store.didCancel(notification: .privacy)
        store.didCancel(notification: .homeRow)
    }
    
    func testWhenLeavingTheAppThenNotificationsAreScheduled() {
        let logic = LocalNotificationsLogic(variantManager: mockManager)
        
        let noNotifications = expectation(description: "There are no notifications scheduled")
        center.getPendingNotificationRequests { (notifications) in
            XCTAssertTrue(notifications.isEmpty)
            noNotifications.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        switch store.scheduleStatus(for: .homeRow) {
        case .none: break
        default: XCTFail("No notification should be scheduled")
        }
        
        switch store.scheduleStatus(for: .privacy) {
        case .none: break
        default: XCTFail("No notification should be scheduled")
        }
        
        logic.willLeaveApplication()
        
        let notificationsScheduled = expectation(description: "There are notifications scheduled")
        center.getPendingNotificationRequests { (notifications) in
            
            let identifiers = Set(notifications.map { $0.identifier })
            XCTAssertEqual(identifiers, Set([LocalNotificationsLogic.Notification.privacy.identifier,
                LocalNotificationsLogic.Notification.homeRow.identifier]))
            
            notificationsScheduled.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        switch store.scheduleStatus(for: .homeRow) {
        case .some(.scheduled): break
        default: XCTFail("Expected scheduled notification")
        }
        
        switch store.scheduleStatus(for: .privacy) {
        case .some(.scheduled): break
        default: XCTFail("Expected scheduled notification")
        }
    }
    
    func testWhenPermissionsIsDeniedAndLeavingTheAppThenNotificationsAreNotScheduled() {
        let logic = LocalNotificationsLogic(variantManager: mockManager)
        let noNotifications = expectation(description: "There are no notifications scheduled")
        center.getPendingNotificationRequests { (notifications) in
            XCTAssertTrue(notifications.isEmpty)
            noNotifications.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        switch store.scheduleStatus(for: .homeRow) {
        case .none: break
        default: XCTFail("No notification should be scheduled")
        }
        
        switch store.scheduleStatus(for: .privacy) {
        case .none: break
        default: XCTFail("No notification should be scheduled")
        }
        
        logic.didUpdateNotificationsPermissions(enabled: false)
        logic.willLeaveApplication()
        
        let notificationsScheduled = expectation(description: "There are no notifications scheduled")
        center.getPendingNotificationRequests { (notifications) in
            XCTAssertTrue(notifications.isEmpty)
            notificationsScheduled.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        switch store.scheduleStatus(for: .homeRow) {
        case .some(.scheduled): XCTFail("No notification should be scheduled")
        default: break
        }
        
        switch store.scheduleStatus(for: .privacy) {
        case .some(.scheduled): XCTFail("No notification should be scheduled")
        default: break
        }
    }
    
    func testWhenAppIsOpenedAndPrivacyNotificationIsScheduledThenItIsCancelled() {
        let logic = LocalNotificationsLogic(variantManager: mockManager)

        logic.willLeaveApplication()
        
        switch store.scheduleStatus(for: .privacy) {
        case .some(.scheduled): break
        case .some(.fired): XCTFail("Privacy notification should not be already fired")
        default: XCTFail("Privacy notification should be scheduled")
        }
        
        logic.didEnterApplication()
        
        switch store.scheduleStatus(for: .privacy) {
        case .some(.scheduled): XCTFail("Privacy notification should not be scheduled")
        case .some(.fired): XCTFail("Privacy notification should not be already fired")
        default: break
        }
        
        switch store.scheduleStatus(for: .homeRow) {
        case .some(.scheduled): break
        default: XCTFail("Expected scheduled notification")
        }
        
        let exp = expectation(description: "Only home row notification is scheduled")
        center.getPendingNotificationRequests { (notifications) in
            
            let identifiers = Set(notifications.map { $0.identifier })
            XCTAssertEqual(identifiers, Set([LocalNotificationsLogic.Notification.homeRow.identifier]))
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWhenAppIsOpenedAndNotificationWasSupposedToBeFiredThenItIsMarkedAsFired() {
        
        let logic = LocalNotificationsLogic(variantManager: mockManager)

        logic.willLeaveApplication()
        logic.didEnterApplication(currentDate: Date().addingTimeInterval(60 * 60))
        
        switch store.scheduleStatus(for: .privacy) {
        case .some(.fired): break
        default: XCTFail("Expected fired notification")
        }
        
        switch store.scheduleStatus(for: .homeRow) {
        case .some(.scheduled): break
        default: XCTFail("Expected scheduled notification")
        }
        
        logic.didEnterApplication(currentDate: Date().addingTimeInterval(25 * 60 * 60))
        
        switch store.scheduleStatus(for: .homeRow) {
        case .some(.fired): break
        default: XCTFail("Expected fired notification")
        }
    }
    
    func testWhenShedulingHomeRowNotificationThenTimeShouldMatchNextDay() {
        
        validateThat(month: 1, day: 1, hour: 10,
                     scheduledMonth: 1, scheduledDay: 2, scheduledHour: 10)
        
        validateThat(month: 1, day: 1, hour: 3,
                     scheduledMonth: 1, scheduledDay: 1, scheduledHour: 15)
        
        validateThat(month: 1, day: 1, hour: 18,
                     scheduledMonth: 1, scheduledDay: 2, scheduledHour: 10)
        
        validateThat(month: 1, day: 1, hour: 6,
                     scheduledMonth: 1, scheduledDay: 2, scheduledHour: 10)
        
        validateThat(month: 1, day: 31, hour: 10,
                     scheduledMonth: 2, scheduledDay: 1, scheduledHour: 10)
        
        validateThat(month: 12, day: 31, hour: 10,
                     matchScheduledYear: 2020, scheduledMonth: 1, scheduledDay: 1, scheduledHour: 10)
    }
    
    // swiftlint:disable function_parameter_count
    // swiftlint:disable line_length
    private func validateThat(year: Int = 2019, month: Int, day: Int, hour: Int, matchScheduledYear scheduledYear: Int = 2019, scheduledMonth: Int, scheduledDay: Int, scheduledHour: Int ) {
        let logic = LocalNotificationsLogic(variantManager: mockManager)

        let calendar = Calendar.current
        
        let dateComponents = DateComponents(calendar: calendar, year: year, month: month, day: day, hour: hour, minute: 0, second: 0)
        let date = dateComponents.date!
        
        let fireDate = logic.fireDateForHomeRowNotification(currentDate: date)!.1
        let components = calendar.dateComponents(in: calendar.timeZone, from: fireDate)
        
        XCTAssertEqual(components.year, scheduledYear)
        XCTAssertEqual(components.hour, scheduledHour)
        XCTAssertEqual(components.day, scheduledDay)
        XCTAssertEqual(components.month, scheduledMonth)
    }
    // swiftlint:enable function_parameter_count
    // swiftlint:enable line_length
    
    func testWhenDay0EnabledThenItIsScheduled() {
        mockManager.isSupportedBlock = { feature in
            return feature == .dayZeroNotification
        }
        
        let logic = LocalNotificationsLogic(variantManager: mockManager)
        
        let noNotifications = expectation(description: "There are no notifications scheduled")
        center.getPendingNotificationRequests { (notifications) in
            XCTAssertTrue(notifications.isEmpty)
            noNotifications.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        switch store.scheduleStatus(for: .homeRow) {
        case .none: break
        default: XCTFail("No notification should be scheduled")
        }
        
        switch store.scheduleStatus(for: .privacy) {
        case .none: break
        default: XCTFail("No notification should be scheduled")
        }
        
        logic.willLeaveApplication()
        
        let notificationsScheduled = expectation(description: "There are notifications scheduled")
        center.getPendingNotificationRequests { (notifications) in
            
            let identifiers = Set(notifications.map { $0.identifier })
            XCTAssertEqual(identifiers, Set([LocalNotificationsLogic.Notification.privacy.identifier]))
            
            notificationsScheduled.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        switch store.scheduleStatus(for: .privacy) {
        case .some(.scheduled): break
        default: XCTFail("Expected scheduled notification")
        }
        
        switch store.scheduleStatus(for: .homeRow) {
        case .none: break
        default: XCTFail("Expected scheduled notification")
        }
    }
    
    func testWhenDay1EnabledThenItIsScheduled() {
        mockManager.isSupportedBlock = { feature in
            return feature == .dayOneNotification
        }
        
        let logic = LocalNotificationsLogic(variantManager: mockManager)
        
        let noNotifications = expectation(description: "There are no notifications scheduled")
        center.getPendingNotificationRequests { (notifications) in
            XCTAssertTrue(notifications.isEmpty)
            noNotifications.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        switch store.scheduleStatus(for: .homeRow) {
        case .none: break
        default: XCTFail("No notification should be scheduled")
        }
        
        switch store.scheduleStatus(for: .privacy) {
        case .none: break
        default: XCTFail("No notification should be scheduled")
        }
        
        logic.willLeaveApplication()
        
        let notificationsScheduled = expectation(description: "There are notifications scheduled")
        center.getPendingNotificationRequests { (notifications) in
            
            let identifiers = Set(notifications.map { $0.identifier })
            XCTAssertEqual(identifiers, Set([LocalNotificationsLogic.Notification.homeRow.identifier]))
            
            notificationsScheduled.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        switch store.scheduleStatus(for: .privacy) {
        case .none: break
        default: XCTFail("Expected scheduled notification")
        }
        
        switch store.scheduleStatus(for: .homeRow) {
        case .some(.scheduled): break
        default: XCTFail("Expected scheduled notification")
        }
    }

}
