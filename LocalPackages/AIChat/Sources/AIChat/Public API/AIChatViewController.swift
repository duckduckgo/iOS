//
//  AIChatViewController.swift
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
import Combine
import WebKit

/// A protocol that defines the delegate methods for `AIChatViewController`.
public protocol AIChatViewControllerDelegate: AnyObject {
    /// Tells the delegate that a request to load a URL has been made.
    ///
    /// - Parameters:
    ///   - viewController: The `AIChatViewController` instance making the request.
    ///   - url: The `URL` that is requested to be loaded.
    func aiChatViewController(_ viewController: AIChatViewController, didRequestToLoad url: URL)
}

public final class AIChatViewController: UIViewController {
    public weak var delegate: AIChatViewControllerDelegate?
    private let chatModel: AIChatViewModeling
    private var webViewController: AIChatWebViewController?

    /// Initializes a new instance of `AIChatViewController` with the specified remote settings and web view configuration.
    ///
    /// - Parameters:
    ///   - remoteSettings: An object conforming to `AIChatSettingsProvider` that provides remote settings.
    ///   - webViewConfiguration: A `WKWebViewConfiguration` object used to configure the web view.
    public convenience init(settings: AIChatSettingsProvider, webViewConfiguration: WKWebViewConfiguration) {
        let chatModel = AIChatViewModel(webViewConfiguration: webViewConfiguration, settings: settings)
        self.init(chatModel: chatModel)
    }

    internal init(chatModel: AIChatViewModeling) {
        self.chatModel = chatModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
}

// MARK: - Lifecycle
extension AIChatViewController {

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addWebViewController()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        /// Clean up the previous conversation and prepare duck.ai for future presentation
        webViewController?.reload()
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        if viewIfLoaded?.window == nil {
            removeWebViewController()
        }
    }
}

// MARK: - Views Setup
extension AIChatViewController {

    private func addWebViewController() {
        guard webViewController == nil else { return }

        let viewController = AIChatWebViewController(chatModel: chatModel)
        viewController.delegate = self
        webViewController = viewController

        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        viewController.didMove(toParent: self)
    }

    private func removeWebViewController() {
        webViewController?.removeFromParent()
        webViewController?.view.removeFromSuperview()
        webViewController = nil
    }
}

extension AIChatViewController: AIChatWebViewControllerDelegate {
    func aiChatWebViewController(_ viewController: AIChatWebViewController, didRequestToLoad url: URL) {
        delegate?.aiChatViewController(self, didRequestToLoad: url)
    }
}