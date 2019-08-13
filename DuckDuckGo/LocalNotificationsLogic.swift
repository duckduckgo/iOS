//
//  LocalNotificationsLogic.swift
//  DuckDuckGo
//
//  Created by Bartek on 12/08/2019.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import Foundation

class LocalNotificationsLogic {
    
    enum Notification: String {
        case privacy = "privacyNotification"
        case homeRow = "homeRowNotification"
        
        var identifier: String {
            return rawValue
        }
        
        var settingsKey: String {
            switch self {
            case .privacy:
                return "privacyNotification"
            case .homeRow:
                return "homeRowNotification"
            }
        }
    }
    
    struct Constants {
        static let privacyNotificationDelay: TimeInterval = 15 * 60
    }
    
    func didEnterApplication() {
        guard !didFireHomeRowNotification else { return }
        
    }
    
    func didEnterApplicationFromNotification(with identifier: String) {
        if let notification = Notification(rawValue: identifier) {
            switch notification {
            case .privacy:
                didFirePrivacyNotification = true
            case .homeRow:
                didFireHomeRowNotification = true
            }
        }
    }
    
    func willLeaveApplication() {
        // schedule
    }
    
    private var didFirePrivacyNotification: Bool = false
    
    private var didFireHomeRowNotification: Bool = false
        
    private func schedulePrivacyNotification() {
        
    }
    
    private func scheduleHomeRowNotification() {
        
    }
    
}
