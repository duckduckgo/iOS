//
//  Logger.swift
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
import os.log

public let generalLog: OSLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? AppVersion.shared.identifier, category: "DDG General")
public let lifecycleLog: OSLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? AppVersion.shared.identifier, category: "DDG Lifecycle")

public struct Logger {

    public static func log(_ log: OSLog = generalLog, text: String) {
        #if DEBUG

        if #available(iOS 12.0, *) {
            os_log("%@", log: log, type: .debug, text)
        } else {
            print(text, separator: " ", terminator: "\n")
        }

        #endif
    }

    public static func log(_ log: OSLog = generalLog, items: Any...) {
        #if DEBUG

        let textItems = items.map { String(reflecting: $0).dropPrefix(prefix: "\"").dropSuffix(suffix: "\"") }
        let text = textItems.joined(separator: " ")

        if #available(iOS 12.0, *) {
            os_log("%@", log: log, type: .debug, text)
        } else {
            print(text, separator: " ", terminator: "\n")
        }

        #endif
    }
}
