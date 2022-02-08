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
    
    // MARK: - Invite Code Screen
    
    public static let macWaitlistInviteScreenSubtitle = NSLocalizedString("mac-waitlist.invite-screen.subtitle", value: "Ready to start browsing privately on Mac?", comment: "Subtitle for the Mac Waitlist Invite screen")
    
    public static let macWaitlistInviteScreenStep1 = NSLocalizedString("mac-waitlist.invite-screen.step-1", value: "Step 1", comment: "Step 1")

    public static let macWaitlistInviteScreenStep2 = NSLocalizedString("mac-waitlist.invite-screen.step-2", value: "Step 2", comment: "Step 2")
    
}
// swiftlint:enable line_length
