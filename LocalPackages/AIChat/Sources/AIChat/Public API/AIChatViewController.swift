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
    private var cleanupCancellable: AnyCancellable?
    private var didCleanup: Bool = false
    private let timerPixelHandler: TimerPixelHandler

    /// Initializes a new instance of `AIChatViewController` with the specified remote settings and web view configuration.
    ///
    /// - Parameters:
    ///   - remoteSettings: An object conforming to `AIChatSettingsProvider` that provides remote settings.
    ///   - webViewConfiguration: A `WKWebViewConfiguration` object used to configure the web view.
    ///   - pixelHandler: A `AIChatPixelHandling` object used to send pixel events.
    public convenience init(settings: AIChatSettingsProvider, webViewConfiguration: WKWebViewConfiguration, pixelHandler: AIChatPixelHandling) {
        let chatModel = AIChatViewModel(webViewConfiguration: webViewConfiguration, settings: settings)
        self.init(chatModel: chatModel, pixelHandler: pixelHandler)
    }

    internal init(chatModel: AIChatViewModeling, pixelHandler: AIChatPixelHandling) {
        self.chatModel = chatModel
        self.timerPixelHandler = TimerPixelHandler(pixelHandler: pixelHandler)

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

        setupNavigationBar()

        subscribeToCleanupPublisher()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addWebViewController()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timerPixelHandler.sendOpenPixel()
        chatModel.cancelTimer()
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        if viewIfLoaded?.window == nil {
            chatModel.cancelTimer()
            removeWebViewController()
        }
    }
}

// MARK: - Views Setup
extension AIChatViewController {

    private func setupNavigationBar() {
        guard let navigationController = navigationController else { return }

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowImage = UIImage()
        appearance.shadowColor = .clear

        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.compactAppearance = appearance
        navigationController.navigationBar.isTranslucent = true

        let imageView = UIImageView(image: UIImage(named: "Logo"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let imageSize: CGFloat = 28
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: imageSize),
            imageView.heightAnchor.constraint(equalToConstant: imageSize)
        ])

        let titleLabel = UILabel()
        titleLabel.text = UserText.aiChatTitle
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .white
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fill

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: stackView)

        let closeButton = UIBarButtonItem(
            image: UIImage(named: "Close-24"),
            style: .plain,
            target: self,
            action: #selector(closeAIChat)
        )
        closeButton.tintColor = .white

        navigationItem.rightBarButtonItem = closeButton
    }


    private func addWebViewController() {
        guard webViewController == nil else { return }

        let viewController = AIChatWebViewController(chatModel: chatModel)
        viewController.delegate = self
        webViewController = viewController

        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        viewController.view.backgroundColor = .black
        viewController.view.layer.cornerRadius = 20
        viewController.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        viewController.view.clipsToBounds = true

        viewController.didMove(toParent: self)
    }

    private func removeWebViewController() {
        webViewController?.removeFromParent()
        webViewController?.view.removeFromSuperview()
        webViewController = nil
    }
}

// MARK: - Event handling
extension AIChatViewController {

    private func subscribeToCleanupPublisher() {
        cleanupCancellable = chatModel.cleanupPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.webViewController?.reload()
                self?.timerPixelHandler.markCleanup()
            }
    }

    @objc private func closeAIChat() {
        chatModel.startCleanupTimer()
        dismiss(animated: true)
    }
}

extension AIChatViewController: AIChatWebViewControllerDelegate {
    func aiChatWebViewController(_ viewController: AIChatWebViewController, didRequestToLoad url: URL) {
        delegate?.aiChatViewController(self, didRequestToLoad: url)
        closeAIChat()
    }
}
