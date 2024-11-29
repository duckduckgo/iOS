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

protocol AIChatViewControllerDelegate: AnyObject {
    func aiChatViewController(_ viewController: AIChatViewController, didRequestToLoad url: URL)
}

final class AIChatViewController: UIViewController {
    weak var delegate: AIChatViewControllerDelegate?
    private let chatModel: AIChatViewModel
    private var webViewController: AIChatWebViewController?
    private var cleanupCancellable: AnyCancellable?

    init(chatModel: AIChatViewModel) {
        self.chatModel = chatModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Lifecycle
extension AIChatViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        subscribeToCleanupPublisher()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addWebViewController()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        chatModel.cancelTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        chatModel.cancelTimer()
        removeWebViewController()
    }
}

// MARK: - Views Setup
extension AIChatViewController {

    private func setupNavigationBar() {
        let imageView = UIImageView(image: UIImage(named: "Logo"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let imageSize: CGFloat = 32
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: imageSize),
            imageView.heightAnchor.constraint(equalToConstant: imageSize)
        ])

        let titleLabel = UILabel()
        titleLabel.text = UserText.aiChatTitle
        titleLabel.font = .semiBoldAppFont(ofSize: 17)

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
        closeButton.tintColor = .label
        navigationItem.rightBarButtonItem = closeButton
    }

    private func addWebViewController() {
        guard webViewController == nil else {
            print("WebViewController already exists, returning")
            return
        }

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

// MARK: - Event handling
extension AIChatViewController {

    private func subscribeToCleanupPublisher() {
        cleanupCancellable = chatModel.cleanupPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.webViewController?.reload()
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