//
//  NotificationViewController.swift
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

import UIKit
import SwiftUI
import UserNotifications
import UserNotificationsUI
import Core
import Persistence

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    @IBOutlet var container: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appTrackingProtectionDatabase: CoreDataDatabase = AppTrackingProtectionDatabase.make()
        appTrackingProtectionDatabase.loadStore { context, error in
            guard context != nil else {
                if let error = error {
                    Pixel.fire(pixel: .appTPCouldNotLoadDatabase, error: error)
                } else {
                    Pixel.fire(pixel: .appTPCouldNotLoadDatabase)
                }

                Thread.sleep(forTimeInterval: 1)
                fatalError("Could not create AppTP database stack: \(error?.localizedDescription ?? "err")")
            }
        }
        
        let viewModel = AppTrackingProtectionNotificationViewModel(appTrackingProtectionDatabase: appTrackingProtectionDatabase)
        let notifView = AppTPSummaryNotifView(viewModel: viewModel)
        let hostingView = UIHostingController(rootView: notifView)
        self.addChild(hostingView)
        self.view.addSubview(hostingView.view)
        hostingView.didMove(toParent: self)
        
        // This ugliness is neccessary to support SwiftUI resizing the notification view
        hostingView.view.translatesAutoresizingMaskIntoConstraints = false
        hostingView.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        hostingView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        hostingView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        hostingView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func didReceive(_ notification: UNNotification) {
        
    }

}
