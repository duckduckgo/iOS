//
//  MockWaitlistRequest.swift
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

public struct MockWaitlistRequest: WaitlistRequest {

    public static func failure() -> MockWaitlistRequest {
        return MockWaitlistRequest(joinResult: .failure(.noData),
                                   statusResult: .failure(.noData),
                                   inviteCodeResult: .failure(.noData))
    }

    public static func returning(_ joinResult: WaitlistJoinResult) -> MockWaitlistRequest {
        return MockWaitlistRequest(joinResult: joinResult,
                                   statusResult: .success(.init(timestamp: 0)),
                                   inviteCodeResult: .failure(.noData))
    }

    public init(
        joinResult: WaitlistJoinResult,
        statusResult: Result<WaitlistResponse.Status, WaitlistResponse.StatusError>,
        inviteCodeResult: Result<WaitlistResponse.InviteCode, WaitlistResponse.InviteCodeError>
    ) {
        self.joinResult = joinResult
        self.statusResult = statusResult
        self.inviteCodeResult = inviteCodeResult
    }

    public let joinResult: WaitlistJoinResult
    public let statusResult: Result<WaitlistResponse.Status, WaitlistResponse.StatusError>
    public let inviteCodeResult: Result<WaitlistResponse.InviteCode, WaitlistResponse.InviteCodeError>

    public func joinWaitlist(completionHandler: @escaping WaitlistJoinCompletion) {
        completionHandler(joinResult)
    }

    public func joinWaitlist() async -> WaitlistJoinResult {
        return joinResult
    }

    public func getWaitlistStatus(completionHandler: @escaping (Result<WaitlistResponse.Status, WaitlistResponse.StatusError>) -> Void) {
        completionHandler(statusResult)
    }

    public func getInviteCode(token: String, completionHandler: @escaping (Result<WaitlistResponse.InviteCode, WaitlistResponse.InviteCodeError>) -> Void) {
        completionHandler(inviteCodeResult)
    }

}
