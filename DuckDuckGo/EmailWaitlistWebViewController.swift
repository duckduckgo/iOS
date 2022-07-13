//
//  EmailWaitlistWebViewController.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

import UIKit
import Core
import BrowserServicesKit
import WebKit

class EmailWaitlistWebViewController: UIViewController, WKNavigationDelegate {

    let userAgentManager: UserAgentManager = DefaultUserAgentManager.shared
    let appUrls = AppUrls()

    @IBOutlet var webView: WKWebView!

    private let baseURL: URL

    private lazy var emailManager: EmailManager = {
        let emailManager = EmailManager()
        emailManager.requestDelegate = self
        return emailManager
    }()

    private lazy var autofillUserScript: AutofillUserScript = {
        // GPC value doesn't matter here as the Autofill script doesn't use it
        let prefs = ContentScopeProperties(gpcEnabled: true,
                                           sessionKey: UUID().uuidString,
                                           featureToggles: ContentScopeFeatureToggles.supportedFeaturesOniOS)
        let script = AutofillUserScript(
            scriptSourceProvider: DefaultAutofillSourceProvider(privacyConfigurationManager: ContentBlocking.shared.privacyConfigurationManager,
                                                                properties: prefs))
        script.emailDelegate = self.emailManager
        return script
    }()

    init?(coder: NSCoder, baseURL: URL) {
        self.baseURL = baseURL
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.navigationDelegate = self

        reloadUserScripts()
        updateContentMode()

        webView.load(URLRequest.userInitiated(baseURL))
    }

    private func reloadUserScripts() {
        webView.configuration.userContentController.removeAllUserScripts()

        let script = autofillUserScript
        webView.configuration.userContentController.addUserScript(WKUserScript(source: script.source,
                                                                               injectionTime: script.injectionTime,
                                                                               forMainFrameOnly: script.forMainFrameOnly))
        
        script.messageNames.forEach { messageName in
            webView.configuration.userContentController.addScriptMessageHandler(script, contentWorld: .page, name: messageName)
        }
        
    }

    func updateContentMode() {
        webView.configuration.defaultWebpagePreferences.preferredContentMode = .mobile
        userAgentManager.update(webView: webView, isDesktop: false, url: nil)
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        let schemeType = SchemeHandler.schemeType(for: url)

        switch schemeType {
        case .navigational:
            let validHost = appUrls.isDuckDuckGo(url: url) || appUrls.isBlog(url: url)
            decisionHandler(validHost ? .allow : .cancel)
        case .external:
            UIApplication.shared.open(url, options: [:]) { opened in
                if !opened {
                    ActionMessageView.present(message: UserText.failedToOpenExternally)
                }
            }

            decisionHandler(.cancel)
        default: decisionHandler(.allow)
        }
    }

}

extension EmailWaitlistWebViewController: EmailManagerRequestDelegate {

    // swiftlint:disable function_parameter_count
    func emailManager(_ emailManager: EmailManager,
                      requested url: URL,
                      method: String,
                      headers: [String: String],
                      parameters: [String: String]?,
                      httpBody: Data?,
                      timeoutInterval: TimeInterval,
                      completion: @escaping (Data?, Error?) -> Void) {
        APIRequest.request(url: url,
                           method: APIRequest.HTTPMethod(rawValue: method) ?? .post,
                           parameters: parameters,
                           headers: headers,
                           httpBody: httpBody,
                           timeoutInterval: timeoutInterval) { response, error in

            completion(response?.data, error)
        }
    }
    // swiftlint:enable function_parameter_count

}
