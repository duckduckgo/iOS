//
//  Logger+Multiple.swift
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
import os.log

public extension Logger {
    static var adAttribution = { Logger(subsystem: "AD Attribution", category: "") }()
    static var lifecycle = { Logger(subsystem: "Lifecycle", category: "") }()
    static var autoconsent = { Logger(subsystem: "Autoconsent", category: "") }()
    static var configuration = { Logger(subsystem: "Configuration", category: "") }()
    static var duckPlayer = { Logger(subsystem: "DuckPlayer", category: "") }()
}
//
//
// public extension OSLog {
//
//    enum AppCategories: String, CaseIterable {
////        case generalLog = "DDG General" // BSK .general
////        case adAttributionLog = "DDG AdAttribution"
////        case lifecycleLog = "DDG Lifecycle"
////        case autoconsentLog = "DDG Autoconsent"
//        case /*configuration*/Log = "DDG Configuration"
//        case syncLog = "DDG Sync"
//        case duckPlayerLog = "Duck Player"
//    }
//
//    @OSLogWrapper(.generalLog) static var generalLog
//    @OSLogWrapper(.adAttributionLog) static var adAttributionLog
//    @OSLogWrapper(.lifecycleLog) static var lifecycleLog
//    @OSLogWrapper(.autoconsentLog) static var autoconsentLog
//    @OSLogWrapper(.configurationLog) static var configurationLog
//    @OSLogWrapper(.syncLog) static var syncLog
//    @OSLogWrapper(.duckPlayerLog) static var duckPlayerLog
//
// }
