//
//  AutoconsentUserScript.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

import WebKit
import Common
import Core
import BrowserServicesKit
import UserScript
import PrivacyDashboard

// swiftlint:disable file_length

protocol AutoconsentPreferences {
    var autoconsentPromptSeen: Bool { get set }
    var autoconsentEnabled: Bool { get set }
}

extension AppUserDefaults: AutoconsentPreferences { }

protocol AutoconsentUserScriptDelegate: AnyObject {
    func autoconsentUserScript(_ script: AutoconsentUserScript, didUpdateCookieConsentStatus cookieConsentStatus: CookieConsentInfo)
    func autoconsentUserScript(_ script: AutoconsentUserScript, didRequestAskingUserForConsent completion: @escaping (Bool) -> Void)
}

protocol UserScriptWithAutoconsent: UserScript {
    var delegate: AutoconsentUserScriptDelegate? { get set }
}

// @available(macOS 11, *)
final class AutoconsentUserScript: NSObject, WKScriptMessageHandlerWithReply, UserScriptWithAutoconsent {
    
    struct UserInfoKeys {
        static let topURL = "com.duckduckgo.autoconsent.top-url"
        static let isCosmetic = "com.duckduckgo.autoconsent.is-cosmetic"
    }
    
    var injectionTime: WKUserScriptInjectionTime { .atDocumentStart }
    var forMainFrameOnly: Bool { false }
    weak var selfTestWebView: WKWebView?
    weak var selfTestFrameInfo: WKFrameInfo?
    var topUrl: URL?
    var preferences: AutoconsentPreferences
    let management = AutoconsentManagement.shared

    public var messageNames: [String] { MessageName.allCases.map(\.rawValue) }
    let source: String
    private let config: PrivacyConfiguration
    private let ignoreNonHTTPURLs: Bool
    weak var delegate: AutoconsentUserScriptDelegate?

    init(config: PrivacyConfiguration, preferences: AutoconsentPreferences = AppUserDefaults(), ignoreNonHTTPURLs: Bool = true) {
        os_log("Initialising autoconsent userscript", log: .autoconsentLog, type: .debug)
        source = Self.loadJS("autoconsent-bundle", from: .main, withReplacements: [:])
        self.config = config
        self.preferences = preferences
        self.ignoreNonHTTPURLs = ignoreNonHTTPURLs
    }
    
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        // this is never used because macOS <11 is not supported by autoconsent
    }

    @MainActor
    func refreshDashboardState(consentManaged: Bool, cosmetic: Bool?, optoutFailed: Bool?, selftestFailed: Bool?) {
        let cookieConsentStatus = CookieConsentInfo(consentManaged: consentManaged,
                                                    cosmetic: cosmetic,
                                                    optoutFailed: optoutFailed,
                                                    selftestFailed: selftestFailed)
        
        os_log("Refreshing dashboard state: %s", log: .autoconsentLog, type: .debug, String(describing: cookieConsentStatus))
        self.delegate?.autoconsentUserScript(self, didUpdateCookieConsentStatus: cookieConsentStatus)
    }

    @MainActor
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage,
                               replyHandler: @escaping (Any?, String?) -> Void) {
        os_log("Message received: %s", log: .autoconsentLog, type: .debug, String(describing: message.body))
        return handleMessage(replyHandler: replyHandler, message: message)
    }
}

// @available(macOS 11, *)
extension AutoconsentUserScript {
    enum MessageName: String, CaseIterable {
        case `init`
        case cmpDetected
        case eval
        case popupFound
        case optOutResult
        case optInResult
        case selfTestResult
        case autoconsentDone
        case autoconsentError
    }

    struct InitMessage: Codable {
        let type: String
        let url: String
    }

    struct CmpDetectedMessage: Codable {
        let type: String
        let cmp: String
        let url: String
    }

    struct EvalMessage: Codable {
        let type: String
        let id: String
        let code: String
    }
    
    struct PopupFoundMessage: Codable {
        let type: String
        let cmp: String
        let url: String
    }
    
    struct OptOutResultMessage: Codable {
        let type: String
        let cmp: String
        let result: Bool
        let scheduleSelfTest: Bool
        let url: String
    }
    
    struct OptInResultMessage: Codable {
        let type: String
        let cmp: String
        let result: Bool
        let scheduleSelfTest: Bool
        let url: String
    }
    
    struct SelfTestResultMessage: Codable {
        let type: String
        let cmp: String
        let result: Bool
        let url: String
    }
    
    struct AutoconsentDoneMessage: Codable {
        let type: String
        let cmp: String
        let url: String
        let isCosmetic: Bool
    }
    
    func decodeMessageBody<Input: Any, Target: Codable>(from message: Input) -> Target? {
        do {
            let json = try JSONSerialization.data(withJSONObject: message)
            return try JSONDecoder().decode(Target.self, from: json)
        } catch {
            os_log(.error, "Error decoding message body: %{public}@", error.localizedDescription)
            return nil
        }
    }
}

