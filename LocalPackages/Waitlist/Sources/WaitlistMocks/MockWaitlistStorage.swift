//
//  MockWaitlistStorage.swift
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

public class MockWaitlistStorage: WaitlistStorage {

    public init() {}

    private var token: String?
    private var timestamp: Int?
    private var code: String?

    public func getWaitlistToken() -> String? {
        return token
    }

    public func getWaitlistTimestamp() -> Int? {
        return timestamp
    }

    public func getWaitlistInviteCode() -> String? {
        return code
    }

    public func store(waitlistToken: String) {
        token = waitlistToken
    }

    public func store(waitlistTimestamp: Int) {
        timestamp = waitlistTimestamp
    }

    public func store(inviteCode: String) {
        code = inviteCode
    }

    public func deleteWaitlistState() {
        token = nil
        timestamp = nil
        code = nil
    }

}
