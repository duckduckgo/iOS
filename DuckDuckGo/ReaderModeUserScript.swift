//
//  ReaderModeUserScript.swift
//  DuckDuckGo
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

import Core
import WebKit
import BrowserServicesKit

// swiftlint:disable:next identifier_name
let ReaderModeNamespace = "window.__firefox__.reader"

enum ReaderModeMessageType: String {
    case stateChange = "ReaderModeStateChange"
    case pageEvent = "ReaderPageEvent"
    case contentParsed = "ReaderContentParsed"
}

enum ReaderPageEvent: String {
    case pageShow = "PageShow"
}

enum ReaderModeState: String {
    case available = "Available"
    case unavailable = "Unavailable"
    case active = "Active"
}

/// This struct captures the response from the Readability.js code.
struct ReadabilityResult {
    var domain = ""
    var url = ""
    var content = ""
    var textContent = ""
    var title = ""
    var credits = ""
    var excerpt = ""

    init?(object: AnyObject?) {
        if let dict = object as? NSDictionary {
            if let uri = dict["uri"] as? NSDictionary {
                if let url = uri["spec"] as? String {
                    self.url = url
                }
                if let host = uri["host"] as? String {
                    self.domain = host
                }
            }
            if let content = dict["content"] as? String {
                self.content = content
            }
            if let textContent = dict["textContent"] as? String {
                self.textContent = textContent
            }
            if let excerpt = dict["excerpt"] as? String {
                self.excerpt = excerpt
            }
            if let title = dict["title"] as? String {
                self.title = title
            }
            if let credits = dict["byline"] as? String {
                self.credits = credits
            }
        } else {
            return nil
        }
    }

    /// Initialize from a JSON encoded string
    init?(data: Data) throws {
        guard let object = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: String] else { return nil }

        let domain = object["domain"]
        let url = object["url"]
        let content = object["content"]
        let textContent = object["textContent"]
        let excerpt = object["excerpt"]
        let title = object["title"]
        let credits = object["credits"]

        if domain == nil || url == nil || content == nil || title == nil || credits == nil {
            return nil
        }

        self.domain = domain!
        self.url = url!
        self.content = content!
        self.title = title!
        self.credits = credits!
        self.textContent = textContent ?? ""
        self.excerpt = excerpt ?? ""
    }

    /// Encode to a dictionary, which can then for example be json encoded
    func encode() -> [String: Any] {
        return ["domain": domain, "url": url, "content": content, "title": title, "credits": credits, "textContent": textContent, "excerpt": excerpt]
    }

    /// Encode to a JSON encoded string
    func encode() -> Data {
        let dict: [String: Any] = self.encode()
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) else { return Data() }
        return jsonData
    }
}

/// Delegate that contains callbacks that we have added on top of the built-in WKWebViewDelegate
protocol ReaderModeUserScriptDelegate: AnyObject {
    func readerMode(_ readerMode: ReaderModeUserScript, didChangeReaderModeState state: ReaderModeState)
    func readerModeDidDisplayReaderizedContentForTab(_ readerMode: ReaderModeUserScript)
    func readerMode(_ readerMode: ReaderModeUserScript, didParseReadabilityResult readabilityResult: ReadabilityResult)
}

public class ReaderModeUserScript: NSObject, StaticUserScript {

    public static var script: WKUserScript = ReaderModeUserScript.makeWKUserScript()

    static public var source: String = {
        return loadJS("ReaderMode", from: Bundle.main)
    }()
    
    static public var injectionTime: WKUserScriptInjectionTime = .atDocumentStart
    
    static public var forMainFrameOnly: Bool = false
    
    public var messageNames: [String] = ["readerModeMessageHandler"]
    
    weak var delegate: ReaderModeUserScriptDelegate?

    private(set) var state: ReaderModeState = .unavailable

    public func resetState() {
        state = .unavailable
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let msg = message.body as? [String: Any],
              let messageType = (msg["Type"] as? String).flatMap(ReaderModeMessageType.init(rawValue:))
        else { return }

        switch messageType {
        case .pageEvent:
            guard let readerPageEvent = ReaderPageEvent(rawValue: msg["Value"] as? String ?? "Invalid") else { return }
            handleReaderPageEvent(readerPageEvent)
        case .stateChange:
            guard let readerModeState = ReaderModeState(rawValue: msg["Value"] as? String ?? "Invalid") else { return }
            handleReaderModeStateChange(readerModeState)
        case .contentParsed:
            guard let readabilityResult = ReadabilityResult(object: msg["Value"] as AnyObject?) else { return }
            handleReaderContentParsed(readabilityResult)
        }
    }

    func handleReaderPageEvent(_ readerPageEvent: ReaderPageEvent) {
        switch readerPageEvent {
        case .pageShow:
            delegate?.readerModeDidDisplayReaderizedContentForTab(self)
        }
    }

    func handleReaderModeStateChange(_ state: ReaderModeState) {
        self.state = state
        delegate?.readerMode(self, didChangeReaderModeState: state)
    }

    func handleReaderContentParsed(_ readabilityResult: ReadabilityResult) {
        delegate?.readerMode(self, didParseReadabilityResult: readabilityResult)
    }

}
