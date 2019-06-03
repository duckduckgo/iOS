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
    
    public enum ContentBlockerFetchResult: String {
        case error
        case cached
        case success
    }
    
    static public let shared = Instruments()
    
    private var eventsLog: OSLog?

    private init() {
        if #available(iOSApplicationExtension 12.0, *) {
            eventsLog = OSLog(subsystem: "com.duckduckgo.instrumentation",
                              category: "Events")
        }
    }
    
    public func willFetchContentBlockerData(for name: String) -> Any? {
        if #available(iOSApplicationExtension 12.0, *),
            let log = eventsLog {
            let id = OSSignpostID(log: log)

            os_signpost(.begin,
                        log: log,
                        name: "Load Content Blocker Configuration",
                        signpostID: id,
                        "Loading: %@", name)
            return id
        }
        return nil
    }
    
    public func didFetchContentBlockerData(for spid: Any?, result: ContentBlockerFetchResult) {
        if #available(iOSApplicationExtension 12.0, *),
            let log = eventsLog,
            let id = spid as? OSSignpostID {
            os_signpost(.end,
                        log: log,
                        name: "Load Content Blocker Configuration",
                        signpostID: id,
                        "Result: %@", result.rawValue)
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