// @available(macOS 11, *)
extension AutoconsentUserScript {
    @MainActor
    func handleMessage(replyHandler: @escaping (Any?, String?) -> Void,
                       message: WKScriptMessage) {
        guard let messageName = MessageName(rawValue: message.name) else {
            replyHandler(nil, "Unknown message type")
            return
        }

        switch messageName {
        case MessageName.`init`:
            handleInit(message: message, replyHandler: replyHandler)
        case MessageName.eval:
            handleEval(message: message, replyHandler: replyHandler)
        case MessageName.popupFound:
            handlePopupFound(message: message, replyHandler: replyHandler)
        case MessageName.optOutResult:
            handleOptOutResult(message: message, replyHandler: replyHandler)
        case MessageName.optInResult:
            // this is not supported in browser
            os_log("ignoring optInResult: %s", log: .autoconsentLog, type: .debug, String(describing: message.body))
            replyHandler(nil, "opt-in is not supported")
        case MessageName.cmpDetected:
            // no need to do anything here
            replyHandler([ "type": "ok" ], nil) // this is just to prevent a Promise rejection
        case MessageName.selfTestResult:
            handleSelfTestResult(message: message, replyHandler: replyHandler)
        case MessageName.autoconsentDone:
            handleAutoconsentDone(message: message, replyHandler: replyHandler)
        case MessageName.autoconsentError:
            os_log("Autoconsent error: %s", log: .autoconsentLog, String(describing: message.body))
            replyHandler([ "type": "ok" ], nil) // this is just to prevent a Promise rejection
        }
    }

    @MainActor
    func handleInit(message: WKScriptMessage, replyHandler: @escaping (Any?, String?) -> Void) {
        guard let messageData: InitMessage = decodeMessageBody(from: message.body) else {
            replyHandler(nil, "cannot decode message")
            return
        }
        guard let url = URL(string: messageData.url) else {
            replyHandler(nil, "cannot decode init request")
            return
        }

        if ignoreNonHTTPURLs && !url.isHttp && !url.isHttps {
            // ignore special schemes
            os_log("Ignoring special URL scheme: %s", log: .autoconsentLog, type: .debug, messageData.url)
            replyHandler([ "type": "ok" ], nil) // this is just to prevent a Promise rejection
            return
        }

        if preferences.autoconsentPromptSeen == true && preferences.autoconsentEnabled == false {
            // this will only happen if the user has just declined a prompt in this tab
            replyHandler([ "type": "ok" ], nil) // this is just to prevent a Promise rejection
            return
        }

        let topURLDomain = message.webView?.url?.host
        guard config.isFeature(.autoconsent, enabledForDomain: topURLDomain) else {
            os_log("disabled for site: %s", log: .autoconsentLog, type: .info, String(describing: url.absoluteString))
            replyHandler([ "type": "ok" ], nil) // this is just to prevent a Promise rejection
            return
        }

        if message.frameInfo.isMainFrame {
            topUrl = url
            // reset dashboard state
            refreshDashboardState(
                consentManaged: management.sitesNotifiedCache.contains(url.host ?? ""),
                cosmetic: nil,
                optoutFailed: nil,
                selftestFailed: nil
            )
        }
        let remoteConfig = self.config.settings(for: .autoconsent)
        let disabledCMPs = remoteConfig["disabledCMPs"] as? [String] ?? []

        replyHandler([
            "type": "initResp",
            "rules": nil, // rules are bundled with the content script atm
            "config": [
                "enabled": true,
                // if it's the first time, disable autoAction
                "autoAction": preferences.autoconsentPromptSeen ? "optOut" : nil,
                "disabledCmps": disabledCMPs,
                // the very first time (autoconsentEnabled = nil), make sure the popup is visible
                "enablePrehide": preferences.autoconsentPromptSeen,
                "enableCosmeticRules": true,
                "detectRetries": 20,
                "isMainWorld": false
            ] as [String: Any?]
        ] as [String: Any?], nil)
    }
    
    @MainActor
    func handleEval(message: WKScriptMessage, replyHandler: @escaping (Any?, String?) -> Void) {
        guard let messageData: EvalMessage = decodeMessageBody(from: message.body) else {
            replyHandler(nil, "cannot decode message")
            return
        }
        let script = """
        (() => {
        try {
            return !!(\(messageData.code));
        } catch (e) {
          // ignore any errors
          return;
        }
        })();
        """
        
        if let webview = message.webView {
            webview.evaluateJavaScript(script, in: message.frameInfo, in: WKContentWorld.page, completionHandler: { (result) in
                switch result {
                case.failure(let error):
                    replyHandler(nil, "Error snippet: \(error)")
                case.success(let value):
                    replyHandler(
                        [
                            "type": "evalResp",
                            "id": messageData.id,
                            "result": value
                        ],
                        nil
                    )
                }
            })
        } else {
            replyHandler(nil, "missing frame target")
        }
    }
    
