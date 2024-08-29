//
//  TabInstrumentation.swift
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

public class TabInstrumentation {

    static let tabsLog = OSLog(subsystem: "com.duckduckgo.instrumentation",
                               category: "TabInstrumentation")

    static var tabMaxIdentifier: UInt64 = 0

    private var siteLoadingSPID: Any?
    private var currentURL: String?
    private var currentTabIdentifier: UInt64

    public init() {
        type(of: self).tabMaxIdentifier += 1
        currentTabIdentifier = type(of: self).tabMaxIdentifier
    }

    private var tabInitSPID: Any?

    public func willPrepareWebView() {
        tabInitSPID = Instruments.shared.startTimedEvent(.tabInitialisation, info: "Tab-\(currentTabIdentifier)")
    }

    public func didPrepareWebView() {
        Instruments.shared.endTimedEvent(for: tabInitSPID)
    }

    public func willLoad(url: URL) {
        currentURL = url.absoluteString
        if #available(iOSApplicationExtension 12.0, *) {
            let id = OSSignpostID(log: type(of: self).tabsLog)
            siteLoadingSPID = id
            os_signpost(.begin,
                        log: type(of: self).tabsLog,
                        name: "Load Page",
                        signpostID: id,
                        "Loading URL: %@ in %llu", url.absoluteString, currentTabIdentifier)
        }
    }

    public func didLoadURL() {
        if #available(iOSApplicationExtension 12.0, *),
            let id = siteLoadingSPID as? OSSignpostID {
            os_signpost(.end,
                        log: type(of: self).tabsLog,
                        name: "Load Page",
                        signpostID: id,
                        "Loading Finished: %{private}@", "T")
        }
    }

    // MARK: - JS events

    public func request(url: String, allowedIn timeInMs: Double) {
        request(url: url, isTracker: false, blocked: false, in: timeInMs)
    }

    public func tracker(url: String, allowedIn timeInMs: Double, reason: String?) {
        request(url: url, isTracker: true, blocked: false, reason: reason ?? "?", in: timeInMs)
    }

    public func tracker(url: String, blockedIn timeInMs: Double) {
        request(url: url, isTracker: true, blocked: true, in: timeInMs)
    }

    private func request(url: String, isTracker: Bool, blocked: Bool, reason: String = "", in timeInMs: Double) {
        if #available(iOSApplicationExtension 12.0, *) {
            let currentURL = self.currentURL ?? "unknown"
            let requestType = isTracker ? "Tracker" : "Regular"
            let status = blocked ? "Blocked" : "Allowed"

            // 0 is treated as 1ms
            let timeInNS: UInt64 = timeInMs.asNanos
            Logger.general.debug("[\(currentURL)] Request: \(url) - \(requestType) - \(status) (\(reason)) in \(timeInNS)")
        }
    }

    public func jsEvent(name: String, executedIn timeInMs: Double) {
        if #available(iOSApplicationExtension 12.0, *) {
            let currentURL = self.currentURL ?? "unknown"
            // 0 is treated as 1ms
            let timeInNS: UInt64 = timeInMs.asNanos
            Logger.general.debug("[\(currentURL)] JSEvent: \(name) executedIn: \(timeInNS)")
        }
    }
}

extension Double {

    var asNanos: UInt64 {
        return self > 0 ? UInt64(self * 1000 * 1000) : 1000000
    }

}
