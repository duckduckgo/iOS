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
import LinkPresentation
import Core

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
        case openNotificationSettings
        case openShareSheet
        case copyDownloadURLToPasteboard
        case copyInviteCodeToPasteboard
    }
    
    enum NotificationPermissionState {
        case notificationAllowed
        case notificationsDisabled
    }
    
    @Published var viewState: ViewState
    @Published var showShareSheet = false
    
    private let waitlistRequest: WaitlistRequest
    private let waitlistStorage: MacBrowserWaitlistStorage
    private let notificationService: NotificationService

    init(waitlistRequest: WaitlistRequest = ProductWaitlistRequest(product: .macBrowser),
         waitlistStorage: MacBrowserWaitlistStorage = MacBrowserWaitlistKeychainStore(),
         notificationService: NotificationService = UNUserNotificationCenter.current()) {
        self.waitlistRequest = waitlistRequest
        self.waitlistStorage = waitlistStorage
        self.notificationService = notificationService
        
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
    
    func updateViewState() {
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
        let notificationSettings = await UNUserNotificationCenter.current().notificationSettings()
        
        if notificationSettings.authorizationStatus == .denied {
            self.viewState = .joinedQueue(.notificationsDisabled)
        } else {
            self.viewState = .joinedQueue(.notificationAllowed)
        }
    }
    
    func perform(action: ViewAction) async {
        switch action {
        case .joinQueue: await joinQueue()
        case .openNotificationSettings: openNotificationSettings()
        case .openShareSheet: openShareSheet()
        case .copyDownloadURLToPasteboard: copyDownloadUrlToClipboard()
        case .copyInviteCodeToPasteboard: copyInviteCodeToClipboard()
        }
    }

    private func joinQueue() async {
        self.viewState = .joiningQueue

        let waitlistJoinResult = await waitlistRequest.joinWaitlist()
        
        switch waitlistJoinResult {
        case .success(let joinResponse):
            waitlistStorage.store(waitlistToken: joinResponse.token)
            waitlistStorage.store(waitlistTimestamp: joinResponse.timestamp)
        case .failure:
            self.viewState = .notJoinedQueue
            return
        }

        await promptForNotifications()
    }
    
    private func promptForNotifications() async {
        do {
            let permissionGranted = try await notificationService.requestAuthorization(options: [.alert])
            
            if permissionGranted {
                self.viewState = .joinedQueue(.notificationAllowed)
                MacBrowserWaitlist.shared.scheduleBackgroundRefreshTask()
            } else {
                self.viewState = .joinedQueue(.notificationsDisabled)
            }
        } catch {
            self.viewState = .joinedQueue(.notificationsDisabled)
        }
    }
    
    private func openNotificationSettings() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
            UIApplication.shared.open(appSettings)
        }
    }
    
    private func openShareSheet() {
        self.showShareSheet = true
    }
    
    private func copyDownloadUrlToClipboard() {
        UIPasteboard.general.url = AppUrls().macBrowserDownloadURL
    }
    
    private func copyInviteCodeToClipboard() {
        guard let inviteCode = waitlistStorage.getWaitlistInviteCode() else {
            assertionFailure("Failed to get waitlist invite code when copying")
            return
        }
        
        UIPasteboard.general.string = inviteCode
    }
    
    func createShareSheetActivityItems() -> [Any] {
        guard let inviteCode = waitlistStorage.getWaitlistInviteCode() else {
            assertionFailure("Failed to get invite code when creating share sheet")
            return []
        }

        let linkMetadata = MacWaitlistLinkMetadata(inviteCode: inviteCode)

        return [linkMetadata]
    }
    
}

private final class MacWaitlistLinkMetadata: NSObject, UIActivityItemSource {
    
    fileprivate let metadata: LPLinkMetadata = {
        let metadata = LPLinkMetadata()
        metadata.originalURL = AppUrls().macBrowserDownloadURL
        metadata.url = metadata.originalURL
        metadata.title = UserText.macWaitlistShareSheetTitle
        metadata.imageProvider = NSItemProvider(object: UIImage(named: "MacWaitlistShareSheetLogo")!)

        return metadata
    }()
    
    private let inviteCode: String
    
    init(inviteCode: String) {
        self.inviteCode = inviteCode
    }
    
    func activityViewControllerLinkMetadata(_: UIActivityViewController) -> LPLinkMetadata? {
        return self.metadata
    }
    
    public func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
        return self.metadata.originalURL as Any
    }

    public func activityViewController(_: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        guard let type = activityType else {
            return self.metadata.originalURL as Any
        }

        switch type {
        case .message, .mail:
            return UserText.macWaitlistShareSheetMessage(code: inviteCode)
        default:
            return self.metadata.originalURL as Any
        }
    }
    
}

struct ActivityViewController: UIViewControllerRepresentable {

    var activityItems: [Any]
    var applicationActivities: [UIActivity]?

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) { }

}
