//
//  UserText+MacWaitlist.swift
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

import Foundation

// swiftlint:disable line_length
extension UserText {
    
    static let macWaitlistTitle = NSLocalizedString("mac-waitlist.title", value: "DuckDuckGo Desktop App", comment: "Title for the Mac Waitlist feature")
    
    static let macWaitlistPrivacyDisclaimer = NSLocalizedString("mac-waitlist.privacy-disclaimer",
                                                                       value: "You won’t need to share any personal information to join the waitlist. You’ll secure your place in line with a timestamp that exists solely on your device so we can notify you when it’s your turn.",
                                                                       comment: "Privacy disclaimer for the Mac Waitlist feature")
    
    public static let macWaitlistSummary = NSLocalizedString("mac-browser.waitlist.summary", value: "The DuckDuckGo Privacy App for Mac has the speed you need, the browsing features you expect, and comes packed with our best-in-class privacy essentials.", comment: "Summary text for the macOS browser waitlist")
    
    public static let macWaitlistInviteCode = NSLocalizedString("mac-browser.waitlist.invite-code", value: "Invite Code", comment: "Label text for the invite code")
    
    public static let macWaitlistJoinedWithNotifications = NSLocalizedString("mac-browser.waitlist.joined.notifications-enabled",
                                                                                    value: "We’ll send you a notification when your copy of DuckDuckGo for Mac is ready for download.",
                                                                                    comment: "Label text for the Joined Waitlist state with notifications enabled")
    
    public static let macWaitlistJoinedWithoutNotifications = NSLocalizedString("mac-browser.waitlist.joined.notifications-declined",
                                                                                    value: "Your invite to try DuckDuckGo for Mac will arrive here. Check back soon, or we can send you a notification when it’s your turn.",
                                                                                    comment: "Label text for the Joined Waitlist state with notifications declined")
    
    public static func macWaitlistLearnMore(learnMoreString: String) -> String {
        let message = NSLocalizedString("mac-browser.waitlist.learn-more", value: "%@ about the beta.", comment: "Footer text for the macOS waitlist. Parameter is 'Learn more'.")
        return message.format(arguments: learnMoreString)
    }
    
    public static func macWaitlistJoinedWithNotificationSummary(learnMoreString: String) -> String {
        let message = NSLocalizedString("mac-browser.waitlist.joined.notification", value: "We’ll send you a notification when we're ready for you. %@.", comment: "Description text for the macOS waitlist. Parameter is 'Learn more.'")
        return message.format(arguments: learnMoreString)
    }

    public static let macWaitlistGetANotification = NSLocalizedString("mac-browser.waitlist.joined.no-notification.get-notification", value: "get a notification", comment: "Notification text for the macOS waitlist")
    
    public static func macWaitlistJoinedWithoutNotificationSummary(getNotifiedString: String, learnMoreString: String) -> String {
        let message =  NSLocalizedString("mac-browser.waitlist.joined.no-notification", value: "Your invite will show up here when we’re ready for you. Want to %@ when it arrives? %@ about the macOS browser beta.", comment: "First parameter is 'get a notification', second is 'Learn more'.")
        return message.format(arguments: getNotifiedString, learnMoreString)
    }
    
    // MARK: - Join Waitlist Screen
    
    static let macWaitlistTryDuckDuckGoForMac = NSLocalizedString("mac-waitlist.join-waitlist-screen.try-duckduckgo-for-mac", value: "Try DuckDuckGo for Mac!", comment: "Title for the Join Waitlist screen")
    
    static let macWaitlistJoin = NSLocalizedString("mac-waitlist.join-waitlist-screen.join", value: "Join the Private Waitlist", comment: "Title for the Join Waitlist screen")
    
    static let macWaitlistWindows = NSLocalizedString("mac-waitlist.join-waitlist-screen.windows", value: "Windows coming soon!", comment: "Disclaimer for the Join Waitlist screen")
    
    static let macWaitlistJoining = NSLocalizedString("mac-waitlist.join-waitlist-screen.joining", value: "Joining Waitlist...", comment: "Temporary status text for the Join Waitlist screen")
    
    // MARK: - Notifications
    
    static let macWaitlistNotificationTitle = NSLocalizedString("mac-waitlist.notification.title", value: "Get a notification when it’s your turn?", comment: "Text used for the notification title")
    
