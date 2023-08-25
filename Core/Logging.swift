//
//  Logging.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
import Common

public extension OSLog {

    enum AppCategories: String, CaseIterable {
        case generalLog = "DDG General"
        case contentBlockingLog = "DDG Content Blocking"
        case adAttributionLog = "DDG AdAttribution"
        case lifecycleLog = "DDG Lifecycle"
        case autoconsentLog = "DDG Autoconsent"
        case configurationLog = "DDG Configuration"
        case syncLog = "DDG Sync"
    }

    @OSLogWrapper(.generalLog) static var generalLog
    @OSLogWrapper(.contentBlockingLog) static var contentBlockingLog
    @OSLogWrapper(.adAttributionLog) static var adAttributionLog
    @OSLogWrapper(.lifecycleLog) static var lifecycleLog
    @OSLogWrapper(.autoconsentLog) static var autoconsentLog
    @OSLogWrapper(.configurationLog) static var configurationLog
    @OSLogWrapper(.syncLog) static var syncLog

    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // To activate Logging Categories add categories here:
#if DEBUG
    static var enabledCategories: Set<AppCategories> = [
        .generalLog,
        .contentBlockingLog,
        .adAttributionLog,
        .lifecycleLog,
        .configurationLog,
        .syncLog
    ]
#endif

}

public extension OSLog.OSLogWrapper {

    private static let enableLoggingCategoriesOnce: Void = {
#if DEBUG
        OSLog.enabledLoggingCategories = Set(OSLog.enabledCategories.map(\.rawValue))
#endif
    }()

    init(_ category: OSLog.AppCategories) {
        _=Self.enableLoggingCategoriesOnce
        self.init(rawValue: category.rawValue)
    }

}
