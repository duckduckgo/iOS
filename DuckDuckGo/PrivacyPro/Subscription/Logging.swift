//
//  Logging.swift
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
import Common

struct Logging {

    static let subsystem = "com.duckduckgo.macos.browser.account"

    fileprivate static let accountLoggingEnabled = true
    fileprivate static let account: OSLog = OSLog(subsystem: subsystem, category: "Account")

    fileprivate static let authServiceLoggingEnabled = true
    fileprivate static let authService: OSLog = OSLog(subsystem: subsystem, category: "Account : AuthService")

    fileprivate static let subscriptionServiceLoggingEnabled = true
    fileprivate static let subscriptionService: OSLog = OSLog(subsystem: subsystem, category: "Account : SubscriptionService")

    fileprivate static let errorsLoggingEnabled = true
    fileprivate static let error: OSLog = OSLog(subsystem: subsystem, category: "Account : Errors")
}

extension OSLog {

    public static var account: OSLog {
        Logging.accountLoggingEnabled ? Logging.account : .disabled
    }

    public static var authService: OSLog {
        Logging.authServiceLoggingEnabled ? Logging.authService : .disabled
    }

    public static var subscriptionService: OSLog {
        Logging.subscriptionServiceLoggingEnabled ? Logging.subscriptionService : .disabled
    }

    public static var error: OSLog {
        Logging.errorsLoggingEnabled ? Logging.error : .disabled
    }
}
