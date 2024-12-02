//
//  AIChatWebViewController.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

import UIKit
import WebKit

protocol AIChatWebViewControllerDelegate: AnyObject {
    @MainActor func aiChatWebViewController(_ viewController: AIChatWebViewController, didRequestToLoad url: URL)
}

final class AIChatWebViewController: UIViewController {
    weak var delegate: AIChatWebViewControllerDelegate?
    private var didLoadAIChat = false
    private let chatModel: AIChatViewModeling

    private lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero, configuration: chatModel.webViewConfiguration)
        webView.navigationDelegate = self
        return webView
    }()

    init(chatModel: AIChatViewModeling) {
        self.chatModel = chatModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        setupWebView()
        loadWebsite()
    }

    private func setupWebView() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

// MARK: - WebView functions

extension AIChatWebViewController {

    func reload() {
        loadWebsite()
    }

    private func loadWebsite() {
        let request = URLRequest(url: chatModel.aiChatURL)
        webView.load(request)
    }
}

// MARK: - WKNavigationDelegate

extension AIChatWebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        if let url = navigationAction.request.url {
            if url == chatModel.aiChatURL || navigationAction.targetFrame?.isMainFrame == false {
                return .allow
            } else {
                delegate?.aiChatWebViewController(self, didRequestToLoad: url)
                return .cancel
            }
        } else {
            return .allow
        }
    }
}