    static let macWaitlistNotificationMessage = NSLocalizedString("mac-waitlist.notification.message", value: "We’ll send you a notification when your copy of DuckDuckGo for Mac is ready for download", comment: "Text used for the notification message")
    
    static let macWaitlistNotificationNotifyMe = NSLocalizedString("mac-waitlist.notification.notify-me", value: "Notify Me", comment: "Confirmation text for the Mac Waitlist notification prompt")
    
    static let macWaitlistNotificationNoThanks = NSLocalizedString("mac-waitlist.notification.no-thanks", value: "No Thanks", comment: "Cancellation text for the Mac Waitlist notification prompt")
    
    public static let macWaitlistAvailableNotificationTitle = NSLocalizedString("mac-waitlist.available.notification.title", value: "DuckDuckGo for Mac is ready!", comment: "Title for the macOS waitlist notification")
    
    public static let macWaitlistAvailableNotificationBody = NSLocalizedString("mac-waitlist.available.notification.body", value: "Open your invite", comment: "Body text for the macOS waitlist notification")
    
    // MARK: - Queue Screen
    
    static let macWaitlistOnTheList = NSLocalizedString("mac-waitlist.queue-screen.on-the-list", value: "You’re on the list!", comment: "Title for the queue screen")
    
    // MARK: - Invite Code Screen
    
    static let macWaitlistYoureInvited = NSLocalizedString("mac-waitlist.invite-screen.youre-invited", value: "You’re Invited!", comment: "Title for the invite code screen")
    
    static let macWaitlistInviteScreenSubtitle = NSLocalizedString("mac-waitlist.invite-screen.subtitle", value: "Ready to start browsing privately on Mac?", comment: "Subtitle for the Mac Waitlist Invite screen")
    
    static let macWaitlistInviteScreenStep1Title = NSLocalizedString("mac-waitlist.invite-screen.step-1.title", value: "Step 1", comment: "Title on the invite screen")

    static let macWaitlistInviteScreenStep1Description = NSLocalizedString("mac-waitlist.invite-screen.step-1.description", value: "Visit this URL on your Mac to download:", comment: "Description on the invite screen")
    
    static let macWaitlistInviteScreenStep2Title = NSLocalizedString("mac-waitlist.invite-screen.step-2.title", value: "Step 2", comment: "Title on the invite screen")
    
    static let macWaitlistInviteScreenStep2Description = NSLocalizedString("mac-waitlist.invite-screen.step-2.description", value: "Open the file to install, then enter your invite code to unlock.", comment: "Description on the invite screen")
    
    static let macWaitlistCopy = NSLocalizedString("mac-waitlist.copy", value: "Copy", comment: "Title for the copy action")
    
    static let macWaitlistNotificationDisabled = NSLocalizedString("mac-waitlist.notification.disabled", value: "We can notify you when it’s your turn, but notifications are currently disabled for DuckDuckGo.", comment: "Text used for the Notifications Disabled state")
    
    // MARK: - Settings Screen
    
    static let macWaitlistAvailableForDownload = NSLocalizedString("mac-waitlist.settings.available-for-download", value: "Available for download on Mac", comment: "Title for the settings subtitle")
    
    static let macWaitlistSettingsOnTheList = NSLocalizedString("mac-waitlist.settings.on-the-list", value: "You’re on the list!", comment: "Title for the settings subtitle")
    
    static let macWaitlistBrowsePrivately = NSLocalizedString("mac-waitlist.settings.browse-privately", value: "Browse privately with our app for Mac", comment: "Title for the settings subtitle")
    
    // MARK: - Share Sheet
    
    static let macWaitlistShareSheetTitle = NSLocalizedString("mac-waitlist.share-sheet.title", value: "You’re Invited!", comment: "Title for the share sheet entry")
    
    static func macWaitlistShareSheetMessage(code: String) -> String {
        let message = """
        You're invited!
        
        Ready to start browsing privately on Mac?
        
        Step 1
        Visit this URL on your Mac to download:
        https://duckduckgo.com/mac
        
        Step 2
        Open the file to install, then enter your invite code to unlock.
        
        Invite code: %@
        """
        
        let localized = NSLocalizedString("mac-waitlist.share-sheet.message", value: message, comment: "Message used when sharing to iMessage. Parameter is an eight digit invite code.")
        return localized.format(arguments: code)
    }
    
}
// swiftlint:enable line_length
