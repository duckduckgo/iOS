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

import Foundation
import Combine

@MainActor
final class MacWaitlistViewModel: ObservableObject {
    
    enum State {
        case notJoinedQueue
        case joinedQueue
        case inBeta
    }
    
    @Published var state: State
    
    private let waitlistRequest: WaitlistRequesting
    private let browserWaitlistStorage: MacBrowserWaitlistStorage
    
    init(waitlistRequest: WaitlistRequesting = WaitlistRequest(product: .macBrowser),
         waitlistStorage: MacBrowserWaitlistStorage = MacBrowserWaitlistKeychainStore()) {
        self.waitlistRequest = waitlistRequest
        self.browserWaitlistStorage = waitlistStorage
        
        if browserWaitlistStorage.getWaitlistTimestamp() != nil, browserWaitlistStorage.getWaitlistInviteCode() == nil {
            self.state = .joinedQueue
        } else if browserWaitlistStorage.getWaitlistInviteCode() != nil {
            self.state = .inBeta
        } else {
            self.state = .notJoinedQueue
        }
    }
    
    func joinWaitlist() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.state = .joinedQueue
        }
    }
    
}