    @MainActor
    func handlePopupFound(message: WKScriptMessage, replyHandler: @escaping (Any?, String?) -> Void) {
        guard preferences.autoconsentPromptSeen == false else {
            // if feature is already enabled, opt-out will happen automatically
            replyHandler([ "type": "ok" ], nil) // this is just to prevent a Promise rejection
            return
        }
        
        os_log("Prompting user about autoconsent", log: .autoconsentLog, type: .debug)

        // if it's the first time, prompt the user and trigger opt-out
        if message.webView?.window != nil {
            ensurePrompt(callback: { shouldProceed in
                if shouldProceed {
                    Task {
                        replyHandler([ "type": "optOut" ], nil)
                    }
                }
            })
        } else {
            replyHandler(nil, "missing frame target")
        }
    }
    
    @MainActor
    func handleOptOutResult(message: WKScriptMessage, replyHandler: @escaping (Any?, String?) -> Void) {
        guard let messageData: OptOutResultMessage = decodeMessageBody(from: message.body) else {
            replyHandler(nil, "cannot decode message")
            return
        }
        os_log("opt-out result: %s", log: .autoconsentLog, type: .debug, String(describing: messageData))

        if !messageData.result {
            refreshDashboardState(consentManaged: true, cosmetic: nil, optoutFailed: true, selftestFailed: nil)
        } else if messageData.scheduleSelfTest {
            // save a reference to the webview and frame for self-test
            selfTestWebView = message.webView
            selfTestFrameInfo = message.frameInfo
        }

        replyHandler([ "type": "ok" ], nil) // this is just to prevent a Promise rejection
    }
    
    @MainActor
    func handleAutoconsentDone(message: WKScriptMessage, replyHandler: @escaping (Any?, String?) -> Void) {
        // report a managed popup
        guard let messageData: AutoconsentDoneMessage = decodeMessageBody(from: message.body) else {
            replyHandler(nil, "cannot decode message")
            return
        }
        os_log("opt-out successful: %s", log: .autoconsentLog, type: .debug, String(describing: messageData))
        
        guard let url = URL(string: messageData.url),
              let host = url.host else {
            replyHandler(nil, "cannot decode message")
            return
        }
        
        refreshDashboardState(consentManaged: true, cosmetic: messageData.isCosmetic, optoutFailed: false, selftestFailed: nil)
        
        // trigger popup once per domain
        if !management.sitesNotifiedCache.contains(host) {
            os_log("bragging that we closed a popup", log: .autoconsentLog, type: .debug)
            management.sitesNotifiedCache.insert(host)
            // post popover notification on main thread
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .newSiteCookiesManaged, object: self, userInfo: [
                    UserInfoKeys.topURL: self.topUrl ?? url,
                    UserInfoKeys.isCosmetic: messageData.isCosmetic
                ])
            }
        }
        
        replyHandler([ "type": "ok" ], nil) // this is just to prevent a Promise rejection

        if let selfTestWebView = selfTestWebView,
           let selfTestFrameInfo = selfTestFrameInfo {
            os_log("requesting self-test in: %s", log: .autoconsentLog, type: .debug, messageData.url)
            selfTestWebView.evaluateJavaScript(
                "window.autoconsentMessageCallback({ type: 'selfTest' })",
                in: selfTestFrameInfo,
                in: WKContentWorld.defaultClient,
                completionHandler: { (result) in
                    switch result {
                    case.failure(let error):
                        os_log("Error running self-test: %s", log: .autoconsentLog, type: .debug, String(describing: error))
                    case.success:
                        os_log("self-test requested", log: .autoconsentLog, type: .debug)
                    }
                }
            )
        } else {
            os_log("no self-test scheduled in this tab", log: .autoconsentLog, type: .debug)
        }
        selfTestWebView = nil
        selfTestFrameInfo = nil
    }
    
    @MainActor
    func handleSelfTestResult(message: WKScriptMessage, replyHandler: @escaping (Any?, String?) -> Void) {
        guard let messageData: SelfTestResultMessage = decodeMessageBody(from: message.body) else {
            replyHandler(nil, "cannot decode message")
            return
        }
        // store self-test result
        os_log("self-test result: %s", log: .autoconsentLog, type: .debug, String(describing: messageData))
        refreshDashboardState(consentManaged: true, cosmetic: nil, optoutFailed: false, selftestFailed: messageData.result)
        replyHandler([ "type": "ok" ], nil) // this is just to prevent a Promise rejection
    }

    @MainActor
    func ensurePrompt(callback: @escaping (Bool) -> Void) {
        let now = Date.init()
        guard management.promptLastShown == nil || now > management.promptLastShown!.addingTimeInterval(1) else {
            // user said "not now" recently, don't bother asking
            os_log("Have a recent user response, canceling prompt", log: .autoconsentLog, type: .debug)
            callback(preferences.autoconsentEnabled) // if two prompts were scheduled from the same tab, result could be true
            return
        }

        management.promptLastShown = now
        self.delegate?.autoconsentUserScript(self, didRequestAskingUserForConsent: { result in
            self.preferences.autoconsentEnabled = result
            self.preferences.autoconsentPromptSeen = true
            callback(result)
        })
    }
}

extension NSNotification.Name {
    static let newSiteCookiesManaged: NSNotification.Name = Notification.Name(rawValue: "com.duckduckgo.notification.new-site-cookies-managed")
}
