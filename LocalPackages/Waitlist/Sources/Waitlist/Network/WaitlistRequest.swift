//
//  WaitlistRequest.swift
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

import Foundation

public enum WaitlistResponse {

    // MARK: Join

    public struct Join: Decodable {
        public let token: String
        public let timestamp: Int

        public init(token: String, timestamp: Int) {
            self.token = token
            self.timestamp = timestamp
        }
    }

    public enum JoinError: Error {
        case failed
        case noData
    }

    // MARK: Status

    public struct Status: Decodable {
        public let timestamp: Int

        public init(timestamp: Int) {
            self.timestamp = timestamp
        }
    }

    public enum StatusError: Error {
        case failed
        case noData
    }

    // MARK: Invite Code

    public struct InviteCode: Decodable {
        public let code: String

        public init(code: String) {
            self.code = code
        }
    }

    public enum InviteCodeError: Error {
        case failed
        case noData
    }

}

public typealias WaitlistJoinResult = Result<WaitlistResponse.Join, WaitlistResponse.JoinError>
public typealias WaitlistJoinCompletion = (Result<WaitlistResponse.Join, WaitlistResponse.JoinError>) -> Void

public protocol WaitlistRequest {

    func joinWaitlist(completionHandler: @escaping WaitlistJoinCompletion)
    func joinWaitlist() async -> WaitlistJoinResult

    func getWaitlistStatus(completionHandler: @escaping (Result<WaitlistResponse.Status, WaitlistResponse.StatusError>) -> Void)
    func getInviteCode(token: String, completionHandler: @escaping (Result<WaitlistResponse.InviteCode, WaitlistResponse.InviteCodeError>) -> Void)

}
