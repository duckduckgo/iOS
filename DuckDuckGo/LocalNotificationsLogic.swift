//
//  LocalNotificationsLogic.swift
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
import Core
import UIKit
import UserNotifications

protocol NotificationsStore {
    
    var notificationsEnabled: Bool { get set }
    
    func scheduleStatus(for notification: LocalNotificationsLogic.Notification) -> LocalNotificationsLogic.ScheduleStatus?
    
    func didSchedule(notification: LocalNotificationsLogic.Notification, date: Date)
    func didFire(notification: LocalNotificationsLogic.Notification)
    
    func didCancel(notification: LocalNotificationsLogic.Notification)

}

protocol LocalNotificationsLogicDelegate: class {
    
    func displayHomeHowInstructions(for: LocalNotificationsLogic)
}

// swiftlint:disable line_length

class LocalNotificationsLogic {
    
    struct Constants {
        static let privacyNotificationDelay: TimeInterval = 15 * 60
        static let privacyNotificationInfoTreshold = 2
    }
    
    struct Keys {
        static let authorization = "au"
        static let alert = "al"
    }
    
    enum Notification: String {
        case privacy = "privacyNotification"
        case homeRow = "homeRowNotification"
        
        var identifier: String {
            return rawValue
        }
        
        var settingsKey: String {
            switch self {
            case .privacy:
                return "privacyNotificationSettingsKey"
            case .homeRow:
                return "homeRowNotificationSettingsKey"
            }
        }
    }
    
    enum ScheduleStatus: Codable {
        case scheduled(Date)
        case fired
        
        // swiftlint:disable nesting
        private enum CodingKeys: String, CodingKey {
            case first
            case second
        }
        
        private enum CodingError: Error {
            case unknownValue
        }
        // swiftlint:enable nesting
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            if let value = try? container.decode(String.self, forKey: .first), value == "fired" {
                self = .fired
                return
            }
            
            if let value = try? container.decode(Date.self, forKey: .second) {
                self = .scheduled(value)
                return
            }
            
            throw CodingError.unknownValue
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            switch self {
            case .fired:
                try container.encode("fired", forKey: .first)
            case .scheduled(let date):
                try container.encode(date, forKey: .second)
            }
        }
    }
    
    weak var delegate: LocalNotificationsLogicDelegate?
    private var store: NotificationsStore = AppUserDefaults()
    private let variantManager: VariantManager
    
    init(variantManager: VariantManager = DefaultVariantManager()) {
        self.variantManager = variantManager
    }
    
    func didUpdateNotificationsPermissions(enabled: Bool) {
        store.notificationsEnabled = enabled
    }
    
    func didEnterApplication(currentDate: Date = Date()) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        markOverdueNotificationsAsFired(currentDate: currentDate)
        
        if let privacyStatus = store.scheduleStatus(for: .privacy),
            case ScheduleStatus.scheduled = privacyStatus {
            cancelPrivacyNotification()
        }
    }
    
    func didSelectNotification(withIdentifier identifier: String) {
        if let notification = Notification(rawValue: identifier) {
            switch notification {
            case .privacy:
                Pixel.fire(pixel: .privacyNotificationOpened)
            case .homeRow:
                Pixel.fire(pixel: .homeRowNotificationOpened)
                delegate?.displayHomeHowInstructions(for: self)
            }
        }
    }

    private func markOverdueNotificationsAsFired(currentDate: Date) {
        for notification in [Notification.privacy, Notification.homeRow] {
            if let status = store.scheduleStatus(for: notification),
                case let ScheduleStatus.scheduled(date) = status,
                date < currentDate {
                store.didFire(notification: notification)
                
                let pixel: PixelName
                switch notification {
                case .privacy:
                    pixel = .privacyNotificationFired
                case .homeRow:
                    pixel = .homeRowNotificationFired
                }
                
                LocalNotifications.shared.checkPermissions { (authorization, alertSettings) in
                    let parameters = [Keys.authorization: String(authorization.rawValue),
                                      Keys.alert: String(alertSettings.rawValue)]
                    Pixel.fire(pixel: pixel, withAdditionalParameters: parameters)
                }
            }
        }
    }
    
    private func cancelPrivacyNotification() {
        LocalNotifications.shared.cancelNotifications(withIdentifiers: [Notification.privacy.identifier])
        store.didCancel(notification: .privacy)
    }
    
    func willLeaveApplication() {
        
        if variantManager.isSupported(feature: .dayZeroNotification),
            store.notificationsEnabled,
            store.scheduleStatus(for: .privacy) == nil {
            schedulePrivacyNotification()
        }
        
        if variantManager.isSupported(feature: .dayOneNotification),
            store.notificationsEnabled,
            store.scheduleStatus(for: .homeRow) == nil {
            scheduleHomeRowNotification()
        }
    }
        
    private func schedulePrivacyNotification() {
        let privacyData = PrivacyReportDataSource()
        
        let title: String
        let body: String
        //Note: when experiment is done, user-facing strings will be extracted to UserText
        if privacyData.trackersCount < Constants.privacyNotificationInfoTreshold {
            title = "Ready to take back your privacy?"
            body = "Keep browsing with DuckDuckGo to block trackers and encrypt connections."
        } else {
            title = "Success! The internet just got less creepy."
            body = "While using DuckDuckGo you blocked \(privacyData.trackersCount) trackers and secured \(privacyData.httpsUpgradesCount) unencrypted connections."
        }
        
        LocalNotifications.shared.scheduleNotification(title: title,
                                                       body: body,
                                                       identifier: Notification.privacy.identifier,
                                                       timeInterval: Constants.privacyNotificationDelay)
        store.didSchedule(notification: .privacy, date: Date(timeIntervalSinceNow: Constants.privacyNotificationDelay))
    }
    
    func fireDateForHomeRowNotification(currentDate: Date = Date()) -> Date? {
        var components = Calendar.current.dateComponents(in: .current, from: currentDate)
        
        if let hour = components.hour, hour > 3 {
            components.day = (components.day ?? 0) + 1
        }
        
        components.hour = 10
        components.minute = 0
        components.second = 0

        let earliestDate = currentDate.addingTimeInterval(12 * 60 * 60)
        
        guard var date = Calendar.current.date(from: components) else { return nil }
        
        if date < earliestDate {
            date = earliestDate
        }
        
        return date
    }
    
    private func scheduleHomeRowNotification() {
        
        if let date = fireDateForHomeRowNotification() {
            let title = "Prioritize your privacy"
            let body = "Move the DuckDuckGo app to your home dock for easy access to private browsing."
            
            LocalNotifications.shared.scheduleNotification(title: title,
                                                           body: body,
                                                           identifier: Notification.homeRow.identifier,
                                                           timeInterval: date.timeIntervalSinceNow)
            
            store.didSchedule(notification: .homeRow, date: date)
        }
    }
}

// swiftlint:enable line_length
