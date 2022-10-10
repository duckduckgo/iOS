//
//  MacBrowserWaitlistMocks.swift
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

import XCTest
@testable import DuckDuckGo

struct MockWaitlistRequest: WaitlistRequest {
    
    static func failure() -> MockWaitlistRequest {
        return MockWaitlistRequest(joinResult: .failure(.noData),
                                   statusResult: .failure(.noData),
                                   inviteCodeResult: .failure(.noData))
    }
    
    static func returning(_ joinResult: WaitlistJoinResult) -> MockWaitlistRequest {
        return MockWaitlistRequest(joinResult: joinResult,
                                   statusResult: .success(.init(timestamp: 0)),
                                   inviteCodeResult: .failure(.noData))
    }
    
    let joinResult: WaitlistJoinResult
    let statusResult: Result<WaitlistResponse.Status, WaitlistResponse.StatusError>
    let inviteCodeResult: Result<WaitlistResponse.InviteCode, WaitlistResponse.InviteCodeError>
    
    func joinWaitlist(completionHandler: @escaping WaitlistJoinCompletion) {
        completionHandler(joinResult)
    }
    
    func joinWaitlist() async -> WaitlistJoinResult {
        return joinResult
    }
    
    func getWaitlistStatus(completionHandler: @escaping (Result<WaitlistResponse.Status, WaitlistResponse.StatusError>) -> Void) {
        completionHandler(statusResult)
    }
    
    func getInviteCode(token: String, completionHandler: @escaping (Result<WaitlistResponse.InviteCode, WaitlistResponse.InviteCodeError>) -> Void) {
        completionHandler(inviteCodeResult)
    }
    
}

class MockWaitlistStorage: MacBrowserWaitlistStorage {
    
    private var token: String?
    private var timestamp: Int?
    private var code: String?
    
    func getWaitlistToken() -> String? {
        return token
    }
    
    func getWaitlistTimestamp() -> Int? {
        return timestamp
    }
    
    func getWaitlistInviteCode() -> String? {
        return code
    }
    
    func store(waitlistToken: String) {
        token = waitlistToken
    }
    
    func store(waitlistTimestamp: Int) {
        timestamp = waitlistTimestamp
    }
    
    func store(inviteCode: String) {
        code = inviteCode
    }
    
    func deleteWaitlistState() {
        token = nil
        timestamp = nil
        code = nil
    }
    
}

struct MockNotificationService: NotificationService {
    
    let authorized: Bool

    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        return authorized
    }
    
}

class MockMacWaitlistViewModelDelegate: MacWaitlistViewModelDelegate {

    private(set) var didOpenShareSheetCalled = false
    
    func macWaitlistViewModelDidOpenShareSheet(_ viewModel: DuckDuckGo.MacWaitlistViewModel, senderFrame: CGRect) {
        didOpenShareSheetCalled = true
    }

}
