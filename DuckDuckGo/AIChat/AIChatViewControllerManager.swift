//
//  AIChatViewControllerManager.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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

import UserScript
import AIChat
import Foundation
import BrowserServicesKit
import WebKit
import Core

protocol AIChatViewControllerManagerDelegate: AnyObject {
    func aiChatViewControllerManager(_ manager: AIChatViewControllerManager, didRequestToLoad url: URL)
}

final class AIChatViewControllerManager {
    weak var delegate: AIChatViewControllerManagerDelegate?
    private var aiChatUserScript: AIChatUserScript?
    private var payloadHandler = AIChatPayloadHandler()
    private let privacyConfigurationManager: PrivacyConfigurationManaging
    private let internalUserDecider: InternalUserDecider
    
    init(privacyConfigurationManager: PrivacyConfigurationManaging = ContentBlocking.shared.privacyConfigurationManager,
         internalUserDecider: InternalUserDecider = AppDependencyProvider.shared.internalUserDecider) {
        self.privacyConfigurationManager = privacyConfigurationManager
        self.internalUserDecider = internalUserDecider
    }
    
    @MainActor
    lazy var aiChatViewController: AIChatViewController = {
        let settings = AIChatSettings(privacyConfigurationManager: privacyConfigurationManager,
                                      internalUserDecider: internalUserDecider)
        
        let webviewConfiguration = WKWebViewConfiguration.persistent()
        let userContentController = UserContentController()
        userContentController.delegate = self

        webviewConfiguration.userContentController = userContentController
        let aiChatViewController = AIChatViewController(settings: settings,
                                                        webViewConfiguration: webviewConfiguration)
        aiChatViewController.delegate = self
        return aiChatViewController
    }()

    @MainActor
    func openAIChat(_ query: URLQueryItem? = nil, payload: Any? = nil, on viewController: UIViewController) {
        let roundedPageSheet = RoundedPageSheetContainerViewController(
            contentViewController: aiChatViewController,
            allowedOrientation: .portrait)

        if let query = query {
            aiChatViewController.loadQuery(query)
        }

        // Force a reload to trigger the user script getUserValues
        if let payload = payload as? AIChatPayload {
            payloadHandler.setPayload(payload)
            aiChatViewController.reload()
        }
        viewController.present(roundedPageSheet, animated: true, completion: nil)
    }
}

extension AIChatViewControllerManager: UserContentControllerDelegate {
    @MainActor
    func userContentController(_ userContentController: UserContentController,
                               didInstallContentRuleLists contentRuleLists: [String: WKContentRuleList],
                               userScripts: UserScriptsProvider,
                               updateEvent: ContentBlockerRulesManager.UpdateEvent) {

        guard let userScripts = userScripts as? UserScripts else { fatalError("Unexpected UserScripts") }
        self.aiChatUserScript = userScripts.aiChatUserScript
        self.aiChatUserScript?.setPayloadHandler(self.payloadHandler)
    }
}

// MARK: - AIChatViewControllerDelegate
extension AIChatViewControllerManager: AIChatViewControllerDelegate {
    func aiChatViewController(_ viewController: AIChatViewController, didRequestToLoad url: URL) {
        delegate?.aiChatViewControllerManager(self, didRequestToLoad: url)
        viewController.dismiss(animated: true)
    }

    func aiChatViewControllerDidFinish(_ viewController: AIChatViewController) {
        viewController.dismiss(animated: true)
        
    }
}
