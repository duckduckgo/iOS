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
    
    public static let macWaitlistTitle = NSLocalizedString("mac-waitlist.title", value: "DuckDuckGo Desktop App", comment: "Title for the Mac Waitlist feature")
    
    public static let macWaitlistPrivacyDisclaimer = NSLocalizedString("mac-waitlist.privacy-disclaimer",
                                                                       value: "You won’t need to share any personal information to join the waitlist. You’ll secure your place in line with a timestamp that exists solely on your device so we can notify you when it’s your turn.",
                                                                       comment: "Privacy disclaimer for the Mac Waitlist feature")
    
    // MARK: - Join Waitlist Screen
    
    public static let macWaitlistTryDuckDuckGoForMac = NSLocalizedString("mac-waitlist.join-waitlist-screen.try-duckduckgo-for-mac", value: "Try DuckDuckGo for Mac!", comment: "Title for the Join Waitlist screen")
    
    public static let macWaitlistJoin = NSLocalizedString("mac-waitlist.join-waitlist-screen.join", value: "Join the Private Waitlist", comment: "Title for the Join Waitlist screen")
    
    public static let macWaitlistWindows = NSLocalizedString("mac-waitlist.join-waitlist-screen.windows", value: "Windows coming soon!", comment: "Disclaimer for the Join Waitlist screen")
    
    public static let macWaitlistJoining = NSLocalizedString("mac-waitlist.join-waitlist-screen.joining", value: "Joining Waitlist...", comment: "Temporary status text for the Join Waitlist screen")
    
    // MARK: - Queue Screen
    
    public static let macWaitlistOnTheList = NSLocalizedString("mac-waitlist.queue-screen.on-the-list", value: "You're on the list!", comment: "Title for the queue screen")
    
    // MARK: - Invite Code Screen
    
    public static let macWaitlistInviteScreenSubtitle = NSLocalizedString("mac-waitlist.invite-screen.subtitle", value: "Ready to start browsing privately on Mac?", comment: "Subtitle for the Mac Waitlist Invite screen")
    
    public static let macWaitlistInviteScreenStep1Title = NSLocalizedString("mac-waitlist.invite-screen.step-1.title", value: "Step 1", comment: "Title on the invite screen")

    public static let macWaitlistInviteScreenStep1Description = NSLocalizedString("mac-waitlist.invite-screen.step-1.description", value: "Visit this URL on your Mac to download:", comment: "Description on the invite screen")
    
    public static let macWaitlistInviteScreenStep2Title = NSLocalizedString("mac-waitlist.invite-screen.step-2.title", value: "Step 2", comment: "Title on the invite screen")
    
    public static let macWaitlistInviteScreenStep2Description = NSLocalizedString("mac-waitlist.invite-screen.step-2.description", value: "Open the file to install, then enter your invite code to unlock.", comment: "Description on the invite screen")
    
    public static let macWaitlistCopy = NSLocalizedString("mac-waitlist.copy", value: "Copy", comment: "Title for the copy action")
    
    // MARK: - Settings Screen
    
    public static let macWaitlistAvailableForDownload = NSLocalizedString("mac-waitlist.settings.available-for-download", value: "Available for download on Mac", comment: "Title for the settings subtitle")
    
    public static let macWaitlistSettingsOnTheList = NSLocalizedString("mac-waitlist.settings.on-the-list", value: "You're on the list!", comment: "Title for the settings subtitle")
    
    public static let macWaitlistBrowsePrivately = NSLocalizedString("mac-waitlist.settings.browse-privately", value: "Browse privately with our app for Mac", comment: "Title for the settings subtitle")
    
}
// swiftlint:enable line_length
