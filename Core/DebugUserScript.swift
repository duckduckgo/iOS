//
//  DebugUserScript.swift
//  Core
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

import Common
import WebKit
import UserScript

public class DebugUserScript: NSObject, UserScript {
    
    struct MessageNames {
        
        static let signpost = "signpost"
        static let log = "log"
        
    }
    
    public lazy var source: String = {
        return ""
    }()
    
    public var injectionTime: WKUserScriptInjectionTime = .atDocumentStart
    
    public var forMainFrameOnly: Bool = false
    
    public var messageNames: [String] = [ MessageNames.signpost, MessageNames.log ]
    
    public weak var instrumentation: TabInstrumentation?

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
            
        case MessageNames.signpost:
            handleSignpost(message: message)
            
        case MessageNames.log:
            handleLog(message: message)
            
        default: break
        }
    }
    
    private func handleLog(message: WKScriptMessage) {
        os_log("%s", log: .generalLog, type: .debug, String(describing: message.body))
    }
    
    private func handleSignpost(message: WKScriptMessage) {
        guard let dict = message.body as? [String: Any],
        let event = dict["event"] as? String else { return }
        
        if event == "Request Allowed" {
            if let elapsedTimeInMs = dict["time"] as? Double,
                let url = dict["url"] as? String {
                instrumentation?.request(url: url, allowedIn: elapsedTimeInMs)
            }
        } else if event == "Tracker Allowed" {
            if let elapsedTimeInMs = dict["time"] as? Double,
                let url = dict["url"] as? String,
                let reason = dict["reason"] as? String? {
                instrumentation?.tracker(url: url, allowedIn: elapsedTimeInMs, reason: reason)
            }
        } else if event == "Tracker Blocked" {
            if let elapsedTimeInMs = dict["time"] as? Double,
                let url = dict["url"] as? String {
                instrumentation?.tracker(url: url, blockedIn: elapsedTimeInMs)
            }
        } else if event == "Generic" {
            if let name = dict["name"] as? String,
                let elapsedTimeInMs = dict["time"] as? Double {
                instrumentation?.jsEvent(name: name, executedIn: elapsedTimeInMs)
            }
        }
    }
}
