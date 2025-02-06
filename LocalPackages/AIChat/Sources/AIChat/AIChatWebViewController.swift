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
    private let chatModel: AIChatViewModeling

    private lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero, configuration: chatModel.webViewConfiguration)
        webView.isOpaque = false /// Required to make the background color visible
        webView.backgroundColor = .webViewBackgroundColor
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    private lazy var loadingView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .label
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
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
        setupLoadingView()
        loadWebsite()
    }

    private func setupWebView() {
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupLoadingView() {
        view.addSubview(loadingView)

        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - WebView functions

extension AIChatWebViewController {

    struct QueryParameters {
        static let queryKey = "q"
        static let autoSendKey = "prompt"
        static let autoSendValue = "1"
    }

    func reload() {
        loadWebsite()
    }

    private func loadWebsite() {
        let request = URLRequest(url: chatModel.aiChatURL)
        webView.load(request)
    }

    func loadQuery(_ query: String, autoSend: Bool) {
        let urlQuery = URLQueryItem(name: QueryParameters.queryKey, value: query)
        var queryURL = chatModel.aiChatURL.addingOrReplacing(urlQuery)
        if autoSend {
            let autoSendQuery = URLQueryItem(name: QueryParameters.autoSendKey, value: QueryParameters.autoSendValue)
            queryURL = queryURL.addingOrReplacing(autoSendQuery)
        }
        webView.load(URLRequest(url: queryURL))
    }
}

// MARK: - WKNavigationDelegate

extension AIChatWebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        guard let url = navigationAction.request.url else {
            return .allow
        }

        if chatModel.shouldAllowRequestWithNavigationAction(navigationAction) {
            return .allow
        } else {
            delegate?.aiChatWebViewController(self, didRequestToLoad: url)
            return .cancel
        }
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingView.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingView.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingView.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadingView.stopAnimating()
    }
}
