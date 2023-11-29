//
//  TestWaitlist.swift
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
import Waitlist

public struct TestWaitlist: Waitlist {
    public static var shared: TestWaitlist = .init(store: MockWaitlistStorage(), request: MockWaitlistRequest.failure())

    public var isAvailable: Bool = true
    public var isWaitlistRemoved: Bool = false
    public var waitlistStorage: WaitlistStorage
    public var waitlistRequest: WaitlistRequest

    public init(store: WaitlistStorage, request: WaitlistRequest) {
        self.waitlistStorage = store
        self.waitlistRequest = request
    }

    public var settingsSubtitle: String = "subtitle"
    public var onBackgroundTaskSubmissionError: ((Error) -> Void)? = { _ in }

    public static var identifier: String = "mockIdentifier"
    public static var apiProductName: String = "mockApiProductName"
    public static var downloadURL: URL = URL(string: "https://duckduckgo.com")!
    public static var backgroundTaskName: String = "BG Task"

    public static var backgroundRefreshTaskIdentifier: String = "bgtask"
    public static var notificationIdentifier: String = "notification"
    public static var inviteAvailableNotificationTitle: String = "Title"
    public static var inviteAvailableNotificationBody: String = "Body"
}
