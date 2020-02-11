//
//  LocalNotifications.swift
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
import UIKit
import Core
import UserNotifications
import os.log

class LocalNotifications: NSObject {
    
    static let shared = LocalNotifications()
    
    override init() {
        super.init()
        
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge ]) { (enabled, _) in
            DispatchQueue.main.async {
                completion(enabled)
            }
        }
    }
    
    func checkPermissions(completion: @escaping (UNAuthorizationStatus, UNNotificationSetting) -> Void) {
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus, settings.alertSetting)
            }
        }
    }
    
    func cancelNotifications(withIdentifiers identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func scheduleNotification(title: String,
                              body: String = "",
                              identifier: String,
                              timeInterval: TimeInterval) {
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        scheduleNotification(title: title, body: body, identifier: identifier, trigger: trigger)
    }
        
    private func scheduleNotification(title: String,
                                      body: String = "",
                                      identifier: String,
                                      trigger: UNNotificationTrigger) {
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.badge = 1
        
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                os_log("Failed to schedule notification. %s", log: generalLog, type: .debug, error.localizedDescription)
            }
        }
    }
}

extension LocalNotifications: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
                
        completionHandler()
    }
}
