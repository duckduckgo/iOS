//
//  MacWaitlistViewModelTests.swift
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
@testable import Core

class MacWaitlistViewModelTests: XCTestCase {

    private let mockToken = "mock-token"
    private let oldTimestamp = 100
    private let newTimestamp = 20
    
    @MainActor
    func testWhenOpenShareSheetActionIsPerformed_ThenShowShareSheetIsTrue() async {
        let inviteCode = "INVITECODE"
        let request = MockWaitlistRequest.returning(.success(.init(token: mockToken, timestamp: newTimestamp)))
        let storage = MockWaitlistStorage()
        storage.store(inviteCode: inviteCode)

        let viewModel = MacWaitlistViewModel(waitlistRequest: request, waitlistStorage: storage)
        let delegate = MockMacWaitlistViewModelDelegate()
        viewModel.delegate = delegate
        
        await viewModel.perform(action: .openShareSheet(.zero))
        
        XCTAssertTrue(delegate.didOpenShareSheetCalled)
    }
    
}
