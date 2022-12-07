//
//  AutofillLoginSession.swift
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
import BrowserServicesKit

class AutofillLoginSession {

    private enum Constants {
        static let timeout: TimeInterval = 15
    }

    private var sessionCreationDate: Date?
    private var sessionAccount: SecureVaultModels.WebsiteAccount?
    private let sessionTimeout: TimeInterval

    init(sessionTimeout: TimeInterval = Constants.timeout) {
        self.sessionTimeout = sessionTimeout
    }

    var isValidSession: Bool {
        guard let sessionCreationDate = sessionCreationDate else { return false }
        let timeInterval = Date().timeIntervalSince(sessionCreationDate)
        // Check that timeInterval is > 0 to prevent a user circumventing by changing their device clock time
        return timeInterval > 0 && timeInterval < sessionTimeout
    }

    var lastAccessedAccount: SecureVaultModels.WebsiteAccount? {
        get {
            return isValidSession ? sessionAccount : nil
        }
        set {
            sessionAccount = newValue
        }
    }

    func startSession() {
        sessionCreationDate = Date()
    }

    func endSession() {
        sessionCreationDate = nil
        lastAccessedAccount = nil
    }
}
