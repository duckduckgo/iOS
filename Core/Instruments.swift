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
            eventsLog = OSLog(subsystem: "com.duckduckgo.eventsLog",
                              category: .pointsOfInterest)
        }
    }
    
    public func requestAllowed(in time: TimeInterval) {
        if #available(iOSApplicationExtension 12.0, *),
            let log = eventsLog {
            os_signpost(.event,
                        log: log,
                        name: "Request Allowed",
                        "%.3f", time)
        }
    }
    
    public func requestBlocked(in time: TimeInterval) {
        if #available(iOSApplicationExtension 12.0, *),
            let log = eventsLog {
            os_signpost(.event,
                        log: log,
                        name: "Request Blocked",
                        "%.3f", time)
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
