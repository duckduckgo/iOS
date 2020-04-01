//
//  DebugUserScript.swift
//  Core
//
//  Created by Chris Brind on 01/04/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import WebKit
import os

public class DebugUserScript: NSObject, UserScript {
    
    struct MessageNames {
        
        static let signpost = "signpost"
        static let log = "log"
        
    }
    
    public lazy var source: String = {
        return loadJS(isDebugBuild ? "debug-messaging-enabled" : "debug-messaging-disabled")
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
        os_log("%s", log: generalLog, type: .debug, String(describing: message.body))
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

    deinit {
        print("*** deinit DBGS")
    }
    
}
