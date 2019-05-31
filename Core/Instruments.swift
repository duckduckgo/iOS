//
//  Instruments.swift
//  Core
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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
import os.signpost

public class Instruments {
    
    static public let shared = Instruments()
    
    private var eventsLog: OSLog?

    private init() {
        if #available(iOSApplicationExtension 12.0, *) {
            eventsLog = OSLog(subsystem: "com.duckduckgo.instrumentation",
                              category: "Behavior")
        }
    }
    
    public func request(url: String, allowedIn time: TimeInterval) {
        if #available(iOSApplicationExtension 12.0, *),
            let log = eventsLog {
            os_log(.debug, log: log, "Request %@ - %@ : %llu", url, "Allowed", UInt64(time * 1000 * 1000 * 1000))
        }
    }
    
    public func request(url: String, blockedIn time: TimeInterval) {
        if #available(iOSApplicationExtension 12.0, *),
            let log = eventsLog {
            os_log(.debug, log: log, "Request %@ - %@ : %llu", url, "Blocked", UInt64(time * 1000 * 1000 * 1000))
        }
    }
    
    public func dataCleared(in time: TimeInterval) {
        if #available(iOSApplicationExtension 12.0, *),
            let log = eventsLog {
            os_signpost(.event,
                        log: log,
                        name: "Data cleared",
                        "%.3f", time)
        }
    }
}
