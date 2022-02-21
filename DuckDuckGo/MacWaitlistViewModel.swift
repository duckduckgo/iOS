//
//  MacWaitlistViewModel.swift
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

import UIKit
import SwiftUI
import Combine

@MainActor
final class MacWaitlistViewModel: ObservableObject {
    
    enum ViewState: Equatable {
        case notJoinedQueue
        case joiningQueue
        case joinedQueue(NotificationPermissionState)
        case invited(inviteCode: String)
    }
    
    enum ViewAction: Equatable {
        case joinQueue
        case acceptNotifications
        case declineNotifications
        case requestNotificationPrompt
        case openNotificationSettings
        case openShareSheet
    }
    
    enum NotificationPermissionState {
        case notificationAllowed
        case notificationDenied
        case cannotPromptForNotification
    }
    
    @Published var viewState: ViewState
    @Published var showNotificationPrompt = false
    @Published var showShareSheet = false
    
    private let waitlistRequest: WaitlistRequesting
    private let waitlistStorage: MacBrowserWaitlistStorage
    
    init(waitlistRequest: WaitlistRequesting = WaitlistRequest(product: .macBrowser),
         waitlistStorage: MacBrowserWaitlistStorage = MacBrowserWaitlistKeychainStore()) {
        self.waitlistRequest = waitlistRequest
        self.waitlistStorage = waitlistStorage
        
        if waitlistStorage.getWaitlistTimestamp() != nil, waitlistStorage.getWaitlistInviteCode() == nil {
            self.viewState = .joinedQueue(.notificationAllowed)
            
            Task {
                await checkNotificationPermissions()
            }
        } else if let inviteCode = waitlistStorage.getWaitlistInviteCode() {
            self.viewState = .invited(inviteCode: inviteCode)
        } else {
            self.viewState = .notJoinedQueue
        }
    }
    
    private func checkNotificationPermissions() async {
        if waitlistStorage.shouldReceiveNotifications() {
            self.viewState = .joinedQueue(.notificationAllowed)
        } else {
            let notificationSettings = await UNUserNotificationCenter.current().notificationSettings()
            
            if notificationSettings.authorizationStatus == .denied {
                self.viewState = .joinedQueue(.cannotPromptForNotification)
            } else {
                self.viewState = .joinedQueue(.notificationDenied)
            }
        }
    }
    
    func perform(action: ViewAction) {
        switch action {
        case .joinQueue: Task { await joinQueue() }
        case .acceptNotifications: Task { await acceptNotifications() }
        case .declineNotifications: declineNotifications()
        case .requestNotificationPrompt: requestNotificationPrompt()
        case .openNotificationSettings: openNotificationSettings()
        case .openShareSheet: openShareSheet()
        }
    }
    
    private func requestNotificationPrompt() {
        self.showNotificationPrompt = true
    }
    
    private func joinQueue() async {
        self.viewState = .joiningQueue

        let waitlistJoinResult = await waitlistRequest.joinWaitlist()
        
        switch waitlistJoinResult {
        case .success(let joinResponse):
            waitlistStorage.store(waitlistToken: joinResponse.token)
            waitlistStorage.store(waitlistTimestamp: joinResponse.timestamp)
        case .failure:
            print("DEBUG: Waitlist join error")
            self.viewState = .notJoinedQueue
            return
        }

        let notificationSettings = await UNUserNotificationCenter.current().notificationSettings()
        
        if notificationSettings.authorizationStatus == .denied {
            self.viewState = .joinedQueue(.cannotPromptForNotification)
        } else {
            self.showNotificationPrompt = true
        }
    }
    
    private func acceptNotifications() async {        
        do {
            let permissionGranted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert])
            
            if permissionGranted {
                self.waitlistStorage.store(shouldReceiveNotifications: true)
                self.viewState = .joinedQueue(.notificationAllowed)
            } else {
                self.viewState = .joinedQueue(.cannotPromptForNotification)
            }
        } catch {
            self.viewState = .joinedQueue(.cannotPromptForNotification)
        }
    }
    
    private func declineNotifications() {
        waitlistStorage.store(shouldReceiveNotifications: false)
        self.viewState = .joinedQueue(.notificationDenied)
    }
    
    private func openNotificationSettings() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
            UIApplication.shared.open(appSettings)
        }
    }
    
    private func openShareSheet() {
        self.showShareSheet = true
    }
    
    func createShareSheetActivityItems() -> [Any] {
        let message = shareSheetMessage(inviteCode: "FAKECODE")
        let url = URL(string: "https://duckduckgo.com/mac")!
        
        return [url, message]
    }
    
    private func shareSheetMessage(inviteCode: String) -> String {
        let message = """
        You're invited!
        
        Ready to start browsing privately on Mac?
        
        Step 1
        Visit this URL on your Mac to download:
        https://duckduckgo.com/mac
        
        Step 2
        Open the file to install, then enter your invite code to unlock.
        
        Invite code: \(inviteCode)
        """
        
        return message
    }
    
}

struct ActivityViewController: UIViewControllerRepresentable {

    var activityItems: [Any]
    var applicationActivities: [UIActivity]?

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController,
                                context: UIViewControllerRepresentableContext<ActivityViewController>) { }

}
