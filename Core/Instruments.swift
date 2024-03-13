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

    public enum TimedEvent: String {
        case fetchingContentBlockerData

        case loadingDisconnectMeStore
        case loadingEasylistStore

        case tabInitialisation

        case clearingData

        case injectScripts
    }

    static public let shared = Instruments()

    static var eventsLog = OSLog(subsystem: "com.duckduckgo.instrumentation", category: "Events")

    public func startTimedEvent(_ event: TimedEvent, info: String? = nil) -> Any? {
        if #available(iOSApplicationExtension 12.0, *) {
            let id = OSSignpostID(log: Instruments.eventsLog)

            os_signpost(.begin,
                        log: Instruments.eventsLog,
                        name: "Timed Event",
                        signpostID: id,
                        "Event: %@ info: %@", event.rawValue, info ?? "")
            return id
        }
        return nil
    }

    public func endTimedEvent(for spid: Any?, result: String? = nil) {
        if #available(iOSApplicationExtension 12.0, *),
            let id = spid as? OSSignpostID {
            os_signpost(.end,
                        log: Instruments.eventsLog,
                        name: "Timed Event",
                        signpostID: id,
                        "Result: %@", result ?? "")
        }
    }
}
